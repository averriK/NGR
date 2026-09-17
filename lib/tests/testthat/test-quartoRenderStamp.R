test_that("publication stamps reflect per-file provenance without writing inputs", {
  Root <- tempfile("ngr-stamp-")
  dir.create(Root)
  on.exit(unlink(Root, recursive = TRUE), add = TRUE)
  FILE <- file.path(Root, "chapter.qmd")
  writeLines("chapter", FILE)
  Digest <- unname(tools::md5sum(FILE))
  Entry <- list(commit = "abcdef0123456789", dirty = FALSE, md5 = Digest)
  Manifest <- list(scaffolds = list(book = list(
    complete = TRUE, files = list("chapter.qmd" = Entry)
  )))
  Prefix <- paste0("Pub: ", format(Sys.Date(), "%d/%m/%Y"), " Rev.")
  expect_message(
    Stamp <- NGR::quartoRenderStamp(Manifest, root = Root),
    "Render timestamp:"
  )
  expect_identical(Stamp, paste0(Prefix, "abcdef0"))
  expect_identical(unname(tools::md5sum(FILE)), Digest)

  Manifest$scaffolds$book$files[["chapter.qmd"]]$dirty <- TRUE
  expect_identical(suppressMessages(NGR::quartoRenderStamp(Manifest, root = Root)),
                   paste0(Prefix, "abcdef0 \u00b7 DRAFT"))
  Manifest$scaffolds$book$files[["chapter.qmd"]]$dirty <- FALSE
  writeLines("local change", FILE)
  expect_identical(suppressMessages(NGR::quartoRenderStamp(Manifest, root = Root)),
                   paste0(Prefix, "abcdef0 \u00b7 DRAFT"))
  unlink(FILE)
  expect_identical(suppressMessages(NGR::quartoRenderStamp(Manifest, root = Root)),
                   paste0(Prefix, "abcdef0 \u00b7 DRAFT"))
})

test_that("mixed revisions are sorted and unknown coverage remains a draft", {
  Root <- tempfile("ngr-stamp-")
  dir.create(Root)
  on.exit(unlink(Root, recursive = TRUE), add = TRUE)
  FILE <- file.path(Root, "chapter.qmd")
  writeLines("chapter", FILE)
  Entry <- list(commit = "abcdef0123456789", dirty = FALSE,
                md5 = unname(tools::md5sum(FILE)))
  Manifest <- list(scaffolds = list(
    book = list(complete = TRUE, files = list("chapter.qmd" = Entry)),
    supplement = list(complete = TRUE, files = list("chapter.qmd" = Entry))
  ))
  Manifest$scaffolds$supplement$files[["chapter.qmd"]]$commit <- "123456789abcdef"
  Prefix <- paste0("Pub: ", format(Sys.Date(), "%d/%m/%Y"), " Rev.")
  expect_identical(suppressMessages(NGR::quartoRenderStamp(Manifest, root = Root)),
                   paste0(Prefix, "1234567 / abcdef0"))
  Manifest$scaffolds$book$complete <- FALSE
  expect_identical(suppressMessages(NGR::quartoRenderStamp(Manifest, root = Root)),
                   paste0(Prefix, "1234567 / abcdef0 / \u2014 \u00b7 DRAFT"))
  expect_identical(suppressMessages(NGR::quartoRenderStamp(list(), root = Root)),
                   paste0(Prefix, "\u2014 \u00b7 DRAFT"))
})

test_that("invalid provenance and escaping paths fail before use", {
  Root <- tempfile("ngr-stamp-")
  dir.create(Root)
  on.exit(unlink(Root, recursive = TRUE), add = TRUE)
  Entry <- list(commit = "abcdef0123456789", dirty = FALSE,
                md5 = "d41d8cd98f00b204e9800998ecf8427e")
  Manifest <- list(scaffolds = list(book = list(
    complete = TRUE, files = list("chapter.qmd" = Entry)
  )))
  Manifest$scaffolds$book$files[["chapter.qmd"]]$commit <- "invalid"
  expect_error(NGR::quartoRenderStamp(Manifest, root = Root),
               "Invalid scaffold provenance for chapter.qmd", fixed = TRUE)
  Manifest$scaffolds$book$files <- list("../outside.qmd" = Entry)
  expect_error(NGR::quartoRenderStamp(Manifest, root = Root),
               "Scaffold path escapes the project: ../outside.qmd", fixed = TRUE)
  Manifest$scaffolds$book$files <- list("/outside.qmd" = Entry)
  expect_error(NGR::quartoRenderStamp(Manifest, root = Root),
               "Scaffold path escapes the project: /outside.qmd", fixed = TRUE)
})
