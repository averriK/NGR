# Highcharter theme based on FiveThirtyEight (538) with enhanced gridlines

A professional data journalism theme based on hc_theme_538() that
includes visible minor gridlines, particularly useful for logarithmic
scales.

FiveThirtyEight is known for their clean, data-driven visualizations.
This theme maintains their signature style while adding:

- Optimized gridLineWidth for both major and minor lines

- Professional color contrast between major (#B0B0B0) and minor
  (#DDDDDD) gridlines

- minorTickInterval = "auto" for logarithmic scales

## Usage

``` r
hc_theme_538_gridlines()
```

## Value

A highcharter theme object (list with class "hc_theme")

## Examples

``` r
if (FALSE) { # \dontrun{
library(highcharter)
hchart(mtcars, "scatter", hcaes(x = wt, y = mpg)) |>
  hc_add_theme(hc_theme_538_gridlines())
} # }
```
