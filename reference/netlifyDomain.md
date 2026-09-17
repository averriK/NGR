# Configure domains for registered Netlify sites

Checks every current domain before changing any. A different existing
domain is rejected unless `rebind = TRUE`. DNS diagnostics do not change
DNS records.

## Usage

``` r
netlifyDomain(
  alias,
  domain,
  root = getwd(),
  https = FALSE,
  rebind = FALSE,
  dryRun = FALSE
)
```

## Arguments

- alias:

  Character vector of local aliases.

- domain:

  Character vector of host names aligned with `alias`.

- root:

  Project directory. Defaults to the current working directory.

- https:

  Enable HTTPS, including certificate provisioning if needed.

- rebind:

  Explicitly clear the current custom domain before binding.

- dryRun:

  Describe the request without provider calls or registry writes.

## Value

Invisibly, the provider UUIDs named by alias.
