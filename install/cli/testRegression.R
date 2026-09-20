# Regression checks run only in scratch; no system R installation is changed.
runChecks <- function(root) {
  Work <- tempfile("installer regression á ")
  dir.create(Work)
  on.exit(unlink(Work, recursive = TRUE), add = TRUE)
  Fixture <- file.path(Work, "product")
  dir.create(Fixture)
  stopifnot(file.copy(file.path(root, "install"), Fixture, recursive = TRUE))
  for (DIR in c("lib", "cli", "library")) dir.create(file.path(Fixture, DIR))
  writeLines(c("Package: stats", paste0("Version: ", utils::packageVersion("stats"))), file.path(Fixture, "lib/DESCRIPTION"))
  writeLines('list(command = "installerprobe", packages = character(), verify = "doctor", pathEnv = "NGR_COMMAND_PATH")', file.path(Fixture, "install/requirements.R"))
  writeLines(c('Args <- commandArgs(TRUE)',
    'if (identical(Args, "doctor")) quit(status = 67L)',
    'if (identical(Args, "--paths")) writeLines(c(R.home(), .libPaths(), Sys.getenv("NGR_COMMAND_PATH")))',
    'if (identical(Args, "--identity")) writeLines(Sys.getenv("INSTALLER_R_ID"))'), file.path(Fixture, "cli/main.R"))
  Files <- c("bin/installerprobe", "bin/installerprobe.cmd", "bin/installerprobe.ps1", "main.R")
  jsonlite::write_json(list(manifest_version = 1L, files = Files), file.path(Fixture, "install/manifest.json"), auto_unbox = TRUE)
  # Baseline has product-owned launchers; candidate generates its own.
  dir.create(file.path(Fixture, "cli/bin"))
  writeLines(c("#!/usr/bin/env bash", 'exec Rscript "${BASH_SOURCE[0]%/*}/../libexec/installerprobe/main.R" "$@"'), file.path(Fixture, "cli/bin/installerprobe"))
  writeLines(c("@echo off", "exit /b 0"), file.path(Fixture, "cli/bin/installerprobe.cmd"))
  writeLines("exit 0", file.path(Fixture, "cli/bin/installerprobe.ps1"))
  Environment <- Sys.getenv(c("R_PROFILE_USER", "R_ENVIRON_USER", "R_LIBS", "PATH"), unset = NA_character_)
  on.exit({
    for (Name in names(Environment)) {
      if (is.na(Environment[[Name]])) Sys.unsetenv(Name)
      if (!is.na(Environment[[Name]])) do.call(Sys.setenv, setNames(list(Environment[[Name]]), Name))
    }
  }, add = TRUE)
  Profile <- file.path(Work, "Rprofile")
  Renviron <- file.path(Work, "Renviron")
  writeLines("quit(status = 66L)", Profile)
  writeLines("INSTALLER_R_ID=normal-profile", Renviron)
  Rscript <- file.path(R.home("bin"), "Rscript")
  Sys.setenv(R_PROFILE_USER = Profile, R_ENVIRON_USER = Renviron,
             R_LIBS = paste(c(file.path(Fixture, "library"), .libPaths()), collapse = .Platform$path.sep))
  runCommand <- function(command, args, status = 0L, env = character()) {
    OUT <- suppressWarnings(system2(command, shQuote(args), stdout = TRUE, stderr = TRUE, env = env))
    Exit <- attr(OUT, "status")
    if (is.null(Exit)) Exit <- 0L
    if (Exit != status) stop("Expected ", status, "; got ", Exit, "\n", paste(OUT, collapse = "\n"))
    OUT
  }
  for (Native in if (.Platform$OS.type == "windows") FALSE else c(FALSE, TRUE)) {
    Prefix <- file.path(Work, if (Native) "bash" else "manager")
    Stage <- NULL
    if (Native) { Stage <- file.path(Work, "stage"); dir.create(Stage) }
    runCommand(Rscript, c("--vanilla", file.path(Fixture, "install/cli/manage.R"), "install", Prefix, Stage))
    if (Native) runCommand("bash", c("-c",
      'source "$1"; as_user() { "$@"; }; r_libs="$R_LIBS"; publish_cli "$2" "$3" installerprobe installerprobe install "$4"',
      "--", file.path(Fixture, "install/cli/publish.sh"), Stage, Prefix, Rscript))
    Launcher <- file.path(Prefix, "bin", if (.Platform$OS.type == "windows") "installerprobe.cmd" else "installerprobe")
    runCommand(Launcher, "--identity", status = 66L)
    writeLines(character(), Profile)
    stopifnot(identical(runCommand(Launcher, "--identity"), "normal-profile"))
    OUT <- runCommand(Launcher, "--paths")
    stopifnot(R.home() %in% OUT, normalizePath(file.path(Fixture, "library")) %in% OUT,
              Sys.getenv("PATH") %in% OUT)
    if (.Platform$OS.type != "windows") {
      Fake <- file.path(Work, "fake")
      dir.create(Fake, showWarnings = FALSE)
      writeLines(c("#!/bin/sh", "exit 99"), file.path(Fake, "Rscript"))
      Sys.chmod(file.path(Fake, "Rscript"), "0755")
      stopifnot(identical(runCommand(Launcher, "--identity", env = paste0("PATH=", shQuote(paste(Fake, "/usr/bin:/bin", sep = ":")))), "normal-profile"))
      stopifnot(identical(runCommand(Launcher, "--identity", env = "PATH=/usr/bin:/bin"), "normal-profile"))
      # Change a stable alias between two identified interpreters, then remove
      # the old one. This models the OS alias; it does not alter a real R install.
      for (Id in c("previous", "current")) {
        writeLines(c("#!/bin/sh", paste0("export INSTALLER_R_ID=", Id),
          paste("exec", shQuote(Rscript), '"$@"')), file.path(Fake, Id))
        Sys.chmod(file.path(Fake, Id), "0755")
      }
      Alias <- file.path(Fake, "active")
      stopifnot(file.symlink(file.path(Fake, "previous"), Alias))
      Resolver <- file.path(Prefix, "libexec/installerprobe/install/cli/r.sh")
      Lines <- readLines(Resolver)
      Lines <- gsub("/Library/Frameworks/R.framework/Resources/bin/Rscript", shQuote(Alias), Lines, fixed = TRUE)
      Lines <- gsub("/usr/local/bin/Rscript", shQuote(Alias), Lines, fixed = TRUE)
      writeLines(Lines, Resolver)
      Sys.setenv(R_ENVIRON_USER = Profile)
      stopifnot(identical(runCommand(Launcher, "--identity"), "previous"))
      unlink(Alias)
      stopifnot(file.symlink(file.path(Fake, "current"), Alias), identical(runCommand(Launcher, "--identity"), "current"))
      unlink(file.path(Fake, "previous"))
      stopifnot(identical(runCommand(Launcher, "--identity"), "current"))
      # Restore the exact owned resolver before asking receipt validation to remove it.
      stopifnot(file.copy(file.path(Fixture, "install/cli/r.sh"), Resolver, overwrite = TRUE))
      unlink(Alias)
      Sys.setenv(R_ENVIRON_USER = Renviron)
    }
    Receipt <- file.path(Prefix, "libexec/installerprobe/install.json")
    Record <- jsonlite::read_json(Receipt, simplifyVector = TRUE)
    Record$package$library <- file.path(Work, "historical library")
    jsonlite::write_json(Record, Receipt, auto_unbox = TRUE)
    Stage <- NULL
    if (Native) { Stage <- file.path(Work, "remove"); dir.create(Stage) }
    OUT <- runCommand(Rscript, c("--vanilla", file.path(Fixture, "install/cli/manage.R"), "uninstall", Prefix, Stage))
    if (Native) OUT <- runCommand("bash", c("-c",
      'source "$1"; as_user() { "$@"; }; r_libs="$R_LIBS"; publish_cli "$2" "$3" installerprobe installerprobe uninstall "$4"',
      "--", file.path(Fixture, "install/cli/publish.sh"), Stage, Prefix, Rscript))
    stopifnot(any(grepl(Record$package$library, OUT, fixed = TRUE)), !file.exists(Receipt))
    writeLines("quit(status = 66L)", Profile)
  }
  Prefix <- file.path(Work, "unknown-history")
  runCommand(Rscript, c("--vanilla", file.path(Fixture, "install/cli/manage.R"), "install", Prefix))
  Receipt <- file.path(Prefix, "libexec/installerprobe/install.json")
  Record <- jsonlite::read_json(Receipt, simplifyVector = TRUE)
  Record$package <- "stats"
  jsonlite::write_json(Record, Receipt, auto_unbox = TRUE)
  OUT <- runCommand(Rscript, c("--vanilla", file.path(Fixture, "install/cli/manage.R"), "uninstall", Prefix))
  stopifnot(any(grepl("library is unknown", OUT, fixed = TRUE)))
  message("PASS regression: controlled acceptance, normal user startup, current R, PATH isolation, path export, receipt history and unknown history")
}
runChecks(normalizePath(commandArgs(TRUE)[1L], mustWork = TRUE))
