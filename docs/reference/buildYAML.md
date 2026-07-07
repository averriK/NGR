# Build Quarto YAML and prepare project structure

Assemble a consolidated Quarto configuration (`_quarto.yml`) by merging
project files (parameters, authors, format-specific YAMLs) with
language-specific variants when present. Copies package support files
into `build_dir`, ensures a clean `publish_dir`, and writes the final
`_quarto.yml`. Rendering is not performed; use Quarto CLI or
[`quarto::quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.html)
after calling this function.

## Usage

``` r
buildYAML(
  build_dir = "_build",
  publish_dir = "_publish",
  index_filename = "index.qmd",
  quarto_filename = "_quarto.yml",
  language = "EN",
  output_format = c("html"),
  extensions = c("spl", "bst", "cls", "md", "aux", "log", "tex", "jpg", "sty", "docx",
    "pdf", "html")
)
```

## Arguments

- build_dir:

  Directory where package support files are copied (created if needed).

- publish_dir:

  Output directory configured in the generated `_quarto.yml`
  (re-created).

- index_filename:

  Report entrypoint (e.g. `index.qmd`). Used to invoke Quarto
  downstream.

- quarto_filename:

  Target filename for the generated Quarto config (default
  `_quarto.yml`).

- language:

  Language code (e.g. `"EN"`, `"ES"`) to pick suffixed files like
  `_html_ES.yml`.

- output_format:

  Character vector of output formats to include (e.g.
  `c("html","pdf")`).

- extensions:

  Reserved for future cleanup behavior (currently used only on error
  paths).
