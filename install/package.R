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

.installPackages <- function(packages, library, repos, type) {
  if (!length(packages)) return(invisible(NULL))
  message("Installing ", paste(packages, collapse = ", "), "\nLibrary: ", library,
          "\nRepository: ", paste(repos, collapse = ", "), "\nType: ", type)
  # install.packages returns NULL even after some failures. A warning is not
  # permission to publish a CLI backed by an old or incomplete installation.
  withCallingHandlers(
    utils::install.packages(packages, lib = library, repos = repos, type = type,
                            dependencies = NA),
    warning = function(e) stop("Package installation failed: ", conditionMessage(e), call. = FALSE)
  )
  invisible(NULL)
}

.satisfiedRequirements <- function(requirements) {
  vapply(seq_len(nrow(requirements)), function(i) {
    Name <- requirements$package[i]
    Version <- getRversion()
    if (Name != "R") {
      FILE <- find.package(Name, quiet = TRUE)
      if (!length(FILE)) return(FALSE)
      Version <- package_version(.packageInfo(FILE)$version)
    }
    Constraint <- requirements$version[i]
    if (Constraint == "*") return(TRUE)
    Operator <- sub("[[:space:]].*$", "", Constraint)
    if (!(Operator %in% c("<", "<=", "==", ">=", ">"))) {
      stop("Unsupported version constraint: ", Name, " ", Constraint, call. = FALSE)
    }
    do.call(Operator, list(Version, package_version(sub("^[^[:space:]]+[[:space:]]+", "", Constraint))))
  }, logical(1L))
}

installRequirements <- function(path, library, packages, dependencies) {
  Package <- .packageInfo(path)
  Fields <- dependencies
  if (identical(dependencies, FALSE)) Fields <- character()
  if (identical(dependencies, NA)) Fields <- c("Depends", "Imports", "LinkingTo")
  if (identical(dependencies, TRUE)) Fields <- c("Depends", "Imports", "LinkingTo", "Suggests")
  if (!is.character(Fields) || anyNA(Fields) ||
      any(!Fields %in% c("Depends", "Imports", "LinkingTo", "Suggests", "Enhances"))) {
    stop("Invalid dependency scope", call. = FALSE)
  }
  if (length(library) != 1L || is.na(library) || !nzchar(library)) {
    stop("Select one R library", call. = FALSE)
  }
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
  Repositories <- getOption("repos")
  if (is.null(Repositories) || !length(Repositories)) Repositories <- c(CRAN = "https://cloud.r-project.org")
  Repositories[Repositories == "@CRAN@"] <- "https://cloud.r-project.org"
  Type <- getOption("pkgType")
  if (length(Fields) && !length(find.package("desc", quiet = TRUE))) {
    .installPackages("desc", library = library, repos = Repositories, type = Type)
  }
  Requirements <- data.frame(package = packages, version = rep("*", length(packages)))
  if (length(Fields)) {
    AUX <- desc::desc_get_deps(file = file.path(Package$path, "DESCRIPTION"))
    Requirements <- rbind(Requirements, AUX[AUX$type %in% Fields, c("package", "version")])
  }
  Missing <- Requirements[!.satisfiedRequirements(Requirements), , drop = FALSE]
  if ("R" %in% Missing$package) {
    stop("R version does not satisfy DESCRIPTION: ", Missing$version[Missing$package == "R"], call. = FALSE)
  }
  .installPackages(unique(Missing$package), library = library, repos = Repositories, type = Type)
  Missing <- Requirements[!.satisfiedRequirements(Requirements), , drop = FALSE]
  if (nrow(Missing)) {
    stop("Unmet package requirements: ", paste(paste(Missing$package, Missing$version), collapse = ", "), call. = FALSE)
  }
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
  Scratch <- tempfile("artifact-description-")
  dir.create(Scratch)
  on.exit(unlink(Scratch, recursive = TRUE), add = TRUE)
  FILE <- paste0(Artifact$package, "/DESCRIPTION")
  if (utils::untar(Artifact$file, files = FILE, exdir = Scratch) != 0L) {
    stop("Cannot read DESCRIPTION from selected artifact", call. = FALSE)
  }
  Package <- .packageInfo(file.path(Scratch, Artifact$package))
  if (!identical(Package$package, Artifact$package) || !identical(Package$version, Artifact$version)) {
    stop("Artifact DESCRIPTION differs from its build record", call. = FALSE)
  }
  installRequirements(path = Package$path, library = library, packages = character(), dependencies = NA)
  library <- normalizePath(library, winslash = "/", mustWork = TRUE)
  Libraries <- .libPaths()
  on.exit(.libPaths(Libraries), add = TRUE)
  .libPaths(c(library, Libraries))
  .installPackages(Artifact$file, library = library, repos = NULL, type = "source")
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
