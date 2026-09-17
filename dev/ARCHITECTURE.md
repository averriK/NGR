# Repository architecture

The owner-selected [installation policy](../install/README.md) governs all installation and package tooling.

| Folder | Ownership |
| --- | --- |
| `lib/` | Independently buildable R package, APIs, help, vignettes, tests and runtime resources |
| `cli/` | Shared `main.R` command entry, minimal platform launchers and operational resources |
| `install/` | macOS/Linux and Windows entry points; library/dependency/CLI installers; package checks and CRAN/release tooling |
| `app/`, `skill/`, `mcp/` | Their implemented components; reserved directories are not installable products |
| `lib/vignettes/`, `lib/man/` | Public articles and R reference, published by pkgdown |
| `dev/` | Plans, experiments, audits, SoT evidence and continuity |
| `.github/` | Repository automation |

## Installation and package lifecycle

Public entries are `install/install.sh` and `install/install.ps1`. All installation
and package lifecycle helpers belong under `install/`, with explicit, separate
operations for dependencies, installation, documentation, build, checks and publication.
Each helper has one maintained implementation under `install/`. This is the
target contract; migration and Windows/macOS acceptance must be verified
independently of this document.

The R package builds from `lib/` without sibling directories. CLI/app consumers
use the installed package. `lib/inst/` is only for package runtime resources,
never repository installation/development/release scripts. Installing software
does not publish Pages/CRAN, mutate Git or migrate project data.

## Documentation and Pages

Repositories are private by policy. GitHub Pages is the public documentation
surface: links must point to published pages, not private source, Issues or
repository files. Help uses the maintainer contact. Keep pkgdown repository
URL discovery disabled with `repo: {url: {}}` and omit repository navigation.

Public articles and reference sources are in `lib/vignettes/` and `lib/man/`.
The package README supplies the home page. With R, Pandoc, pkgdown and package
dependencies available, build locally from the repository root:

```sh
Rscript -e 'pkgdown::build_site("lib")'
```

The current `.github/workflows/pkgdown.yaml` builds from `lib/` on pushes to
`main` or manual dispatch and publishes `lib/docs/` to `gh-pages`. Pages serves
that branch at `https://averrik.github.io/NGR/`; reference and articles use
`reference/` and `articles/`. There is no Jekyll portal or second documentation
pipeline. App, skill and MCP folders remain reserved components.

There is currently no R-hub workflow. Its maintenance entry requires a workflow
configured for the package in `lib/` before remote checks can be dispatched.
