# Exercise the installed product without changing its selected R library.
runChecks <- function(root, library) {
  Requirements <- source(file.path(root, "install/requirements.R"), local = TRUE)$value
  Package <- read.dcf(file.path(root, "lib/DESCRIPTION"), fields = "Package")[1L, 1L]
  Runtime <- Requirements$runtime
  if (!length(Runtime)) Runtime <- Requirements$command
  Work <- tempfile("product CLI á ")
  dir.create(Work)
  on.exit(unlink(Work, recursive = TRUE), add = TRUE)
  WD <- getwd()
  on.exit(setwd(WD), add = TRUE, after = FALSE)
  setwd(Work)
  Environment <- Sys.getenv(c("R_LIBS", "R_ENVIRON_USER", "R_PROFILE_USER", "ZOTERO_API_KEY", "ZOTERO_LIBRARY_ID"), unset = NA_character_)
  on.exit({
    for (Name in names(Environment)) {
      if (is.na(Environment[[Name]])) Sys.unsetenv(Name)
      if (!is.na(Environment[[Name]])) do.call(Sys.setenv, setNames(list(Environment[[Name]]), Name))
    }
  }, add = TRUE)
  writeLines(character(), file.path(Work, "Renviron"))
  writeLines(character(), file.path(Work, "Rprofile"))
  Sys.setenv(R_LIBS = paste(c(library, .libPaths()), collapse = .Platform$path.sep),
             R_ENVIRON_USER = file.path(Work, "Renviron"), R_PROFILE_USER = file.path(Work, "Rprofile"),
             ZOTERO_API_KEY = "", ZOTERO_LIBRARY_ID = "")
  Prefix <- file.path(Work, "prefix")
  Windows <- .Platform$OS.type == "windows"
  Launcher <- file.path(Prefix, "bin", paste0(Requirements$command, if (Windows) ".cmd" else ""))
  runCommand <- function(command, args, status = 0L) {
    OUT <- suppressWarnings(system2(command, shQuote(args), stdout = TRUE, stderr = TRUE))
    Status <- attr(OUT, "status")
    if (is.null(Status)) Status <- 0L
    if (Status != status) stop(paste(OUT, collapse = "\n"))
    OUT
  }
  runEntry <- function(name, args, status = 0L, libraryPath = library) {
    if (Windows) return(runCommand("powershell.exe", c("-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
      file.path(root, "install", paste0(name, ".ps1")), "-Yes", "-NoPath", "-Library", libraryPath, "-Prefix", Prefix, args), status = status))
    runCommand("bash", c(file.path(root, "install", paste0(name, ".sh")), "--yes", "--library", libraryPath, "--prefix", Prefix, args), status = status)
  }
  Files <- list.files(file.path(library, Package), recursive = TRUE, all.files = TRUE, full.names = TRUE)
  Hash <- tools::md5sum(Files)
  runEntry("install", if (Windows) "-Check" else "--check")
  stopifnot(!dir.exists(Prefix))
  runEntry("install", if (Windows) c("-Component", "cli") else c("--component", "cli"))
  runCommand(Launcher, "--help")
  runCommand(Launcher, "--version")
  Record <- jsonlite::read_json(file.path(Prefix, "libexec", Runtime, "install.json"), simplifyVector = TRUE)
  stopifnot(identical(unname(tools::md5sum(file.path(Prefix, Record$file))), Record$md5))
  if (Package == "newmark") {
    Spec <- list(ky = 0.1, Ts = 0.3, Sa = 0.8, PGA = 0.5, PGV = 80, Mw = 7)
    jsonlite::write_json(c(list(IDn = "BM19"), Spec), "input.json", auto_unbox = TRUE)
    runCommand(Launcher, c("dn-model", "input.json", "--output", "result.json"))
    Expected <- jsonlite::toJSON(do.call(newmark::Dn_BM19, Spec), dataframe = "rows",
                                  auto_unbox = TRUE, digits = NA, na = "null", null = "null", pretty = TRUE)
    stopifnot(identical(paste(readLines("result.json"), collapse = "\n"), as.character(Expected)))
  }
  if (Package == "NGR") {
    runCommand(Launcher, c("pull", "--from", "ngr", "bib/apa.csl"))
    runCommand(Launcher, c("status", "--check", "bib/apa.csl"))
    stopifnot(identical(unname(tools::md5sum("bib/apa.csl")),
                        unname(tools::md5sum(file.path(Prefix, "libexec/ngr/scaffold/bib/apa.csl")))))
  }
  if (Package == "gmsp") {
    Roots <- file.path(Work, c("reference", "project á"))
    for (Root in Roots) {
      dir.create(file.path(Root, "index"), recursive = TRUE)
      dir.create(file.path(Root, "gmsp"))
      writeLines(c("RecordID,OwnerID,EventID,StationID,DIR,OCID,PGA",
                    "001,A,2020A,01,H1,H1,100", "002,A,2021B,02,H1,H1,200"),
                  file.path(Root, "index/MasterIndex.A.csv"))
      jsonlite::write_json(list(path = list(index = "index", selection = "selection"), owners = "A"),
                           file.path(Root, "gmsp/select.json"), auto_unbox = TRUE)
    }
    gmsp::runSelect(root = Roots[1L])
    runCommand(Launcher, c("select", "--root", Roots[2L]))
    Outputs <- c("candidates.csv", "selection.csv", "selection.json", "summary.json")
    stopifnot(identical(unname(tools::md5sum(file.path(Roots[1L], "selection", Outputs))),
                        unname(tools::md5sum(file.path(Roots[2L], "selection", Outputs)))))
  }
  if (Package == "hazard") {
    stopifnot(all(c("initSpec", "runRemote") %in% Requirements$exports),
              is.null(Requirements$buildInfo),
              !dir.exists(file.path(Prefix, "libexec/hazard/runtime")))
    runCommand(Launcher, c("--init", "site", "installer"))
    stopifnot(identical(jsonlite::read_json("oq/sites/installer.json")$siteID, "installer"))
    runCommand(Launcher, c("--pack", "--help"))
    runCommand(Launcher, c("--run", "--help"))
    runCommand(Launcher, "--unknown", status = 1L)
    # Incomplete libraries must fail before the currently working CLI is replaced.
    Source <- file.path(Work, "incomplete")
    Library <- file.path(Work, "library")
    dir.create(file.path(Source, "R"), recursive = TRUE)
    dir.create(Library)
    writeLines(c("Package: hazard", paste0("Version: ", Record$package$version),
      "Title: Installer Fixture", "Description: A fixture for missing CLI exports.",
      "Author: Fixture", "Maintainer: Fixture <fixture@example.org>", "License: MIT"),
      file.path(Source, "DESCRIPTION"))
    CliHash <- tools::md5sum(file.path(Prefix, c(Record$file, "libexec/hazard/install.json")))
    for (Missing in c("initSpec", "runRemote")) {
      Exports <- setdiff(Requirements$exports, Missing)
      writeLines(paste0("export(", Exports, ")"), file.path(Source, "NAMESPACE"))
      writeLines(paste0(Exports, " <- function(...) invisible(NULL)"), file.path(Source, "R/probe.R"))
      runCommand(file.path(R.home("bin"), if (Windows) "R.exe" else "R"),
                 c("CMD", "INSTALL", "--no-docs", paste0("--library=", Library), Source))
      OUT <- runEntry("install", if (Windows) c("-Component", "cli") else
        c("--component", "cli"), status = 1L, libraryPath = Library)
      stopifnot(any(grepl(paste0("Package lacks CLI exports: ", Missing), OUT, fixed = TRUE)),
                identical(CliHash, tools::md5sum(names(CliHash))))
    }
  }
  if (Package == "ssel") {
    Spec <- list(x = c("1", "x", NA_character_, "2.5"))
    saveRDS(Spec, "input.rds")
    runCommand(Launcher, c("which.nonnum", "--spec", "input.rds", "--output", "result.rds"))
    invisible(loadNamespace(Package, lib.loc = library))
    stopifnot(identical(readRDS("result.rds"), do.call(getExportedValue(Package, "which.nonnum"), Spec)))
  }
  if (Package == "dbAudit") {
    runCommand(Launcher, "doctor")
    if (!Windows) {
      dir.create("fake")
      writeLines(c("#!/bin/sh", "exit 99"), "fake/Rscript")
      Sys.chmod("fake/Rscript", "0755")
      runCommand("env", c(paste0("PATH=", file.path(Work, "fake"), ":", Sys.getenv("PATH")), Launcher, "--version"))
    }
  }
  if (Package == "zot") {
    OUT <- runCommand(Launcher, c("clean", "title", "Installer á's title (1).pdf", "--json"))
    stopifnot(identical(jsonlite::fromJSON(paste(OUT, collapse = "\n"))$data, "Installer á's title"))
    runCommand(Launcher, "bogus", status = 2L)
  }
  runEntry("install", if (Windows) c("-Component", "cli") else c("--component", "cli"))
  stopifnot(identical(Hash, tools::md5sum(Files)))
  Foreign <- file.path(Prefix, "libexec", Runtime, "foreign.txt")
  writeLines("keep", Foreign)
  runEntry("uninstall", character())
  stopifnot(file.exists(Foreign), !file.exists(Launcher), identical(Hash, tools::md5sum(Files)))
  message("PASS ", Package, ": installed command, local operation, update, pinned R when required, uninstall, library unchanged")
}
Args <- commandArgs(TRUE)
stopifnot(length(Args) == 2L)
runChecks(normalizePath(Args[1L], mustWork = TRUE), normalizePath(Args[2L], mustWork = TRUE))
