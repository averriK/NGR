# NGR

**Next Generation Reporting**

> **Last updated:** November 13, 2025

R package for generating professional multi-format reports with advanced plotting and table formatting capabilities.

[![R Version](https://img.shields.io/badge/R-%3E%3D%204.1.0-blue)](https://www.r-project.org/)
[![Version](https://img.shields.io/badge/version-0.3.3-green)](https://github.com/averriK/NGR)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## What is it?

NGR streamlines data visualization and presentation by providing high-level functions for creating publication-quality plots and tables. Integrates Quarto for seamless multi-format rendering (HTML/PDF/DOCX) with configurable templates.

## Features

- **High-quality plots**: Advanced plotting functions with consistent styling
- **Professional tables**: Multiple backends (flextable, gt, kableExtra)
- **Multi-format output**: HTML, PDF, DOCX via Quarto integration
- **Interactive visualizations**: highcharter and plotly support
- **Configurable templates**: YAML-based report customization

## Installation

```r
devtools::install_github("averriK/NGR")
```

## Usage

```r
library(NGR)

# Show code with syntax highlighting
showCode(code_file)

# Display rendered HTML
showHTML(html_file)

# Create publication-quality plots
buildPlot(data, config)

# Generate formatted tables
buildTable(data, format = "flextable")

# Show rendered markdown
showMarkdownRendered(md_file)

# Display GitHub README
showGithubREADME(repo)
```

## Examples

Complete examples available in:

- `~/github/inno/revealjs/_slides/` - Presentation workflows
- `~/github/psha/_fig/` - Plot examples
- `~/github/psha/_tbl/` - Table examples

## Documentation

Function documentation available via R help:

```r
?NGR
```

## Dependencies

- R (>= 4.1.0)
- yaml, brio, data.table
- flextable, gt, officer, kableExtra
- highcharter, htmlwidgets, webshot2, plotly
- grDevices, stats, graphics

## License

[MIT License](LICENSE)

---

**Author:** Alejandro Verri Kozlowski  
**Email:** averri@fi.uba.ar  
**ORCID:** [0000-0002-8535-1170](https://orcid.org/0000-0002-8535-1170)
