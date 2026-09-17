# Render a Quarto document in a disposable project copy

Uses `yml/_quarto.yml` and `yml/_quarto-<profile>.yml` from the project.
Book masters supply chapters and appendices through their frontmatter.
Single-file masters are moved to the root of the disposable copy so
their resource paths resolve from the project root. Source files are not
changed.

## Usage

``` r
quartoRender(
  input,
  profile,
  root = getwd(),
  output = NULL,
  args = character(),
  manifest = "manifest.json"
)
```

## Arguments

- input:

  Project-relative QMD or Markdown master.

- profile:

  One of `book`, `html`, `revealjs` or `docx`.

- root:

  Project directory. Defaults to the current working directory.

- output:

  Output directory relative to `root`. HTML formats require
  `html/<name>`; DOCX requires `docx`. When `NULL`, uses
  `html/<master stem>` or `docx`, respectively.

- args:

  Character vector of additional arguments passed to Quarto.

- manifest:

  Path to the project provenance manifest, relative to `root` or
  absolute. An absent manifest produces a draft publication stamp.

## Value

Invisibly, a character vector of delivered file paths.

## Details

Requires Quarto on `PATH`; DOCX and staging symbolic links on Windows
also require Python 3. The DOCX repair script is a private resource of
the installed NGR package. Rendering and DOCX repair finish before
publication begins. HTML output replaces the selected directory; DOCX
overwrites delivered files and keeps other documents. Publication is not
transactional: a copy failure can leave partial output. Temporary files,
the working directory and the publication-stamp environment variable are
restored on ordinary exit.
