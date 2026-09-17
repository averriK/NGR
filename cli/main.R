#!/usr/bin/env Rscript
# ngr: command-line interface of the installed NGR package. This file interprets
# arguments, prints results and sets the exit status; every operation is an
# exported NGR function.

.failUsage <- function(...) stop(errorCondition(paste0(...), class = "ngrUsageError"))

.splitAliases <- function(value) Filter(nzchar, strsplit(value, ",", fixed = TRUE)[[1L]])

.requiredLibrary <- function(runtime) {
  AUX <- grep("^requires NGR >= ", readLines(file.path(runtime, "VERSION")), value = TRUE)
  if (length(AUX) != 1L) stop("VERSION does not declare the required NGR version", call. = FALSE)
  sub("^requires NGR >= ", "", AUX)
}

.loadLibrary <- function(runtime) {
  Required <- .requiredLibrary(runtime)
  if (!suppressPackageStartupMessages(requireNamespace("NGR", quietly = TRUE))) {
    stop("the NGR R package >= ", Required, " is not installed in the active R library", call. = FALSE)
  }
  if (utils::packageVersion("NGR") < Required) {
    stop("NGR >= ", Required, " is required; found ", utils::packageVersion("NGR"), " at ",
         find.package("NGR"), call. = FALSE)
  }
  invisible(NULL)
}

.showVersion <- function(runtime) {
  cat(readLines(file.path(runtime, "VERSION")), sep = "\n")
  FILE <- file.path(runtime, "scaffold/BUILD_INFO")
  if (file.exists(FILE)) {
    cat(sub("^git_describe=", "revision ", grep("^git_describe=", readLines(FILE), value = TRUE)), sep = "\n")
  }
  if (suppressPackageStartupMessages(requireNamespace("NGR", quietly = TRUE))) {
    cat("NGR ", as.character(utils::packageVersion("NGR")), " at ", find.package("NGR"), "\n", sep = "")
  } else {
    cat("NGR is not installed in the active R library\n")
  }
  0L
}

.showHelp <- function() {
  cat("ngr \u2014 resources, reports and publication\n\n",
      "Run from the project directory:\n",
      "  ngr pull --from <manifest.json> [--from <manifest.json> ...] [paths...]\n",
      "  ngr pull [--source <id> ...] [--force] [--dry-run] [paths...]\n",
      "  ngr status [--source <id> ...] [--check] [paths...]\n",
      "  ngr doctor [--source <id> ...]\n",
      "  ngr render <input.qmd> --profile <book|html|revealjs|docx> [Quarto args...]\n",
      "  ngr render --manifest <file> [--dry-run] [--only <aliases>] [--except <aliases>]\n",
      "  ngr deploy --help\n  ngr --version\n\n",
      "The first pull names its sources; --from ngr selects the installed base.\n",
      "Later pulls use manifest.json; --from re-points a registered source.\n",
      "Seeds stay local.\n",
      "--force replaces managed files; incompatible sources always fail.\n", sep = "")
  0L
}

.runResources <- function(args, runtime) {
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
      if (length(Matches) != 1L) .failUsage("Unknown or ambiguous argument: ", Arg)
      Flag <- Matches[[1L]]
      if (Flag %in% c("--source", "--from")) {
        Value <- NULL
        if (grepl("=", Arg, fixed = TRUE)) Value <- substring(Arg, regexpr("=", Arg, fixed = TRUE) + 1L)
        if (is.null(Value)) {
          if (i > length(Args) || startsWith(Args[[i]], "-")) .failUsage(Flag, " requires a value")
          Value <- Args[[i]]
          i <- i + 1L
        }
        Name <- substring(Flag, 3L)
        Values[[Name]] <- c(Values[[Name]], Value)
        next
      }
      if (grepl("=", Arg, fixed = TRUE)) .failUsage(Flag, " takes no value")
      if (Flag == "--help") Help <- TRUE
      if (Flag == "--force") Force <- TRUE
      if (Flag == "--dry-run") DryRun <- TRUE
      if (Flag == "--check") Check <- TRUE
      next
    }
    if (Command == "doctor") .failUsage("Unknown argument: ", Arg)
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
  .loadLibrary(runtime)
  Values$from[Values$from == "ngr"] <- file.path(runtime, "scaffold/manifest.json")
  if (Command == "pull") {
    Result <- NGR::pullResources(from = Values$from, source = Values$source, paths = Values$paths,
                                 force = Force, dryRun = DryRun)
    for (i in seq_len(nrow(Result$actions))) {
      cat(Result$actions$source[[i]], Result$actions$action[[i]], Result$actions$path[[i]], sep = "\t")
      cat("\n")
    }
    cat("[pull] ", if (DryRun) "plan" else "complete", ": ", nrow(Result$actions), " resource contributions\n", sep = "")
    return(0L)
  }
  if (Command == "status") {
    Result <- NGR::compareResources(from = Values$from, source = Values$source, paths = Values$paths)
    for (i in seq_len(nrow(Result$files))) {
      cat(Result$files$source[[i]], Result$files$state[[i]], Result$files$path[[i]], sep = "\t")
      if (Result$files$modified[[i]]) cat("\tlocally-modified")
      cat("\n")
    }
    return(as.integer(Check && Result$changed))
  }
  message("NGR ", utils::packageVersion("NGR"), " at ", find.package("NGR"))
  withCallingHandlers(NGR::checkResources(source = Values$source), message = function(e) {
    cat(conditionMessage(e))
    invokeRestart("muffleMessage")
  })
  cat("[doctor] declared checks passed\n")
  0L
}

.runRender <- function(args, runtime) {
  Values <- list(manifest = NULL, profile = NULL, only = "", except = "")
  Input <- NULL
  Extra <- character()
  DryRun <- FALSE
  i <- 1L
  while (i <= length(args)) {
    Arg <- args[[i]]
    i <- i + 1L
    if (Arg %in% c("-h", "--help")) {
      cat("Usage: ngr render <input.qmd> --profile <book|revealjs|docx|html> [Quarto args...]\n",
          "       ngr render --manifest <file> [--dry-run] [--only <aliases>] [--except <aliases>]\n\n",
          "Uses yml/_quarto.yml and yml/_quarto-<profile>.yml from the project.\n",
          "Book masters supply chapters and appendices through frontmatter.\n",
          "Output: html/<stem>/, the manifest's HTML path, or docx/.\n",
          "Run ngr pull --from ngr first if yml/ does not exist.\n", sep = "")
      return(0L)
    }
    if (Arg %in% paste0("--", names(Values))) {
      if (i > length(args)) stop(Arg, " requires a value.", call. = FALSE)
      Values[[substring(Arg, 3L)]] <- args[[i]]
      i <- i + 1L
      next
    }
    if (Arg == "--dry-run") {
      DryRun <- TRUE
      next
    }
    if (grepl("\\.(qmd|md)$", Arg)) {
      if (!is.null(Input)) stop("Multiple render inputs.", call. = FALSE)
      Input <- Arg
      next
    }
    Extra <- c(Extra, Arg)
  }
  if (!is.null(Values$manifest)) {
    if (!is.null(Input) || !is.null(Values$profile)) stop("--manifest cannot be combined with input/--profile.", call. = FALSE)
    if (length(Extra)) stop("Unsupported arguments with --manifest: ", paste(Extra, collapse = " "), call. = FALSE)
    .loadLibrary(runtime)
    NGR::quartoRenderManifest(Values$manifest, only = .splitAliases(Values$only),
                              except = .splitAliases(Values$except), dryRun = DryRun)
    return(0L)
  }
  if (DryRun || nzchar(Values$only) || nzchar(Values$except)) {
    stop("--dry-run/--only/--except require --manifest.", call. = FALSE)
  }
  .loadLibrary(runtime)
  NGR::quartoRender(input = Input, profile = Values$profile, args = Extra)
  0L
}

.runDeploy <- function(args, runtime) {
  Action <- "upload"
  if (length(args) && args[[1L]] %in% c("init", "domain", "unbind")) {
    Action <- args[[1L]]
    args <- args[-1L]
  }
  if (!length(args) || args[[1L]] %in% c("-h", "--help")) {
    cat("Usage:\n",
        "  ngr deploy <alias> <dir> [--prod]\n",
        "  ngr deploy --manifest <file> [--dry-run] [--prod] [--only <aliases>] [--except <aliases>]\n",
        "  ngr deploy init <alias> <site-name> [--create] [--account <slug>]\n",
        "  ngr deploy init --manifest <file> [--dry-run] [--create] [--account <slug>] [--only <aliases>] [--except <aliases>]\n",
        "  ngr deploy domain <alias> <domain> [--https] [--rebind] [--dry-run]\n",
        "  ngr deploy domain --manifest <file> [--https] [--dry-run] [--only <aliases>] [--except <aliases>]\n",
        "  ngr deploy unbind <alias>\n", sep = "")
    return(if (length(args)) 0L else 1L)
  }
  Values <- list(manifest = NULL, only = "", except = "", account = NULL)
  Flags <- list(prod = FALSE, create = FALSE, https = FALSE, rebind = FALSE, dryRun = FALSE)
  Supplied <- character()
  Positional <- character()
  i <- 1L
  while (i <= length(args)) {
    Arg <- args[[i]]
    i <- i + 1L
    if (Arg %in% paste0("--", names(Values))) {
      if (i > length(args)) stop(Arg, " requires a value.", call. = FALSE)
      Values[[substring(Arg, 3L)]] <- args[[i]]
      i <- i + 1L
      Supplied <- c(Supplied, Arg)
      next
    }
    if (Arg %in% c("--prod", "--create", "--https", "--rebind", "--dry-run")) {
      Name <- substring(Arg, 3L)
      if (Arg == "--dry-run") Name <- "dryRun"
      Flags[[Name]] <- TRUE
      Supplied <- c(Supplied, Arg)
      next
    }
    if (startsWith(Arg, "-")) stop("Unknown deploy argument: ", Arg, call. = FALSE)
    Positional <- c(Positional, Arg)
  }
  Allowed <- switch(Action, upload = "--prod", init = c("--create", "--account"),
                    domain = c("--https", "--rebind", "--dry-run"), unbind = character())
  if (!is.null(Values$manifest) && Action != "unbind") {
    Allowed <- c(setdiff(Allowed, "--rebind"), "--manifest", "--dry-run", "--only", "--except")
  }
  if (any(!Supplied %in% Allowed)) stop("Unsupported deploy argument: ", paste(setdiff(Supplied, Allowed), collapse = " "), call. = FALSE)
  if (is.null(Values$manifest)) {
    Expected <- 2L
    if (Action == "unbind") Expected <- 1L
    if (length(Positional) != Expected) stop("Missing or extra deploy arguments; see ngr deploy --help.", call. = FALSE)
    .loadLibrary(runtime)
    if (Action == "unbind") NGR::netlifyUnbind(Positional[[1L]])
    if (Action == "init") NGR::netlifyRegister(Positional[[1L]], site = Positional[[2L]], create = Flags$create, account = Values$account)
    if (Action == "upload") NGR::netlifyDeploy(Positional[[1L]], path = Positional[[2L]], prod = Flags$prod)
    if (Action == "domain") NGR::netlifyDomain(Positional[[1L]], domain = Positional[[2L]], https = Flags$https, rebind = Flags$rebind, dryRun = Flags$dryRun)
    return(0L)
  }
  if (length(Positional)) stop("--manifest cannot be combined with positional arguments.", call. = FALSE)
  .loadLibrary(runtime)
  Only <- .splitAliases(Values$only)
  Except <- .splitAliases(Values$except)
  if (Action == "init") {
    NGR::netlifyRegisterManifest(Values$manifest, only = Only, except = Except, create = Flags$create,
                                 account = Values$account, dryRun = Flags$dryRun)
    return(0L)
  }
  if (Action == "domain") {
    NGR::netlifyDomainManifest(Values$manifest, only = Only, except = Except, https = Flags$https,
                               dryRun = Flags$dryRun)
    return(0L)
  }
  if (Action == "upload") {
    NGR::netlifyDeployManifest(Values$manifest, only = Only, except = Except, prod = Flags$prod,
                               dryRun = Flags$dryRun)
    return(0L)
  }
  stop("Unsupported deploy operation: ", Action, call. = FALSE)
}

.runCommand <- function(args, runtime) {
  if (!length(args) || args[[1L]] %in% c("--help", "-h")) return(.showHelp())
  Command <- args[[1L]]
  if (Command == "--version") {
    if (length(args) != 1L) .failUsage("--version takes no arguments")
    return(.showVersion(runtime))
  }
  if (Command %in% c("pull", "status", "doctor")) return(.runResources(args, runtime = runtime))
  if (Command == "render") return(.runRender(args[-1L], runtime = runtime))
  if (Command == "deploy") return(.runDeploy(args[-1L], runtime = runtime))
  .failUsage("Unknown command: ", Command, "; use ngr --help")
}

Status <- tryCatch({
  Path <- Sys.getenv("NGR_COMMAND_PATH", unset = NA_character_)
  if (!is.na(Path)) Sys.setenv(PATH = Path)
  Sys.unsetenv("NGR_COMMAND_PATH")
  File <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[[1L]])
  .runCommand(commandArgs(trailingOnly = TRUE),
              runtime = dirname(normalizePath(File, winslash = "/", mustWork = TRUE)))
}, error = function(e) {
  message("ngr: ", conditionMessage(e))
  if (inherits(e, "ngrUsageError")) return(2L)
  1L
})
quit(save = "no", status = Status)
