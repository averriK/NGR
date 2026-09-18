Args <- commandArgs(trailingOnly = TRUE)
if (!(length(Args) %in% c(2L, 3L)) || !(Args[1L] %in% c("check", "inspect", "install", "uninstall"))) {
  stop("Usage: Rscript manage.R check|inspect|install|uninstall PREFIX [STAGE]", call. = FALSE)
}
if (.Platform$OS.type != "windows" && identical(Sys.info()[["effective_user"]], "root")) {
  stop("Run the R manager as the invoking user, never as root", call. = FALSE)
}
FILE <- grep("^--file=", commandArgs(), value = TRUE)
if (length(FILE) != 1L) stop("Run manage.R with Rscript", call. = FALSE)
# R encodes spaces as ~+~ in --file= on Unix.
FILE <- gsub("~+~", " ", sub("^--file=", "", FILE), fixed = TRUE)
Source <- dirname(normalizePath(FILE, winslash = "/", mustWork = TRUE))
Root <- normalizePath(file.path(Source, "..", ".."), winslash = "/", mustWork = TRUE)

.manageCli <- function(action, prefix, root, source, stage) {
  if (!nzchar(prefix) || is.na(prefix)) stop("PREFIX must be non-empty", call. = FALSE)
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("jsonlite is required by the installer to read its manifest and receipt. ",
         "Install it as your R user in a visible library, then retry: ",
         "install.packages('jsonlite', repos = 'https://cloud.r-project.org')", call. = FALSE)
  }
  Windows <- .Platform$OS.type == "windows"
  Requirements <- source(file.path(root, "install", "requirements.R"), local = TRUE)$value
  Command <- Requirements$command
  if (!is.character(Command) || length(Command) != 1L || !nzchar(Command)) {
    stop("install/requirements.R must name exactly one command", call. = FALSE)
  }
  Runtime <- Requirements$runtime
  if (!length(Runtime)) Runtime <- Command
  if (length(Runtime) != 1L || !grepl("^[A-Za-z0-9_-]+$", Runtime) ||
      !grepl("^[A-Za-z0-9_-]+$", Command)) stop("Invalid command or runtime name")
  .relativePaths <- function(paths) {
    is.character(paths) && !anyNA(paths) && all(nzchar(paths)) &&
      !any(grepl("[:\\\\\t\r\n]", paths)) &&
      !any(vapply(strsplit(paths, "/", fixed = TRUE),
                  function(x) any(x %in% c("", ".", "..")), logical(1L)))
  }
  Package <- unname(read.dcf(file.path(root, "lib", "DESCRIPTION"),
                             fields = "Package")[1L, 1L])
  Manifest <- jsonlite::read_json(file.path(root, "install", "manifest.json"),
                                  simplifyVector = TRUE)
  if (!identical(Manifest$manifest_version, 1L) || !is.character(Manifest$files) ||
      !length(Manifest$files) || anyNA(Manifest$files) || !all(nzchar(Manifest$files))) {
    stop("install/manifest.json must be {\"manifest_version\":1,\"files\":[...]}",
         call. = FALSE)
  }
  Files <- sort(Manifest$files, method = "radix")
  if (anyDuplicated(Files)) stop("install/manifest.json lists a file twice", call. = FALSE)
  Parts <- strsplit(Files, "/", fixed = TRUE)
  Invalid <- vapply(Parts, function(x) any(x %in% c("", "..")), logical(1L)) |
    startsWith(Files, "/") | grepl("^[A-Za-z]:", Files) | grepl("\\", Files, fixed = TRUE)
  if (any(Invalid) || !.relativePaths(Files)) {
    stop("Manifest paths must be relative to cli/, without absolute drives, \\\\ or ..: ",
         paste(Files[Invalid], collapse = ", "), call. = FALSE)
  }
  Launcher <- file.path("bin", Command)
  if (!(Launcher %in% Files)) {
    stop("install/manifest.json does not list ", Launcher, call. = FALSE)
  }
  Sources <- file.path(root, "cli", Files)
  if (isTRUE(Requirements$launchers)) {
    Sources[dirname(Files) == "bin"] <- file.path(root, "install/launchers", basename(Files[dirname(Files) == "bin"]))
  }
  if (action != "uninstall") {
    if (!all(file.exists(Sources)) || any(dir.exists(Sources))) {
      stop("Missing CLI source: ", paste(Sources[!file.exists(Sources)], collapse = ", "),
           call. = FALSE)
    }
    # Directories covered by the manifest must not hold unlisted files (psha
    # parity); cli/README.md and cli/tests/ are documentation, not payload.
    for (DIR in unique(dirname(Files))) {
      if (DIR == ".") next
      Directory <- file.path(root, "cli", DIR)
      if (DIR == "bin" && isTRUE(Requirements$launchers)) Directory <- file.path(root, "install/launchers")
      Present <- file.path(DIR, list.files(Directory, recursive = TRUE,
                                           include.dirs = FALSE, no.. = TRUE))
      Unlisted <- setdiff(Present, Files)
      if (length(Unlisted)) {
        stop("install/manifest.json is out of date; unlisted under cli/: ",
             paste(Unlisted, collapse = ", "),
             "; regenerate with install/update-manifest.sh", call. = FALSE)
      }
    }
  }
  # Keep removal independent of the original checkout, using the same manager
  # and wrappers. These files belong to the receipt like the runtime payload.
  Removal <- c("lib/DESCRIPTION", "install/requirements.R", "install/manifest.json",
               "install/uninstall.sh", "install/uninstall.ps1",
               "install/cli/manage.R", "install/cli/checkPaths.ps1", "install/cli/publish.sh")
  Files <- c(Files, Removal)
  Sources <- c(Sources, file.path(root, Removal))
  if (action != "uninstall" && !all(file.exists(Sources))) {
    stop("Incomplete installer distribution: ", paste(Sources[!file.exists(Sources)], collapse = ", "))
  }
  prefix <- path.expand(prefix)
  if (Windows) {
    prefix <- chartr("\\", "/", prefix)
    if (grepl("^[A-Za-z]:[^/]|^[A-Za-z]:$", prefix)) {
      stop("PREFIX must not be drive-relative: ", prefix, call. = FALSE)
    }
  }
  if (!startsWith(prefix, "/") && !(Windows && grepl("^[A-Za-z]:/", prefix))) {
    prefix <- file.path(getwd(), prefix)
  }
  if (grepl("[\r\n]", prefix)) stop("PREFIX cannot contain line breaks", call. = FALSE)
  Destination <- ifelse(dirname(Files) == "bin", Files,
                        file.path("libexec", Runtime, Files))
  .gitValue <- function(args) {
    if (!nzchar(Sys.which("git"))) return(NULL)
    OUT <- suppressWarnings(system2("git", c("-c", shQuote(paste0("safe.directory=", root)),
      "-C", shQuote(root), args), stdout = TRUE, stderr = FALSE))
    if (!is.null(attr(OUT, "status"))) return(NULL)
    OUT
  }
  Commit <- NULL
  if (action == "install" || (action != "uninstall" && length(Requirements$buildInfo))) {
    Commit <- .gitValue("rev-parse HEAD")
  }
  Extra <- file.path("libexec", Runtime, "BUILD_INFO")
  if (isTRUE(Requirements$launchers)) Extra <- c(Extra, file.path("libexec", Runtime, "RSCRIPT"))
  if (length(Requirements$buildInfo)) {
    if (!.relativePaths(Requirements$buildInfo)) stop("Invalid buildInfo path")
    # Resource consumers represent unknown provenance by an absent stamp.
    if (length(Commit)) Extra <- c(Extra, file.path("libexec", Runtime, Requirements$buildInfo))
  }
  Targets <- c(Destination, Extra)
  if (anyDuplicated(Targets)) stop("Manifest repeats a generated target")
  if (file.path("libexec", Runtime, "install.json") %in% Targets) {
    stop("The manifest cannot replace the installation receipt")
  }
  if (!dir.exists(prefix)) {
    if (action == "uninstall") stop("PREFIX does not exist: ", prefix, call. = FALSE)
  }
  Link <- Sys.readlink(prefix)
  if (!is.na(Link) && nzchar(Link)) stop("Managed prefix is a symlink: ", prefix)
  prefix <- normalizePath(prefix, winslash = "/", mustWork = FALSE)
  File <- file.path(prefix, "libexec", Runtime, "install.json")
  for (Path in c(file.path(prefix, c("bin", "libexec", file.path("libexec", Runtime))),
                 File)) {
    Link <- Sys.readlink(Path)
    if (!is.na(Link) && nzchar(Link)) stop("Managed path is a symlink: ", Path)
  }
  Record <- NULL
  Owned <- character()
  if (file.exists(File)) {
    Record <- jsonlite::read_json(File, simplifyVector = TRUE)
    if (identical(Record$schema, 1L)) Owned <- Launcher
    if (identical(Record$schema, 2L)) {
      Owned <- c(Launcher, file.path("libexec", Runtime, "main.R"))
    }
    if (identical(Record$schema, 3L)) {
      Owned <- c(paste0("bin/", Command, ".cmd"),
                 file.path("libexec", Runtime, "main.R"),
                 paste0("bin/", Command, ".ps1"))
    }
    if (identical(Record$schema, 4L)) Owned <- Record$file
    if (!identical(Record$product, paste0(Command, "-cli")) || !length(Owned) ||
        !is.character(Owned) || anyNA(Owned) ||
        (!identical(Record$schema, 4L) && !identical(unname(Record$file), unname(Owned))) ||
        !is.character(Record$md5) || length(Record$md5) != length(Owned) ||
        anyNA(Record$md5) || any(!grepl("^[a-f0-9]{32}$", Record$md5)) ||
        !.relativePaths(Owned) || anyDuplicated(Owned) ||
        any(!(Owned %in% paste0(Launcher, c("", ".cmd", ".ps1")) |
              startsWith(Owned, paste0("libexec/", Runtime, "/")))) ||
        file.path("libexec", Runtime, "install.json") %in% Owned) {
      stop("Invalid installation receipt: ", File, call. = FALSE)
    }
    Created <- unlist(Record$created, use.names = FALSE)
    if (length(Created) && (!.relativePaths(setdiff(Created, ".")) ||
        any(!(Created %in% c(".", "bin", "libexec", file.path("libexec", Runtime)) |
              startsWith(Created, paste0("libexec/", Runtime, "/")))))) {
      stop("Invalid created directories in receipt: ", File, call. = FALSE)
    }
  }
  Paths <- file.path(prefix, union(Targets, Owned))
  if (action == "uninstall") Paths <- file.path(prefix, Owned)
  Paths <- c(Paths, File)
  Ancestors <- Paths
  for (Path in Paths) {
    while (startsWith(Path, paste0(prefix, "/"))) {
      Path <- dirname(Path)
      Ancestors <- c(Ancestors, Path)
    }
  }
  Ancestors <- unique(Ancestors)
  if (Windows) {
    # NGR ships hundreds of resources; their paths exceed Windows argv limits.
    PathList <- tempfile("installer-paths-", fileext = ".txt")
    on.exit(unlink(PathList), add = TRUE)
    writeLines(enc2utf8(Ancestors), PathList, useBytes = TRUE)
    Status <- system2("powershell.exe", args = c("-NoProfile", "-NonInteractive",
      "-ExecutionPolicy", "Bypass", "-File", shQuote(file.path(source, "checkPaths.ps1")),
      shQuote(PathList)))
    if (Status != 0L) stop("Cannot validate managed Windows paths", call. = FALSE)
  }
  for (Path in Ancestors) {
    Link <- Sys.readlink(Path)
    if (!is.na(Link) && nzchar(Link)) stop("Managed path is a symlink: ", Path)
  }
  if (!is.null(Record) &&
      !identical(unname(tools::md5sum(file.path(prefix, Owned))), Record$md5)) {
    stop("Invalid receipt or modified managed executable: ", File, call. = FALSE)
  }
  if (is.null(Record) && action == "uninstall") {
    stop("No installation receipt; existing paths cannot be attributed to ", Package,
         call. = FALSE)
  }
  if (action != "uninstall" &&
      any(file.exists(file.path(prefix, setdiff(Targets, Owned))))) {
    stop("No installation receipt for existing managed path", call. = FALSE)
  }
  if (any(dir.exists(Paths))) stop("Managed file path is a directory", call. = FALSE)
  Kit <- c("installProduct.R", "product.R", "package.R", "build.R",
           "install.sh", "install.ps1", "uninstall.sh", "uninstall.ps1",
           "update-manifest.sh",
           file.path("cli", c("manage.R", "checkPaths.ps1",
                              "publish.sh", "test-installers.sh", "test-installers.ps1",
                              "testManager.R", "testWrapper.R", "testProduct.R")))
  if (action %in% c("check", "inspect")) {
    for (DIR in unique(dirname(Paths))) {
      while (!file.exists(DIR)) {
        if (identical(DIR, dirname(DIR))) stop("Installation parent does not exist: ", DIR)
        DIR <- dirname(DIR)
      }
      if (!dir.exists(DIR) || (action == "check" && file.access(DIR, 2L) != 0L)) {
        stop("Installation parent is not a writable directory: ", DIR, call. = FALSE)
      }
    }
    message("CLI destination available: ", prefix)
    return(invisible(NULL))
  }
  Dirs <- unique(dirname(Paths))
  Needed <- character()
  for (DIR in Dirs) {
    while (!dir.exists(DIR)) {
      if (identical(DIR, dirname(DIR))) stop("Cannot create installation directory",
                                             call. = FALSE)
      Needed <- c(Needed, DIR)
      DIR <- dirname(DIR)
    }
  }
  Created <- unique(Needed)
  for (DIR in if (is.null(stage)) Dirs else character()) {
    if (!dir.exists(DIR) && !dir.create(DIR, recursive = TRUE)) stop("Cannot create ", DIR)
  }
  CreatedRel <- vapply(Created[Created == prefix | startsWith(Created, paste0(prefix, "/"))], function(x) {
    if (identical(x, prefix)) return(".")
    substring(x, nchar(prefix) + 2L)
  }, character(1L))
  CreatedRel <- unique(c(unlist(Record$created, use.names = FALSE), CreatedRel))

  Recovery <- tempfile(".install-", tmpdir = prefix)
  if (!is.null(stage)) {
    if (!dir.exists(stage) || length(list.files(stage, all.files = TRUE, no.. = TRUE))) {
      stop("STAGE must be an existing empty directory", call. = FALSE)
    }
    Recovery <- file.path(normalizePath(stage, mustWork = TRUE), "payload")
  }
  if (!dir.create(Recovery)) stop("Cannot prepare recovery directory", call. = FALSE)
  Exists <- file.exists(Paths)
  # Backup and staging slots are numbered: distinct targets can share a basename
  # (for example libexec/<runtime>/BUILD_INFO and libexec/<runtime>/scaffold/BUILD_INFO).
  Backup <- file.path(Recovery, as.character(seq_along(Paths)))
  Changed <- rep(FALSE, length(Paths))
  Complete <- FALSE
  if (is.null(stage)) on.exit({
    Restored <- TRUE
    if (any(Changed) && !Complete) {
      for (i in which(Changed)) {
        if (Exists[i]) {
          Restored <- isTRUE(file.copy(Backup[i], Paths[i], overwrite = TRUE,
                                       copy.mode = TRUE)) && Restored
        }
        if (!Exists[i]) Restored <- (unlink(Paths[i]) == 0L) && Restored
      }
      if (!Restored) warning("Restore UNKNOWN; recovery retained at ", Recovery)
    }
    if (Restored) unlink(Recovery, recursive = TRUE)
    if (!Complete && Restored && !Windows) {
      for (DIR in Created[order(nchar(Created), decreasing = TRUE)]) {
        system2("rmdir", shQuote(DIR), stdout = FALSE, stderr = FALSE)
      }
    }
  }, add = TRUE)
  if (is.null(stage) && any(Exists) && !all(file.copy(Paths[Exists], Backup[Exists], copy.mode = TRUE))) {
    stop("Cannot preserve managed files before update", call. = FALSE)
  }
  if (action == "install") {
    Prepared <- file.path(Recovery, paste0(as.character(seq_along(Paths)), ".next"))
    if (!all(file.copy(Sources, Prepared[seq_along(Files)])) ||
        !all(Sys.chmod(Prepared[seq_along(Files)], "0644")) ||
        !Sys.chmod(Prepared[match(Launcher, Files)], "0755")) {
      stop("Cannot prepare CLI payloads", call. = FALSE)
    }
    Now <- format(Sys.time(), tz = "UTC", format = "%Y-%m-%dT%H:%M:%SZ")
    # Dirt is scoped to the payload sources: foreign working-tree changes
    # (plans, docs) must not stamp every render as DRAFT (psha parity).
    Scoped <- intersect(c("cli", "install", "lib"), list.files(root))
    Describe <- .gitValue(c("describe", "--tags", "--always"))
    Porcelain <- .gitValue(c("status", "--porcelain", "--", Scoped))
    Dirty <- if (is.null(Porcelain)) "unknown" else length(Porcelain) > 0L
    if (length(Describe) && identical(Dirty, TRUE)) {
      Describe[[1L]] <- paste0(Describe[[1L]], "-dirty")
    }
    Git <- list(commit = if (length(Commit)) Commit[[1L]] else "unknown",
                describe = if (length(Describe)) Describe[[1L]] else "unknown",
                dirty = Dirty)
    Info <- c(paste0("built_at_utc=", Now), paste0("git_commit=", Git$commit),
              paste0("git_describe=", Git$describe),
              paste0("dirty=", tolower(as.character(Git$dirty))))
    for (i in seq_along(Extra)) {
      Lines <- Info
      if (basename(Extra[i]) == "RSCRIPT") Lines <- file.path(R.home("bin"), if (Windows) "Rscript.exe" else "Rscript")
      writeLines(Lines, Prepared[length(Files) + i])
    }
    Found <- find.package(Package, quiet = TRUE)
    if (!length(Found)) {
      stop("The ", Package, " R package is required; install it before the CLI",
           call. = FALSE)
    }
    Hash <- tools::md5sum(file.path(root, "install", Kit))
    KitHash <- as.list(unname(Hash))
    names(KitHash) <- Kit
    jsonlite::write_json(list(product = paste0(Command, "-cli"), schema = 4L,
                              installed_at_utc = Now,
                              package = list(name = Package,
                                             version = as.character(utils::packageVersion(Package)),
                                             library = dirname(normalizePath(Found, winslash = "/"))),
                              R = list(version = paste(R.version$major, R.version$minor,
                                                       sep = "."),
                                       rscript = file.path(R.home("bin"),
                                                           if (Windows) "Rscript.exe" else "Rscript")),
                              source = Git, kit = KitHash, pathAdded = isTRUE(Record$pathAdded),
                              file = Targets,
                              md5 = unname(tools::md5sum(Prepared[seq_along(Targets)])),
                              created = CreatedRel),
                         Prepared[length(Paths)], auto_unbox = TRUE, pretty = TRUE)
  }
  if (!is.null(stage)) {
    Hashes <- rep("-", length(Paths))
    Hashes[Exists] <- unname(tools::md5sum(Paths[Exists]))
    Slots <- rep("-", length(Paths))
    if (action == "install") {
      Slots[seq_along(Targets)] <- paste0(seq_along(Targets), ".next")
      Slots[length(Paths)] <- paste0(length(Paths), ".next")
    }
    write.table(data.frame(path = substring(Paths, nchar(prefix) + 2L), hash = Hashes, slot = Slots),
                file.path(stage, "files.tsv"), sep = "\t", quote = FALSE,
                row.names = FALSE, col.names = FALSE)
    writeLines(CreatedRel[order(nchar(CreatedRel), decreasing = TRUE)], file.path(stage, "created.txt"))
    message("Prepared CLI ", action, " for the elevated Bash publisher: ", stage)
    return(invisible(NULL))
  }
  if (action == "install") {
    for (i in seq_along(Targets)) {
      if (!file.rename(Prepared[i], Paths[i])) stop("Cannot replace ", Paths[i])
      Changed[i] <- TRUE
    }
    for (i in which(Paths %in% file.path(prefix, setdiff(Owned, Targets)))) {
      if (unlink(Paths[i]) != 0L) stop("Cannot retire ", Paths[i])
      Changed[i] <- TRUE
    }
    if (!file.rename(Prepared[length(Paths)], File)) stop("Cannot replace ", File)
    Changed[length(Paths)] <- TRUE
    CommandPath <- file.path(prefix, paste0(Launcher, if (Windows) ".cmd" else ""))
    for (Option in c("--version", Requirements$verify)) {
      Status <- system2(CommandPath, shQuote(Option))
      if (Status != 0L) stop("Installed CLI verification failed (", Status, "): ", CommandPath)
    }
  }
  if (action == "uninstall") {
    for (i in seq_along(Paths)) {
      if (unlink(Paths[i]) != 0L) stop("Cannot remove ", Paths[i])
      Changed[i] <- TRUE
    }
  }
  Complete <- TRUE
  unlink(Recovery, recursive = TRUE)
  if (action == "uninstall") {
    Dirs <- character()
    if (identical(Record$schema, 4L)) {
      Dirs <- file.path(prefix, Record$created[order(nchar(Record$created),
                                                     decreasing = TRUE)])
      Dirs[Dirs == file.path(prefix, ".")] <- prefix
    }
    if (!identical(Record$schema, 4L)) Dirs <- file.path(prefix, "libexec", Runtime)
    for (DIR in Dirs) {
      if (dir.exists(DIR)) {
        Status <- if (Windows) system2("cmd.exe", c("/c", "rmdir", shQuote(DIR)),
                                       stdout = FALSE, stderr = FALSE) else
          system2("rmdir", shQuote(DIR), stdout = FALSE, stderr = FALSE)
        if (Status != 0L) message("Kept ", DIR, ": not empty")
      }
    }
  }
  message(if (action == "install") "Installed " else "Removed ", Paths[1L])
  invisible(NULL)
}

.manageCli(action = Args[1L], prefix = Args[2L], root = Root, source = Source,
           stage = if (length(Args) == 3L) Args[3L] else NULL)
