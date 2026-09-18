# Run against a kit root. The fixture never builds or changes an R package.
runChecks <- function(root, native) {
  Windows <- .Platform$OS.type == "windows"
  Work <- tempfile("installer á ")
  dir.create(Work)
  on.exit(unlink(Work, recursive = TRUE), add = TRUE)
  Fixture <- file.path(Work, "product")
  dir.create(Fixture)
  stopifnot(file.copy(file.path(root, "install"), Fixture, recursive = TRUE))
  for (DIR in c("lib", "cli/bin", "cli/helpers")) {
    dir.create(file.path(Fixture, DIR), recursive = TRUE)
  }
  writeLines(c("Package: stats", paste0("Version: ", utils::packageVersion("stats"))),
             file.path(Fixture, "lib/DESCRIPTION"))
  writeLines('list(command = "installerprobe", minimum = "0.0.0")',
             file.path(Fixture, "install/requirements.R"))
  Launcher <- file.path(Fixture, "cli/bin/installerprobe")
  writeLines(c("#!/bin/sh", "echo installerprobe"), Launcher)
  writeLines("invisible(NULL)", file.path(Fixture, "cli/main.R"))
  writeLines("invisible(NULL)", file.path(Fixture, "cli/helpers/retired.R"))
  Files <- c("bin/installerprobe", "main.R", "helpers/retired.R")
  if (Windows) {
    Launcher <- paste0(Launcher, ".cmd")
    writeLines(c("@echo off", "echo installerprobe", "exit /b 0"), Launcher)
    writeLines("Write-Output installerprobe", file.path(Fixture, "cli/bin/installerprobe.ps1"))
    Files <- c(Files, "bin/installerprobe.cmd", "bin/installerprobe.ps1")
  }
  Manifest <- file.path(Fixture, "install/manifest.json")
  jsonlite::write_json(list(manifest_version = 1L, files = Files), Manifest, auto_unbox = TRUE)
  Rscript <- file.path(R.home("bin"), if (Windows) "Rscript.exe" else "Rscript")
  Manager <- file.path(Fixture, "install/cli/manage.R")
  runManager <- function(action, prefix, success = TRUE) {
    Stage <- NULL
    Present <- dir.exists(prefix)
    if (native && action != "check") { Stage <- tempfile(tmpdir = Work); dir.create(Stage) }
    OUT <- suppressWarnings(system2(Rscript, shQuote(c("--vanilla", Manager, action, prefix, Stage)),
                                    stdout = TRUE, stderr = TRUE))
    Status <- attr(OUT, "status")
    if (is.null(Status)) Status <- 0L
    if (Status == 0L && !is.null(Stage)) {
      if (!Present) stopifnot(!dir.exists(prefix))
      OUT <- suppressWarnings(system2("bash", shQuote(c("-c",
        'source "$1"; as_user() { "$@"; }; r_libs=""; publish_cli "$2" "$3" installerprobe installerprobe "$4" ""',
        "--", file.path(Fixture, "install/cli/publish.sh"), Stage, prefix, action)),
        stdout = TRUE, stderr = TRUE))
      Status <- attr(OUT, "status")
      if (is.null(Status)) Status <- 0L
    }
    if ((Status == 0L) != success) stop(paste(OUT, collapse = "\n"))
    invisible(OUT)
  }
  receiptPath <- function(prefix) file.path(prefix, "libexec/installerprobe/install.json")
  Prefix <- file.path(Work, "retirement")
  runManager("check", Prefix)
  stopifnot(!dir.exists(Prefix))
  # Exercise the R-to-PowerShell transport without certifying Windows itself.
  ENV <- new.env(parent = globalenv())
  for (Expr in parse(Manager)) {
    if (is.call(Expr) && identical(Expr[[1L]], as.name("<-")) &&
        identical(Expr[[2L]], as.name(".manageCli"))) eval(Expr, ENV)
  }
  ENV$.Platform <- .Platform
  ENV$.Platform$OS.type <- "windows"
  PathList <- NULL
  ENV$system2 <- function(command, args) {
    stopifnot(command == "powershell.exe", length(args) == 7L)
    PathList <<- substring(args[7L], 2L, nchar(args[7L]) - 1L)
    Paths <- readLines(PathList, encoding = "UTF-8")
    stopifnot(chartr("\\", "/", file.path(Prefix, "bin/installerprobe")) %in% Paths,
              chartr("\\", "/", file.path(Prefix, "libexec/installerprobe/main.R")) %in% Paths)
    0L
  }
  ENV$.manageCli("check", Prefix, Fixture, dirname(Manager), stage = NULL)
  stopifnot(!is.null(PathList), !file.exists(PathList), !dir.exists(Prefix))
  writeLines('list(command = "installerprobe", minimum = "0.0.0", buildInfo = "helpers/BUILD_INFO")',
             file.path(Fixture, "install/requirements.R"))
  runManager("install", Prefix)
  stopifnot(!file.exists(file.path(Prefix, "libexec/installerprobe/helpers/BUILD_INFO")))
  Created <- jsonlite::read_json(receiptPath(Prefix), simplifyVector = TRUE)$created
  unlink(file.path(Fixture, "cli/helpers/retired.R"))
  jsonlite::write_json(list(manifest_version = 1L, files = Files[-3L]), Manifest, auto_unbox = TRUE)
  runManager("install", Prefix)
  Record <- jsonlite::read_json(receiptPath(Prefix), simplifyVector = TRUE)
  stopifnot(!file.exists(file.path(Prefix, "libexec/installerprobe/helpers/retired.R")),
            all(Created %in% Record$created))
  Hash <- tools::md5sum(file.path(Prefix, c(Record$file, "libexec/installerprobe/install.json")))
  writeLines(if (Windows) c("@echo off", "exit /b 42") else c("#!/bin/sh", "echo broken >&2", "exit 42"), Launcher)
  runManager("install", Prefix, success = FALSE)
  stopifnot(identical(Hash, tools::md5sum(names(Hash))))
  writeLines(if (Windows) c("@echo off", "echo installerprobe", "exit /b 0") else c("#!/bin/sh", "echo installerprobe"), Launcher)
  Foreign <- file.path(Prefix, "libexec/installerprobe/foreign.txt")
  writeLines("keep", Foreign)
  runManager("uninstall", Prefix)
  stopifnot(file.exists(Foreign), !file.exists(receiptPath(Prefix)),
            !file.exists(file.path(Prefix, "bin/installerprobe")))
  Prefix <- file.path(Work, "empty")
  runManager("install", Prefix)
  if (native) runManager("uninstall", Prefix)
  if (!native) {
    Uninstaller <- file.path(Prefix, "libexec/installerprobe/install", if (Windows) "uninstall.ps1" else "uninstall.sh")
    stopifnot(file.exists(Uninstaller), file.rename(Fixture, paste0(Fixture, "-hidden")))
    OUT <- suppressWarnings(system2(if (Windows) "powershell.exe" else "bash", shQuote(
      if (Windows) c("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", Uninstaller,
                     "-Yes", "-NoPath", "-Prefix", Prefix, "-Library", dirname(find.package("jsonlite"))) else
        c(Uninstaller, "--yes", "--prefix", Prefix, "--library", dirname(find.package("jsonlite")))),
      stdout = TRUE, stderr = TRUE))
    stopifnot(file.rename(paste0(Fixture, "-hidden"), Fixture))
    if (!is.null(attr(OUT, "status"))) stop(paste(OUT, collapse = "\n"))
  }
  stopifnot(!dir.exists(Prefix))
  Prefix <- file.path(Work, "receipt")
  runManager("install", Prefix)
  Outside <- file.path(Work, "foreign.txt")
  writeLines("keep", Outside)
  Record <- jsonlite::read_json(receiptPath(Prefix), simplifyVector = TRUE)
  Record$file <- c(Record$file, "../foreign.txt")
  Record$md5 <- c(Record$md5, unname(tools::md5sum(Outside)))
  jsonlite::write_json(Record, receiptPath(Prefix), auto_unbox = TRUE)
  runManager("uninstall", Prefix, success = FALSE)
  stopifnot(file.exists(Outside), file.exists(file.path(Prefix, "bin/installerprobe")))
  if (Windows) {
    message("PASS: check, receipt confinement, retirement, rollback, uninstall; Unix symlink case skipped")
    return(invisible(NULL))
  }
  Prefix <- file.path(Work, "symlink")
  Outside <- file.path(Work, "outside")
  dir.create(file.path(Prefix, "libexec/installerprobe"), recursive = TRUE)
  dir.create(Outside)
  stopifnot(file.symlink(Outside, file.path(Prefix, "libexec/installerprobe/helpers")))
  writeLines("invisible(NULL)", file.path(Fixture, "cli/helpers/retired.R"))
  jsonlite::write_json(list(manifest_version = 1L, files = Files), Manifest, auto_unbox = TRUE)
  runManager("install", Prefix, success = FALSE)
  stopifnot(!length(list.files(Outside)))
  message("PASS: check, receipt confinement, retirement, rollback, symlinks, uninstall without checkout")
}
Args <- commandArgs(TRUE)
runChecks(normalizePath(Args[1L], mustWork = TRUE), native = "--native" %in% Args)
