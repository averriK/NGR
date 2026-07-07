# Knit a QMD block with dynamic labels

Reads a QMD fragment, expands Quarto include shortcodes recursively,
rewrites static figure/table labels with a caller-provided stem, and
emits the result through
[`knitr::knit_child()`](https://rdrr.io/pkg/knitr/man/knit_child.html).
The default `labels = "parent"` rewrites labels in the requested block
and strips labels/captions from recursively included child blocks.

## Usage

``` r
knitBlock(
  path,
  stem,
  vars = list(),
  labels = c("parent", "rewrite", "strip", "keep"),
  root = getwd()
)
```

## Arguments

- path:

  Character scalar. QMD fragment path. Absolute paths are used as
  supplied; paths starting with `/` are resolved below `root`.

- stem:

  Character scalar or vector used to prefix labels when
  `labels = "rewrite"`.

- vars:

  Named list of variables visible to the child document.

- labels:

  One of `"parent"`, `"rewrite"`, `"strip"`, or `"keep"`. `"parent"`
  rewrites labels in `path` and strips labels/captions from included
  child blocks.

- root:

  Project root used to resolve absolute-looking include paths.

## Value

Invisibly returns the knitted child markdown. The markdown is also
emitted with [`cat()`](https://rdrr.io/r/base/cat.html) for use in
`results: asis` chunks.
