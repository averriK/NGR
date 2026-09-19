test_that("default rendering coexists with an unmigrated qrt.manifest.json", {
  Root <- tempfile("ngr-manifest-")
  dir.create(Root)
  on.exit(unlink(Root, recursive = TRUE), add = TRUE)
  writeLines("{}", file.path(Root, "qrt.manifest.json"))
  for (Both in c(FALSE, TRUE)) {
    if (Both) writeLines("{}", file.path(Root, "manifest.json"))
    Files <- list.files(Root, full.names = TRUE)
    Hashes <- tools::md5sum(Files)
    expect_error(quartoRender("page.qmd", profile = "html", root = Root), "Render input not found")
    expect_identical(list.files(Root, full.names = TRUE), Files)
    expect_identical(tools::md5sum(Files), Hashes)
  }
})

test_that("render staging preserves links, hidden resources and metadata", {
  Root <- tempfile("ngr-copy-")
  dir.create(Root)
  on.exit(fs::dir_delete(Root), add = TRUE)
  Source <- file.path(Root, "source")
  Target <- file.path(Root, "target")
  dir.create(Source)
  dir.create(file.path(Source, "empty"))
  writeLines("resource", file.path(Source, ".resource"))
  Time <- as.POSIXct("2020-01-01", tz = "UTC")
  Sys.setFileTime(file.path(Source, ".resource"), Time)
  Sys.chmod(file.path(Source, ".resource"), "0666", use_umask = FALSE)
  Links <- c(linked = ".resource", broken = "missing", directory = "empty", dangling = "missing-directory")
  if (.Platform$OS.type == "windows") {
    for (Name in names(Links)) {
      expect_identical(system2("python", args = shQuote(c("-c",
        "import os, sys; os.symlink(sys.argv[1], sys.argv[2], target_is_directory=sys.argv[3]=='True')",
        Links[[Name]], file.path(Source, Name), if (Name %in% c("directory", "dangling")) "True" else "False"
      ))), 0L)
    }
  }
  if (.Platform$OS.type != "windows") {
    for (Name in names(Links)) expect_true(file.symlink(from = Links[[Name]], to = file.path(Source, Name)))
  }
  Sys.setFileTime(Source, Time)
  getFromNamespace(".copyRenderPath", "NGR")(from = Source, to = Target)
  expect_identical(readLines(file.path(Target, ".resource")), "resource")
  expect_true(dir.exists(file.path(Target, "empty")))
  expect_identical(as.numeric(file.info(file.path(Target, ".resource"))$mtime), as.numeric(Time))
  expect_identical(as.numeric(file.info(Target)$mtime), as.numeric(Time))
  expect_true(isTRUE(fs::is_link(file.path(Target, "linked"))))
  expect_true(isTRUE(fs::is_link(file.path(Target, "broken"))))
  expect_identical(as.character(fs::link_path(file.path(Target, "linked"))), ".resource")
  expect_identical(as.character(fs::link_path(file.path(Target, "broken"))), "missing")
  for (Name in c("directory", "dangling")) {
    expect_true(isTRUE(fs::is_link(file.path(Target, Name))))
    expect_identical(as.character(fs::link_path(file.path(Target, Name))), Links[[Name]])
  }
  expect_true(dir.exists(file.path(Target, "directory")))
  if (.Platform$OS.type != "windows") {
    expect_identical(file.info(file.path(Target, ".resource"))$mode,
                     file.info(file.path(Source, ".resource"))$mode)
    Sys.chmod(file.path(Source, "empty"), "0000")
    on.exit(Sys.chmod(file.path(Source, "empty"), "0700"), add = TRUE, after = FALSE)
    expect_error(getFromNamespace(".copyRenderPath", "NGR")(
      from = file.path(Source, "empty"), to = file.path(Root, "unreadable")
    ), "Cannot read render directory")
    expect_false(file.exists(file.path(Root, "unreadable")))
  }
  fs::dir_delete(Target)
  expect_false(dir.exists(Target))
  expect_identical(readLines(file.path(Source, ".resource")), "resource")
  expect_true(dir.exists(file.path(Source, "empty")))
})

test_that("the installed API renders without the CLI and preserves output on failure", {
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is required for the render integration check")
  Root <- tempfile("ngr document á ")
  dir.create(Root)
  on.exit(fs::dir_delete(Root), add = TRUE)
  Directory <- getwd()
  Stamp <- Sys.getenv("NGR_RENDER_STAMP", unset = NA_character_)
  on.exit({
    if (is.na(Stamp)) Sys.unsetenv("NGR_RENDER_STAMP")
    if (!is.na(Stamp)) Sys.setenv(NGR_RENDER_STAMP = Stamp)
  }, add = TRUE)
  Sys.setenv(NGR_RENDER_STAMP = "caller stamp")
  dir.create(file.path(Root, "yml"))
  dir.create(file.path(Root, "_master"))
  writeLines(c("project:", "  type: default"), file.path(Root, "yml/_quarto.yml"))
  writeLines(c("format:", "  html:", "    output-file: index.html"),
             file.path(Root, "yml/_quarto-html.yml"))
  writeLines(c("---", "title: Native API", "---", "", "A render sentinel."),
             file.path(Root, "_master/page.qmd"))
  if (.Platform$OS.type == "windows") {
    expect_identical(system2("python", args = shQuote(c("-c",
      "import os, sys; os.symlink('yml', sys.argv[1], target_is_directory=True)",
      file.path(Root, "linked-directory")
    ))), 0L)
  }
  if (.Platform$OS.type != "windows") {
    expect_true(file.symlink(from = "yml", to = file.path(Root, "linked-directory")))
  }
  Source <- unname(tools::md5sum(file.path(Root, "_master/page.qmd")))
  dir.create(file.path(Root, "html/page"), recursive = TRUE)
  writeLines("stale", file.path(Root, "html/page/stale.txt"))
  Stage <- list.files(tempdir(), pattern = "^ngr-render-")
  OUT <- NGR::quartoRender("_master/page.qmd", profile = "html", root = Root, args = "--quiet")
  expect_true(normalizePath(file.path(Root, "html/page/index.html"), winslash = "/") %in% OUT)
  expect_true(all(file.exists(OUT)))
  expect_false(file.exists(file.path(Root, "html/page/stale.txt")))
  expect_match(paste(readLines(file.path(Root, "html/page/index.html"), warn = FALSE), collapse = "\n"), "A render sentinel")
  expect_identical(unname(tools::md5sum(file.path(Root, "_master/page.qmd"))), Source)
  expect_identical(getwd(), Directory)
  expect_identical(Sys.getenv("NGR_RENDER_STAMP"), "caller stamp")
  expect_identical(list.files(tempdir(), pattern = "^ngr-render-"), Stage)
  Output <- unname(tools::md5sum(file.path(Root, "html/page/index.html")))

  expect_error(NGR::quartoRender("_master/page.qmd", profile = "html", root = Root,
                                args = "--ngr-invalid-option"), "failed with status")
  expect_identical(unname(tools::md5sum(file.path(Root, "html/page/index.html"))), Output)
  expect_identical(getwd(), Directory)
  expect_identical(Sys.getenv("NGR_RENDER_STAMP"), "caller stamp")
  expect_identical(list.files(tempdir(), pattern = "^ngr-render-"), Stage)

  writeLines("root master", file.path(Root, "page.qmd"))
  expect_error(NGR::quartoRender("_master/page.qmd", profile = "html", root = Root), "also exists at the project root")
  expect_identical(readLines(file.path(Root, "page.qmd")), "root master")
  expect_identical(unname(tools::md5sum(file.path(Root, "html/page/index.html"))), Output)
  expect_identical(list.files(tempdir(), pattern = "^ngr-render-"), Stage)
  expect_error(NGR::quartoRender("_master/page.qmd", profile = "html", root = Root,
                                output = "html/.."), "Invalid render output")
})
