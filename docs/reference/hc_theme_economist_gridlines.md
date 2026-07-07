# Highcharter theme based on The Economist with enhanced gridlines

A professional magazine-quality theme based on hc_theme_economist() that
includes visible minor gridlines, particularly useful for logarithmic
scales.

The Economist is renowned for their clean, authoritative visualizations.
This theme adds:

- Subtle major gridlines in light gray (#D8D8D8)

- Very light minor gridlines (#F0F0F0)

- Thin line widths (0.6 for major, 0.25 for minor)

- minorTickInterval = "auto" for logarithmic scales

## Usage

``` r
hc_theme_economist_gridlines()
```

## Value

A highcharter theme object (list with class "hc_theme")

## Examples

``` r
if (FALSE) { # \dontrun{
library(highcharter)
hchart(mtcars, "scatter", hcaes(x = wt, y = mpg)) |>
  hc_add_theme(hc_theme_economist_gridlines())
} # }
```
