# NGR

[Documentation](https://averriK.github.io/NGR/) · [R package](lib/) · [Architecture and development](dev/ARCHITECTURE.md)

| Component | Source | Status |
|---|---|---|
| R package | [lib/](lib/) | Existing package |
| CLI | [cli/](cli/) | Planned |
| Application | [app/](app/) | Planned |
| Skill | [skill/](skill/) | Planned |
| MCP | [mcp/](mcp/) | Planned |

Documentation sources live in `docs/`; build output is `_site/`.

## R package installation

From this checkout:

```sh
R CMD INSTALL lib
```

From GitHub:

```r
remotes::install_github("averriK/NGR", subdir = "lib")
```

Open the RStudio project inside `lib/` for package development.
