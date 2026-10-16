runChecks <- function(kit) {
  Work <- tempfile("installer wrapper á's ")
  dir.create(Work)
  on.exit(unlink(Work, recursive = TRUE), add = TRUE)
  Fixture <- file.path(Work, "product")
  dir.create(Fixture)
  dir.create(file.path(Fixture, "install"))
  stopifnot(all(file.copy(list.files(kit, full.names = TRUE), file.path(Fixture, "install"), recursive = TRUE)))
  for (DIR in c("lib/R", "cli/bin", "library")) dir.create(file.path(Fixture, DIR), recursive = TRUE)
  stopifnot(file.copy(file.path(dirname(kit), "lib/inst"), file.path(Fixture, "lib"), recursive = TRUE))
  Library <- file.path(Fixture, "library")
  Rscript <- file.path(R.home("bin"), "Rscript")
  Windows <- .Platform$OS.type == "windows"
  writePackage <- function(version, value) {
    writeLines(c("Package: installerprobe", paste0("Version: ", version),
      "Title: Installer Fixture", "Description: A fixture for product updates.",
      "Author: Fixture", "Maintainer: Fixture <fixture@example.org>", "License: MIT",
      "Depends: R (>= 4.1.0)"), file.path(Fixture, "lib/DESCRIPTION"))
    writeLines("export(probe)", file.path(Fixture, "lib/NAMESPACE"))
    writeLines(paste0('probe <- function() "', value, '"'), file.path(Fixture, "lib/R/probe.R"))
  }
  runCommand <- function(command, args, success = TRUE, input = character()) {
    OUT <- suppressWarnings(system2(command, shQuote(args), stdout = TRUE, stderr = TRUE, input = input))
    Status <- attr(OUT, "status")
    if (is.null(Status)) Status <- 0L
    if ((Status == 0L) != success) {
      message(paste(OUT, collapse = "\n"))
      stop("Unexpected command exit status: ", Status)
    }
    OUT
  }
  readPackage <- function() {
    runCommand(Rscript, c("--vanilla", "-e",
      'Args <- commandArgs(TRUE); library("installerprobe", lib.loc = Args[1L]); cat(as.character(packageVersion("installerprobe")), probe(), sep = "\n")',
      Library))
  }
  writePackage("0.4.0", "old")
  # A source update replaces the installed package regardless of its version.
  Requirements <- 'list(command = "installerprobe", packages = "jsonlite", exports = "probe")'
  writeLines(Requirements, file.path(Fixture, "install/requirements.R"))
  writeLines(c("#!/bin/sh", "echo installerprobe"), file.path(Fixture, "cli/bin/installerprobe"))
  writeLines(c("@echo off", "echo installerprobe"), file.path(Fixture, "cli/bin/installerprobe.cmd"))
  writeLines("invisible(NULL)", file.path(Fixture, "cli/main.R"))
  jsonlite::write_json(list(manifest_version = 1L,
    files = c("bin/installerprobe", "bin/installerprobe.cmd", "bin/installerprobe.ps1", "main.R")),
    file.path(Fixture, "install/manifest.json"), auto_unbox = TRUE)
  Prefix <- file.path(Work, "prefix")
  runWrapper <- function(args, success = TRUE, yes = TRUE, input = character(), prompts = 0L) {
    if (Windows) {
      args <- sub("^--", "-", args)
      OUT <- runCommand("powershell.exe", c("-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
        file.path(Fixture, "install/install.ps1"), if (yes) "-Yes", "-NoPath",
        "-Library", Library, "-Prefix", Prefix, args), success = success, input = input)
    }
    if (!Windows) OUT <- runCommand("bash", c(file.path(Fixture, "install/install.sh"), if (yes) "--yes",
      "--library", Library, "--prefix", Prefix, args), success = success, input = input)
    stopifnot(sum(lengths(regmatches(OUT, gregexpr("\\[[yY]/[nN]\\]", OUT)))) == prompts)
    OUT
  }
  snapshot <- function() {
    Files <- sort(list.files(c(Library, Prefix), recursive = TRUE, all.files = TRUE,
                             full.names = TRUE, include.dirs = TRUE))
    list(paths = Files, hash = tools::md5sum(Files[!dir.exists(Files)]))
  }
  cancelWrapper <- function() {
    Before <- snapshot()
    for (Input in list("n", character())) {
      OUT <- runWrapper(character(), success = length(Input) > 0L,
                        yes = FALSE, input = Input, prompts = 1L)
      stopifnot(identical(Before, snapshot()),
                !any(grepl("Building ", OUT, fixed = TRUE)))
      if (!length(Input)) stopifnot(any(grepl("End of input", OUT, fixed = TRUE)))
    }
  }
  runWrapper(character(), yes = FALSE)
  stopifnot(identical(readPackage(), c("0.4.0", "old")))
  writePackage("0.4.2", "updated")
  runWrapper(character(), yes = FALSE, input = "y", prompts = 1L)
  stopifnot(identical(readPackage(), c("0.4.2", "updated")))
  stopifnot(file.exists(file.path(Prefix, "bin/installerprobe")))
  cancelWrapper()
  Before <- snapshot()
  runWrapper("--check", yes = FALSE)
  stopifnot(identical(Before, snapshot()))
  writePackage("0.4.2", "same-version")
  OUT <- runWrapper(character(), yes = FALSE, input = "", prompts = 1L)
  stopifnot(identical(readPackage(), c("0.4.2", "same-version")))
  stopifnot(any(grepl("[Y/n]", OUT, fixed = TRUE)))
  Hash <- tools::md5sum(file.path(Prefix, "libexec/installerprobe/install.json"))
  writeLines('list(command = "installerprobe", exports = "missingApi")',
    file.path(Fixture, "install/requirements.R"))
  OUT <- runWrapper(character(), success = FALSE)
  stopifnot(any(grepl("Package lacks CLI exports: missingApi", OUT, fixed = TRUE)),
            identical(Hash, tools::md5sum(names(Hash))))
  writeLines('list(command = "installerprobe", packages = "jsonlite", exports = "probe")',
    file.path(Fixture, "install/requirements.R"))
  Prefix <- file.path(Work, "library present CLI absent")
  cancelWrapper()
  writePackage("0.4.4", "archive")
  Before <- snapshot()
  runWrapper("--check")
  stopifnot(!dir.exists(Prefix), identical(Before, snapshot()))
  runWrapper(character())
  stopifnot(identical(readPackage(), c("0.4.4", "archive")))
  # An existing CLI alone still asks before installing the whole product.
  stopifnot(file.rename(file.path(Library, "installerprobe"), file.path(Library, "held")))
  cancelWrapper()
  stopifnot(file.rename(file.path(Library, "held"), file.path(Library, "installerprobe")))
  Previous <- Prefix
  Prefix <- file.path(Work, "foreign")
  dir.create(file.path(Prefix, "bin"), recursive = TRUE)
  writeLines("foreign", file.path(Prefix, "bin/installerprobe"))
  Before <- snapshot()
  OUT <- runWrapper(character(), success = FALSE)
  stopifnot(any(grepl("No installation receipt", OUT, fixed = TRUE)),
            identical(Before, snapshot()))
  Prefix <- Previous
  runWrapper("--build", success = FALSE)
  runWrapper(c("--component", "cli", "--tarball", "unused.tar.gz"), success = FALSE)
  local({
    source(file.path(dirname(kit), "lib/inst/package.R"), local = TRUE)
    Archive <- buildPackage(file.path(Fixture, "lib"), output = file.path(Work, "archive"),
                            documents = FALSE)
    runWrapper(c("--tarball", Archive))
    writePackage("0.4.4", "different-build-same-version")
    runWrapper(c("--tarball", Archive), success = FALSE)
    stopifnot(identical(readPackage(), c("0.4.4", "archive")))
  })
  message("PASS: single confirmation, Enter accepts replacement, N/EOF unchanged, new/partial installs, yes/check, foreign conflict, source/same-version updates, removed partial modes, exports, tarball, dependency order")
}
runChecks(normalizePath(commandArgs(TRUE)[1L], mustWork = TRUE))
