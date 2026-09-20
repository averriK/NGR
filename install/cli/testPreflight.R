# Public preflight and a complete installation with a Renviron-selected library.
runChecks <- function(kit) {
  Work <- tempfile("installer preflight ")
  dir.create(Work)
  on.exit(unlink(Work, recursive = TRUE), add = TRUE)
  Fixture <- file.path(Work, "product")
  dir.create(Fixture)
  dir.create(file.path(Fixture, "install"))
  stopifnot(all(file.copy(list.files(kit, full.names = TRUE), file.path(Fixture, "install"), recursive = TRUE)))
  for (Path in c("lib/R", "cli")) dir.create(file.path(Fixture, Path), recursive = TRUE)
  writeLines(c("Package: preflightprobe", "Version: 0.1.0", "Title: Installer Fixture",
    "Description: A disposable public installer fixture.", "Author: Fixture",
    "Maintainer: Fixture <fixture@example.org>", "License: MIT"), file.path(Fixture, "lib/DESCRIPTION"))
  writeLines("export(probe)", file.path(Fixture, "lib/NAMESPACE"))
  writeLines('probe <- function() "installed"', file.path(Fixture, "lib/R/probe.R"))
  writeLines('list(command = "preflightprobe", exports = "probe", packages = character())',
             file.path(Fixture, "install/requirements.R"))
  writeLines('writeLines(c(preflightprobe::probe(), find.package("preflightprobe")))',
             file.path(Fixture, "cli/main.R"))
  jsonlite::write_json(list(manifest_version = 1L,
    files = c("bin/preflightprobe", "bin/preflightprobe.cmd", "bin/preflightprobe.ps1", "main.R")),
    file.path(Fixture, "install/manifest.json"), auto_unbox = TRUE)
  Prefix <- file.path(Work, "prefix")
  Library <- file.path(Work, "user-library")
  Environment <- Sys.getenv(c("R_LIBS", "R_LIBS_USER", "R_LIBS_SITE", "R_ENVIRON",
                             "R_ENVIRON_USER", "R_PROFILE", "R_PROFILE_USER"), unset = NA_character_)
  on.exit({
    for (Name in names(Environment)) {
      if (is.na(Environment[[Name]])) Sys.unsetenv(Name)
      if (!is.na(Environment[[Name]])) do.call(Sys.setenv, setNames(list(Environment[[Name]]), Name))
    }
  }, add = TRUE)
  Renviron <- file.path(Work, "Renviron")
  Profile <- file.path(Work, "Rprofile")
  Empty <- file.path(Work, "empty")
  writeLines(character(), Empty)
  writeLines(paste0('R_LIBS_USER="', Library, '"'), Renviron)
  writeLines('stop("User profile must not run during installation")', Profile)
  Sys.unsetenv(c("R_LIBS_USER", "R_LIBS_SITE"))
  Sys.setenv(R_LIBS = paste(.libPaths(), collapse = .Platform$path.sep),
             R_ENVIRON = Empty, R_ENVIRON_USER = Renviron,
             R_PROFILE = Empty, R_PROFILE_USER = Profile)
  Windows <- .Platform$OS.type == "windows"
  runWrapper <- function(args) {
    Command <- "bash"
    Args <- c(file.path(Fixture, "install/install.sh"), "--prefix", Prefix, args)
    if (Windows) {
      Command <- "powershell.exe"
      Args <- c("-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
        file.path(Fixture, "install/install.ps1"), "-NoPath", "-Prefix", Prefix,
        sub("^--", "-", args))
    }
    OUT <- suppressWarnings(system2(Command, shQuote(Args), stdout = TRUE, stderr = TRUE))
    Status <- attr(OUT, "status")
    if (is.null(Status)) Status <- 0L
    list(status = Status, output = OUT)
  }
  Failures <- character()
  OUT <- runWrapper("--check")
  if (OUT$status != 0L || !any(grepl(paste0("R library: ", Library), OUT$output, fixed = TRUE))) {
    Failures <- c(Failures, "Renviron-selected library is ignored or a profile was executed")
  }
  Occupied <- file.path(Work, "occupied")
  writeLines("preserve", Occupied)
  Cases <- list(c("--library", Occupied), c("--tarball", file.path(Work, "absent.tar.gz")),
                c("--dependency", file.path(Work, "missing-dependency.tar.gz")))
  for (Args in Cases) {
    OUT <- runWrapper(c("--check", Args))
    if (OUT$status == 0L) Failures <- c(Failures, paste("Invalid preflight accepted:", paste(Args, collapse = " ")))
    stopifnot(!dir.exists(Prefix), !dir.exists(Library), identical(readLines(Occupied), "preserve"))
  }
  if (length(Failures)) stop(paste(Failures, collapse = "\n"), call. = FALSE)
  OUT <- runWrapper("--yes")
  if (OUT$status != 0L) stop(paste(OUT$output, collapse = "\n"), call. = FALSE)
  stopifnot(!any(grepl("is not the default R user library", OUT$output, fixed = TRUE)))
  stopifnot(dir.exists(file.path(Library, "preflightprobe")))
  writeLines(character(), Profile)
  Launcher <- file.path(Prefix, "bin", if (Windows) "preflightprobe.cmd" else "preflightprobe")
  OUT <- system2(Launcher, "--version", stdout = TRUE, stderr = TRUE)
  stopifnot(is.null(attr(OUT, "status")), identical(OUT[1L], "installed"),
            identical(normalizePath(OUT[2L]), normalizePath(file.path(Library, "preflightprobe"))))
  message("PASS preflight: Renviron default, no R profiles, invalid library/tarball/dependency rejected without writes; full public install and normal CLI resolve the selected package")
}
runChecks(normalizePath(commandArgs(TRUE)[1L], mustWork = TRUE))
