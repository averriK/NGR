# NGR

**Next Generation Reporting: Advanced Tools for Professional Report Generation in R**

The NGR package provides comprehensive tools for generating professional and customizable reports in R. It offers advanced functions to create high-quality plots and well-formatted tables effortlessly, streamlining the process of data visualization and presentation. NGR integrates Quarto for multi-format rendering (HTML/PDF/DOCX) with configurable templates, enabling reproducible computational documents combining insightful graphics and tables seamlessly.

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![R](https://img.shields.io/badge/R-%E2%89%A54.1.0-blue)](https://www.r-project.org/)

## Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Core Features](#core-features)
- [Documentation](#documentation)
- [Dependencies](#dependencies)
- [References](#references)
- [Contributing](#contributing)
- [License](#license)
- [Citation](#citation)
- [Author](#author)

---

## Installation

Install NGR from GitHub using devtools:

```r
# Install devtools if not already installed
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Install NGR from GitHub
devtools::install_github("averriK/NGR")

# Load the package
library(NGR)
```

---

## Quick Start

### Display Content in Quarto/RMarkdown Documents

NGR provides specialized functions for embedding external content with `results: asis` chunk option:

```r
# Display GitHub README pages
showGithubREADME("NGR", user = "averriK", height = "500px")

# Embed HTML content (presentations, reports, web apps)
showHTML("https://example.com/presentation.html", height = "600px")

# Display PDF documents using PDF.js viewer
showPDF("document.pdf", height = "850px", pagemode = "none")

# Show syntax-highlighted source code
showCode("script.R")

# Display ASCII art with typewriter animation
showTypewriter(filePath = "banner.txt", font = "vt323", speed = 5)
```

### Create Highcharts Visualizations

```r
# Build interactive highchart plots
library(data.table)

# Prepare line data
lines <- data.table(
  ID = rep(c("Series A", "Series B"), each = 10),
  X = rep(1:10, 2),
  Y = c(rnorm(10, 5), rnorm(10, 8))
)

# Create plot
buildPlot(
  data.lines = lines,
  plot.title = "Sample Plot",
  xAxis.legend = "Time",
  yAxis.legend = "Value",
  color.palette = "Dark 3"
)
```

### Generate Tables

```r
# Create formatted tables for reports
buildTable(
  data = iris[1:10, ],
  output.format = "html"
)
```

---

## Core Features

### Content Display Functions

- **`showGithubREADME()`**: Embeds GitHub Pages README with automatic fallback for repositories without Pages or redirects blocking iframes
- **`showHTML()`**: Displays external HTML content (presentations, reports, web applications) in iframes
- **`showPDF()`**: Renders PDF documents using PDF.js viewer with configurable sidebar modes (none, thumbs, bookmarks)
- **`showCode()`**: Displays syntax-highlighted source code with automatic language detection from file extensions (supports 30+ languages)
- **`showTypewriter()`**: Animates ASCII art or text with typewriter effect, supporting 18 monospace fonts (Google Fonts and system fonts)
- **`rotateTypewriter()`**: Cycles through multiple text content with typewriter animations and configurable rotation intervals
- **`showASCII()`**: Displays static ASCII art with monospace font rendering

### Plotting Functions

- **`buildPlot()`**: Creates interactive Highcharts plots with support for lines, scatter points, arearange fills, log scales, custom color palettes, and configurable legends
- **`buildPlot.Bar()`**: Generates bar charts with grouping and stacking options
- **`buildPlot.Histogram()`**: Creates histogram distributions with customizable bins
- **`buildPlot.Hist2D()`**: Produces 2D heatmap histograms
- **`buildPlot.Hist3D()`**: Generates 3D surface plots from histogram data
- **`buildPlot.Model()`**: Visualizes statistical model fits and predictions

### Table Functions

- **`buildTable()`**: Generates formatted tables supporting multiple output formats (HTML, PDF, DOCX) using gt, flextable, or kableExtra backends

### Utility Functions

- **`buildYAML()`**: Constructs YAML front matter for Quarto/RMarkdown documents
- **`export()`**: Saves Highcharts visualizations as PNG/JPEG using webshot2
- **`local()`**: Manages local configuration and paths

---

## Documentation

### Function Reference

All exported functions include comprehensive documentation accessible via R's help system:

```r
# View function documentation
?showGithubREADME
?buildPlot
?showTypewriter
```

### Chunk Options for Display Functions

When using content display functions (`showGithubREADME`, `showHTML`, `showPDF`, `showCode`, `showTypewriter`), use these Quarto/RMarkdown chunk options:

```r
#| results: asis
#| echo: false  # Optional: hide code, show only output
```

### Font Support in Typewriter Functions

Available fonts for `showTypewriter()` and `rotateTypewriter()`:

**Google Fonts**: vt323 (default), ibm, courier, space, anonymous, press, silkscreen, atari, c64, dotgothic, overpass, nova, syne, orbitron, electrolize

**System Fonts**: printchar21, prnumber3, data70

---

## Dependencies

### Core Packages

- `yaml`: YAML configuration parsing
- `brio`: Fast file operations
- `data.table`: Efficient data manipulation
- `highcharter`: Interactive Highcharts visualizations
- `htmlwidgets`: HTML widget framework
- `webshot2`: Screenshot functionality for saving plots

### Table Generation

- `flextable`: Flexible table formatting
- `gt`: Grammar of tables
- `kableExtra`: Enhanced kable tables
- `officer`: Office document generation

### Visualization

- `plotly`: Interactive plotly charts
- `grDevices`: Graphics device interface
- `graphics`: Base R graphics
- `stats`: Statistical functions

### Development Dependencies

- `devtools`: Package development tools
- `roxygen2`: Documentation generation
- `knitr`: Dynamic report generation
- `rmarkdown`: R Markdown rendering

---

## References

### Related Tools

NGR integrates with the following ecosystem:

1. **Quarto**: Scientific and technical publishing system. [https://quarto.org/](https://quarto.org/)
2. **Highcharts**: Interactive charting library. [https://www.highcharts.com/](https://www.highcharts.com/)
3. **PDF.js**: PDF rendering in web browsers. [https://mozilla.github.io/pdf.js/](https://mozilla.github.io/pdf.js/)

---

## Contributing

Issues and pull requests are welcome at the [GitHub repository](https://github.com/averriK/NGR).

For bug reports, please include:
- Operating system and version
- R version (check with `R.version.string`)
- Complete command that caused the issue
- Error messages and logs
- Session info output (`sessionInfo()`)

---

## License

MIT License

Copyright (c) 2025 Alejandro Verri Kozlowski

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

## Citation

When using this package in research or professional work, please cite:

```bibtex
@software{NGR2025,
  author = {Verri Kozlowski, Alejandro},
  title = {NGR: Next Generation Reporting},
  year = {2025},
  version = {0.3.3},
  url = {https://github.com/averriK/NGR}
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
