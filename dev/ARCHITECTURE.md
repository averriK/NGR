# Repository architecture

| Folder | Ownership |
|---|---|
| `lib/` | Complete R package: metadata, code, help, tests, vignettes and installed resources |
| `cli/` | Command-line adapter, installer and its tests/resources |
| `app/` | Shiny or React application and its tests/assets |
| `skill/` | Product skill source and references |
| `mcp/` | MCP adapter and its tests |
| `docs/` | Jekyll portal and interface manuals |
| `dev/` | Maintenance, experiments, release tooling and development state |
| `.github/` | Repository automation |

A reserved component contains a README until it has an implementation.
The R package must build from `lib/` without any sibling directory.
Keep runtime resources with their consumer; package resources belong in
`lib/inst/`. Package datasets, data preparation and examples retain the
native R layout under `lib/`. Tests belong with the component they exercise.

## R development

Open the RStudio project inside `lib/`. From the repository root:

```sh
R CMD build lib
R CMD INSTALL lib
```

For development installation from GitHub, use `subdir = "lib"`.
The package name and public API are unchanged. CLI and Shiny consumers load
the installed package; a deployed React client needs an explicit service or
data interface.

Existing maintenance scripts moved from `inst/` to `dev/lib/`. Run their
documented sections with `lib/` as the working directory, for example
`source("../dev/lib/cran-check.R")` where present. Release and R-hub
entry points retain their explicit interactive/publication gates.
Archived development notes retain their historical paths; consult this
mapping before running an older command:
`R/` → `lib/R/`, `inst/dev/` → `dev/lib/`.

## CLI installation

The CLI loads the installed R package through R's normal library resolution.
Its runtime and installer must work without the package source checkout or
the sibling `lib/` directory. A missing package is an explicit prerequisite
error; the CLI does not install it automatically.

The CLI installer and uninstaller manage only CLI launchers, runtime files
and their installation receipts. They do not build, install, update or
remove the R package or its dependencies. Package installation remains a
separate operation through its maintenance scripts.

## Documentation and Pages

`docs/` contains source Markdown, templates and styles; R reference and
articles remain in `lib/man/` and `lib/vignettes/`.
With Ruby 3.3, Bundler, R, pkgdown and the package's dependencies available:

```sh
BUNDLE_GEMFILE=docs/Gemfile bundle install
bash dev/build-site.sh
```

The build runs Jekyll first into `_site/`, then pkgdown into `_site/lib/`.
Generated HTML is ignored. One Actions artifact contains the complete site.
Pages must use **GitHub Actions** as its publishing source in repository
settings. A push to `main` builds and deploys; pull requests only build.
Committing this layout does not itself change the repository setting.

Routes: portal `/<repo>/`, R `/<repo>/lib/`, CLI `/<repo>/cli/`,
skill `/<repo>/skill/`, MCP `/<repo>/mcp/`, app manual
`/<repo>/guide/app/`. Existing reference/article HTML paths redirect to
their corresponding R pages, preserving query strings and fragments.

A future static React build owns `_site/app/`; a Shiny app runs on an
application host and the portal links to it. Choose one owner for `/app/`
when implementing the app. No Shiny server is run by GitHub Pages.

R-CMD-check actions explicitly target `lib/`. The existing R-hub actions
assume a package at the checkout root, so their disposable runner copy stages
`lib/` there before checking; this does not move the repository's sources.
