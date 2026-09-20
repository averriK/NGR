# Maintenance operations. Sourcing this file has no installation or release effect.

.packageInfo <- function(path) {
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  FILE <- file.path(path, "DESCRIPTION")
  if (!file.exists(FILE)) stop("No package DESCRIPTION at ", path, call. = FALSE)
  AUX <- read.dcf(FILE, fields = c("Package", "Version"))[1L, ]
  if (anyNA(AUX) || any(!nzchar(AUX))) {
    stop("DESCRIPTION must identify Package and Version", call. = FALSE)
  }
  list(path = path, package = unname(AUX[["Package"]]),
       version = unname(AUX[["Version"]]))
}

.gitOutput <- function(path, args) {
  OUT <- suppressWarnings(system2(
    "git", c("-C", shQuote(path), shQuote(args)), stdout = TRUE, stderr = TRUE
  ))
  if (!is.null(attr(OUT, "status"))) {
    stop("Git failed: ", paste(args, collapse = " "), "\n",
         paste(OUT, collapse = "\n"), call. = FALSE)
  }
  OUT
}

.sourceIdentity <- function(path) {
  if (!nzchar(Sys.which("git"))) {
    return(list(commit = NA_character_, clean = FALSE))
  }
  OUT <- suppressWarnings(system2(
    "git", c("-C", shQuote(path), "rev-parse", "HEAD"),
    stdout = TRUE, stderr = FALSE
  ))
  if (!is.null(attr(OUT, "status"))) {
    return(list(commit = NA_character_, clean = FALSE))
  }
  list(commit = OUT, clean = !length(.gitOutput(path, c("status", "--porcelain"))))
}

.readArtifact <- function(file) {
  file <- normalizePath(file, winslash = "/", mustWork = TRUE)
  FILE <- paste0(file, ".rds")
  if (!file.exists(FILE)) stop("Missing build record: ", FILE, call. = FALSE)
  Artifact <- readRDS(FILE)
  if (!identical(Artifact$sha256, digest::digest(file = file, algo = "sha256"))) {
    stop("Artifact differs from its recorded SHA-256: ", file, call. = FALSE)
  }
  Artifact$file <- file
  Artifact
}

installRequirements <- function(path, library, packages, dependencies) {
  .packageInfo(path)
  if (!dir.exists(library) && !dir.create(library, recursive = TRUE)) {
    stop("Cannot create R library: ", library, call. = FALSE)
  }
  library <- normalizePath(library, winslash = "/", mustWork = TRUE)
  if (file.access(library, 2L) != 0L) {
    stop("R library is not writable: ", library, call. = FALSE)
  }
  Libraries <- .libPaths()
  on.exit(.libPaths(Libraries), add = TRUE)
  .libPaths(unique(c(library, Libraries)))
  if (!length(find.package("pak", quiet = TRUE))) {
    # Bootstrap with network access; the installer announces it, never silent.
    message("[INFO] pak is not available; bootstrapping pak from CRAN into ", library)
    utils::install.packages("pak", lib = library, repos = "https://cloud.r-project.org")
  }
  # Only absent extra tools are direct installation targets. The package solver
  # handles dependency versions; compatible packages in other libraries stay visible.
  packages <- packages[!vapply(packages, function(x) {
    length(find.package(x, quiet = TRUE)) > 0L
  }, logical(1L))]
  if (length(packages)) {
    pak::pkg_install(packages, lib = .libPaths(), upgrade = FALSE,
                     ask = FALSE, dependencies = NA)
  }
  pak::local_install_deps(root = path, lib = .libPaths(), upgrade = FALSE,
                          ask = FALSE, dependencies = dependencies)
  invisible(library)
}

documentPackage <- function(path, roxygen) {
  Package <- .packageInfo(path)
  if (roxygen) roxygen2::roxygenise(package.dir = Package$path)
  OUT <- spelling::spell_check_package(pkg = Package$path, vignettes = TRUE,
                                      use_wordlist = TRUE)
  if (NROW(OUT)) {
    print(OUT)
    stop("Spelling check found unreviewed terms", call. = FALSE)
  }
  message("Documentation prepared. Review the source diff before building a release.")
  invisible(OUT)
}

buildPackage <- function(path, output, documents = TRUE) {
  Package <- .packageInfo(path)
  Source <- .sourceIdentity(Package$path)
  if (!dir.exists(output) && !dir.create(output, recursive = TRUE)) {
    stop("Cannot create build directory: ", output, call. = FALSE)
  }
  output <- normalizePath(output, winslash = "/", mustWork = TRUE)
  if (identical(output, Package$path) || startsWith(output, paste0(Package$path, "/"))) {
    stop("Build output must be outside the package source", call. = FALSE)
  }
  FILE <- file.path(output, paste0(Package$package, "_", Package$version, ".tar.gz"))
  if (file.exists(FILE) || file.exists(paste0(FILE, ".rds"))) {
    stop("Build destination already exists: ", FILE, call. = FALSE)
  }
  FILE <- pkgbuild::build(path = Package$path, dest_path = output,
                          manual = documents, vignettes = documents)
  Source$clean <- Source$clean && identical(Source, .sourceIdentity(Package$path))
  Artifact <- list(
    file = normalizePath(FILE, winslash = "/", mustWork = TRUE),
    sha256 = digest::digest(file = FILE, algo = "sha256"),
    package = Package$package, version = Package$version,
    source = Package$path, commit = Source$commit, clean = Source$clean,
    built = Sys.time(), r = R.version.string, check = NULL
  )
  saveRDS(Artifact, paste0(FILE, ".rds"))
  message("Built ", FILE, "\nSHA-256: ", Artifact$sha256)
  invisible(FILE)
}

checkPackage <- function(file, output) {
  Artifact <- .readArtifact(file)
  if (file.exists(output)) {
    stop("Use a new check directory: ", output, call. = FALSE)
  }
  if (!dir.create(output, recursive = TRUE)) {
    stop("Cannot create check directory: ", output, call. = FALSE)
  }
  output <- normalizePath(output, winslash = "/", mustWork = TRUE)
  Args <- c("--as-cran", "--run-donttest", "--timings")
  Environment <- c(
    `_R_CHECK_CRAN_INCOMING_` = "true",
    `_R_CHECK_CRAN_INCOMING_REMOTE_` = "true",
    `_R_CHECK_FORCE_SUGGESTS_` = "true",
    NOT_CRAN = "false"
  )
  Artifact$check <- list(status = "running", started = Sys.time(),
                         directory = output, args = Args, env = Environment)
  saveRDS(Artifact, paste0(Artifact$file, ".rds"))
  Result <- rcmdcheck::rcmdcheck(
    path = Artifact$file, args = Args, check_dir = output,
    error_on = "never", env = Environment
  )
  writeLines(Result$stdout, file.path(output, "stdout.log"))
  writeLines(Result$stderr, file.path(output, "stderr.log"))
  Artifact <- .readArtifact(Artifact$file)
  Artifact$check$status <- "failed"
  Artifact$check$exit <- Result$status
  Artifact$check$errors <- Result$errors
  Artifact$check$warnings <- Result$warnings
  Artifact$check$notes <- Result$notes
  Artifact$check$r <- Result$rversion
  Artifact$check$platform <- Result$platform
  Artifact$check$finished <- Sys.time()
  OK <- identical(Result$status, 0L) && !length(Result$errors) && !length(Result$warnings)
  if (OK) Artifact$check$status <- "passed"
  saveRDS(Artifact, paste0(Artifact$file, ".rds"))
  if (!OK) stop("Package check failed; evidence retained in ", output, call. = FALSE)
  message("Check passed; review ", length(Result$notes), " NOTE(s). Evidence: ", output)
  invisible(Artifact)
}

installPackage <- function(file, library) {
  Artifact <- .readArtifact(file)
  if (!dir.exists(library) && !dir.create(library, recursive = TRUE)) {
    stop("Cannot create R library: ", library, call. = FALSE)
  }
  library <- normalizePath(library, winslash = "/", mustWork = TRUE)
  if (file.access(library, 2L) != 0L) {
    stop("R library is not writable: ", library, call. = FALSE)
  }
  pak::pkg_install(paste0("local::", Artifact$file), lib = unique(c(library, .libPaths())),
                   upgrade = FALSE, ask = FALSE, dependencies = NA)
  Package <- .packageInfo(file.path(library, Artifact$package))
  if (!identical(Package$version, Artifact$version)) {
    stop("Installed package version differs from the selected artifact", call. = FALSE)
  }
  message("Installed ", Package$package, " ", Package$version, " at ", Package$path)
  invisible(Package)
}

.releaseSource <- function(path) {
  Package <- .packageInfo(path)
  if (length(.gitOutput(Package$path, c("status", "--porcelain")))) {
    stop("Release operation requires a clean working tree", call. = FALSE)
  }
  Branch <- .gitOutput(Package$path, c("branch", "--show-current"))
  if (length(Branch) != 1L || !nzchar(Branch)) stop("A named branch is required", call. = FALSE)
  Head <- .gitOutput(Package$path, c("rev-parse", "HEAD"))
  Remote <- .gitOutput(Package$path, c("config", "--get", paste0("branch.", Branch, ".remote")))
  Ref <- .gitOutput(Package$path, c("config", "--get", paste0("branch.", Branch, ".merge")))
  OUT <- .gitOutput(Package$path, c("ls-remote", "--exit-code", Remote, Ref))
  if (length(OUT) != 1L || !identical(strsplit(OUT, "\t", fixed = TRUE)[[1L]][1L], Head)) {
    stop("Selected branch does not match its live remote", call. = FALSE)
  }
  list(branch = Branch, commit = Head, package = Package$package)
}

dispatchRhub <- function(path) {
  if (!interactive()) stop("R-hub dispatch requires an interactive session", call. = FALSE)
  Source <- .releaseSource(path)
  WD <- getwd()
  on.exit(setwd(WD), add = TRUE)
  setwd(path)
  rhub::rhub_doctor()
  rhub::rhub_check(branch = Source$branch, platforms = c("linux", "windows", "macos"))
}

.entryArguments <- function(package, fields) {
  Package <- .packageInfo(".")
  if (!identical(Package$package, package)) {
    stop("Run from the ", package, " lib/ directory", call. = FALSE)
  }
  Args <- commandArgs(trailingOnly = TRUE)
  if (!length(Args) && length(fields) && interactive()) {
    Args <- vapply(fields, function(x) readline(paste0(x, ": ")), character(1L))
  }
  if (length(Args) != length(fields) || any(!nzchar(Args))) {
    stop("Required arguments: ", paste(fields, collapse = " "), call. = FALSE)
  }
  setNames(Args, fields)
}
