# Product installation composes package maintenance and the component installer.

.installationPath <- function(path, writable = TRUE) {
  path <- path.expand(path)
  if (!nzchar(path) || grepl("[\r\n]", path)) stop("Invalid installation path", call. = FALSE)
  if (.Platform$OS.type == "windows") path <- chartr("\\", "/", path)
  if (.Platform$OS.type == "windows" && grepl("^[A-Za-z]:($|[^/])", path)) {
    stop("Use an absolute drive path, not a drive-relative path: ", path, call. = FALSE)
  }
  Absolute <- startsWith(path, "/") ||
    (.Platform$OS.type == "windows" && grepl("^[A-Za-z]:/", path))
  if (!Absolute) path <- file.path(getwd(), path)
  Parent <- path
  Parts <- character()
  while (!file.exists(Parent) && !dir.exists(Parent)) {
    Link <- Sys.readlink(Parent)
    if (!is.na(Link) && nzchar(Link)) stop("Broken symlink: ", Parent, call. = FALSE)
    Parts <- c(basename(Parent), Parts)
    Parent <- dirname(Parent)
  }
  if (!dir.exists(Parent)) stop("Directory path is occupied by a file: ", Parent, call. = FALSE)
  if (writable && file.access(Parent, 2L) != 0L) stop("Directory is not writable: ", Parent, call. = FALSE)
  Path <- normalizePath(Parent, winslash = "/", mustWork = TRUE)
  for (Part in Parts) {
    if (Part == "..") Path <- dirname(Path)
    if (!(Part %in% c(".", ".."))) Path <- file.path(Path, Part)
  }
  Path
}

.runInstaller <- function(command, path, args = character(), system = FALSE) {
  WD <- getwd()
  on.exit(setwd(WD), add = TRUE)
  setwd(path)
  if (system) {
    command <- c("sudo", "-n", "--", "env", paste0("PATH=", Sys.getenv("PATH")),
                 paste0("R_LIBS=", paste(.libPaths(), collapse = .Platform$path.sep)), command)
  }
  Status <- system2(command[1L], args = shQuote(c(command[-1L], args)))
  if (Status != 0L) stop("Installer command failed (", Status, "): ",
                         paste(command, collapse = " "), call. = FALSE)
  invisible(NULL)
}

.verifyInstallation <- function(package, library, version, packages, exports) {
  Script <- c(
    "Args <- commandArgs(TRUE)",
    ".libPaths(c(Args[1L], .libPaths()))",
    "invisible(loadNamespace(Args[2L]))",
    "Path <- normalizePath(find.package(Args[2L]), mustWork = TRUE)",
    "if (!identical(Path, normalizePath(file.path(Args[1L], Args[2L]), mustWork = TRUE))) stop('Selected R library is shadowed: ', Path)",
    "if (!identical(as.character(utils::packageVersion(Args[2L])), Args[3L])) stop('Installed version differs from selected artifact')",
    "Count <- as.integer(Args[4L])",
    "for (Name in Args[4L + seq_len(Count)]) loadNamespace(Name)",
    "Missing <- setdiff(Args[-seq_len(4L + Count)], getNamespaceExports(Args[2L]))",
    "if (length(Missing)) stop('Package lacks CLI exports: ', paste(Missing, collapse = ', '))",
    "message('Verified installed package: ', Args[2L], ' ', Args[3L], ' at ', Path)"
  )
  .runInstaller(c(file.path(R.home("bin"), "Rscript"), "--vanilla", "-e",
                  paste(Script, collapse = "\n")), path = tempdir(),
                args = c(library, package, version, length(packages), packages, exports))
}

installProduct <- function(root, args, system = FALSE) {
  if (!length(args) || identical(args, "--help")) {
    writeLines(c(
      "Install the selected R package and available CLI from this repository.",
      "Usage: bash install/install.sh --library DIR [--prefix DIR] (--tarball FILE | --build DIR)",
      "       bash install/install.sh --component cli --library DIR --prefix DIR",
      "Options:",
      "  --component all|lib|cli  Default: all available components",
      "  --library DIR          Explicit writable R library",
      "  --prefix DIR           CLI prefix; required when installing a CLI",
      "  --tarball FILE         Selected package archive and adjacent .rds record",
      "  --build DIR            Build from lib/ into this directory, without manual/vignettes",
      "  --dependency FILE      Additional recorded package archive; repeat in dependency order",
      "CLI conflict checks run before R installation. Existing CLI replacement follows its manager.",
      "R and external tools must be available. No Git, publishing or legacy-tool removal."
    ))
    return(invisible(NULL))
  }
  if (.Platform$OS.type != "windows" && identical(Sys.info()[["effective_user"]], "root")) {
    stop("R installation must run as the invoking user; use install/install.sh", call. = FALSE)
  }
  if (system && .Platform$OS.type == "windows") {
    stop("Unix CLI elevation is not a Windows installation mode", call. = FALSE)
  }
  Options <- list(dependency = character())
  while (length(args)) {
    Key <- sub("^--", "", args[1L])
    if (!startsWith(args[1L], "--") ||
        !(Key %in% c("component", "library", "prefix", "tarball", "build", "dependency"))) {
      stop("Unknown installation argument: ", args[1L], call. = FALSE)
    }
    if (length(args) < 2L || !nzchar(args[2L]) || startsWith(args[2L], "--")) {
      stop("Missing value for ", args[1L], call. = FALSE)
    }
    if (Key == "dependency") Options$dependency <- c(Options$dependency, args[2L])
    if (Key != "dependency") {
      if (!is.null(Options[[Key]])) stop("Repeated option: ", Key, call. = FALSE)
      Options[[Key]] <- args[2L]
    }
    args <- args[-c(1L, 2L)]
  }
  if (is.null(Options$component)) Options$component <- "all"
  if (!(Options$component %in% c("all", "lib", "cli"))) stop("Unknown component", call. = FALSE)
  if (is.null(Options$library)) stop("--library is required", call. = FALSE)
  Library <- .installationPath(Options$library)
  Libraries <- .libPaths()
  Environment <- Sys.getenv("R_LIBS", unset = NA_character_, names = TRUE)
  on.exit({
    .libPaths(Libraries)
    for (Name in names(Environment)) {
      if (is.na(Environment[[Name]])) Sys.unsetenv(Name)
      if (!is.na(Environment[[Name]])) do.call(Sys.setenv, setNames(list(Environment[[Name]]), Name))
    }
  }, add = TRUE)
  .libPaths(unique(c(Library, Libraries)))
  Sys.setenv(R_LIBS = paste(unique(c(Library, Libraries)), collapse = .Platform$path.sep))
  message("R executable: ", file.path(R.home("bin"), "Rscript"),
          "\nR user: ", Sys.info()[["effective_user"]], "\nR library: ", Library)
  Package <- .packageInfo(file.path(root, "lib"))
  Cli <- NULL
  FILE <- file.path(root, "install/requirements.R")
  if (Options$component != "lib" && file.exists(FILE)) Cli <- source(FILE, local = TRUE)$value
  if (Options$component == "cli" && is.null(Cli)) stop("This product has no implemented CLI", call. = FALSE)
  if (is.null(Cli) && !is.null(Options$prefix)) stop("--prefix requires an implemented, selected CLI", call. = FALSE)
  if (!is.null(Cli) && is.null(Options$prefix)) stop("--prefix is required for the CLI", call. = FALSE)
  if (Options$component == "cli" &&
      (!is.null(Options$build) || !is.null(Options$tarball) || length(Options$dependency))) {
    stop("CLI-only installation does not install R archives", call. = FALSE)
  }
  if (Options$component != "cli" && (is.null(Options$build) == is.null(Options$tarball))) {
    stop("Select exactly one of --tarball or --build", call. = FALSE)
  }
  Prefix <- NULL
  if (!is.null(Cli)) {
    Prefix <- .installationPath(Options$prefix, writable = !system)
    Missing <- unique(c(Cli$check[1L], Cli$install[1L], Cli$tools, if (system) "sudo"))
    Missing <- Missing[!nzchar(Sys.which(Missing))]
    if (length(Missing)) stop("Required executable(s) unavailable: ", paste(Missing, collapse = ", "), call. = FALSE)
    .runInstaller(Cli$check, path = file.path(root, "install/cli"), args = Prefix, system = system)
  }
  Output <- NULL
  if (!is.null(Options$build)) {
    Output <- .installationPath(Options$build)
    FILE <- file.path(Output, paste0(Package$package, "_", Package$version, ".tar.gz"))
    if (file.exists(FILE) || file.exists(paste0(FILE, ".rds"))) stop("Build destination already exists: ", FILE, call. = FALSE)
    if (Output == Package$path || startsWith(Output, paste0(Package$path, "/"))) {
      stop("Build output must be outside the package source", call. = FALSE)
    }
  }
  Files <- c(Options$dependency, Options$tarball)
  for (File in Files) {
    if (!file.exists(File) || !file.exists(paste0(File, ".rds"))) {
      stop("Archive and adjacent .rds record are required: ", File, call. = FALSE)
    }
  }
  # Hashing is needed before modifying the selected library. Bootstrap only
  # this verifier in scratch when it is absent; runtime resolution excludes it.
  if (length(Files) && !requireNamespace("digest", quietly = TRUE)) {
    Scratch <- tempfile("product-verifier-")
    dir.create(Scratch)
    on.exit(unlink(Scratch, recursive = TRUE), add = TRUE)
    utils::install.packages("digest", lib = Scratch, repos = "https://cloud.r-project.org")
    loadNamespace("digest", lib.loc = Scratch)
  }
  Artifacts <- lapply(Files, .readArtifact)
  if (anyDuplicated(vapply(Artifacts, `[[`, character(1L), "package"))) stop("Repeated package archive", call. = FALSE)
  if (!is.null(Options$tarball) && !identical(tail(Artifacts, 1L)[[1L]]$package, Package$package)) {
    stop("Selected archive is not package ", Package$package, call. = FALSE)
  }
  if (length(Options$dependency) && any(vapply(head(Artifacts, length(Options$dependency)),
      function(x) identical(x$package, Package$package), logical(1L)))) {
    stop("The product package cannot also be a --dependency", call. = FALSE)
  }
  if (Options$component != "cli") {
    Tools <- c("digest", if (!is.null(Output)) "pkgbuild")
    installRequirements(path = Package$path, library = Library, packages = Tools, dependencies = NA)
  }
  if (!dir.exists(Library)) stop("R library does not exist: ", Library, call. = FALSE)
  .libPaths(unique(c(Library, Libraries)))
  Sys.setenv(R_LIBS = paste(unique(c(Library, Libraries)), collapse = .Platform$path.sep))
  if (Options$component != "cli") {
    for (Artifact in head(Artifacts, length(Options$dependency))) {
      installPackage(file = Artifact$file, library = Library)
    }
    if (!is.null(Output)) {
      FILE <- buildPackage(path = Package$path, output = Output, documents = FALSE)
      Artifact <- .readArtifact(FILE)
    }
    if (is.null(Output)) Artifact <- tail(Artifacts, 1L)[[1L]]
    installPackage(file = Artifact$file, library = Library)
    Version <- Artifact$version
    message("Selected artifact SHA-256: ", Artifact$sha256)
  }
  if (Options$component == "cli") Version <- .packageInfo(file.path(Library, Package$package))$version
  Packages <- character()
  if (!is.null(Cli) && length(Cli$packages)) {
    Packages <- names(Cli$packages)
    Missing <- Packages[!vapply(Packages, function(x) {
      if (!length(find.package(x, quiet = TRUE))) return(FALSE)
      !nzchar(Cli$packages[[x]]) || utils::packageVersion(x) >= Cli$packages[[x]]
    }, logical(1L))]
    if (length(Missing) && Options$component == "cli") {
      stop("CLI requires R packages: ", paste(Missing, collapse = ", "), call. = FALSE)
    }
    if (length(Missing)) {
      References <- vapply(Missing, function(x) {
        if (!nzchar(Cli$packages[[x]])) return(x)
        paste0(x, "@>=", Cli$packages[[x]])
      }, character(1L))
      pak::pkg_install(References, lib = .libPaths(), upgrade = FALSE, ask = FALSE, dependencies = NA)
    }
  }
  .verifyInstallation(package = Package$package, library = Library, version = Version,
                       packages = Packages, exports = Cli$exports)
  if (!is.null(Cli)) {
    tryCatch(.runInstaller(Cli$install, path = file.path(root, "install/cli"), args = Prefix, system = system),
             error = function(e) stop(conditionMessage(e), "\nR package remains installed at ",
                                       file.path(Library, Package$package), call. = FALSE))
    .runInstaller(file.path(Prefix, "bin", Cli$command), path = tempdir(), args = "--version")
  }
  message("R library for future CLI invocations: ", Library,
          "\nKeep it in the invoking shell's R_LIBS/R_LIBS_USER; no shell profile was changed.")
  invisible(list(package = Package$package, version = Version, library = Library, prefix = Prefix))
}
