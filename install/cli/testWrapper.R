runChecks <- function(kit) {
  Work <- tempfile("installer wrapper á ")
  dir.create(Work)
  on.exit(unlink(Work, recursive = TRUE), add = TRUE)
  Fixture <- file.path(Work, "product")
  dir.create(Fixture)
  dir.create(file.path(Fixture, "install"))
  stopifnot(all(file.copy(list.files(kit, full.names = TRUE), file.path(Fixture, "install"), recursive = TRUE)))
  for (DIR in c("lib", "cli/bin", "library")) dir.create(file.path(Fixture, DIR), recursive = TRUE)
  Library <- file.path(Fixture, "library")
  stopifnot(file.symlink(find.package("stats"), file.path(Library, "stats")))
  writeLines(c("Package: stats", "Version: 99.0.0", "Depends: R (>= 4.1.0)"),
             file.path(Fixture, "lib/DESCRIPTION"))
  writeLines('list(command = "installerprobe", minimum = "0.0.0", exports = "lm")',
             file.path(Fixture, "install/requirements.R"))
  writeLines(c("#!/bin/sh", "echo installerprobe"), file.path(Fixture, "cli/bin/installerprobe"))
  writeLines("invisible(NULL)", file.path(Fixture, "cli/main.R"))
  jsonlite::write_json(list(manifest_version = 1L, files = c("bin/installerprobe", "main.R")),
                       file.path(Fixture, "install/manifest.json"), auto_unbox = TRUE)
  Prefix <- file.path(Work, "prefix")
  runWrapper <- function(args, success = TRUE) {
    OUT <- suppressWarnings(system2("bash", shQuote(c(file.path(Fixture, "install/install.sh"),
      "--yes", "--library", Library, "--prefix", Prefix, args)), stdout = TRUE, stderr = TRUE))
    Status <- attr(OUT, "status")
    if (is.null(Status)) Status <- 0L
    if ((Status == 0L) != success) stop(paste(OUT, collapse = "\n"))
    OUT
  }
  runWrapper(c("--component", "lib"))
  stopifnot(!dir.exists(Prefix))
  runWrapper(character())
  stopifnot(file.exists(file.path(Prefix, "bin/installerprobe")))
  Hash <- tools::md5sum(file.path(Prefix, "libexec/installerprobe/install.json"))
  writeLines('list(command = "installerprobe", minimum = "0.0.0", exports = "missingApi")',
             file.path(Fixture, "install/requirements.R"))
  OUT <- runWrapper(character(), success = FALSE)
  stopifnot(any(grepl("Package lacks CLI exports: missingApi", OUT, fixed = TRUE)),
            any(grepl("Rebuild explicitly", OUT, fixed = TRUE)),
            identical(Hash, tools::md5sum(names(Hash))))
  Prefix <- file.path(Work, "check")
  writeLines(c("Package: installerabsent", "Version: 0.1.0"), file.path(Fixture, "lib/DESCRIPTION"))
  runWrapper("--check")
  stopifnot(!dir.exists(Prefix), !dir.exists(file.path(Library, "installerabsent")))
  runWrapper(c("--component", "cli", "--build"), success = FALSE)
  # Exercise the real explicit build route, including a quoted library path.
  Library <- file.path(Work, "R library á's")
  dir.create(Library)
  writeLines(c("Package: installerabsent", "Version: 0.1.0", "Title: Installer Fixture",
    "Description: A fixture for the explicit installer build route.",
    "Author: Fixture", "Maintainer: Fixture <fixture@example.org>", "License: MIT"),
    file.path(Fixture, "lib/DESCRIPTION"))
  writeLines(character(), file.path(Fixture, "lib/NAMESPACE"))
  writeLines('list(command = "installerprobe", minimum = "0.0.0")',
    file.path(Fixture, "install/requirements.R"))
  runWrapper(c("--component", "lib", "--build"))
  stopifnot(file.exists(file.path(Library, "installerabsent/DESCRIPTION")), !dir.exists(Prefix))
  local({
    source(file.path(kit, "package.R"), local = TRUE)
    source(file.path(kit, "product.R"), local = TRUE)
    Calls <- character()
    installRequirements <- function(path, library, packages, dependencies) {
      Calls <<- c(Calls, if (identical(dependencies, FALSE)) "tools" else "dependencies")
    }
    installPackage <- function(file, library) Calls <<- c(Calls, basename(file))
    .readArtifact <- function(file) list(file = file, package = sub("[.]tar.gz$", "", basename(file)), version = "0.1.0", sha256 = "fixture")
    .verifyInstallation <- function(...) invisible(NULL)
    for (File in c("private.tar.gz", "installerabsent.tar.gz")) {
      writeLines("fixture", file.path(Work, File))
      writeLines("fixture", file.path(Work, paste0(File, ".rds")))
    }
    installProduct(root = Fixture, args = c("--component", "lib", "--library", Library,
      "--dependency", file.path(Work, "private.tar.gz"), "--tarball", file.path(Work, "installerabsent.tar.gz")))
    stopifnot(identical(Calls, c("tools", "private.tar.gz", "dependencies", "installerabsent.tar.gz")))
  })
  message("PASS: lib isolation, compatible version, missing API cause, --library, check without build, explicit build, dependency order")
}
runChecks(normalizePath(commandArgs(TRUE)[1L], mustWork = TRUE))
