# Register local aliases for Netlify sites

Queries the installed Netlify CLI and records associations in
`.netlify/sites.env` under `root`. Existing aliases cannot be
retargeted. All requested associations are checked before creating or
registering sites.

## Usage

``` r
netlifyRegister(
  alias,
  site,
  root = getwd(),
  create = FALSE,
  account = NULL,
  dryRun = FALSE
)
```

## Arguments

- alias:

  Character vector of local aliases.

- site:

  Character vector of provider site names, aligned with `alias`.

- root:

  Project directory. Defaults to the current working directory.

- create:

  Permit creating missing sites. Defaults to `FALSE`.

- account:

  Optional Netlify account slug.

- dryRun:

  Describe the request without provider calls or registry writes.

## Value

Invisibly, UUIDs named by alias; a dry run returns the requested names.

## Details

Requires an installed and authenticated Netlify CLI. Batches are
sequential, not transactions; a later failure retains earlier effects.
