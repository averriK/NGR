# NGR

[Documentation](https://averriK.github.io/NGR/) · [R package](lib/) · [Architecture and development](dev/ARCHITECTURE.md)

| Component | Source | Status |
|---|---|---|
| R package | [lib/](lib/) | Existing package |
| CLI | [cli/](cli/) | Development implementation; project acceptance in progress |
| Application | [app/](app/) | Planned |
| Skill | [skill/](skill/) | Planned |
| MCP | [mcp/](mcp/) | Planned |

Public documentation is rendered by pkgdown from `lib/vignettes/` and
`lib/man/`, then published to `gh-pages`.

## Installation and use

Use the common macOS or Windows installer from the repository root, selecting
the R library and component explicitly. Follow the
[installation and CLI guide](https://averrik.github.io/NGR/articles/cli.html).
The package and CLI are separate installations; runtime commands load the
installed package and do not install dependencies.

The repository is private. Public documentation is on
[GitHub Pages](https://averrik.github.io/NGR/).

Open the RStudio project inside `lib/` for package development.
