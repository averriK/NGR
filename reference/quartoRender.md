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

Requires Quarto on `PATH`; DOCX also requires Python 3.9 or later with
`lxml` in that interpreter (`python3`, or `python` on Windows). DOCX
uses the master's `title` and `lang` (English when absent), and reads
`params.client.name`, `params.consultant.name` and `params.project_id`
from the project's `params.yml`. Required values are non-empty
single-line strings; missing values fail before Quarto. The date is
calculated for the render in `dd/mm/yyyy`, matching the print stamp.
Cover labels follow English or Spanish. A master `srk` block is not
read. Other Word metadata is left blank for editing in Word. The CAN
inner title page uses optional `address` lists and `web` strings from
the client and consultant blocks, together with the output filename. The
project DOCX profile must use a CAN-compatible reference and
`number-sections: true`. Each appendix file declared in `appendices`
needs one numbered level-1 heading with an explicit identifier
(`{#sec-...}`), which selects its separator. A book without `appendices`
emits a diagnostic and receives no CAN appendix separators. Input DOCX
sections within the body are currently unsupported. Preliminaries before
the first Heading1 use Roman numbering; the body starts at page 1. The
profile enables a Word table of contents, which may need a manual
update. No field-update request is set on document opening. The
installed library owns the Python compositor and semantic filters.
Quarto resolves citations and cross-references once for the complete
book. Rendering and composition finish before publication begins. HTML
output replaces the selected directory; each DOCX replaces its
destination through a sibling temporary file, keeping other documents.
Publication of multiple files is not a transaction. Temporary files, the
working directory and the publication-stamp environment variable are
restored on ordinary exit.
