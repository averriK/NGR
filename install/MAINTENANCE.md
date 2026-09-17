# R package maintenance

Run these entry points from `lib/`. They operate on the package identified by
that directory's DESCRIPTION. `package.R` defines their operations without
executing them; it can also be sourced and called with explicit paths.
Runtime resources remain in `lib/inst/`.

This repository currently has no R-hub workflow; configure one for `lib/`
before using the dispatch entry. The older `testthat.R` is not called by this
suite; the package tests included in the tarball are exercised by R CMD check.

## Prepare the environment

Install R and make `Rscript` available first. Source builds may need the
platform's compiler tools and system libraries; manuals need LaTeX. These
scripts install R packages, not operating-system dependencies or R itself.
They never clone, pull, merge, commit or push a repository.

Choose a writable R library explicitly, preferably one already in `.libPaths()`.
From `lib/`:

```sh
Rscript ../install/setup.R "/absolute/path/to/R/library"
```

This installs absent maintenance tools and the package's development
dependencies, including Suggests. `pak` resolves DESCRIPTION constraints and
Remotes with `upgrade = FALSE`; compatible dependencies in visible R libraries
are reused. Missing tools come from CRAN. The bootstrap prepares `pak >= 0.11.1`;
restart R first if an older pak namespace is already loaded. Installing a
needed incompatible dependency can replace it in the selected library.
This is a dependency preparation operation, not a rollback transaction.

A new library must remain visible in subsequent sessions: use R's existing
`R_LIBS_USER` configuration, or `.libPaths(c(Library, .libPaths()))` in an
interactive R session. Each operation restores any temporary library search
path it changes. Private dependency sources require their normal credentials;
the helper does not create credentials or make a private repository public.

## Independent operations

| Script | Required positional arguments | Effect |
| --- | --- | --- |
| `setup.R` | library | Prepare R development dependencies and maintenance tools |
| `document.R` | none | Prepare documentation under the repository's ownership policy and check spelling |
| `build.R` | output | Build one source tarball with vignettes/manual support; write its record |
| `cran-check.R` | tarball, output | Check that exact tarball; retain options, results and logs |
| `install.R` | tarball, library | Install the selected tarball and needed runtime dependencies |
| `rhub-check.R` | none; interactive R only | Dispatch remote R-hub jobs for a clean, pushed branch |
| `testMaintenance.R` | none | Exercise maintenance boundaries in a temporary fixture tree |

Use `Rscript ../install/<script> <arguments>`. An interactive
`source("../install/<script>")` prompts for its required arguments. A missing
argument in a noninteractive session fails before the requested operation.
The old argument-free check/install commands now require explicit destinations
and an artifact. Documentation, checks and site generation are separate steps.

For example, after preparing dependencies, in R with working directory `lib/`:

```r
source("../install/document.R")
# Review the generated diff before identifying a release candidate.
source("../install/package.R")
Artifact <- buildPackage(path = ".", output = "../dev/release/candidate")
checkPackage(file = Artifact, output = "../dev/release/check")
# Run this separately when installation is wanted:
installPackage(file = Artifact, library = "/absolute/path/to/R/library")
```

Use a new build destination when that version already exists, and a new check
directory for each attempt. Keep the `.tar.gz` and adjacent `.tar.gz.rds`
together. The record contains the SHA-256, package/version, source commit and
clean-tree observation. Check adds the R version, platform, arguments,
environment, status, errors, warnings, NOTEs and log directory. Checks reject
changed tarball bytes. Errors and warnings fail; NOTEs remain for human review.
Interrupted checks cannot retain a passed verdict.

The check enables `--as-cran`, `--run-donttest`, incoming/remote checks and
Suggested dependencies. It checks the built artifact's tests/examples/vignettes;
it cannot exercise tests excluded from that artifact. It does not imply a
complete contextual CRAN audit or certification on another R/platform.

Installation does not rebuild the source or run a release check. It verifies
the selected artifact's hash, installs into the explicit library and verifies
the resulting package version. A local development installation may use an
unchecked build. Installing a CRAN release candidate still requires the
separate release review below.

## Release and external operations

Follow `cran-release.R`, a comment-only runbook. Record the exact candidate
commit, tarball/hash, local check, contextual CRAN review, CI/Pages results and
R-hub results. R-hub uses the branch on the live remote, not the local tarball;
its dispatch is not its result. The helper reads the live remote ref and refuses
a mismatch before dispatch. It does not publish your branch.
An R-hub workflow configured for the `lib/` layout and its authentication are
prerequisites; this helper does not install or configure that workflow.

**Submission migration is pending.** The older `cran-submit.R`, where present,
rebuilds a package through devtools and is not part of this exact-artifact flow.
Do not use it to claim that the checked tarball was submitted. The choice of
official-form submission versus an automated client is awaiting the owner.
No new CRAN upload command is provided by this maintenance revision.

The approved `cran` skill reviews the source and saved evidence. It neither
installs dependencies nor replaces these executable checks. Site generation
uses `pkgdown::build_site("lib")` from the repository root and the pkgdown
workflow; it is not a side effect of the check.

## Product dependencies

This is package maintenance, not an installer for all product components.
An application's R requirements must be read from its real CLI/app consumers;
the package DESCRIPTION alone is insufficient. `installRequirements()` accepts
an explicit vector of additional CRAN package names independently of DESCRIPTION
and an explicit dependency scope. Currently present extra names are preserved;
that list does not encode version constraints or private package sources.
Those contracts must be supplied by each implemented component before claiming
a complete product installation. CLI runtime still loads the installed package
through normal R resolution, independently of this source checkout.

## Verify the maintenance itself

```sh
Rscript ../install/testMaintenance.R
```

This exercises real Rscript entries, a fixture build, collision and tampering
guards, failed/interrupted checker records, dependency bootstrap and preservation
of library resolution. Checker failures are simulated through testthat. These
tests neither install this product into a personal library nor dispatch or
submit a release. They do not certify the scientific package or other platforms.
