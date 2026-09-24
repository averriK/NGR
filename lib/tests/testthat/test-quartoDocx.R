test_that("DOCX metadata is explicit and mapped from the master", {
  Spec <- getFromNamespace(".docxSpec", "NGR")
  Master <- list(title = "Formato de informes SRK", srk = list(
    client = "Verificación del formato documental", company = "SRK Consulting (Argentina) S.A.",
    project = "NGR", date = "Septiembre 2026"))
  OUT <- Spec(Master)
  expect_identical(OUT$cover$issue, Master$srk$project)
  expect_identical(OUT$headerFooter$date, Master$srk$date)
  expect_identical(OUT$appendices, list())
  expect_error(Spec(list(title = Master$title)), "requires srk")
  for (Name in names(Master$srk)) {
    DATA <- Master
    DATA$srk[[Name]] <- NULL
    expect_error(Spec(DATA), "requires srk")
    DATA$srk[[Name]] <- ""
    expect_error(Spec(DATA), "non-empty")
  }
  Master$title <- NULL
  expect_error(Spec(Master), "title")
})

test_that("appendix identity uses Pandoc and flattens part entries", {
  skip_if(!nzchar(Sys.which("quarto")))
  Root <- tempfile("ngr-appendices-")
  dir.create(Root)
  Directory <- getwd()
  on.exit({setwd(Directory); unlink(Root, recursive = TRUE)}, add = TRUE)
  setwd(Root)
  writeLines("# Catálogo de objetos {#sec-apx-a}", "a.qmd")
  writeLines("# Tablas y notas {#sec-apx-b}", "b.qmd")
  Appendices <- getFromNamespace(".docxAppendices", "NGR")
  Master <- list(appendices = list(list(part = "Apéndices", chapters = list("a.qmd", "b.qmd"))))
  expect_identical(Appendices(Master), list(list(bookmark = "sec-apx-a"), list(bookmark = "sec-apx-b")))
  expect_identical(Appendices(list()), list())
  writeLines("# Tablas y notas {#sec-apx-a}", "b.qmd")
  expect_error(Appendices(Master), "unique")
  writeLines("# Tablas y notas {.unnumbered}", "b.qmd")
  expect_error(Appendices(Master), "must be numbered")
  writeLines(c("# One", "# Two"), "b.qmd")
  expect_error(Appendices(Master), "one level-1")
})

test_that("installed DOCX API composes a single master and fails without replacing output", {
  skip_if(!nzchar(Sys.which("quarto")))
  Root <- tempfile("ngr docx á ")
  dir.create(Root)
  on.exit(unlink(Root, recursive = TRUE), add = TRUE)
  dir.create(file.path(Root, "yml"))
  dir.create(file.path(Root, "styles"))
  dir.create(file.path(Root, "_master"))
  file.copy(system.file("docx", "reference.docx", package = "NGR", mustWork = TRUE),
            file.path(Root, "styles/reference.docx"))
  writeLines("project: {type: default}", file.path(Root, "yml/_quarto.yml"))
  writeLines(c("format:", "  docx:", "    reference-doc: styles/reference.docx", "    number-sections: true"),
             file.path(Root, "yml/_quarto-docx.yml"))
  Master <- c("---", "title: Formato de informes SRK", "srk:",
    "  client: Verificación del formato documental", "  company: SRK Consulting (Argentina) S.A.",
    "  project: NGR", "  date: Septiembre 2026", "---", "", "# Results", "", "A render sentinel.")
  Input <- file.path(Root, "_master/document.qmd")
  writeLines(Master, Input)
  Directory <- getwd()
  Stamp <- Sys.getenv("NGR_RENDER_STAMP", unset = NA_character_)
  Stage <- list.files(tempdir(), pattern = "^ngr-render-")
  Before <- tools::md5sum(Input)
  OUT <- NGR::quartoRender("_master/document.qmd", profile = "docx", root = Root, args = "--quiet")
  Output <- file.path(Root, "docx/document.docx")
  expect_true(normalizePath(Output, winslash = "/") %in% OUT)
  expect_identical(tools::md5sum(Input), Before)
  Parts <- unzip(Output, list = TRUE)$Name
  expect_true("word/srk-composition.json" %in% Parts)
  Connection <- unz(Output, "word/srk-composition.json")
  DATA <- jsonlite::fromJSON(paste(readLines(Connection), collapse = "\n"))
  close(Connection)
  expect_length(DATA$appendices, 0L)
  expect_true(DATA$titleRemoved)
  Hash <- tools::md5sum(Output)
  # A real unsupported body section fails in Python after Quarto has rendered.
  writeLines(c(Master, "", "```{=openxml}", "<w:p><w:pPr><w:sectPr/></w:pPr></w:p>", "```"), Input)
  expect_error(NGR::quartoRender("_master/document.qmd", profile = "docx", root = Root, args = "--quiet"), "failed with status")
  expect_identical(tools::md5sum(Output), Hash)
  expect_identical(getwd(), Directory)
  expect_identical(Sys.getenv("NGR_RENDER_STAMP", unset = NA_character_), Stamp)
  expect_identical(list.files(tempdir(), pattern = "^ngr-render-"), Stage)
  writeLines(Master, Input)
  testthat::local_mocked_bindings(.runRenderCommand = function(command, args) stop("Python dependency absent"), .package = "NGR")
  expect_error(NGR::quartoRender("_master/document.qmd", profile = "docx", root = Root), "Python dependency absent")
  expect_identical(tools::md5sum(Output), Hash)
  expect_identical(getwd(), Directory)
  expect_identical(Sys.getenv("NGR_RENDER_STAMP", unset = NA_character_), Stamp)
  expect_identical(list.files(tempdir(), pattern = "^ngr-render-"), Stage)
})

test_that("DOCX delivery retains the previous file when the sibling copy fails", {
  Root <- tempfile("ngr-replace-")
  dir.create(Root)
  on.exit(unlink(Root, recursive = TRUE), add = TRUE)
  Target <- file.path(Root, "report.docx")
  writeLines("previous output", Target)
  expect_error(getFromNamespace(".replaceResource", "NGR")(
    from = file.path(Root, "missing.docx"), to = Target), "Cannot replace")
  expect_identical(readLines(Target), "previous output")
  expect_identical(list.files(Root, all.files = TRUE, no.. = TRUE), "report.docx")
})
