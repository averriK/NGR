# Render a table with specified formatting options

This function renders a table using the specified library and formatting
options. It supports three libraries: `flextable`, `gt`, and `kable`.

## Usage

``` r
buildTable(
  .x,
  library = "gt",
  format = "html",
  font.size.header = 14,
  font.size.body = 12,
  font.family.header = "Arial",
  font.family.body = "Arial",
  caption = NULL,
  font.bold.header = TRUE,
  font.bold.body = FALSE,
  font.bold.all = NULL,
  font.size.all = NULL,
  font.family.all = NULL,
  vlines.show = FALSE,
  hlines.show = TRUE,
  vlines.color = "grey",
  hlines.color = "grey",
  vlines.size = 1,
  hlines.size = 1,
  align.header = "center",
  align.body = "left",
  padding.header = 5,
  padding.body = 5,
  padding.all = NULL
)
```

## Arguments

- .x:

  A data frame or data table to be rendered as a table.

- library:

  The library to be used for rendering. Options are `"flextable"`,
  `"gt"`, and `"kable"`.

- format:

  The output format. Options are `"html"`, `"pdf"`, and `"docx"`.

- font.size.header:

  Numeric. Font size for the table header.

- font.size.body:

  Numeric. Font size for the table body.

- font.family.header:

  Character. Font family for the table header.

- font.family.body:

  Character. Font family for the table body.

- caption:

  Character. The table caption.

- font.bold.header:

  Logical. Whether to bold the header font.

- font.bold.body:

  Logical. Whether to bold the body font.

- font.bold.all:

  Logical. If `TRUE`, bolds all text. Overrides `font.bold.header` and
  `font.bold.body`.

- font.size.all:

  Numeric. Font size for all text. Overrides `font.size.header` and
  `font.size.body`.

- font.family.all:

  Character. Font family for all text. Overrides `font.family.header`
  and `font.family.body`.

- vlines.show:

  Logical. Whether to show vertical lines.

- hlines.show:

  Logical. Whether to show horizontal lines.

- vlines.color:

  Character. Color of vertical lines.

- hlines.color:

  Character. Color of horizontal lines.

- vlines.size:

  Numeric. Thickness of vertical lines.

- hlines.size:

  Numeric. Thickness of horizontal lines.

- align.header:

  Character. Alignment of header text. Options are `"center"`, `"left"`,
  `"right"`.

- align.body:

  Character. Alignment of body text. Options are `"center"`, `"left"`,
  `"right"`.

- padding.header:

  Numeric. Vertical cell padding (top and bottom, in pt) for header
  rows. Default 5.

- padding.body:

  Numeric. Vertical cell padding (top and bottom, in pt) for body rows.
  Default 5.

- padding.all:

  Numeric. Vertical cell padding for all rows. Overrides
  `padding.header` and `padding.body`.

## Value

A formatted table rendered using the specified library and options.

## Examples

``` r

# Render a table using gt library for HTML format
buildTable(
  iris,
  library = "gt",
  format = "html",
  font.size.header = 14,
  font.size.body = 12,
  font.family.header = "Arial",
  font.family.body = "Arial",
  font.bold.header = TRUE,
  font.bold.body = FALSE,
  vlines.show = TRUE,
  hlines.show = TRUE,
  caption = "Iris Data Table"
)


  
Iris Data Table

  
Sepal.Length
```
