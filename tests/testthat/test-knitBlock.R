test_that("knitBlock rewrites labels after expanding includes", {
  Root <- tempfile("ngr-knit-block-")
  dir.create(file.path(Root, "_tbl"), recursive = TRUE)
  writeLines(c(
    "```{r}",
    "#| label: tbl-child",
    "#| tbl-cap: \"Child\"",
    "knitr::kable(data.frame(x = X))",
    "```"
  ), file.path(Root, "_tbl", "child.qmd"))
  writeLines(c(
    "{{< include /_tbl/child.qmd >}}",
    "```{r}",
    "#| label: fig-parent",
    "cat('parent')",
    "```"
  ), file.path(Root, "_tbl", "mother.qmd"))

  Lines <- NGR:::.qmdExpandIncludes(
    readLines(file.path(Root, "_tbl", "mother.qmd"), warn = FALSE),
    Root
  )
  Lines <- NGR:::.qmdRewriteLabels(Lines, "site-a-model-1")
  Labels <- NGR:::.qmdCheckLabels(Lines)

  expect_identical(Labels, c(
    "tbl-site-a-model-1-child",
    "fig-site-a-model-1-parent"
  ))
})

test_that("knitBlock strips labels from included child blocks in parent mode", {
  Root <- tempfile("ngr-knit-block-")
  dir.create(file.path(Root, "_fig"), recursive = TRUE)
  writeLines(c(
    "```{r}",
    "#| label: fig-child",
    "#| fig-cap: \"Child\"",
    "cat('child')",
    "```"
  ), file.path(Root, "_fig", "child.qmd"))
  writeLines(c(
    "{{< include /_fig/child.qmd >}}",
    "```{r}",
    "#| label: fig-parent",
    "#| fig-cap: \"Parent\"",
    "cat('parent')",
    "```"
  ), file.path(Root, "_fig", "mother.qmd"))

  Lines <- NGR:::.qmdExpandIncludes(
    readLines(file.path(Root, "_fig", "mother.qmd"), warn = FALSE),
    Root,
    childLabels = "strip"
  )
  Lines <- NGR:::.qmdRewriteLabels(Lines, "site-a")

  expect_identical(NGR:::.qmdCheckLabels(Lines), "fig-site-a-parent")
  expect_false(any(grepl("#| fig-cap: \"Child\"", Lines, fixed = TRUE)))
})

test_that("knitBlock strips labels and captions explicitly", {
  Lines <- c(
    "#| label: fig-a",
    "#| fig-label: fig-b",
    "#| tbl-label: tbl-a",
    "#| fig-cap: \"A\"",
    "#| tbl-cap: \"B\"",
    "x <- 1"
  )
  OUT <- NGR:::.qmdStripLabels(Lines)

  expect_identical(OUT, "x <- 1")
})

test_that("knitBlock knits repeated blocks with distinct stems", {
  Root <- tempfile("ngr-knit-block-")
  dir.create(file.path(Root, "_tbl"), recursive = TRUE)
  writeLines(c(
    "```{r}",
    "#| label: tbl-demo",
    "#| tbl-cap: \"Demo\"",
    "knitr::kable(data.frame(x = X))",
    "```"
  ), file.path(Root, "_tbl", "demo.qmd"))
  Text <- c(
    "```{r, results=\"asis\", error=FALSE}",
    "knitBlock(\"/_tbl/demo.qmd\", \"site-a\", vars = list(X = 1), root = Root)",
    "knitBlock(\"/_tbl/demo.qmd\", \"site-b\", vars = list(X = 2), root = Root)",
    "```"
  )

  expect_error(knitr::knit(text = Text, quiet = TRUE), NA)
})

test_that("knitBlock vars are visible to sourced scripts", {
  Root <- tempfile("ngr-knit-block-")
  dir.create(file.path(Root, "_fig"), recursive = TRUE)
  dir.create(file.path(Root, "scripts"), recursive = TRUE)
  writeLines(c(
    "if (!exists(\"siteID_TARGET\")) stop(\"missing siteID_TARGET\", call. = FALSE)",
    "cat(siteID_TARGET)"
  ), file.path(Root, "scripts", "check.R"))
  writeLines(c(
    "```{r}",
    "#| label: fig-check",
    "source(file.path(root, \"scripts\", \"check.R\"))",
    "```"
  ), file.path(Root, "_fig", "check.qmd"))
  Text <- c(
    "```{r, results=\"asis\", error=FALSE}",
    "root <- Root",
    "knitBlock(\"/_fig/check.qmd\", \"site-a\", vars = list(siteID_TARGET = \"SITE_A\"), root = Root)",
    "```"
  )

  OUT <- knitr::knit(text = Text, quiet = TRUE)

  expect_match(OUT, "SITE_A", fixed = TRUE)
})

test_that("knitBlock rejects repeated dynamic labels", {
  Root <- tempfile("ngr-knit-block-")
  dir.create(file.path(Root, "_tbl"), recursive = TRUE)
  writeLines(c(
    "```{r}",
    "#| label: tbl-demo",
    "knitr::kable(data.frame(x = 1))",
    "```"
  ), file.path(Root, "_tbl", "demo.qmd"))

  Text <- c(
    "```{r, results=\"asis\", error=FALSE}",
    "knitBlock(\"/_tbl/demo.qmd\", \"same\", root = Root)",
    "knitBlock(\"/_tbl/demo.qmd\", \"same\", root = Root)",
    "```"
  )

  expect_error(knitr::knit(text = Text, quiet = TRUE), "labels already emitted")
})
