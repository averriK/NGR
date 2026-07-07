# Highcharter theme based on hc_theme_hcrt with enhanced gridlines

A professional highcharter theme based on hc_theme_hcrt() that includes
visible minor gridlines, particularly useful for logarithmic scales.

This theme is identical to hc_theme_hcrt() but adds:

- minorGridLineWidth for both axes (visible minor gridlines)

- minorTickInterval = "auto" for logarithmic scales

- Lighter color for minor gridlines (#E8E8E8) vs major gridlines
  (#F3F3F3)

## Usage

``` r
hc_theme_hcrt_gridlines()
```

## Value

A highcharter theme object (list with class "hc_theme")

## Examples

``` r
if (FALSE) { # \dontrun{
library(highcharter)
hchart(mtcars, "scatter", hcaes(x = wt, y = mpg)) |>
  hc_add_theme(hc_theme_hcrt_gridlines())
} # }
```
