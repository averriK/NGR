# NGR

**NextGen Report Generation for data-driven technical documents**

R package providing visualization, table formatting, and document embedding tools for Quarto-based reproducible research workflows.

[![R Version](https://img.shields.io/badge/R-%3E%3D%204.1.0-blue)](https://www.r-project.org/)
[![Version](https://img.shields.io/badge/version-0.4.1-green)](https://github.com/averriK/NGR)
[![License](https://img.shields.io/badge/license-GPL--3.0-green.svg)](LICENSE)

---

## Quick Start

```r
# Install from GitHub
devtools::install_github("averriK/NGR")

# Load package
library(NGR)

# Create interactive plot
data <- data.table(ID = "Series1", X = 1:10, Y = rnorm(10))
buildPlot(data.lines = data)

# Format table
buildTable(iris[1:5,], library = "gt")

# Embed rendered markdown
showMarkdownRendered("document.md", theme = "sketchy")
```

---

## Features

NGR provides **19 exported functions** organized into 5 categories:

### 📊 Visualization (6 functions)
Interactive highcharter and plotly visualizations with extensive customization

### 📋 Tables (1 function)
Format-aware table generation with gt, flextable, and kable support

### 📄 Document Embedding (6 functions)
Inline viewers for HTML, PDF, Markdown, ASCII, code, and GitHub READMEs

### 🎬 Presentation Effects (3 functions)
Vintage typewriter animations and chapter indices for RevealJS slides

### 🔧 Report Assembly (3 functions)
Quarto configuration management and multi-format rendering

---

## Installation

### Requirements
- **R 4.1.0+**
- **Quarto CLI**: https://quarto.org/docs/get-started/
- **LaTeX** (PDF output): `quarto install tinytex`

### Install Package

```r
# Install devtools if needed
install.packages("devtools")

# Install NGR from GitHub
devtools::install_github("averriK/NGR")
```

---

## Function Reference

### 📊 Visualization

| Function | Description | Output |
|----------|-------------|--------|
| `buildPlot()` | Interactive line/scatter/area plots | highchart |
| `buildPlot.Bar()` | Bar and column charts | highchart |
| `buildPlot.Histogram()` | 1D histograms with optional density curves | highchart |
| `buildPlot.Model()` | Model comparison plots (lines + points) | highchart |
| `buildPlot.Hist2D()` | 2D heatmaps and contour plots | plotly |
| `buildPlot.Hist3D()` | 3D bar histograms | plotly |

**Example:**
```r
# Line plot with area shading
data <- data.table(
  ID = rep("A", 10),
  X = 1:10,
  Y = rnorm(10),
  fill = rnorm(10, sd = 0.5)
)
buildPlot(data.lines = data, line.type = "spline")
```

### 📋 Tables

| Function | Description | Libraries |
|----------|-------------|-----------|
| `buildTable()` | Format data.table as professional table | gt, flextable, kable |

**Features:**
- Automatic format detection (HTML/PDF/DOCX)
- Global font controls (size, family, bold)
- Border customization (show/hide, color, size)
- Caption support across all libraries

**Example:**
```r
buildTable(
  data = iris[1:10,],
  library = "gt",
  caption = "Iris Dataset Sample",
  font.size.all = 12,
  font.family.all = "Arial"
)
```

### 📄 Document Embedding

| Function | Description | Use Case |
|----------|-------------|----------|
| `showMarkdownRendered()` | Render markdown with themes (sketchy/water) | Agent session outputs |
| `showHTML()` | Embed HTML files in iframe | Interactive dashboards |
| `showPDF()` | Display PDF via PDF.js viewer | Technical reports |
| `showASCII()` | Display raw text with syntax highlighting | Log files, configs |
| `showCode()` | Display source code with line numbers | Code examples |
| `showGithubREADME()` | Fetch and render GitHub README | Package documentation |

**Example:**
```r
# Render markdown with sketchy theme
showMarkdownRendered(
  "analysis.md",
  theme = "sketchy",
  force = TRUE
)

# Embed PDF document
showPDF("report.pdf", height = "600px")

# Display code with syntax highlighting
showCode("script.R", language = "r")
```

### 🎬 Presentation Effects

| Function | Description | Use Case |
|----------|-------------|----------|
| `showTypewriter()` | Vintage typewriter animation | Terminal session playback |
| `rotateTypewriter()` | Rotating typewriter displays | Multi-file showcase |
| `buildIndexTypewriter()` | Chapter index with typewriter effect | Presentation navigation |

**Features:**
- Configurable speed, font, colors
- Terminal width emulation (40/60/80 columns)
- Fixed-height containers with auto-scroll
- Multiple text rotation

**Example:**
```r
# Display terminal session
showTypewriter(
  filePaths = "session.out",
  speed = 5,
  terminalWidth = 80,
  height = "400px"
)

# Rotate multiple displays
rotateTypewriter(
  filePaths = c("log1.txt", "log2.txt"),
  speed = 3,
  interval = 5000
)
```

### 🔧 Report Assembly

| Function | Description | Output |
|----------|-------------|--------|
| `buildYAML()` | Assemble `_quarto.yml` from modular configs | Quarto config file |
| `export.highchart()` | Save highchart as standalone HTML | Interactive widget |
| `export.plotly()` | Save plotly as standalone HTML | Interactive widget |

**Example:**
```r
# Build Quarto configuration
buildYAML(
  root = ".",
  language = "EN",
  project_type = "book"
)

# Export standalone plot
chart <- buildPlot(data.lines = data)
export.highchart(chart, file = "plot.html")
```

---

## Use Cases

### Scientific Reports
- **Seismic hazard analysis**: Acceleration spectra, hazard curves
- **Engineering calculations**: Displacement time-histories, capacity curves
- **Statistical analysis**: Correlation plots, distribution histograms

### Research Publications
- **Multi-format output**: HTML (web), PDF (journals), Word (preprints)
- **Reproducible workflows**: Version-controlled Quarto + embedded R code
- **Interactive visualizations**: Standalone HTML exports for web

### Technical Documentation
- **API documentation**: Code examples with syntax highlighting
- **Method descriptions**: Mathematical formulas + validation plots
- **Session playback**: Terminal typewriter effects for demos

### Agent-Assisted Workflows
- **RAG review sessions**: Embed agent outputs with sketchy/water themes
- **Verification audits**: Display footnoted markdown with inline citations
- **Code generation logs**: Typewriter animation of agent sessions

---

## Documentation

Function documentation via R help system:

```r
# Package overview
?NGR

# Visualization
?buildPlot
?buildPlot.Bar
?buildPlot.Histogram
?buildPlot.Model
?buildPlot.Hist2D
?buildPlot.Hist3D

# Tables
?buildTable

# Document embedding
?showMarkdownRendered
?showHTML
?showPDF
?showASCII
?showCode
?showGithubREADME

# Presentation
?showTypewriter
?rotateTypewriter
?buildIndexTypewriter

# Report assembly
?buildYAML
```

---

## Dependencies

### Core Requirements
- **R 4.1.0+**
- **Quarto CLI**: https://quarto.org

### R Packages (auto-installed)

**Visualization (5):**
- `highcharter`: JavaScript charts
- `plotly`: 3D plots
- `htmlwidgets`: Widget export
- `webshot2`: Screenshots
- `grDevices`, `graphics`, `stats`: Base graphics

**Tables (4):**
- `gt`: Grammar of tables
- `flextable`: Flexible layouts
- `kableExtra`: Enhanced kable
- `officer`: Office formats

**Data (1):**
- `data.table`: Fast manipulation

**Reports (2):**
- `yaml`: Config parsing
- `brio`: File I/O

---

## Project Structure

```
NGR/
├── DESCRIPTION              # Package metadata
├── NAMESPACE                # Exported functions (19 total)
├── LICENSE.md               # GPL-3.0
├── README.md                # This file
├── R/                       # Source code (19 files)
│   ├── buildPlot*.R        # Visualization (6 files)
│   ├── buildTable.R        # Tables
│   ├── show*.R             # Document embedding (6 files)
│   ├── *typewriter*.R      # Presentation effects (3 files)
│   ├── buildYAML.R         # Report assembly
│   ├── export.R            # Export utilities
│   └── local.R             # Internal helpers
├── man/                     # Documentation (auto-generated)
├── inst/                    # Installed files
│   ├── extdata/            # Report templates
│   ├── examples/           # Usage examples
│   └── docx/               # Word styles
└── tests/                   # Unit tests
```

---

## Changelog

### Version 0.4.1 (Development)

**New Features:**
- Added `height=` parameter to typewriter functions (default "300px")
- Added `texts=` parameter to `rotateTypewriter()` for string vectors
- Added `terminalWidth=` parameter (40/60/80 column emulation)

**Bug Fixes:**
- Fixed `get_decimal_places()` processing only first element
- Fixed typewriter infinite vertical growth in slides

**Breaking Changes:**
- Renamed `buildHist2D` → `buildPlot.Hist2D`
- Renamed `buildHist3D` → `buildPlot.Hist3D`

### Version 0.3.3

**Plot Enhancements:**
- Refactored `buildPlot()` with separate `data.lines`/`data.points`
- Added `line.type` parameter: "line", "spline"
- Area range shading via `fill` column
- Enhanced color palette validation

**Table Improvements:**
- Global font controls (`font.size.all`, `font.family.all`)
- Border customization (show/hide, color, size)
- Caption support for gt, flextable, kable

**Report Features:**
- Multi-language templates (_params_ES.yml, _html_EN.yml)
- Modular YAML configuration
- Bibliography integration (references.bib auto-detection)

**Breaking Changes:**
- `buildPlot()` requires `data.lines` or `data.points` (not `data`)
- `library` and `plot.type` parameters deprecated

---

## Contributing

Issues and pull requests: [GitHub repository](https://github.com/averriK/NGR)

**Bug reports include:**
- R version and platform (`sessionInfo()`)
- Minimal reproducible example
- Expected vs actual output

**Feature requests include:**
- Use case description
- Proposed API
- Example code

---

## License

GPL-3.0 - Copyright (c) 2025 Alejandro Verri Kozlowski

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

---

## Citation

```bibtex
@software{NGR2025,
  author = {Verri Kozlowski, Alejandro},
  title = {NGR: NextGen Report Generation for R},
  year = {2025},
  version = {0.4.1},
  url = {https://github.com/averriK/NGR}
}
```

---

## Author

**Alejandro Verri Kozlowski**

- Email: averri@fi.uba.ar
- ORCID: [0000-0002-8535-1170](https://orcid.org/0000-0002-8535-1170)
- GitHub: [@averriK](https://github.com/averriK)
- Affiliation: Facultad de Ingeniería, Universidad de Buenos Aires

---

## Acknowledgments

Built on excellent R packages:
- Highcharts.js via `highcharter` (Joshua Kunst)
- `gt` Grammar of Tables (RStudio)
- `flextable` (David Gohel)
- Quarto (Posit PBC)
- `data.table` (Matt Dowle, Arun Srinivasan)
