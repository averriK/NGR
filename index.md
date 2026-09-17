# NGR

**Next Generation Reporting**

[![R
Version](https://img.shields.io/badge/R-%3E%3D%204.1.0-blue)](https://www.r-project.org/)
[![Version](https://img.shields.io/badge/version-0.3.11-green)](https://averriK.github.io/NGR/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://averrik.github.io/NGR/LICENSE.html)

R package for generating professional multi-format reports with advanced
plotting and table formatting capabilities.

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

NGR streamlines data visualization and presentation by providing
high-level functions for creating publication-quality plots and tables.
Integrates Quarto for seamless multi-format rendering (HTML/PDF/DOCX)
with configurable templates.

## Features

- **High-quality plots**: Advanced plotting functions with consistent
  styling
- **Professional tables**: Multiple backends (flextable, gt, kableExtra)
- **Multi-format output**: HTML, PDF, DOCX via Quarto integration
- **Interactive visualizations**: highcharter widgets
- **Configurable templates**: YAML-based report customization
- **Quarto YAML helpers**: reusable frontmatter and runtime
  `_quarto.yml` utilities for qrt-style render pipelines
- **Display utilities**: Built-in rendering functions for code, HTML,
  PDF, Markdown

## Installation

The R package and CLI are separate components. Use the repository’s
common installer from the repository root, selecting an R library
explicitly. The [installation
guide](https://averrik.github.io/NGR/articles/cli.html#install) explains
the macOS and Windows entries, package-only installation and the
separate CLI destination. Runtime commands do not install dependencies.
The repository is private; obtaining its development sources requires
access.

## Usage

### Plots (`buildPlot()`)

[`buildPlot()`](https://averriK.github.io/NGR/reference/buildPlot.md)
consumes `data.table`s with:

- **Lines**: `data.lines` with columns `ID`, `X`, `Y` (optional:
  `style`, `size`, `fill`, `yAxis`)
- **Points**: `data.points` with columns `ID`, `X`, `Y` (optional:
  `style`, `yAxis`)
- **Ranges**: `data.ranges` with columns `ID`, `X`, `lower`, `upper`
  (optional: `size`, `color`, `yAxis`, `custom.lower`, `custom.upper`)

#### Basic line plot

``` r

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

Use this when you want **one curve** but the right axis shows a
transformed label, e.g. `TR = 1 / AEP`.

``` r

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

``` r

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

``` r

library(NGR)

tbl <- buildTable(
  iris,
  library = "gt",
  format  = "html",
  caption = "Iris summary"
)
```

### Quarto YAML helpers

These helpers are ordinary R APIs for qrt-style runtime Quarto YAML.
They do not call the `qrt` CLI. This example requires your existing
`report.qmd` and `yml/_quarto.yml` in the working directory and writes
`_quarto.yml` there.

``` r

library(NGR)

frontmatter <- quartoReadFrontmatter("report.qmd")
base <- yaml::read_yaml("yml/_quarto.yml")

book_config <- quartoMergeBookManifest(base, frontmatter)
quartoWriteYaml(book_config, "_quarto.yml")

single_file_config <- quartoSetProjectRender(base, "report.qmd")
quartoAsYaml(single_file_config)
```

See the [Quarto YAML
guide](https://averrik.github.io/NGR/articles/quarto-yaml.html) for
complete examples.

### Display utilities

``` r

showCode("script.R")                # Syntax-highlighted code
showHTML("report.html")             # Rendered HTML
showPDF("document.pdf")             # PDF viewer
showMarkdownRendered("README.md")   # Rendered markdown
```

## Exported API

The [function
reference](https://averrik.github.io/NGR/reference/index.html) lists the
exported API. The principal families are:

### Plotting

- [`buildPlot()`](https://averriK.github.io/NGR/reference/buildPlot.md)
  — high-level plotting with consistent styling.
- [`buildPlot.Bar()`](https://averriK.github.io/NGR/reference/buildPlot.Bar.md),
  [`buildPlot.Histogram()`](https://averriK.github.io/NGR/reference/buildPlot.Histogram.md),
  [`buildPlot.Model()`](https://averriK.github.io/NGR/reference/buildPlot.Model.md)
  — specialised variants.
- [`buildHeatmap()`](https://averriK.github.io/NGR/reference/buildHeatmap.md)
  — categorical Highcharts heatmaps.
- [`buildSectionResultantsPlot()`](https://averriK.github.io/NGR/reference/buildSectionResultantsPlot.md)
  — responsive circular-section diagrams for any prepared subset of `N`,
  `M`, and `Q` layers.

### Tables and reporting

- [`buildTable()`](https://averriK.github.io/NGR/reference/buildTable.md)
  — publication-quality tables via gt/flextable/kableExtra.
- [`buildYAML()`](https://averriK.github.io/NGR/reference/buildYAML.md)
  — compose Quarto YAML blocks for multi-format rendering.
- [`quartoReadFrontmatter()`](https://averriK.github.io/NGR/reference/quartoYaml.md),
  [`quartoMergeBookManifest()`](https://averriK.github.io/NGR/reference/quartoYaml.md),
  [`quartoSetProjectRender()`](https://averriK.github.io/NGR/reference/quartoYaml.md),
  [`quartoDocxBookProfile()`](https://averriK.github.io/NGR/reference/quartoYaml.md),
  [`quartoAsYaml()`](https://averriK.github.io/NGR/reference/quartoYaml.md),
  and related helpers — reusable qrt-style Quarto YAML utilities.
- [`export()`](https://averriK.github.io/NGR/reference/export.md) —
  render/export utility.

### Project resources, rendering and publication

- [`pullResources()`](https://averriK.github.io/NGR/reference/pullResources.md),
  [`compareResources()`](https://averriK.github.io/NGR/reference/compareResources.md),
  [`checkResources()`](https://averriK.github.io/NGR/reference/checkResources.md)
  — composition, comparison and declared checks for project sources.
- [`quartoRender()`](https://averriK.github.io/NGR/reference/quartoRender.md),
  [`quartoRenderManifest()`](https://averriK.github.io/NGR/reference/quartoRenderManifest.md),
  [`quartoRenderStamp()`](https://averriK.github.io/NGR/reference/quartoRenderStamp.md)
  — Quarto output, batch selection and provenance.
- [`netlifyRegister()`](https://averriK.github.io/NGR/reference/netlifyRegister.md),
  [`netlifyDeploy()`](https://averriK.github.io/NGR/reference/netlifyDeploy.md),
  [`netlifyDomain()`](https://averriK.github.io/NGR/reference/netlifyDomain.md),
  [`netlifyUnbind()`](https://averriK.github.io/NGR/reference/netlifyUnbind.md)
  — explicit site and publication operations. Rendering does not publish
  a site.

### Highcharter themes (gridlines)

- [`hc_theme_538_gridlines()`](https://averriK.github.io/NGR/reference/hc_theme_538_gridlines.md),
  [`hc_theme_economist_gridlines()`](https://averriK.github.io/NGR/reference/hc_theme_economist_gridlines.md),
  [`hc_theme_flat_gridlines()`](https://averriK.github.io/NGR/reference/hc_theme_flat_gridlines.md),
  [`hc_theme_hcrt_gridlines()`](https://averriK.github.io/NGR/reference/hc_theme_hcrt_gridlines.md).

### Display utilities

- [`showCode()`](https://averriK.github.io/NGR/reference/showCode.md),
  [`showHTML()`](https://averriK.github.io/NGR/reference/showHTML.md),
  [`showPDF()`](https://averriK.github.io/NGR/reference/showPDF.md),
  [`showMarkdownRendered()`](https://averriK.github.io/NGR/reference/showMarkdownRendered.md),
  [`showGithubREADME()`](https://averriK.github.io/NGR/reference/showGithubREADME.md),
  [`showASCII()`](https://averriK.github.io/NGR/reference/showASCII.md).

### Presentation effects

- [`showTypewriter()`](https://averriK.github.io/NGR/reference/showTypewriter.md),
  [`rotateTypewriter()`](https://averriK.github.io/NGR/reference/rotateTypewriter.md),
  [`buildIndexTypewriter()`](https://averriK.github.io/NGR/reference/buildIndexTypewriter.md).

## Dependencies

- R (\>= 4.1.0)
- yaml, brio, data.table
- flextable, gt, officer, kableExtra (table backends)
- highcharter, htmlwidgets, webshot2 (interactive plots)
- fs, digest, jsonlite, stringi (resources and manifests)
- grDevices, stats, graphics

## Documentation (how to read)

See function documentation via R help:

``` r

?NGR
?buildPlot
?buildTable
```

Pkgdown is configured by `_pkgdown.yml` and renders the articles in
`vignettes/` and the R reference in `man/`. The public site is
<https://averrik.github.io/NGR/>.

Public articles:

- [Command-line
  interface](https://averrik.github.io/NGR/articles/cli.html).
- [Quarto YAML
  helpers](https://averrik.github.io/NGR/articles/quarto-yaml.html).
- [Secondary Y
  axis](https://averrik.github.io/NGR/articles/secondary-y-axis.html).
- [Themes with
  gridlines](https://averrik.github.io/NGR/articles/themes-gridlines.html).
- [Typewriter web
  fonts](https://averrik.github.io/NGR/articles/adding-web-fonts-typewriter.html).

## License

MIT License - see [LICENSE](https://averrik.github.io/NGR/LICENSE.html)

## Citation

``` bibtex
@software{ngr,
  author = {Verri Kozlowski, Alejandro},
  title = {NGR: Next Generation Reporting},
  year = {2020},
  version = {0.3.11},
  url = {https://averriK.github.io/NGR/}
}
```

------------------------------------------------------------------------

## Author

**Alejandro Verri Kozlowski**  
**Email:** <averri@fi.uba.ar>  
**ORCID:**
[0000-0002-8535-1170](https://orcid.org/0000-0002-8535-1170)  
**Affiliation:** Universidad de Buenos Aires, Facultad de Ingeniería
