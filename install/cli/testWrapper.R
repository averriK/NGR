runChecks <- function(kit) {
  Work <- tempfile("installer wrapper á's ")
  dir.create(Work)
  on.exit(unlink(Work, recursive = TRUE), add = TRUE)
  Fixture <- file.path(Work, "product")
  dir.create(Fixture)
  dir.create(file.path(Fixture, "install"))
  stopifnot(all(file.copy(list.files(kit, full.names = TRUE), file.path(Fixture, "install"), recursive = TRUE)))
  for (DIR in c("lib/R", "cli/bin", "library")) dir.create(file.path(Fixture, DIR), recursive = TRUE)
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
  # A stale minimum must not authorize retaining the old package.
  Requirements <- 'list(command = "installerprobe", minimum = "0.4.0", exports = "probe")'
  writeLines(Requirements, file.path(Fixture, "install/requirements.R"))
  writeLines(c("#!/bin/sh", "echo installerprobe"), file.path(Fixture, "cli/bin/installerprobe"))
  writeLines(c("@echo off", "echo installerprobe"), file.path(Fixture, "cli/bin/installerprobe.cmd"))
  writeLines("invisible(NULL)", file.path(Fixture, "cli/main.R"))
  jsonlite::write_json(list(manifest_version = 1L,
    files = c("bin/installerprobe", "bin/installerprobe.cmd", "main.R")),
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
    stopifnot(sum(lengths(regmatches(OUT, gregexpr("[y/N]", OUT, fixed = TRUE)))) == prompts)
    OUT
  }
  snapshot <- function() {
    Files <- sort(list.files(c(Library, Prefix), recursive = TRUE, all.files = TRUE,
                             full.names = TRUE, include.dirs = TRUE))
    list(paths = Files, hash = tools::md5sum(Files[!dir.exists(Files)]))
  }
  cancelWrapper <- function(component) {
    Before <- snapshot()
    for (Input in list("n", "", character())) {
      OUT <- runWrapper(c("--component", component), success = length(Input) > 0L,
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
  for (Component in c("all", "lib", "cli")) cancelWrapper(Component)
  Before <- snapshot()
  runWrapper("--check", yes = FALSE)
  stopifnot(identical(Before, snapshot()))
  writePackage("0.4.2", "same-version")
  runWrapper(character())
  stopifnot(identical(readPackage(), c("0.4.2", "same-version")))
  Hash <- tools::md5sum(file.path(Prefix, "libexec/installerprobe/install.json"))
  writeLines('list(command = "installerprobe", exports = "missingApi")',
    file.path(Fixture, "install/requirements.R"))
  OUT <- runWrapper(c("--component", "cli"), success = FALSE)
  stopifnot(any(grepl("Package lacks CLI exports: missingApi", OUT, fixed = TRUE)),
            !any(grepl("--build", OUT, fixed = TRUE)),
            identical(Hash, tools::md5sum(names(Hash))))
  writeLines('list(command = "installerprobe", exports = "probe")',
    file.path(Fixture, "install/requirements.R"))
  Prefix <- file.path(Work, "lib only")
  cancelWrapper("all")
  cancelWrapper("lib")
  writePackage("0.4.3", "lib-only")
  runWrapper(c("--component", "lib"))
  stopifnot(identical(readPackage(), c("0.4.3", "lib-only")), !dir.exists(Prefix))
  Files <- list.files(file.path(Library, "installerprobe"), recursive = TRUE, full.names = TRUE)
  Hash <- tools::md5sum(Files)
  writePackage("0.4.4", "archive")
  runWrapper("--check")
  stopifnot(!dir.exists(Prefix), identical(Hash, tools::md5sum(Files)))
  runWrapper(c("--component", "cli"), yes = FALSE)
  stopifnot(identical(Hash, tools::md5sum(Files)))
  # An existing CLI alone still requires consent for an all-components update.
  stopifnot(file.rename(file.path(Library, "installerprobe"), file.path(Library, "held")))
  cancelWrapper("all")
  stopifnot(file.rename(file.path(Library, "held"), file.path(Library, "installerprobe")))
  runWrapper(c("--component", "cli"), yes = FALSE, input = "y", prompts = 1L)
  stopifnot(identical(Hash, tools::md5sum(Files)))
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
    source(file.path(kit, "package.R"), local = TRUE)
    Archive <- buildPackage(file.path(Fixture, "lib"), output = file.path(Work, "archive"),
                            documents = FALSE)
    writePackage("0.4.5", "checkout")
    runWrapper(c("--tarball", Archive))
    stopifnot(identical(readPackage(), c("0.4.4", "archive")))
  })
  local({
    source(file.path(kit, "package.R"), local = TRUE)
    source(file.path(kit, "product.R"), local = TRUE)
    Calls <- character()
    installRequirements <- function(path, library, packages, dependencies) {
      Calls <<- c(Calls, if (identical(dependencies, FALSE)) "tools" else "dependencies")
    }
    installPackage <- function(file, library) Calls <<- c(Calls, basename(file))
    .readArtifact <- function(file) list(file = file, package = sub("[.]tar.gz$", "", basename(file)),
                                        version = "0.4.5", sha256 = "fixture")
    .verifyInstallation <- function(...) invisible(NULL)
    for (File in c("private.tar.gz", "installerprobe.tar.gz")) {
      writeLines("fixture", file.path(Work, File))
      writeLines("fixture", file.path(Work, paste0(File, ".rds")))
    }
    installProduct(root = Fixture, args = c("--component", "lib", "--library", Library,
      "--dependency", file.path(Work, "private.tar.gz"), "--tarball", file.path(Work, "installerprobe.tar.gz")))
    stopifnot(identical(Calls, c("tools", "private.tar.gz", "dependencies", "installerprobe.tar.gz")))
  })
  message("PASS: single confirmation, new/partial installs, N/empty/EOF unchanged, yes/check, foreign conflict, source/same-version updates, cli-only isolation, exports, tarball, dependency order")
}
runChecks(normalizePath(commandArgs(TRUE)[1L], mustWork = TRUE))
