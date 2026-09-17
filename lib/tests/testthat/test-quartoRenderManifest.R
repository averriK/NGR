test_that("batch preflight validates all claims and preserves selection order", {
  Root <- tempfile("ngr-batch-")
  dir.create(Root)
  on.exit(unlink(Root, recursive = TRUE))
  writeLines("# One", file.path(Root, "one.qmd"))
  writeLines("# Two", file.path(Root, "two.qmd"))
  Artifacts <- lapply(c("one", "two"), function(x) list(
    alias = x, kind = "quarto", renderSource = paste0(x, ".qmd"),
    profile = "html", path = paste0("html/", x), required = TRUE
  ))
  Path <- file.path(Root, "manifest.json")
  writeManifest <- function(artifacts, schema = 2) {
    jsonlite::write_json(list(schemaVersion = schema, artifacts = artifacts), Path, auto_unbox = TRUE)
  }
  writeManifest(Artifacts)
  Result <- suppressMessages(quartoRenderManifest(Path, root = Root, only = c("two", "one"), dryRun = TRUE))
  expect_identical(vapply(Result, `[[`, character(1L), "alias"), c("one", "two"))
  Result <- suppressMessages(quartoRenderManifest(Path, root = Root, except = "one", dryRun = TRUE))
  expect_identical(Result[[1L]]$alias, "two")
  expect_error(quartoRenderManifest(Path, root = Root, only = "absent", dryRun = TRUE), "Unknown alias")
  expect_error(quartoRenderManifest(Path, root = Root, only = "one", except = "one", dryRun = TRUE), "No artifacts")
  Artifacts[[2L]]$path <- "html/ONE"
  writeManifest(Artifacts)
  expect_error(quartoRenderManifest(Path, root = Root, only = "one", dryRun = TRUE), "already claimed")
  Artifacts[[2L]]$path <- "outside"
  writeManifest(Artifacts)
  expect_error(quartoRenderManifest(Path, root = Root), "Invalid render output")
  expect_false(dir.exists(file.path(Root, "html")))
  Artifacts[[2L]]$path <- "html/two"
  Artifacts[[2L]]$renderSource <- "missing.qmd"
  writeManifest(Artifacts)
  expect_error(quartoRenderManifest(Path, root = Root), "Missing render source")
  expect_false(dir.exists(file.path(Root, "html")))
  Artifacts[[2L]]$renderSource <- "two.qmd"
  Artifacts <- lapply(Artifacts, function(x) { x$kind <- NULL; x })
  writeManifest(Artifacts, schema = 1)
  expect_length(suppressMessages(quartoRenderManifest(Path, root = Root, dryRun = TRUE)), 2L)
})

test_that("external products are never executed and outputs respect required", {
  Root <- tempfile("ngr-external-")
  dir.create(Root)
  on.exit(unlink(Root, recursive = TRUE))
  Path <- file.path(Root, "manifest.json")
  Artifacts <- list(
    list(alias = "map", kind = "map", renderSource = "absent.py", path = "map", required = TRUE),
    list(alias = "static", kind = "static", path = "static", required = FALSE)
  )
  jsonlite::write_json(list(schemaVersion = 2, artifacts = Artifacts), Path, auto_unbox = TRUE)
  expect_length(suppressMessages(quartoRenderManifest(Path, root = Root, dryRun = TRUE)), 2L)
  expect_error(suppressMessages(quartoRenderManifest(Path, root = Root)), "Missing required output: map")
  dir.create(file.path(Root, "map"))
  writeLines("External product", file.path(Root, "map/index.html"))
  expect_length(suppressMessages(quartoRenderManifest(Path, root = Root)), 2L)
  expect_identical(readLines(file.path(Root, "map/index.html")), "External product")
  Artifacts[[1L]]$required <- "true"
  jsonlite::write_json(list(schemaVersion = 2, artifacts = Artifacts), Path, auto_unbox = TRUE)
  expect_error(quartoRenderManifest(Path, root = Root), "boolean")
  jsonlite::write_json(list(schemaVersion = 2, artifacts = list(map = Artifacts[[2L]])), Path, auto_unbox = TRUE)
  expect_error(quartoRenderManifest(Path, root = Root), "Invalid artifact manifest")
})
