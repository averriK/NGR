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
  source(file.path(source, "manifest.R"), local = TRUE)
  Package <- unname(read.dcf(file.path(root, "lib", "DESCRIPTION"), fields = "Package")[1L, 1L])
  Manifest <- .readManifest(file.path(root, "install/manifest.json"), Command)
  Launcher <- file.path("bin", Command)
  Launchers <- paste0(Launcher, c("", ".cmd", ".ps1"))
  Binding <- NULL
  Found <- find.package(Package, quiet = TRUE)
  if (action == "install" && Manifest$manifest_version == 2L) {
    if (!length(Found)) stop("Install the package before publishing its CLI")
    source(file.path(root, "lib/inst/package.R"), local = TRUE)
    Binding <- .packageRecord(Found, source = file.path(root, "lib"))
  }
  Resources <- Manifest$files
  Payload <- Filter(function(x) x$origin == "product", Resources)
  Files <- vapply(Payload, `[[`, character(1L), "installed")
  Sources <- vapply(Payload, function(x) file.path(root, x$source), character(1L))
  Modes <- vapply(Payload, `[[`, character(1L), "mode")
  PathEnv <- Requirements$pathEnv
  if (length(PathEnv) && (length(PathEnv) != 1L || is.na(PathEnv) ||
      !grepl("^[A-Z][A-Z0-9_]*_COMMAND_PATH$", PathEnv))) stop("Invalid pathEnv declaration")
  if (action != "uninstall") {
    if (!all(file.exists(Sources)) || any(dir.exists(Sources))) {
      stop("Missing CLI source: ", paste(Sources[!file.exists(Sources)], collapse = ", "),
           call. = FALSE)
    }
    # Preserve the completeness check of legacy manifests during migration.
    if (Manifest$manifest_version == 1L) {
      for (DIR in setdiff(unique(dirname(Files)), c(".", "bin"))) {
        Directory <- file.path(root, "cli", DIR)
        if (!dir.exists(Directory)) next
        Present <- file.path(DIR, list.files(Directory, recursive = TRUE, no.. = TRUE))
        if (length(setdiff(Present, Files))) stop("install/manifest.json is out of date; regenerate with install/update-manifest.sh")
      }
    }
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
  if (length(Requirements$buildInfo)) {
    if (!.relativePaths(Requirements$buildInfo)) stop("Invalid buildInfo path")
    # Resource consumers represent unknown provenance by an absent stamp.
    if (length(Commit)) Extra <- c(Extra, file.path("libexec", Runtime, Requirements$buildInfo))
  }
  Targets <- c(Destination, Extra)
  if (anyDuplicated(tolower(Targets))) stop("Manifest repeats a generated target")
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
  PackageNotice <- "R package untouched; its installation library is unknown (not recorded in receipt)."
  if (is.list(Record$package) && is.character(Record$package$library) && length(Record$package$library) == 1L &&
      !is.na(Record$package$library) && nzchar(Record$package$library)) {
    PackageNotice <- paste0("R package untouched. Recorded library: ", Record$package$library)
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
        !all(vapply(seq_along(Files), function(i) Sys.chmod(Prepared[i], Modes[i]), logical(1L)))) {
      stop("Cannot prepare CLI payloads", call. = FALSE)
    }
    for (i in which(Files %in% Launchers)) {
      Lines <- readLines(Prepared[i], warn = FALSE)
      Export <- ""
      if (length(PathEnv) && Files[i] == Launcher) Export <- paste0('export ', PathEnv, '="$PATH"')
      if (length(PathEnv) && Files[i] == paste0(Launcher, ".ps1")) Export <- paste0('$env:', PathEnv, ' = $env:PATH')
      Lines <- gsub("@RUNTIME@", Runtime, Lines, fixed = TRUE)
      Lines <- gsub("@PATH_EXPORT@", Export, Lines, fixed = TRUE)
      writeLines(Lines, Prepared[i])
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
      writeLines(Lines, Prepared[length(Files) + i])
    }
    Found <- find.package(Package, quiet = TRUE)
    if (!length(Found)) {
      stop("The ", Package, " R package is required; install it before the CLI",
           call. = FALSE)
    }
    if (!is.null(Binding)) {
      for (i in seq_along(Resources)) {
        Entry <- Resources[[i]]
        if (Entry$origin == "product") {
          j <- match(Entry$installed, Files)
          Entry$file <- Destination[j]
          Entry$sha256 <- digest::digest(file = Prepared[j], algo = "sha256")
        }
        if (Entry$origin == "package") {
          Entry$sha256 <- digest::digest(file = file.path(Found, Entry$source), algo = "sha256")
        }
        Resources[[i]] <- Entry
      }
    }
    jsonlite::write_json(list(product = paste0(Command, "-cli"), schema = 4L,
                              installed_at_utc = Now,
                              package = list(name = Package,
                                             version = as.character(utils::packageVersion(Package)),
                                             library = dirname(normalizePath(Found, winslash = "/"))),
                              R = list(version = paste(R.version$major, R.version$minor,
                                                       sep = "."),
                                       rscript = file.path(R.home("bin"),
                                                           if (Windows) "Rscript.exe" else "Rscript")),
                              source = Git, binding = if (is.null(Binding)) NULL else list(artifact = Binding$artifact, files = as.list(Binding$files)),
                              resources = if (is.null(Binding)) NULL else Resources, pathAdded = isTRUE(Record$pathAdded),
                              file = Targets,
                              md5 = unname(tools::md5sum(Prepared[seq_along(Targets)])),
                              created = CreatedRel),
                         Prepared[length(Paths)], auto_unbox = TRUE, pretty = TRUE, null = "null")
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
    if (action == "uninstall") writeLines(PackageNotice, file.path(stage, "package.txt"))
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
    Status <- system2(file.path(R.home("bin"), "Rscript"),
                      shQuote(c("--vanilla", file.path(source, "verify.R"), CommandPath)))
    if (Status != 0L) stop("Installed CLI local verification failed (", Status, "): ", CommandPath)
  }
  if (action == "uninstall") {
    for (i in seq_along(Paths)) {
      if (unlink(Paths[i]) != 0L) stop("Cannot remove ", Paths[i])
      Changed[i] <- TRUE
    }
  }
  Complete <- TRUE
  unlink(Recovery, recursive = TRUE)
  Dirs <- file.path(prefix, CreatedRel[order(nchar(CreatedRel), decreasing = TRUE)])
  Dirs[Dirs == file.path(prefix, ".")] <- prefix
  if (action == "uninstall" && !identical(Record$schema, 4L)) Dirs <- file.path(prefix, "libexec", Runtime)
  for (DIR in Dirs) {
    if (dir.exists(DIR)) {
      Status <- if (Windows) system2("cmd.exe", c("/c", "rmdir", shQuote(DIR)),
                                     stdout = FALSE, stderr = FALSE) else
        system2("rmdir", shQuote(DIR), stdout = FALSE, stderr = FALSE)
      if (Status != 0L && action == "uninstall") message("Kept ", DIR, ": not empty")
    }
  }
  if (action == "uninstall") message(PackageNotice)
  message(if (action == "install") "Installed " else "Removed ", Paths[1L])
  invisible(NULL)
}

.manageCli(action = Args[1L], prefix = Args[2L], root = Root, source = Source,
           stage = if (length(Args) == 3L) Args[3L] else NULL)
