# Local installation acceptance. User profiles and service diagnostics are
# deliberately outside this transaction; normal CLI calls keep their environment.
verifyCommand <- function(command) {
  Variables <- c("R_ENVIRON", "R_ENVIRON_USER", "R_PROFILE", "R_PROFILE_USER")
  Environment <- Sys.getenv(Variables, unset = NA_character_)
  on.exit({
    for (Name in Variables) {
      if (is.na(Environment[[Name]])) Sys.unsetenv(Name)
      if (!is.na(Environment[[Name]])) do.call(Sys.setenv, setNames(list(Environment[[Name]]), Name))
    }
  }, add = TRUE)
  File <- tempfile("installer-startup-")
  writeLines(character(), File)
  on.exit(unlink(File), add = TRUE)
  do.call(Sys.setenv, setNames(as.list(rep(File, length(Variables))), Variables))
  for (Option in c("--version", "--help")) {
    Status <- system2(command, shQuote(Option))
    if (Status != 0L) stop("Installed CLI local verification failed (", Status, "): ", command, call. = FALSE)
  }
  invisible(NULL)
}
ARGS <- commandArgs(TRUE)
if (length(ARGS) != 1L) stop("Usage: Rscript verify.R COMMAND", call. = FALSE)
verifyCommand(ARGS[[1L]])
