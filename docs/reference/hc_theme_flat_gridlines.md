# Highcharter theme based on hc_theme_flat with enhanced gridlines

A professional highcharter theme based on hc_theme_flat() that includes
visible minor gridlines, particularly useful for logarithmic scales.

This theme is identical to hc_theme_flat() but adds:

- minorGridLineWidth for both axes

- minorTickInterval = "auto" for logarithmic scales

- Lighter color for minor gridlines (#D5D8DC) vs major gridlines
  (#BDC3C7)

## Usage

``` r
hc_theme_flat_gridlines()
```

## Value

A highcharter theme object (list with class "hc_theme")

## Examples

``` r
if (FALSE) { # \dontrun{
library(highcharter)
hchart(mtcars, "scatter", hcaes(x = wt, y = mpg)) |>
  hc_add_theme(hc_theme_flat_gridlines())
} # }
```
