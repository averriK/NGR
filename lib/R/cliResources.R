.cliResources <- function(args, base) {
  Command <- args[[1L]]
  Args <- args[-1L]
  Flags <- c("--source", "--help")
  if (Command %in% c("pull", "status")) Flags <- c(Flags, "--from")
  if (Command == "pull") Flags <- c(Flags, "--force", "--dry-run")
  if (Command == "status") Flags <- c(Flags, "--check")
  Values <- list(from = NULL, source = NULL, paths = character())
  Force <- DryRun <- Check <- Help <- FALSE
  Positional <- FALSE
  i <- 1L
  while (i <= length(Args)) {
    Arg <- Args[[i]]
    i <- i + 1L
    if (!Positional && Arg == "--") {
      Positional <- TRUE
      next
    }
    if (!Positional && Arg == "-h") Arg <- "--help"
    if (!Positional && startsWith(Arg, "-")) {
      Flag <- sub("=.*$", "", Arg)
      Matches <- Flags[startsWith(Flags, Flag)]
      if (length(Matches) != 1L) stop(errorCondition(paste0("Unknown or ambiguous argument: ", Arg), class = "ngrUsageError"))
      Flag <- Matches[[1L]]
      if (Flag %in% c("--source", "--from")) {
        Value <- NULL
        if (grepl("=", Arg, fixed = TRUE)) Value <- substring(Arg, regexpr("=", Arg, fixed = TRUE) + 1L)
        if (is.null(Value)) {
          if (i > length(Args) || startsWith(Args[[i]], "-")) {
            stop(errorCondition(paste0(Flag, " requires a value"), class = "ngrUsageError"))
          }
          Value <- Args[[i]]
          i <- i + 1L
        }
        Name <- substring(Flag, 3L)
        Values[[Name]] <- c(Values[[Name]], Value)
        next
      }
      if (grepl("=", Arg, fixed = TRUE)) {
        stop(errorCondition(paste0(Flag, " takes no value"), class = "ngrUsageError"))
      }
      if (Flag == "--help") Help <- TRUE
      if (Flag == "--force") Force <- TRUE
      if (Flag == "--dry-run") DryRun <- TRUE
      if (Flag == "--check") Check <- TRUE
      next
    }
    if (Command == "doctor") stop(errorCondition(paste0("Unknown argument: ", Arg), class = "ngrUsageError"))
    Values$paths <- c(Values$paths, Arg)
  }
  if (Help) {
    cat("usage: ngr ", Command, " [--source ID] ", sep = "")
    if (Command %in% c("pull", "status")) cat("[--from MANIFEST] ")
    if (Command == "pull") cat("[--force] [--dry-run] ")
    if (Command == "status") cat("[--check] ")
    cat("[--help]")
    if (Command %in% c("pull", "status")) cat(" [TARGETS ...]")
    cat("\n")
    return(0L)
  }
  Values$from[Values$from == "ngr"] <- base
  if (Command == "pull") {
    Result <- pullResources(from = Values$from, source = Values$source, paths = Values$paths,
                            force = Force, dryRun = DryRun)
    for (i in seq_len(nrow(Result$actions))) {
      cat(Result$actions$source[[i]], Result$actions$action[[i]], Result$actions$path[[i]], sep = "\t")
      cat("\n")
    }
    cat("[pull] ", if (DryRun) "plan" else "complete", ": ", nrow(Result$actions), " resource contributions\n", sep = "")
    return(0L)
  }
  if (Command == "status") {
    Result <- compareResources(from = Values$from, source = Values$source, paths = Values$paths)
    for (i in seq_len(nrow(Result$files))) {
      cat(Result$files$source[[i]], Result$files$state[[i]], Result$files$path[[i]], sep = "\t")
      if (Result$files$modified[[i]]) cat("\tlocally-modified")
      cat("\n")
    }
    return(as.integer(Check && Result$changed))
  }
  if (Command == "doctor") {
    withCallingHandlers(checkResources(source = Values$source), message = function(e) {
      cat(conditionMessage(e))
      invokeRestart("muffleMessage")
    })
    cat("[doctor] declared checks passed\n")
    return(0L)
  }
  stop("Unknown resource command: ", Command, call. = FALSE)
}
