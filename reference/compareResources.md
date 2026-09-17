# Compare project resources with their sources

Reads sources, local files and per-file receipts without writing them.

## Usage

``` r
compareResources(
  from = NULL,
  source = NULL,
  paths = character(),
  root = getwd()
)
```

## Arguments

- from:

  Character vector of source manifest paths, or `NULL` to use existing
  project associations. Relative paths resolve from the R working
  directory. Incompatible with a nonempty `source`.

- source:

  Registered source identities, or `NULL` for all associations.

- paths:

  Destination files or directory prefixes. Empty selection uses the
  enrolled selection, or the complete source when `from` is supplied.

- root:

  Existing project directory; defaults to the working directory.

## Value

A list with `files` (source, state, path and modified columns) and
`changed`, which is true for differences, missing/retired files or edits
against a receipt. Customized seeds alone do not set `changed`.
