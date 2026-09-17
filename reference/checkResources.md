# Run checks declared by registered resource sources

Validates all applied source claims, then runs the selected sources'
declared argument vectors in the project directory. Those commands can
have effects; this is not a read-only query. A failed command stops the
operation.

## Usage

``` r
checkResources(source = NULL, root = getwd())
```

## Arguments

- source:

  Registered source identities, or `NULL` for all associations.

- root:

  Existing project directory; defaults to the working directory.

## Value

Invisibly, a list of completed checks with source, command and status.
