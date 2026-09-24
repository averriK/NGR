# Private contract between the master, Pandoc and the CAN compositor.
.docxSpec <- function(frontmatter) {
  Fields <- c("client", "company", "project", "date")
  if (!is.list(frontmatter$srk) || !setequal(names(frontmatter$srk), Fields)) {
    stop("DOCX master requires srk.client, srk.company, srk.project and srk.date (issue date).", call. = FALSE)
  }
  Values <- c(list(title = frontmatter$title), frontmatter$srk)
  for (Name in names(Values)) {
    x <- Values[[Name]]
    if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(trimws(x)) || grepl("[[:cntrl:]]", x)) {
      stop("DOCX metadata must be a non-empty single-line string: ", Name, call. = FALSE)
    }
  }
  Cover <- list(title = Values$title, client = Values$client, company = Values$company,
                issue = Values$project, date = Values$date)
  list(cover = Cover, headerFooter = Values[c("title", "date", "project", "company")], appendices = list())
}

.docxAppendices <- function(frontmatter) {
  OUT <- list()
  for (FILE in .quartoChapterFiles(frontmatter$appendices)) {
    Path <- normalizePath(FILE, winslash = "/", mustWork = TRUE)
    Root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
    if (!startsWith(Path, paste0(Root, "/"))) {
      stop("Appendix resolves outside the staged project: ", FILE, call. = FALSE)
    }
    Json <- tempfile("ngr-appendix-", fileext = ".json")
    on.exit(unlink(Json), add = TRUE)
    .runRenderCommand("quarto", args = c("pandoc", FILE, "--from", "markdown", "--to", "json", "--output", Json))
    DATA <- jsonlite::fromJSON(Json, simplifyVector = FALSE)$blocks
    Headers <- Filter(function(x) identical(x$t, "Header") && identical(x$c[[1L]], 1L), DATA)
    if (length(Headers) != 1L || !nzchar(Headers[[1L]]$c[[2L]][[1L]])) {
      stop("Each appendix file requires one level-1 heading with an identifier: ", FILE, call. = FALSE)
    }
    if ("unnumbered" %in% unlist(Headers[[1L]]$c[[2L]][[2L]])) {
      stop("Appendix heading must be numbered so Quarto can resolve its letter and references: ", FILE, call. = FALSE)
    }
    OUT[[length(OUT) + 1L]] <- list(bookmark = Headers[[1L]]$c[[2L]][[1L]])
    unlink(Json)
  }
  Ids <- vapply(OUT, function(x) x$bookmark, character(1L))
  if (anyDuplicated(Ids)) stop("Appendix heading identifiers must be unique.", call. = FALSE)
  OUT
}

.docxProfile <- function(profile, module, python) {
  Reference <- profile$format$docx$`reference-doc`
  if (!is.character(Reference) || length(Reference) != 1L || !nzchar(Reference)) {
    stop("DOCX profile requires an explicit CAN-compatible reference-doc.", call. = FALSE)
  }
  Filters <- unlist(profile$format$docx$filters, use.names = FALSE)
  if (any(grepl("(^|/)appendix-style[.]lua$", Filters))) {
    stop("The DOCX profile still uses appendix-style.lua. Migrate yml/_quarto-docx.yml before rendering CAN.", call. = FALSE)
  }
  .runRenderCommand(python, args = c(module, "check-reference", "--reference", Reference))
  if (!isTRUE(profile$format$docx$`number-sections`)) {
    stop("CAN DOCX requires number-sections: true; Quarto owns heading and cross-reference numbers.", call. = FALSE)
  }
  profile$format$docx$filters <- c(profile$format$docx$filters, list(
    list(at = "pre-quarto", path = system.file("docx", "styles.lua", package = "NGR", mustWork = TRUE)),
    list(at = "post-quarto", path = system.file("docx", "layout.lua", package = "NGR", mustWork = TRUE))))
  profile
}
