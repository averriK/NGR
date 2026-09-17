# Resolve the publication stamp from scaffold provenance

Aggregates the per-file revisions recorded in a project manifest and
checks those files against their recorded MD5 digests. The stamp
describes all registered scaffolds, not only the files used by one
rendered artifact. Missing or modified files, dirty revisions and
unknown provenance mark the result as a draft. This function reads files
without changing them.

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

A character scalar with the publication date, sorted abbreviated
revisions and, when applicable, a `DRAFT` marker. The current local time
supplies the date and is also reported through a message condition.
