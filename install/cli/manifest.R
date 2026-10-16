# Shared manifest and installed-resource contract, used by the publisher and AOM.
.relativePaths <- function(paths) {
  is.character(paths) && !anyNA(paths) && all(nzchar(paths)) &&
    !any(grepl("[:\\\\\t\r\n]", paths)) &&
    !any(vapply(strsplit(paths, "/", fixed = TRUE),
                function(x) any(x %in% c("", ".", "..")), logical(1L)))
}

.readManifest <- function(path, command) {
  Manifest <- jsonlite::read_json(path, simplifyVector = FALSE)
  Launchers <- paste0("bin/", command, c("", ".cmd", ".ps1"))
  if (identical(Manifest$manifest_version, 1L)) {
    Files <- unlist(Manifest$files, use.names = FALSE)
    if (!length(Files) || !.relativePaths(Files) || anyDuplicated(tolower(Files))) stop("Invalid CLI payload manifest")
    Manifest$files <- lapply(Files, function(path) {
      Source <- paste0("cli/", path)
      if (path %in% Launchers) Source <- paste0("install/cli/command", c(".sh", ".cmd", ".ps1")[match(path, Launchers)])
      list(origin = "product", source = Source, installed = path, kind = "runtime",
           mode = if (path == Launchers[1L]) "0755" else "0644")
    })
    Removal <- c("lib/DESCRIPTION", "install/requirements.R", "install/manifest.json",
      "install/uninstall.sh", "install/uninstall.ps1", "install/cli/manage.R",
      "install/cli/checkPaths.ps1", "install/cli/publish.sh", "install/cli/r.sh",
      "install/cli/r.ps1", "install/cli/verify.R", "install/cli/manifest.R", "install/cli/entry.R")
    Manifest$files <- c(Manifest$files, lapply(Removal, function(path) {
      list(origin = "product", source = path, installed = path, kind = "runtime",
           mode = if (endsWith(path, ".sh")) "0755" else "0644")
    }))
  }
  if (!(Manifest$manifest_version %in% c(1L, 2L)) || !length(Manifest$files)) stop("Invalid CLI payload manifest")
  for (Entry in Manifest$files) {
    if (!(Entry$origin %in% c("product", "package")) || !.relativePaths(Entry$source) ||
        !(Entry$kind %in% c("runtime", "common", "initial", "migration", "metadata")) ||
        !(Entry$mode %in% c("0644", "0755"))) stop("Invalid manifest entry")
    if (Entry$origin == "product" && !.relativePaths(Entry$installed)) stop("Missing installed destination")
    if (Entry$origin == "package" && !is.null(Entry$installed)) stop("Package resources must not be copied into the CLI")
    if (Entry$kind %in% c("common", "initial") && !.relativePaths(Entry$target)) stop("Invalid module destination")
    if (!is.null(Entry$installed) && dirname(Entry$installed) == "bin" && !Entry$installed %in% Launchers) stop("Only the declared command may occupy bin/")
  }
  Installed <- unlist(lapply(Manifest$files, `[[`, "installed"), use.names = FALSE)
  Targets <- unlist(lapply(Manifest$files, `[[`, "target"), use.names = FALSE)
  if (anyDuplicated(tolower(Installed)) || anyDuplicated(tolower(Targets))) stop("Manifest repeats a destination")
  if (!all(Launchers %in% Installed)) stop("Manifest must list all command launchers")
  Manifest
}

.packageRecord <- function(path, source) {
  File <- file.path(path, ".aom-install.rds")
  if (!file.exists(File)) stop("Package has no installation identity; install the complete product")
  Record <- readRDS(File)
  if (is.null(Record$source) || !identical(Record$source, .sourceHashes(source))) {
    stop("Installed package was built from different library sources", call. = FALSE)
  }
  Files <- .sourceHashes(path)
  Files <- Files[names(Files) != ".aom-install.rds"]
  if (!identical(Files, Record$files)) stop("Installed package differs from its artifact record")
  Record
}

.verifyResources <- function(root, package = NULL) {
  Record <- jsonlite::read_json(file.path(root, "install.json"), simplifyVector = FALSE)
  Binding <- Record$binding
  if (is.null(Binding)) stop("Installed resources lack a package binding; reinstall the complete product")
  Path <- file.path(Record$package$library, Record$package$name)
  Path <- normalizePath(Path, winslash = "/", mustWork = TRUE)
  if (!is.null(package) && !identical(Path, normalizePath(package, winslash = "/", mustWork = TRUE))) stop("Loaded package differs from installed resources")
  if (Record$package$name %in% loadedNamespaces() &&
      !identical(Path, normalizePath(getNamespaceInfo(Record$package$name, "path"), winslash = "/", mustWork = TRUE))) stop("A different package namespace is already loaded")
  Identity <- readRDS(file.path(Path, ".aom-install.rds"))
  if (!identical(Identity$artifact, Binding$artifact)) stop("Installed package artifact differs from resource receipt")
  if (!identical(unlist(Binding$files), Identity$files)) stop("Installed package file map differs from resource receipt")
  for (Name in names(Binding$files)) {
    if (!.relativePaths(Name) || !identical(digest::digest(file = file.path(Path, Name), algo = "sha256"), Binding$files[[Name]])) stop("Installed package hash mismatch: ", Name)
  }
  Prefix <- dirname(dirname(root))
  for (Entry in Record$resources) {
    Base <- if (Entry$origin == "package") Path else Prefix
    Name <- if (Entry$origin == "package") Entry$source else Entry$file
    if (!.relativePaths(Name)) stop("Invalid resource path")
    File <- file.path(Base, Name)
    if (!file.exists(File) || !identical(digest::digest(file = File, algo = "sha256"), Entry$sha256)) stop("Installed resource hash mismatch: ", Name)
    if (.Platform$OS.type != "windows" && bitwAnd(as.integer(file.info(File)$mode), 511L) != as.integer(as.octmode(Entry$mode))) stop("Installed resource mode mismatch: ", Name)
  }
  Record$package$path <- Path
  Record
}
