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
  runCommand <- function(command, args, success = TRUE) {
    OUT <- suppressWarnings(system2(command, shQuote(args), stdout = TRUE, stderr = TRUE))
    Status <- attr(OUT, "status")
    if (is.null(Status)) Status <- 0L
    if ((Status == 0L) != success) stop(paste(OUT, collapse = "\n"))
    OUT
  }
  readPackage <- function() {
    runCommand(Rscript, c("--vanilla", "-e",
      'Args <- commandArgs(TRUE); library("installerprobe", lib.loc = Args[1L]); cat(as.character(packageVersion("installerprobe")), probe(), sep = "\n")',
      Library))
  }
  writePackage("0.4.0", "old")
  runCommand(file.path(R.home("bin"), "R"), c("CMD", "INSTALL", "--no-docs",
    paste0("--library=", Library), file.path(Fixture, "lib")))
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
  runWrapper <- function(args, success = TRUE) {
    if (Windows) {
      args <- sub("^--", "-", args)
      return(runCommand("powershell.exe", c("-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
        file.path(Fixture, "install/install.ps1"), "-Yes", "-NoPath",
        "-Library", Library, "-Prefix", Prefix, args), success = success))
    }
    runCommand("bash", c(file.path(Fixture, "install/install.sh"), "--yes",
      "--library", Library, "--prefix", Prefix, args), success = success)
  }
  writePackage("0.4.2", "updated")
  runWrapper(character())
  stopifnot(identical(readPackage(), c("0.4.2", "updated")))
  stopifnot(file.exists(file.path(Prefix, "bin/installerprobe")))
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
  writePackage("0.4.3", "lib-only")
  runWrapper(c("--component", "lib"))
  stopifnot(identical(readPackage(), c("0.4.3", "lib-only")), !dir.exists(Prefix))
  Files <- list.files(file.path(Library, "installerprobe"), recursive = TRUE, full.names = TRUE)
  Hash <- tools::md5sum(Files)
  writePackage("0.4.4", "archive")
  runWrapper("--check")
  stopifnot(!dir.exists(Prefix), identical(Hash, tools::md5sum(Files)))
  runWrapper(c("--component", "cli"))
  stopifnot(identical(Hash, tools::md5sum(Files)))
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
  message("PASS: default source update, same-version source change, lib-only update, cli-only isolation, exports, check, tarball, dependency order")
}
runChecks(normalizePath(commandArgs(TRUE)[1L], mustWork = TRUE))
