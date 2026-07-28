# NGR

**Next Generation Reporting**

[![R Version](https://img.shields.io/badge/R-%3E%3D%204.1.0-blue)](https://www.r-project.org/) [![Version](https://img.shields.io/badge/version-0.3.3-green)](https://github.com/averriK/NGR) [![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

R package for generating professional multi-format reports with advanced plotting and table formatting capabilities.

## Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Exported API](#exported-api)
- [Dependencies](#dependencies)
- [Documentation (how to read)](#documentation-how-to-read)
- [License](#license)
- [Citation](#citation)
- [Author](#author)

## Overview

NGR streamlines data visualization and presentation by providing high-level functions for creating publication-quality plots and tables. Integrates Quarto for seamless multi-format rendering (HTML/PDF/DOCX) with configurable templates.

## Features

- **High-quality plots**: Advanced plotting functions with consistent styling
- **Professional tables**: Multiple backends (flextable, gt, kableExtra)
- **Multi-format output**: HTML, PDF, DOCX via Quarto integration
- **Interactive visualizations**: highcharter and plotly support
- **Configurable templates**: YAML-based report customization
- **Quarto YAML helpers**: reusable frontmatter and runtime `_quarto.yml` utilities for qrt-style render pipelines
- **Display utilities**: Built-in rendering functions for code, HTML, PDF, Markdown

## Installation

### R package

```r
# From GitHub
devtools::install_github("averriK/NGR")

# From CRAN (when published)
# install.packages("NGR")
```

## Usage

### Plots (`buildPlot()`)

`buildPlot()` consumes `data.table`s with:

- **Lines**: `data.lines` with columns `ID`, `X`, `Y` (optional: `style`, `size`, `fill`, `yAxis`)
- **Points**: `data.points` with columns `ID`, `X`, `Y` (optional: `style`, `yAxis`)
- **Ranges**: `data.ranges` with columns `ID`, `X`, `lower`, `upper` (optional: `size`, `color`, `yAxis`, `custom.lower`, `custom.upper`)

#### Basic line plot

```r
library(NGR)
library(data.table)

lines <- data.table(
  ID = "Series",
  X  = 1:10,
  Y  = (1:10)^2
)

plt <- buildPlot(
  data.lines   = lines,
  plot.title   = "Example plot",
  xAxis.legend = "X",
  yAxis.legend = "Y"
)
```

#### Secondary Y axis — linked (same curve, relabel ticks)

Use this when you want **one curve** but the right axis shows a transformed label, e.g. `TR = 1 / AEP`.

```r
plt <- buildPlot(
  data.lines = lines,
  yAxis.legend  = "AEP [1/yr]",
  yAxis2.legend = "TR [yr]",
  yAxis2.transform = ~ 1 / Y,
  yAxis2.decimals = 0
)
```

#### Secondary Y axis — independent (two variables / two scales)

Assign each series to axis 0 or 1 via a `yAxis` column.

```r
dt <- data.table::rbindlist(list(
  data.table::data.table(ID = "Pressure", X = 1:50, Y = 10 + sin((1:50)/6), yAxis = 0),
  data.table::data.table(ID = "Temp",     X = 1:50, Y = 20 + cos((1:50)/8), yAxis = 1)
))

plt <- buildPlot(
  data.lines   = dt,
  yAxis.legend  = "Pressure",
  yAxis2.legend = "Temp"
)
```

### Tables (`buildTable()`)

```r
library(NGR)

tbl <- buildTable(
  iris,
  library = "gt",
  format  = "html",
  caption = "Iris summary"
)
```

### Quarto YAML helpers

These helpers are ordinary R APIs for qrt-style runtime Quarto YAML. They do not
call the `qrt` CLI.

```r
library(NGR)

frontmatter <- quartoReadFrontmatter("report.qmd")
base <- yaml::read_yaml("yml/_quarto.yml")

book_config <- quartoMergeBookManifest(base, frontmatter)
quartoWriteYaml(book_config, "_quarto.yml")

single_file_config <- quartoSetProjectRender(base, "report.qmd")
quartoAsYaml(single_file_config)
```

See `vignettes/quarto-yaml.Rmd` for the package-facing article source.

### Display utilities

```r
showCode("script.R")                # Syntax-highlighted code
showHTML("report.html")             # Rendered HTML
showPDF("document.pdf")             # PDF viewer
showMarkdownRendered("README.md")   # Rendered markdown
```

## Exported API

The package exports 29 functions (see `NAMESPACE`):

### Plotting

- `buildPlot()` — high-level plotting with consistent styling.
- `buildPlot.Bar()`, `buildPlot.Histogram()`, `buildPlot.Model()` — specialised variants.

### Tables and reporting

- `buildTable()` — publication-quality tables via gt/flextable/kableExtra.
- `buildYAML()` — compose Quarto YAML blocks for multi-format rendering.
- `quartoReadFrontmatter()`, `quartoMergeBookManifest()`, `quartoSetProjectRender()`, `quartoDocxBookProfile()`, `quartoAsYaml()`, and related helpers — reusable qrt-style Quarto YAML utilities.
- `export()` — render/export utility.

### Highcharter themes (gridlines)

- `hc_theme_538_gridlines()`, `hc_theme_economist_gridlines()`, `hc_theme_flat_gridlines()`, `hc_theme_hcrt_gridlines()`.

### Display utilities

- `showCode()`, `showHTML()`, `showPDF()`, `showMarkdownRendered()`, `showGithubREADME()`, `showASCII()`.

### Presentation effects

- `showTypewriter()`, `rotateTypewriter()`, `buildIndexTypewriter()`.

## Dependencies

- R (>= 4.1.0)
- yaml, brio, data.table
- flextable, gt, officer, kableExtra (table backends)
- highcharter, htmlwidgets, webshot2, plotly (interactive plots)
- grDevices, stats, graphics

## Documentation (how to read)

See function documentation via R help:

```r
?NGR
?buildPlot
?buildTable
```

Pkgdown is configured by `_pkgdown.yml` and builds the site into `docs/`, following the `gmsp`/`newmark` package-site layout.

Pkgdown article sources:

- `vignettes/quarto-yaml.Rmd` — package-facing vignette for the Quarto YAML helper API.
- `vignettes/secondary-y-axis.Rmd` — primary/secondary Y axis configuration.
- `vignettes/themes-gridlines.Rmd` — `hc_theme_*_gridlines()` reference.
- `vignettes/adding-web-fonts-typewriter.Rmd` — maintainer guide for typewriter web fonts.

## License

MIT License - see [LICENSE](LICENSE)

## Citation

```bibtex
@software{ngr,
  author = {Verri Kozlowski, Alejandro},
  title = {NGR: Next Generation Reporting},
  year = {2020},
  version = {0.3.3},
  url = {https://github.com/averriK/NGR}
}
```

---

## Author

**Alejandro Verri Kozlowski**  
**Email:** averri@fi.uba.ar  
**ORCID:** [0000-0002-8535-1170](https://orcid.org/0000-0002-8535-1170)  
**Affiliation:** Universidad de Buenos Aires, Facultad de Ingeniería
