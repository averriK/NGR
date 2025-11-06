# NGR

**NextGen Report Generation for data-driven technical documents**

R package for precise, reproducible report generation with interactive plots, professional tables, and Quarto integration.

- Version: 0.3.3
- License: GPL (>= 3)
- R: >= 4.1.0

[![R Version](https://img.shields.io/badge/R-%3E%3D%204.1.0-blue)](https://www.r-project.org/)
[![Version](https://img.shields.io/badge/version-0.3.3-green)](https://github.com/averriK/ngr)
[![License](https://img.shields.io/badge/license-GPL--3.0-green.svg)](LICENSE)

## Contents

- [Features](#features)
- [Installation](#installation)
- [Core Functions](#core-functions)
- [Use Cases](#use-cases)
- [Dependencies](#dependencies)
- [Project Structure](#project-structure)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [Changelog](#changelog)
- [License](#license)
- [Citation](#citation)
- [Author](#author)
- [Acknowledgments](#acknowledgments)

---

## Features

- **Interactive Highcharter Plots**: Line, spline, area, and scatter plots with `buildPlot()`
- **Specialized Plot Types**: Bar charts, histograms, 2D/3D histograms (plotly), model comparison plots  
- **Multi-Library Table Support**: `buildTable()` works with flextable, gt, and kable
- **Quarto Integration**: `buildYAML()` assembles `_quarto.yml` for multi-format rendering
- **Advanced Customization**: Fonts, colors, themes, logarithmic/reversed axes, legends, annotations
- **Format-Aware Tables**: Automatic styling adaptation for HTML, PDF, and DOCX outputs
- **Multi-Format Output**: Render HTML, PDF, Word via Quarto in a single step
- **Language Support**: Multi-language report generation with configurable templates
- **Interactive Exports**: Save highcharter plots as standalone HTML widgets
- **Presentation Tools**: Vintage typewriter effects for revealjs presentations
- **Viewers**: Inline ASCII and rendered Markdown via iframe

---

## Installation

```r
# Install devtools if needed
install.packages("devtools")

# Install ngr from GitHub
devtools::install_github("averriK/ngr")
```

---

## Core Functions

### Exported Functions

From NAMESPACE, the following are exported:

**Plotting:**
- `buildPlot` - Interactive line/scatter plots
- `buildPlot.Bar` - Bar/column charts
- `buildPlot.Histogram` - 1D histograms with optional density
- `buildPlot.Model` - Model comparison plots
- `buildPlot.Hist2D` - 2D heatmaps/contour plots (plotly)
- `buildPlot.Hist3D` - 3D bar histograms (plotly)

**Tables:**
- `buildTable` - Formatted tables (gt/flextable/kable)

**Reports:**
- `buildYAML` - Assemble `_quarto.yml` and prepare folders

**Presentation:**
- `showTypewriter` - Typewriter effect for revealjs
- `rotateTypewriter` - Rotating typewriter animations
- `buildIndexTypewriter` - Chapter index with typewriter effect

**Viewers:**
- `showASCII` - Display raw text files
- `showMarkdownRendered` - Render and embed markdown files

### Function Overview

| Function | Description | Input | Output |
|----------|-------------|-------|--------|
| **Plotting** |
| `buildPlot` | Interactive line/scatter plots | data.table with ID, X, Y | highchart object |
| `buildPlot.Bar` | Bar/column charts | data.table with ID, X, Y | highchart object |
| `buildPlot.Histogram` | 1D histograms with optional density | data.table with ID, X | highchart object |
| `buildPlot.Model` | Model comparison plots | data.lines, data.points | highchart object |
| `buildPlot.Hist2D` | 2D heatmaps/contour plots | data.table with X, Y, Z | plotly object |
| `buildPlot.Hist3D` | 3D bar histograms | data.table with X, Y, Z | plotly object |
| **Tables** |
| `buildTable` | Formatted tables | data.table | Formatted table object |
| **Reports** |
| `buildYAML` | Assemble Quarto config | .qmd + config files | `_quarto.yml` + dirs |

---

## Use Cases

- **Seismic Hazard Reports**: Acceleration spectra, hazard curves, site amplification plots
- **Engineering Analysis**: Structural response, displacement time-histories, capacity curves
- **Research Publications**: Multi-format output (HTML for web, PDF for journals, Word for preprints)
- **Client Deliverables**: Professional tables and interactive plots embedded in reports
- **Data Exploration**: Rapid prototyping of visualization + table combinations
- **Reproducible Research**: Version-controlled Quarto workflows with embedded R code
- **Technical Documentation**: API documentation, method descriptions with code examples
- **Dashboards**: Standalone HTML plots exported for embedding in web applications

---

## Dependencies

### Core Requirements

- **R 4.1.0+**: Required R version (per DESCRIPTION)
- **Quarto**: External CLI tool for rendering (install from https://quarto.org)

### R Package Dependencies

**Plotting (5 packages):**
- `highcharter`: JavaScript charts (primary)
- `plotly`: 3D plots
- `htmlwidgets`: Widget export
- `webshot2`: Screenshot generation
- `grDevices`, `graphics`, `stats`: Base R graphics

**Tables (4 packages):**
- `gt`: Grammar of tables
- `flextable`: Flexible table layouts
- `kableExtra`: Enhanced kable
- `officer`: Office formats

**Data (1 package):**
- `data.table`: Fast data manipulation

**Report (2 packages):**
- `yaml`: Configuration parsing
- `brio`: File I/O

### System Dependencies

- **Quarto CLI**: https://quarto.org/docs/get-started/
- **Pandoc**: Included with Quarto
- **LaTeX** (for PDF): TinyTeX recommended (`quarto install tinytex`)

---

## Project Structure

```
ngr/
├── DESCRIPTION              # Package metadata
├── NAMESPACE                # Exported functions
├── LICENSE.md               # GPL-3.0
├── README.md                # This file
├── R/                       # Source code
│   ├── buildPlot.R         # Main plotting function
│   ├── buildPlot.Bar.R     # Bar chart specialization
│   ├── buildPlot.Histogram.R
│   ├── buildPlot.Model.R
│   ├── buildPlot.Hist2D.R  # 2D histograms (heatmaps/contours)
│   ├── buildPlot.Hist3D.R  # 3D bar histograms
│   ├── buildTable.R        # Table formatting
│   ├── buildYAML.R         # Build consolidated _quarto.yml
│   ├── typewriter.R        # Typewriter effects
│   ├── showASCII.R         # ASCII viewer
│   ├── showMarkdownRendered.R  # Markdown viewer
│   ├── export.R            # Export utilities
│   └── local.R             # Internal helpers
├── man/                     # Documentation (auto-generated)
├── inst/                    # Installed files
│   ├── extdata/            # Support files for reports
│   ├── examples/           # Usage examples
│   └── docx/               # Word styles
└── tests/                   # Unit tests
```

---

## Documentation

Function documentation is available via R help system:

```r
# Plotting functions
?buildPlot              # Main plotting function
?buildPlot.Bar          # Bar charts
?buildPlot.Histogram    # Histograms with density
?buildPlot.Model        # Model comparison plots
?buildPlot.Hist2D       # 2D heatmaps/contours
?buildPlot.Hist3D       # 3D bar histograms

# Table functions
?buildTable             # Format tables (gt/flextable/kable)

# Report functions
?buildYAML              # Assemble Quarto configuration

# Presentation utilities
?showTypewriter         # Typewriter effect
?rotateTypewriter       # Rotating typewriter
?buildIndexTypewriter   # Chapter index

# Viewers
?showASCII              # Display raw text
?showMarkdownRendered   # Render and embed markdown
```

For package overview:
```r
?ngr
```

---

## Contributing

Issues and pull requests are welcome at the [GitHub repository](https://github.com/averriK/ngr).

For bug reports, please include:
- R version and platform
- Package versions (`sessionInfo()`)
- Minimal reproducible example
- Expected vs actual output

For feature requests:
- Use case description
- Proposed API
- Example code

---

## Changelog

### Version 0.4.1 (Current - Development Branch)

**Typewriter Enhancements:**
- Added `texts=` parameter to `rotateTypewriter()` for direct string vectors
- Added `terminalWidth=` parameter to both `showTypewriter()` and `rotateTypewriter()`
- Emulate classic terminal widths: 40, 60, or 80 columns
- Auto-calculated width based on fontSize
- Validates terminalWidth input (40/60/80) with warning for invalid values
- Backward compatible: default behavior unchanged

**Histogram Functions:**
- Renamed `buildHist2D` → `buildPlot.Hist2D` for naming consistency
- Renamed `buildHist3D` → `buildPlot.Hist3D` for naming consistency
- Fixed critical bug in `get_decimal_places()` that only processed first vector element
- Removed dead code in `buildPlot.Hist3D`
- Updated NAMESPACE and documentation

**Breaking Changes:**
- `buildHist2D` and `buildHist3D` renamed (use `buildPlot.Hist2D`, `buildPlot.Hist3D`)

### Version 0.3.3

**Plot Enhancements:**
- Refactored `buildPlot()` to support separate `data.lines` and `data.points` inputs
- Added `line.type` parameter: "line", "spline"
- Implemented area range shading via `fill` column in data.lines
- Improved color palette validation with fallback to Highcharts defaults
- Enhanced line style handling with solid/dash/dot/dashDot options
- Added interpolation method parameter for `approx()` customization
- Deprecated `library` and `plot.type` parameters

**Table Improvements:**
- Enhanced global font controls (`font.size.all`, `font.family.all`, `font.bold.all`)
- Improved border customization (show/hide, color, size for h/v lines)
- Better format detection and library-specific rendering
- Caption support for gt, flextable, and kable

**Report Features:**
- Multi-language template support (_params_ES.yml, _html_EN.yml, etc.)
- Modular YAML configuration system
- Bibliography integration (references.bib auto-detection)
- Author metadata validation and formatting
- Automatic logo and CSS file detection and inclusion
- New `buildYAML()` function to assemble `_quarto.yml`

**Bug Fixes:**
- Fixed axis log scale behavior
- Improved legend positioning and alignment
- Fixed table border rendering in DOCX format
- Corrected color palette fallback mechanism

**Breaking Changes:**
- `buildPlot()` now requires `data.lines` or `data.points` instead of `data`
- `library` and `plot.type` parameters deprecated (use `line.type` instead)
- Rendering now done via Quarto directly

### Version 0.3.0

- Initial public release
- Core functions: buildPlot, buildTable, buildYAML
- Support for highcharter plots
- gt, flextable, kableExtra table rendering
- Quarto integration

---

## License

GPL-3.0

Copyright (c) 2025 Alejandro Verri Kozlowski

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

---

## Citation

When using this package in research or professional work, please cite:

```bibtex
@software{ngr2025,
  author = {Verri Kozlowski, Alejandro},
  title = {ngr: Professional Report Generation for R},
  year = {2025},
  version = {0.3.3},
  url = {https://github.com/averriK/ngr}
}
```

---

## Author

**Alejandro Verri Kozlowski**

- Email: averri@fi.uba.ar
- ORCID: [0000-0002-8535-1170](https://orcid.org/0000-0002-8535-1170)
- GitHub: [@averriK](https://github.com/averriK)

**Affiliation:**
- Facultad de Ingeniería, Universidad de Buenos Aires

---

## Acknowledgments

Built on the work of many excellent R packages:
- Highcharts.js via `highcharter` by Joshua Kunst
- Grammar of Tables (`gt`) by RStudio
- `flextable` by David Gohel
- Quarto by Posit PBC
- data.table by Matt Dowle and Arun Srinivasan
