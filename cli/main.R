#!/usr/bin/env Rscript
Status <- tryCatch({
  Path <- Sys.getenv("NGR_COMMAND_PATH", unset = NA_character_)
  if (!is.na(Path)) Sys.setenv(PATH = Path)
  Sys.unsetenv("NGR_COMMAND_PATH")
  File <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[[1L]])
  Runtime <- dirname(normalizePath(File, winslash = "/", mustWork = TRUE))
  suppressPackageStartupMessages(loadNamespace("NGR"))
  getFromNamespace(".cliNgr", "NGR")(commandArgs(trailingOnly = TRUE), runtime = Runtime)
}, error = function(e) {
  message("ngr: ", conditionMessage(e))
  if (inherits(e, "ngrUsageError")) return(2L)
  1L
})
quit(save = "no", status = Status)
