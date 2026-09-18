Args <- commandArgs(trailingOnly = TRUE)
if (length(Args) != 2L || !(Args[1L] %in% c("check", "install", "uninstall"))) {
  stop("Usage: Rscript manage.R check|install|uninstall PREFIX", call. = FALSE)
}
FILE <- grep("^--file=", commandArgs(), value = TRUE)
if (length(FILE) != 1L) stop("Run manage.R with Rscript", call. = FALSE)
# R encodes spaces as ~+~ in --file= on Unix.
FILE <- gsub("~+~", " ", sub("^--file=", "", FILE), fixed = TRUE)
Source <- dirname(normalizePath(FILE, winslash = "/", mustWork = TRUE))
Root <- normalizePath(file.path(Source, "..", ".."), winslash = "/", mustWork = TRUE)

.manageCli <- function(action, prefix, root, source) {
  if (!nzchar(prefix) || is.na(prefix)) stop("PREFIX must be non-empty", call. = FALSE)
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("jsonlite is required to read the installation manifest and receipt", call. = FALSE)
  }
  Windows <- .Platform$OS.type == "windows"
  Requirements <- source(file.path(root, "install", "requirements.R"), local = TRUE)$value
  Command <- Requirements$command
  if (!is.character(Command) || length(Command) != 1L || !nzchar(Command)) {
    stop("install/requirements.R must name exactly one command", call. = FALSE)
  }
  Runtime <- Requirements$runtime
  if (!length(Runtime)) Runtime <- Command
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
  if (any(Invalid)) {
    stop("Manifest paths must be relative to cli/, without absolute drives, \\\\ or ..: ",
         paste(Files[Invalid], collapse = ", "), call. = FALSE)
  }
  Launcher <- file.path("bin", Command)
  if (!(Launcher %in% Files)) {
    stop("install/manifest.json does not list ", Launcher, call. = FALSE)
  }
  Sources <- file.path(root, "cli", Files)
  if (action != "uninstall") {
    if (!all(file.exists(Sources))) {
      stop("Missing CLI source: ", paste(Sources[!file.exists(Sources)], collapse = ", "),
           call. = FALSE)
    }
    # Directories covered by the manifest must not hold unlisted files (psha
    # parity); cli/README.md and cli/tests/ are documentation, not payload.
    for (DIR in unique(dirname(Files))) {
      if (DIR == ".") next
      Present <- file.path(DIR, list.files(file.path(root, "cli", DIR), recursive = TRUE,
                                           include.dirs = FALSE, no.. = TRUE))
      Unlisted <- setdiff(Present, Files)
      if (length(Unlisted)) {
        stop("install/manifest.json is out of date; unlisted under cli/: ",
             paste(Unlisted, collapse = ", "),
             "; regenerate with install/update-manifest.sh", call. = FALSE)
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
  Extra <- file.path("libexec", Runtime, "BUILD_INFO")
  if (length(Requirements$buildInfo)) {
    Extra <- c(Extra, file.path("libexec", Runtime, Requirements$buildInfo))
  }
  Targets <- c(Destination, Extra)
  if (!dir.exists(prefix)) {
    if (action == "uninstall") stop("PREFIX does not exist: ", prefix, call. = FALSE)
    if (action != "check" && !dir.create(prefix, recursive = TRUE)) {
      stop("Cannot create PREFIX: ", prefix)
    }
  }
  prefix <- normalizePath(prefix, winslash = "/", mustWork = action != "check")
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
        anyNA(Record$md5)) {
      stop("Invalid installation receipt: ", File, call. = FALSE)
    }
  }
  Paths <- file.path(prefix, Targets)
  if (action == "uninstall") Paths <- file.path(prefix, Owned)
  Paths <- c(Paths, File)
  if (Windows) {
    Status <- system2("powershell.exe", args = c("-NoProfile", "-NonInteractive",
      "-ExecutionPolicy", "Bypass", "-File", shQuote(file.path(source, "checkPaths.ps1")),
      shQuote(unique(c(file.path(prefix, c("bin", "libexec", file.path("libexec", Runtime))),
                      file.path(prefix, Owned), Paths)))))
    if (Status != 0L) stop("Cannot validate managed Windows paths", call. = FALSE)
  }
  for (Path in Paths) {
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
                              "test-installers.sh", "test-installers.ps1")))
  if (action == "check") {
    for (DIR in unique(dirname(Paths))) {
      while (!file.exists(DIR)) {
        if (identical(DIR, dirname(DIR))) stop("Installation parent does not exist: ", DIR)
        DIR <- dirname(DIR)
      }
      if (!dir.exists(DIR) || file.access(DIR, 2L) != 0L) {
        stop("Installation parent is not a writable directory: ", DIR, call. = FALSE)
      }
    }
    # The canonical kit lives outside the products; repo copies are byte-identical.
    Canonical <- path.expand("~/github/agents/install")
    if (dir.exists(Canonical)) {
      Repo <- file.path(root, "install", Kit)
      Canon <- file.path(Canonical, Kit)
      if (!all(file.exists(Repo)) || !all(file.exists(Canon)) ||
          !identical(unname(tools::md5sum(Repo)), unname(tools::md5sum(Canon)))) {
        stop("install/ differs from the canonical kit at ", Canonical, call. = FALSE)
      }
    } else {
      message("Canonical kit not found at ", Canonical, "; kit drift not checked")
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
  for (DIR in Dirs) {
    if (!dir.exists(DIR) && !dir.create(DIR, recursive = TRUE)) stop("Cannot create ", DIR)
  }
  CreatedRel <- vapply(Created, function(x) {
    if (identical(x, prefix)) return(".")
    substring(x, nchar(prefix) + 2L)
  }, character(1L))

  Recovery <- tempfile(".install-", tmpdir = prefix)
  if (!dir.create(Recovery)) stop("Cannot prepare recovery directory", call. = FALSE)
  Exists <- file.exists(Paths)
  # Backup and staging slots are numbered: distinct targets can share a basename
  # (for example libexec/<runtime>/BUILD_INFO and libexec/<runtime>/scaffold/BUILD_INFO).
  Backup <- file.path(Recovery, as.character(seq_along(Paths)))
  Changed <- rep(FALSE, length(Paths))
  Complete <- FALSE
  on.exit({
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
  }, add = TRUE)
  if (any(Exists) && !all(file.copy(Paths[Exists], Backup[Exists], copy.mode = TRUE))) {
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
    .gitValue <- function(args) {
      OUT <- suppressWarnings(system2("git", c("-c", paste0("safe.directory=", root),
        "-C", shQuote(root), args), stdout = TRUE, stderr = FALSE))
      if (!is.null(attr(OUT, "status"))) return(NULL)
      OUT
    }
    Commit <- .gitValue("rev-parse HEAD")
    Describe <- .gitValue(c("describe", "--tags", "--always", "--dirty"))
    Porcelain <- .gitValue(c("status", "--porcelain"))
    Git <- list(commit = if (length(Commit)) Commit[[1L]] else "unknown",
                describe = if (length(Describe)) Describe[[1L]] else "unknown",
                dirty = if (is.null(Porcelain)) "unknown" else length(Porcelain) > 0L)
    Info <- c(paste0("built_at_utc=", Now), paste0("git_commit=", Git$commit),
              paste0("git_describe=", Git$describe),
              paste0("dirty=", tolower(as.character(Git$dirty))))
    for (i in seq_along(Extra)) writeLines(Info, Prepared[length(Files) + i])
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
                              source = Git, kit = KitHash,
                              file = Targets,
                              md5 = unname(tools::md5sum(Prepared[seq_along(Targets)])),
                              created = CreatedRel),
                         Prepared[length(Paths)], auto_unbox = TRUE, pretty = TRUE)
    for (i in seq_along(Paths)) {
      if (!file.rename(Prepared[i], Paths[i])) stop("Cannot replace ", Paths[i])
      Changed[i] <- TRUE
    }
  }
  if (action == "uninstall") {
    for (i in seq_along(Paths)) {
      if (unlink(Paths[i]) != 0L) stop("Cannot remove ", Paths[i])
      Changed[i] <- TRUE
    }
  }
  Complete <- TRUE
  if (action == "uninstall") {
    Dirs <- character()
    if (identical(Record$schema, 4L)) {
      Dirs <- file.path(prefix, Record$created[order(nchar(Record$created),
                                                     decreasing = TRUE)])
    }
    if (!identical(Record$schema, 4L)) Dirs <- file.path(prefix, "libexec", Runtime)
    for (DIR in Dirs) {
      if (dir.exists(DIR) && suppressWarnings(unlink(DIR) != 0L)) {
        message("Kept ", DIR, ": not empty")
      }
    }
  }
  message(if (action == "install") "Installed " else "Removed ", Paths[1L])
  invisible(NULL)
}

.manageCli(action = Args[1L], prefix = Args[2L], root = Root, source = Source)
