# Display markdown file as rendered HTML via iframe

Display markdown file as rendered HTML via iframe

## Usage

``` r
showMarkdownRendered(
  filePath,
  height = "500px",
  theme = "spacelab",
  toc = FALSE,
  force = FALSE,
  fontsize = NULL
)
```

## Arguments

- filePath:

  Path to markdown file (will be rendered to HTML at runtime)

- height:

  Height of iframe (default "500px")

- theme:

  HTML theme (default "spacelab")

- toc:

  Show table of contents (default FALSE)

- force:

  Force re-render even if HTML is up to date (default FALSE)

- fontsize:

  Base font size (e.g., "0.8em", "14px", "90%", default NULL = theme
  default)

## Value

Prints iframe HTML using cat() for results: asis
