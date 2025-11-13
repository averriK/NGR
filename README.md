# NGR

**Next Generation Reporting**

[![R Version](https://img.shields.io/badge/R-%3E%3D%204.1.0-blue)](https://www.r-project.org/) [![Version](https://img.shields.io/badge/version-0.3.3-green)](https://github.com/averriK/NGR) [![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

R package for generating professional multi-format reports with advanced plotting and table formatting capabilities.

## What is it?

NGR streamlines data visualization and presentation by providing high-level functions for creating publication-quality plots and tables. Integrates Quarto for seamless multi-format rendering (HTML/PDF/DOCX) with configurable templates.

## Features

- **High-quality plots**: Advanced plotting functions with consistent styling
- **Professional tables**: Multiple backends (flextable, gt, kableExtra)
- **Multi-format output**: HTML, PDF, DOCX via Quarto integration
- **Interactive visualizations**: highcharter and plotly support
- **Configurable templates**: YAML-based report customization
- **Display utilities**: Built-in rendering functions for code, HTML, PDF, Markdown

## Installation

```r
devtools::install_github("averriK/NGR")
```

## Usage

```r
library(NGR)
library(data.table)

# Create publication-quality plots
plt <- buildPlot(
  data = my_data,
  type = "scatter",
  x = "variable1",
  y = "variable2"
)

# Generate formatted tables
tbl <- buildTable(
  data = my_data,
  format = "flextable",
  caption = "Summary statistics"
)

# Display utilities
showCode("script.R")                 # Syntax-highlighted code
showHTML("report.html")              # Rendered HTML
showPDF("document.pdf")              # PDF viewer
showMarkdownRendered("README.md")   # Rendered markdown
```

## Documentation

See function documentation via R help:

```r
?NGR
?buildPlot
?buildTable
```

Full API: `buildPlot()`, `buildTable()`, `buildYAML()`, `showCode()`, `showHTML()`, `showPDF()`, `showMarkdownRendered()`, `showGithubREADME()`, `showASCII()`, `typewriter()`, `rotateTypewriter()`, specialized plot functions (Bar, Histogram, Hist2D, Hist3D, Model)

## Dependencies

- R (>= 4.1.0)
- yaml, brio, data.table
- flextable, gt, officer, kableExtra (table backends)
- highcharter, htmlwidgets, webshot2, plotly (interactive plots)
- grDevices, stats, graphics

## License

[MIT License](LICENSE)

---

**Author:** Alejandro Verri Kozlowski  
**Email:** averri@fi.uba.ar  
**ORCID:** [0000-0002-8535-1170](https://orcid.org/0000-0002-8535-1170)
