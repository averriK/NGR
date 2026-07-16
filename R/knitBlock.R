# nolint start
#' Knit a QMD block with dynamic labels
#'
#' Reads a QMD fragment, expands Quarto include shortcodes recursively, rewrites
#' static figure/table labels with a caller-provided stem, and emits the result
#' through `knitr::knit_child()`. The default `labels = "parent"` rewrites
#' labels in the requested block and strips labels/captions from recursively
#' included child blocks.
#'
#' @param path Character scalar. QMD fragment path. Absolute paths are used as
#'   supplied; paths starting with `/` are resolved below `root`.
#' @param stem Character scalar or vector used to prefix labels when
#'   `labels = "rewrite"`.
#' @param vars Named list of variables visible to the child document.
#' @param labels One of `"parent"`, `"rewrite"`, `"strip"`, or `"keep"`.
#'   `"parent"` rewrites labels in `path` and strips labels/captions from
#'   included child blocks.
#' @param root Project root used to resolve absolute-looking include paths.
#'
#' @return Invisibly returns the knitted child markdown. The markdown is also
#'   emitted with `cat()` for use in `results: asis` chunks.
#' @export
knitBlock <- function(path, stem, vars = list(),
                      labels = c("parent", "rewrite", "strip", "keep"), root = getwd()) {
  labels <- match.arg(labels)
  Names <- names(vars)
  if (length(vars) && (is.null(Names) || any(!nzchar(Names)))) {
    stop("knitBlock: vars must be a named list.", call. = FALSE)
  }
  File <- .qmdBlockPath(path, root)
  ChildLabels <- if (labels == "parent") "strip" else "keep"
  Lines <- .qmdExpandIncludes(readLines(File, warn = FALSE), root, File, ChildLabels)
  if (labels %in% c("parent", "rewrite")) Lines <- .qmdRewriteLabels(Lines, stem)
  if (labels == "strip") Lines <- .qmdStripLabels(Lines)
  .qmdCheckLabels(Lines, basename(File), register = TRUE)
  Env <- knitr::knit_global()
  Restore <- .qmdOverlayVars(vars, Env)
  on.exit(Restore(), add = TRUE)
  OUT <- knitr::knit_child(text = Lines, envir = Env, quiet = TRUE)
  cat(OUT, sep = "\n")
  invisible(OUT)
}

.qmdOverlayVars <- function(vars, envir) {
  Names <- names(vars)
  Old <- vector("list", length(Names))
  names(Old) <- Names
  Had <- setNames(logical(length(Names)), Names)
  for (Name in Names) {
    Had[[Name]] <- exists(Name, envir = envir, inherits = FALSE)
    if (Had[[Name]]) Old[[Name]] <- get(Name, envir = envir, inherits = FALSE)
    assign(Name, vars[[Name]], envir = envir)
  }
  function() {
    for (Name in rev(Names)) {
      if (Had[[Name]]) assign(Name, Old[[Name]], envir = envir)
      else rm(list = Name, envir = envir)
    }
  }
}

.qmdBlockPath <- function(path, root) {
  Path <- as.character(path)
  if (length(Path) != 1L || !nzchar(Path)) {
    stop("knitBlock: path must be one non-empty value.", call. = FALSE)
  }
  Path <- sub("^['\"]|['\"]$", "", Path)
  if (startsWith(Path, "/")) Path <- file.path(root, sub("^/+", "", Path))
  else if (!file.exists(Path)) Path <- file.path(root, Path)
  normalizePath(Path, mustWork = TRUE)
}

.qmdCleanStem <- function(stem) {
  Stem <- paste(as.character(stem), collapse = "-")
  Stem <- gsub("[^A-Za-z0-9_.-]+", "-", Stem)
  Stem <- gsub("(^[-.]+|[-.]+$)", "", Stem)
  if (!nzchar(Stem)) stop("knitBlock: stem is empty.", call. = FALSE)
  Stem
}

.qmdLabelValues <- function(lines) {
  Pattern <- "^\\s*#\\|\\s*(label|fig-label|tbl-label):\\s*['\"]?([^'\"[:space:]]+)['\"]?.*$"
  Lines <- lines[grepl(Pattern, lines)]
  if (!length(Lines)) return(character())
  sub(Pattern, "\\2", Lines)
}

.qmdRewriteLabel <- function(label, stem) {
  Label <- as.character(label)
  Stem <- .qmdCleanStem(stem)
  if (grepl("^(fig|tbl)-", Label)) {
    return(sub("^([[:alpha:]]+)-", paste0("\\1-", Stem, "-"), Label))
  }
  paste0(Stem, "-", Label)
}

.qmdRewriteLabels <- function(lines, stem) {
  Pattern <- "^(\\s*#\\|\\s*(label|fig-label|tbl-label):\\s*)(['\"]?)([^'\"[:space:]]+)(['\"]?)(.*)$"
  Lines <- lines
  Sel <- grepl(Pattern, Lines)
  if (!any(Sel)) return(Lines)
  Parts <- regmatches(Lines[Sel], regexec(Pattern, Lines[Sel]))
  Lines[Sel] <- vapply(Parts, function(x) {
    paste0(x[2], x[4], .qmdRewriteLabel(x[5], stem), x[6], x[7])
  }, character(1))
  Lines
}

.qmdStripLabels <- function(lines) {
  Pattern <- "^\\s*#\\|\\s*(label|fig-label|tbl-label|fig-cap|tbl-cap):"
  lines[!grepl(Pattern, lines)]
}

.qmdCheckLabels <- function(lines, context = "dynamic QMD block", register = FALSE) {
  Labels <- .qmdLabelValues(lines)
  Dups <- unique(Labels[duplicated(Labels)])
  if (length(Dups)) {
    stop(sprintf(
      "%s: duplicate labels after rewrite: %s.",
      context, paste(Dups, collapse = ", ")
    ), call. = FALSE)
  }
  if (register && length(Labels)) .qmdRegisterLabels(Labels, context)
  invisible(Labels)
}

.qmdRegisterLabels <- function(labels, context) {
  Input <- knitr::current_input()
  if (is.null(Input)) Input <- ""
  if (nzchar(Input)) Input <- normalizePath(Input, mustWork = FALSE)
  Env <- knitr::knit_global()
  Used <- if (exists(".NGRLabels", envir = Env, inherits = FALSE)) {
    get(".NGRLabels", envir = Env, inherits = FALSE)
  } else {
    character()
  }
  if (!identical(attr(Used, "input"), Input)) Used <- character()
  Hit <- intersect(labels, Used)
  if (length(Hit)) {
    stop(sprintf(
      "%s: labels already emitted: %s.",
      context, paste(Hit, collapse = ", ")
    ), call. = FALSE)
  }
  Used <- unique(c(Used, labels))
  attr(Used, "input") <- Input
  assign(".NGRLabels", Used, envir = Env)
}

.qmdExpandIncludes <- function(lines, root, seen = character(),
                               childLabels = c("keep", "strip")) {
  childLabels <- match.arg(childLabels)
  Pattern <- "^\\s*\\{\\{<\\s+include\\s+([^ >]+)\\s+>\\}\\}\\s*$"
  OUT <- character()
  for (Line in lines) {
    Parts <- regmatches(Line, regexec(Pattern, Line))[[1]]
    if (!length(Parts)) {
      OUT <- c(OUT, Line)
      next
    }
    File <- .qmdBlockPath(Parts[2], root)
    if (File %in% seen) stop(sprintf("recursive include: %s.", File), call. = FALSE)
    Child <- readLines(File, warn = FALSE)
    if (childLabels == "strip") Child <- .qmdStripLabels(Child)
    OUT <- c(OUT, .qmdExpandIncludes(Child, root, c(seen, File), childLabels))
  }
  OUT
}
