# Upload existing directories to Netlify

Validates all directories and registered sites before uploading. Never
builds a site; passes `--no-build` to Netlify. Draft deployments are the
default.

## Usage

``` r
netlifyDeploy(alias, path, root = getwd(), prod = FALSE, dryRun = FALSE)
```

## Arguments

- alias:

  Character vector of local aliases.

- path:

  Character vector of directories aligned with `alias`, relative to
  `root` or absolute.

- root:

  Project directory. Defaults to the current working directory.

- prod:

  Publish to production instead of creating a draft.

- dryRun:

  Describe the request without provider calls or registry writes.

## Value

Invisibly, the provider UUIDs named by alias.
