#' Resolve the publication stamp from scaffold provenance
#'
#' Aggregates the per-file revisions recorded in a project manifest and checks
#' those files against their recorded MD5 digests. The stamp describes all
#' registered scaffolds, not only the files used by one rendered artifact.
#' Missing or modified files, dirty revisions and unknown provenance mark the
#' result as a draft. This function reads files without changing them.
#'
#' @param manifest Parsed project manifest as a list. An empty list represents
#'   a project without recorded scaffold provenance.
#' @param root Project directory containing the recorded relative file paths.
#'   Defaults to the current working directory.
#'
#' @return A character scalar with the publication date, sorted abbreviated
#'   revisions and, when applicable, a `DRAFT` marker. The current local time
#'   supplies the date and is also reported through a message condition.
#' @export
quartoRenderStamp <- function(manifest, root = getwd()) {
  Root <- normalizePath(root, winslash = "/")
  Revisions <- list()
  for (Source in manifest$scaffolds) {
    if (!isTRUE(Source$complete)) Revisions$unknown <- FALSE
    for (FILE in names(Source$files)) {
      if (startsWith(FILE, "/") || ".." %in% strsplit(FILE, "/", fixed = TRUE)[[1L]]) {
        stop("Scaffold path escapes the project: ", FILE, call. = FALSE)
      }
      Entry <- Source$files[[FILE]]
      if (!is.character(Entry$commit) || length(Entry$commit) != 1L ||
          !grepl("^([0-9a-f]{7,64}|unknown)$", Entry$commit) ||
          !is.logical(Entry$dirty) || length(Entry$dirty) != 1L ||
          !is.character(Entry$md5) || length(Entry$md5) != 1L ||
          !grepl("^[0-9a-f]{32}$", Entry$md5)) {
        stop("Invalid scaffold provenance for ", FILE, call. = FALSE)
      }
      Path <- file.path(Root, FILE)
      Modified <- TRUE
      if (file.exists(Path)) {
        Path <- normalizePath(Path, winslash = "/")
        if (!startsWith(Path, paste0(Root, "/"))) {
          stop("Scaffold path escapes the project: ", FILE, call. = FALSE)
        }
        Modified <- !identical(unname(tools::md5sum(Path)), Entry$md5)
      }
      Revisions[[Entry$commit]] <- isTRUE(Revisions[[Entry$commit]]) || Entry$dirty || Modified
    }
  }
  if (!length(Revisions)) Revisions$unknown <- FALSE
  Draft <- any(unlist(Revisions)) || "unknown" %in% names(Revisions)
  Revisions <- vapply(sort(names(Revisions)), function(commit) {
    if (commit == "unknown") return("\u2014")
    substr(commit, 1L, 7L)
  }, character(1L))
  Timestamp <- Sys.time()
  message("Render timestamp: ", format(Timestamp, "%Y-%m-%d %H:%M:%S %Z"))
  paste0("Pub: ", format(Timestamp, "%d/%m/%Y"), " Rev.", paste(Revisions, collapse = " / "),
      if (Draft) " \u00b7 DRAFT" else "")
}
