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

### R package

```r
# From GitHub
devtools::install_github("averriK/NGR")

# From CRAN (when published)
# install.packages("NGR")
```

### Python package (experimental)

The same repository contains a Python package installable via `pip`. Its API
will progressively mirror the main NGR functions available in R.

Install from PyPI:

```bash
pip install ngr
```

Basic usage:

```python
import ngr

print(ngr.__version__)
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

Full API: `buildPlot()`, `buildTable()`, `buildYAML()`, `showCode()`, `showHTML()`, `showPDF()`, `showMarkdownRendered()`, `showGithubREADME()`, `showASCII()`, `showTypewriter()`, `rotateTypewriter()`, `buildIndexTypewriter()`, specialized plot functions (Bar, Histogram, Hist2D, Hist3D, Model)

### Main functions
- buildPlot(...): High-level plotting with consistent styling; specialized variants for Bar/Histogram/Hist2D/Hist3D/Model.
- buildTable(...): Publication-quality tables via gt/flextable/kableExtra backends with captions and styles.
- buildYAML(...): Compose Quarto YAML blocks for multi-format rendering.
- Display utilities: showCode(), showHTML(), showPDF(), showMarkdownRendered(), showGithubREADME(), showASCII().
- Presentation effects: showTypewriter(), rotateTypewriter(), buildIndexTypewriter().

## Dependencies

- R (>= 4.1.0)
- yaml, brio, data.table
- flextable, gt, officer, kableExtra (table backends)
- highcharter, htmlwidgets, webshot2, plotly (interactive plots)
- grDevices, stats, graphics

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
