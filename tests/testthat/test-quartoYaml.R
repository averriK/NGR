test_that("quartoReadFrontmatter reads qrt-style manifest fields", {
  Fixture <- testthat::test_path("fixtures", "qrt-yaml")
  Frontmatter <- quartoReadFrontmatter(file.path(Fixture, "book-single.qmd"))

  expect_identical(Frontmatter$title, "Single Chapter")
  expect_identical(Frontmatter$chapters, "_chapters/intro.qmd")
  expect_identical(Frontmatter$bibliography, "bib/references.bib")
  expect_true(quartoHasBookManifest(Frontmatter))
})

test_that("quartoReadFrontmatter returns empty list for non-manifest files", {
  Fixture <- testthat::test_path("fixtures", "qrt-yaml")

  expect_identical(quartoReadFrontmatter(file.path(Fixture, "plain.qmd")), list())
  expect_false(quartoHasBookManifest(quartoReadFrontmatter(file.path(Fixture, "title-only.qmd"))))
})

test_that("quartoMergeBookManifest preserves single-entry sequences", {
  Fixture <- testthat::test_path("fixtures", "qrt-yaml")
  Base <- yaml::read_yaml(file.path(Fixture, "base.yml"))
  Manifest <- quartoReadFrontmatter(file.path(Fixture, "book-single.qmd"))
  Merged <- quartoMergeBookManifest(Base, Manifest)

  expect_true(is.list(Merged$book$chapters))
  expect_length(Merged$book$chapters, 1)
  expect_identical(Merged$book$chapters[[1]], "_chapters/intro.qmd")
  expect_true(is.list(Merged$project$render))
  expect_identical(Merged$project$render[[1]], "_chapters/intro.qmd")

  Yaml <- quartoAsYaml(Merged)
  expect_match(Yaml, "preview: false", fixed = TRUE)
  expect_match(Yaml, "echo: true", fixed = TRUE)
  expect_match(Yaml, "chapters:\n    - _chapters/intro.qmd")
  expect_match(Yaml, "render:\n    - _chapters/intro.qmd")
  expect_false(grepl(": yes($|\\n)|: no($|\\n)", Yaml))
})

test_that("quartoMergeBookManifest merges chapters, appendices, and bibliography", {
  Fixture <- testthat::test_path("fixtures", "qrt-yaml")
  Base <- yaml::read_yaml(file.path(Fixture, "base.yml"))
  Manifest <- quartoReadFrontmatter(file.path(Fixture, "book-multi.qmd"))
  Merged <- quartoMergeBookManifest(Base, Manifest)

  expect_identical(Merged$book$title, "Multi Chapter")
  expect_equal(unlist(Merged$book$chapters, use.names = FALSE), c(
    "_chapters/intro.qmd",
    "_chapters/methods.qmd"
  ))
  expect_equal(unlist(Merged$book$appendices, use.names = FALSE), "_appendices/data.qmd")
  expect_equal(unlist(Merged$project$render, use.names = FALSE), c(
    "_chapters/intro.qmd",
    "_chapters/methods.qmd",
    "_appendices/data.qmd"
  ))
  expect_equal(Merged$bibliography, c("bib/main.bib", "bib/extra.bib"))
})

test_that("quartoSetProjectRender sets render targets without touching other fields", {
  Fixture <- testthat::test_path("fixtures", "qrt-yaml")
  Base <- yaml::read_yaml(file.path(Fixture, "base.yml"))
  Rendered <- quartoSetProjectRender(Base, "report.qmd")

  expect_identical(Rendered$project$type, "default")
  expect_true(is.list(Rendered$project$render))
  expect_identical(Rendered$project$render[[1]], "report.qmd")
})

test_that("quartoDocxBookProfile sets book type and validates docx format", {
  Fixture <- testthat::test_path("fixtures", "qrt-yaml")
  Profile <- yaml::read_yaml(file.path(Fixture, "docx.yml"))
  Out <- quartoDocxBookProfile(Profile)

  expect_identical(Out$project$type, "book")
  expect_true(Out$format$docx$toc)
  expect_false(Out$format$docx$`number-sections`)

  Bad <- yaml::read_yaml(file.path(Fixture, "docx-missing-format.yml"))
  expect_error(quartoDocxBookProfile(Bad), "format.docx")
})

test_that("quartoWriteYaml returns or writes exact YAML text", {
  X <- list(project = list(preview = FALSE, render = list("report.qmd")))
  Text <- quartoWriteYaml(X)
  File <- tempfile("ngr-quarto-yaml-", fileext = ".yml")

  expect_match(Text, "preview: false", fixed = TRUE)
  expect_match(Text, "render:\n    - report.qmd")
  quartoWriteYaml(X, File)
  expect_identical(readChar(File, file.info(File)$size), Text)
})
