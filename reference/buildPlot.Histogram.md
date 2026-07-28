# Build a histogram (and/or density) plot

Creates a histogram and/or density plot, with optional log-scale,
quantile markers, and Freedman–Diaconis bin calculation. This version
ensures density scaling is computed even if only density is plotted (so
the density curve appears).

## Usage

``` r
buildPlot.Histogram(
  .data,
  plot.type = c("histogram"),
  histogram.breaks = NULL,
  xAxis.log = FALSE,
  xAxis.offset = 0.1,
  xAxis.legend = "X axis",
  yAxis.legend = "Count",
  plot.title = NULL,
  plot.subtitle = NULL,
  plot.markers = FALSE,
  color.palette = "Dark3",
  legend.layout = "horizontal",
  legend.align = "right",
  legend.valign = "top",
  legend.show = TRUE,
  plot.height = NULL,
  plot.width = NULL
)
```

## Arguments

- .data:

  A data.table with columns "X" (numeric) and "ID" (factor or
  character).

- plot.type:

  Character vector: `"histogram"`, `"density"`, or both, e.g.
  `c("histogram","density")`.

- histogram.breaks:

  Either NULL (automatic Freedman–Diaconis) or numeric (number of bins).

- xAxis.log:

  Logical; if TRUE, use log-scale on the X data. Default FALSE.

- xAxis.offset:

  Numeric; fraction to expand the x-axis range on each side. Default
  0.1.

- xAxis.legend:

  Character label for the x-axis (display only). Default "X axis".

- yAxis.legend:

  Character label for the y-axis. Default "Count".

- plot.title:

  Character; main title. Default NULL.

- plot.subtitle:

  Character; optional subtitle. Default NULL.

- plot.markers:

  Logical; if TRUE, add quantile markers. Default FALSE.

- color.palette:

  Either a character vector of colors or a single string fallback.
  Default "Dark3".

- legend.layout:

  One of `c("horizontal","vertical")`. Default "horizontal".

- legend.align:

  One of `c("left","center","right")`. Default "right".

- legend.valign:

  One of `c("top","middle","bottom")`. Default "top".

- legend.show:

  Logical; if FALSE, hides the legend. Default TRUE.

- plot.height:

  Numeric, chart height in pixels (if NULL, defaults). Default NULL.

- plot.width:

  Numeric, chart width in pixels (if NULL, defaults). Default NULL.

## Value

A highchart object.
