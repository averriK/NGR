#' @importFrom utils file_test
NULL

.cliNgr <- function(args, runtime) {
  if (!length(args) || args[[1L]] %in% c("--help", "-h")) {
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
        "Later pulls use manifest.json. Seeds stay local.\n",
        "--force replaces managed files; incompatible sources always fail.\n", sep = "")
    return(0L)
  }
  Command <- args[[1L]]
  if (Command == "--version") {
    if (length(args) != 1L) stop(errorCondition("--version takes no arguments", class = "ngrUsageError"))
    cat(readLines(file.path(runtime, "VERSION")), sep = "\n")
    return(0L)
  }
  if (Command %in% c("pull", "status", "doctor")) {
    if (Command == "doctor" && !any(args %in% c("--help", "-h"))) {
      message("NGR ", utils::packageVersion("NGR"), " at ", find.package("NGR"))
    }
    return(.cliResources(args, base = file.path(runtime, "scaffold/manifest.json")))
  }
  if (Command == "render") return(.cliRender(args[-1L]))
  if (Command == "deploy") return(.cliDeploy(args[-1L]))
  stop(errorCondition(paste0("Unknown command: ", Command, "; use ngr --help"), class = "ngrUsageError"))
}

.cliRender <- function(args) {
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
    if (Arg == "--dry-run") { DryRun <- TRUE; next }
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
    quartoRenderManifest(Values$manifest,
      only = Filter(nzchar, strsplit(Values$only, ",", fixed = TRUE)[[1L]]),
      except = Filter(nzchar, strsplit(Values$except, ",", fixed = TRUE)[[1L]]), dryRun = DryRun)
    return(0L)
  }
  if (DryRun || nzchar(Values$only) || nzchar(Values$except)) {
    stop("--dry-run/--only/--except require --manifest.", call. = FALSE)
  }
  quartoRender(input = Input, profile = Values$profile, args = Extra)
  0L
}

.cliDeploy <- function(args) {
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
      Name <- if (Arg == "--dry-run") "dryRun" else substring(Arg, 3L)
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
    if (length(Positional) != if (Action == "unbind") 1L else 2L) stop("Missing or extra deploy arguments; see ngr deploy --help.", call. = FALSE)
    if (Action == "unbind") netlifyUnbind(Positional[[1L]])
    if (Action == "init") netlifyRegister(Positional[[1L]], site = Positional[[2L]], create = Flags$create, account = Values$account)
    if (Action == "upload") netlifyDeploy(Positional[[1L]], path = Positional[[2L]], prod = Flags$prod)
    if (Action == "domain") netlifyDomain(Positional[[1L]], domain = Positional[[2L]], https = Flags$https, rebind = Flags$rebind, dryRun = Flags$dryRun)
    return(0L)
  }
  if (length(Positional)) stop("--manifest cannot be combined with positional arguments.", call. = FALSE)
  Artifacts <- .readArtifacts(manifest = Values$manifest, root = getwd())
  Selected <- .selectArtifacts(Artifacts,
    only = Filter(nzchar, strsplit(Values$only, ",", fixed = TRUE)[[1L]]),
    except = Filter(nzchar, strsplit(Values$except, ",", fixed = TRUE)[[1L]]))
  if (Action %in% c("init", "domain")) {
    Field <- if (Action == "init") "siteSlug" else "domain"
    Claims <- unlist(lapply(Artifacts, `[[`, Field), use.names = FALSE)
    if (anyDuplicated(Claims)) stop("Duplicate ", Field, " across manifest.", call. = FALSE)
    if (any(vapply(Selected, function(x) is.null(x[[Field]]), logical(1L)))) {
      stop("Every selected artifact requires ", Field, ".", call. = FALSE)
    }
    Aliases <- vapply(Selected, `[[`, character(1L), "alias")
    Targets <- vapply(Selected, `[[`, character(1L), Field)
    if (Action == "init") netlifyRegister(Aliases, site = Targets, create = Flags$create, account = Values$account, dryRun = Flags$dryRun)
    if (Action == "domain") netlifyDomain(Aliases, domain = Targets, https = Flags$https, dryRun = Flags$dryRun)
    return(0L)
  }
  if (Action == "upload") {
    if (!nzchar(Sys.which("netlify"))) stop("Netlify CLI not found on PATH.", call. = FALSE)
    if (!Flags$dryRun && !file.exists(".netlify/sites.env")) stop("Missing .netlify/sites.env; register aliases first.", call. = FALSE)
    Keep <- logical(length(Selected))
    for (i in seq_along(Selected)) {
      Entry <- Selected[[i]]
      Keep[[i]] <- dir.exists(Entry$path) && file_test("-f", file.path(Entry$path, "index.html"))
      if (Keep[[i]]) next
      if (Entry$required) stop("Missing required static site: ", Entry$alias, ": ", Entry$path, "/index.html", call. = FALSE)
      message("SKIP deploy ", Entry$alias, " optional missing path=", Entry$path)
    }
    Selected <- Selected[Keep]
    if (length(Selected)) netlifyDeploy(
      vapply(Selected, `[[`, character(1L), "alias"),
      path = vapply(Selected, `[[`, character(1L), "path"), prod = Flags$prod, dryRun = Flags$dryRun)
    return(0L)
  }
  stop("Unsupported deploy operation: ", Action, call. = FALSE)
}
