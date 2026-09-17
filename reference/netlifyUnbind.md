# Remove a local Netlify alias association

Changes only `.netlify/sites.env`. Does not contact or delete provider
sites.

## Usage

``` r
netlifyUnbind(alias, root = getwd())
```

## Arguments

- alias:

  One local alias.

- root:

  Project directory. Defaults to the current working directory.

## Value

Invisibly, the removed UUID.
