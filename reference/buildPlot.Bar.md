# Build a bar/column plot (Highcharts)

Produce a bar/column chart from a data.table that has columns X, Y, and
ID.

- X can be factor/character for categorical x-axis or numeric for linear
  x-axis.

- Y must be numeric (the bar height).

- ID is used to create separate series (groups).

## Usage

``` r
buildPlot.Bar(
  .data,
  plot.title = NULL,
  plot.subtitle = NULL,
  xAxis.legend = "X axis",
  yAxis.legend = "Y axis",
  color.palette = "Dark 2",
  legend.show = TRUE,
  legend.layout = "horizontal",
  legend.align = "right",
  legend.valign = "top",
  plot.width = NULL,
  plot.height = NULL,
  stacking = c("none", "normal", "percent"),
  bar.groupPadding = 0.2,
  bar.pointPadding = 0.1,
  bar.borderWidth = 0,
  bar.borderColor = "#FFFFFF",
  plot.theme = NULL
)
```

## Arguments

- .data:

  A data.table with columns: X, Y, ID.

- plot.title:

  Character; main chart title.

- plot.subtitle:

  Character; optional subtitle.

- xAxis.legend:

  Character; label for the x-axis. Default "X axis".

- yAxis.legend:

  Character; label for the y-axis. Default "Y axis".

- color.palette:

  Either a character vector of hex colors or a single string matching a
  known palette in
  [`grDevices::hcl.pals()`](https://rdrr.io/r/grDevices/palettes.html).
  Defaults to "Dark 2".

- legend.show:

  Logical; whether to show the legend. Default TRUE.

- legend.layout:

  One of c("horizontal","vertical"). Default "horizontal".

- legend.align:

  One of c("left","center","right"). Default "right".

- legend.valign:

  One of c("top","middle","bottom"). Default "top".

- plot.width:

  Numeric; width in pixels. If NULL, uses default.

- plot.height:

  Numeric; height in pixels. If NULL, uses default.

- stacking:

  One of c("none","normal","percent"). Default "none".

  - "none": grouped bars

  - "normal": stacked bars

  - "percent": 100% stacked

- bar.groupPadding:

  Numeric; spacing between groups of bars, default 0.2.

- bar.pointPadding:

  Numeric; spacing between bars within a group, default 0.1.

- bar.borderWidth:

  Numeric; width of bar border line. Default = 0.

- bar.borderColor:

  Character; color of the bar border line. Default "#FFFFFF".

- plot.theme:

  Optional highchart theme object (e.g. `hc_theme_flat()`).

## Value

A highchart object representing the bar/column plot.
