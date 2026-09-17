resourceFixture <- function() {
  Root <- tempfile("resources-")
  dir.create(Root)
  Project <- file.path(Root, "project with spaces")
  Source <- file.path(Root, "source with spaces")
  dir.create(Project)
  dir.create(Source)
  writeLines("one", file.path(Source, "first.txt"))
  writeLines("two", file.path(Source, "second.txt"))
  Manifest <- file.path(Source, "manifest.json")
  jsonlite::write_json(list(schemaVersion = 1L, id = "fixture", resources = list(
    list(from = "first.txt", to = "nested/first.txt", ownership = "managed"),
    list(from = "second.txt", to = "nested/second.txt", ownership = "managed")
  )), Manifest, auto_unbox = TRUE)
  list(root = Root, project = Project, source = Source, manifest = Manifest)
}

test_that("public resource operations preserve receipt shapes and project metadata", {
  Fixture <- resourceFixture()
  on.exit(unlink(Fixture$root, recursive = TRUE), add = TRUE)
  Result <- pullResources(from = Fixture$manifest, root = Fixture$project, dryRun = TRUE)
  expect_identical(Result$actions$action, c("create", "create"))
  expect_length(list.files(Fixture$project, all.files = TRUE, no.. = TRUE), 0L)
  pullResources(from = Fixture$manifest, root = Fixture$project)
  Manifest <- file.path(Fixture$project, "manifest.json")
  Project <- jsonlite::fromJSON(Manifest, simplifyVector = FALSE)
  expect_identical(Project$artifacts, list())
  expect_identical(Project$scaffolds$fixture$selection, list())
  expect_identical(Project$scaffolds$fixture$checks, list())
  Project$owner <- list(unused = NULL, precision = 1.12345678901234,
                         nested = list(array = list("x"), object = stats::setNames(list(), character())))
  jsonlite::write_json(Project, Manifest, auto_unbox = TRUE, digits = NA, null = "null")
  pullResources(root = Fixture$project)
  Result <- jsonlite::fromJSON(Manifest, simplifyVector = FALSE)
  expect_identical(Result$owner, Project$owner)
  expect_identical(Result$scaffolds$fixture$files, Project$scaffolds$fixture$files)
  expect_false(compareResources(root = Fixture$project)$changed)
})

test_that("a failed write restores all project bytes and leaves inputs intact", {
  Fixture <- resourceFixture()
  on.exit(unlink(Fixture$root, recursive = TRUE), add = TRUE)
  pullResources(from = Fixture$manifest, root = Fixture$project)
  Paths <- list.files(Fixture$project, recursive = TRUE, full.names = TRUE)
  Before <- tools::md5sum(Paths)
  writeLines("changed", file.path(Fixture$source, "first.txt"))
  writeLines("changed too", file.path(Fixture$source, "second.txt"))
  Replace <- .replaceResource
  local_mocked_bindings(.package = "NGR", .replaceResource = function(from, to) {
    if (basename(to) == "second.txt") stop("injected write failure")
    Replace(from = from, to = to)
  })
  expect_error(pullResources(root = Fixture$project, force = TRUE), "injected write failure")
  expect_identical(tools::md5sum(Paths), Before)
  expect_identical(list.files(Fixture$project, recursive = TRUE, full.names = TRUE), Paths)
  expect_identical(readLines(file.path(Fixture$source, "first.txt")), "changed")
})

test_that("failed incorporation removes only newly created paths", {
  Fixture <- resourceFixture()
  on.exit(unlink(Fixture$root, recursive = TRUE), add = TRUE)
  writeLines("keep", file.path(Fixture$project, "extra.txt"))
  Replace <- .replaceResource
  local_mocked_bindings(.package = "NGR", .replaceResource = function(from, to) {
    if (basename(to) == "second.txt") stop("injected write failure")
    Replace(from = from, to = to)
  })
  expect_error(pullResources(from = Fixture$manifest, root = Fixture$project), "injected write failure")
  expect_identical(list.files(Fixture$project, all.files = TRUE, no.. = TRUE), "extra.txt")
  expect_identical(readLines(file.path(Fixture$project, "extra.txt")), "keep")
})

test_that("declared checks use argument vectors and restore the caller directory", {
  Fixture <- resourceFixture()
  on.exit(unlink(Fixture$root, recursive = TRUE), add = TRUE)
  Manifest <- jsonlite::fromJSON(Fixture$manifest, simplifyVector = FALSE)
  Script <- file.path(Fixture$root, "check resources.R")
  writeLines('stopifnot(file.exists("nested/first.txt"), identical(commandArgs(TRUE), "a b;$(bad)"))', Script)
  Manifest$checks <- list(list(file.path(R.home("bin"), "Rscript"), Script, "a b;$(bad)"))
  jsonlite::write_json(Manifest, Fixture$manifest, auto_unbox = TRUE)
  pullResources(from = Fixture$manifest, root = Fixture$project)
  WD <- getwd()
  expect_message(Result <- checkResources(root = Fixture$project), "fixture")
  expect_identical(Result[[1L]]$status, 0L)
  expect_identical(getwd(), WD)
  writeLines('stop("declared failure")', Script)
  expect_error(suppressMessages(checkResources(root = Fixture$project)), "Source check failed")
  expect_identical(getwd(), WD)
})

test_that("Unicode claims and exact artifact metadata follow source compatibility", {
  Fixture <- resourceFixture()
  on.exit(unlink(Fixture$root, recursive = TRUE), add = TRUE)
  Manifest <- jsonlite::fromJSON(Fixture$manifest, simplifyVector = FALSE)
  Manifest$resources[[1L]]$to <- "stra\u00dfe.txt"
  Manifest$resources[[2L]]$to <- "STRASSE.txt"
  jsonlite::write_json(Manifest, Fixture$manifest, auto_unbox = TRUE)
  expect_error(pullResources(from = Fixture$manifest, root = Fixture$project), "Source conflict")
  expect_length(list.files(Fixture$project, all.files = TRUE, no.. = TRUE), 0L)
  expect_true(.sameResourceValue(list(a = list(x = 1, y = "z")), list(a = list(y = "z", x = 1))))
  expect_false(.sameResourceValue(list(x = 1), list(x = 1 + 1e-12)))
  expect_false(.sameResourceValue(list(), stats::setNames(list(), character())))
})
