# Resolve the print stamp of a render from scaffold provenance

Validates the per-file scaffold provenance recorded in a project
manifest and returns the print stamp of the render: the print date
alone. The technical revisions and the draft state of the resources stay
in the manifest receipts and are not shown to readers. This function
reads files without changing them.

## Usage

``` r
quartoRenderStamp(manifest, root = getwd())
```

## Arguments

- manifest:

  Parsed project manifest as a list. An empty list represents a project
  without recorded scaffold provenance.

- root:

  Project directory containing the recorded relative file paths.
  Defaults to the current working directory.

## Value

A character scalar `Printed: dd/mm/yyyy` with the current local date,
which is also reported through a message condition.
