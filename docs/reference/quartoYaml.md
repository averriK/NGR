# Quarto YAML helper functions

Small helpers for R callers that need qrt-style Quarto runtime YAML
behavior without shelling out to qrt runtime scripts.

## Usage

``` r
quartoReadFrontmatter(path)

quartoAsSequence(x)

quartoHasBookManifest(frontmatter)

quartoSetProjectRender(base, render)

quartoMergeBookManifest(base, manifest)

quartoDocxBookProfile(profile)

quartoAsYaml(x)

quartoWriteYaml(x, path = NULL)
```

## Arguments

- path:

  Character scalar path.

- x:

  Object to coerce or serialize.

- frontmatter:

  Parsed QMD frontmatter list.

- base:

  Parsed base Quarto YAML list.

- render:

  Character vector or list of render targets.

- manifest:

  Parsed qrt-style book manifest frontmatter.

- profile:

  Parsed DOCX profile YAML list.

## Details

The helpers preserve single-entry sequence fields and serialize logical
values as YAML 1.2 booleans (`true`/`false`) for Quarto compatibility.

## Value

Lists for merge/transform helpers, a logical for
`quartoHasBookManifest`, YAML text for `quartoAsYaml` and
`quartoWriteYaml(path = NULL)`, or invisible `path` when
`quartoWriteYaml()` writes to disk.
