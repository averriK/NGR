# Incorporate and update project resources

Sources declare mappings to shared project paths. All implicated claims
are checked before writes, including claims of sources not selected for
update. Existing seeds, extra project files and scientific data are
preserved. Files retired from a source are not deleted. Ordinary write
errors restore the files already written; concurrent writers and process
termination are not covered by this recovery.

## Usage

``` r
pullResources(
  from = NULL,
  source = NULL,
  paths = character(),
  root = getwd(),
  force = FALSE,
  dryRun = FALSE
)
```

## Arguments

- from:

  Character vector of source manifest paths, or `NULL` to use existing
  project associations. Relative paths resolve from the R working
  directory. A source is identified by its `id`: a manifest whose `id`
  is already associated re-points that association to the new location,
  with a message. Incompatible with a nonempty `source`.

- source:

  Registered source identities, or `NULL` for all associations.

- paths:

  Destination files or directory prefixes. Empty selection uses the
  enrolled selection, or the complete source when `from` is supplied.

- root:

  Existing project directory; defaults to the working directory.

- force:

  Replace different managed files; never replace existing seeds or
  override incompatible source claims.

- dryRun:

  Return the same validated plan without writing files.

## Value

A list containing `actions` (a data frame with source, path and action
columns) and `manifest` (the resulting project manifest).
