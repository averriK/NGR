# Build a highchart plot

Build a highchart plot using separate data sources for lines, points,
and explicit lower/upper ranges.

Supports line, scatter, and range series. A range is rendered as one
line when its bounds coincide, or as two linked boundary lines and a
shaded band otherwise. Also includes optional arearange shading between
two line groups if indicated in `data.lines$fill`, and interpolation is
handled via the `approx` function (which can be customized using the
`interpolation.method` argument). Fallback behaviors: if an invalid
`line.type` is provided, `"line"` is used; if an invalid or missing line
style is found, `"solid"` is used; if an invalid `color.palette` is
provided, a default Highcharts palette is chosen.

## Usage

``` r
buildPlot(
  library = NULL,
  plot.type = NULL,
  data.lines = NULL,
  data.points = NULL,
  line.type = "line",
  plot.title = NULL,
  plot.subtitle = NULL,
  plot.height = NULL,
  plot.width = NULL,
  xAxis.legend = "X",
  yAxis.legend = "Y",
  group.legend = "ID",
  color.palette = "Dark 3",
  line.style = "solid",
  point.style = "circle",
  line.size = 1,
  point.size = 3,
  xAxis.log = FALSE,
  yAxis.log = FALSE,
  xAxis.log.zero = TRUE,
  xAxis.log.zero.label = "0",
  xAxis.reverse = FALSE,
  yAxis.reverse = FALSE,
  xAxis.max = NA,
  yAxis.max = NA,
  xAxis.min = NA,
  yAxis.min = NA,
  xAxis.label = TRUE,
  yAxis.label = TRUE,
  legend.layout = "horizontal",
  legend.align = "right",
  legend.valign = "top",
  legend.show = TRUE,
  plot.save = FALSE,
  plot.theme = NULL,
  xAxis.legend.fontsize = "14px",
  yAxis.legend.fontsize = "14px",
  group.legend.fontsize = "12px",
  plot.title.fontsize = "24px",
  plot.subtitle.fontsize = "18px",
  print.max.abs = FALSE,
  point.dataLabels = FALSE,
  plot.filename = NULL,
  fill.opacity = 0.3,
  fill.legend = NULL,
  fill.max = ".max",
  fill.min = ".min",
  fill.minmax = FALSE,
  fill.max.style = "Solid",
  fill.min.style = "Solid",
  fill.max.size = NULL,
  fill.min.size = NULL,
  fill.max.color = "#00008B",
  fill.min.color = "#8B0000",
  interpolation.method = "linear",
  yAxis2 = NULL,
  yAxis2.legend = NULL,
  yAxis2.transform = NULL,
  yAxis2.decimals = 0,
  data.ranges = NULL
)
```

## Arguments

- library:

  DEPRECATED. A placeholder parameter that triggers a warning if used.

- plot.type:

  DEPRECATED. A placeholder parameter that triggers a warning if used.

- data.lines:

  A data.table containing columns "ID", "X", "Y", optional "style",
  optional "size", optional "fill", optional "yAxis" (0 or 1). If NULL,
  no lines will be plotted.

- data.points:

  A data.table containing columns "ID", "X", "Y", optional "style",
  optional "yAxis" (0 or 1). If NULL, no scatter points will be plotted.

- line.type:

  A string indicating the line series type. Options might include
  `"line"` or `"spline"`. If invalid, `"line"` is used.

- plot.title:

  A string for the plot title

- plot.subtitle:

  A string for the plot subtitle

- plot.height:

  A numeric for the plot height

- plot.width:

  A numeric for the plot width

- xAxis.legend:

  A string for the x-axis legend

- yAxis.legend:

  A string for the y-axis legend

- group.legend:

  A string for the legend title

- color.palette:

  A string for the color palette (must exist in
  [`grDevices::hcl.pals()`](https://rdrr.io/r/grDevices/palettes.html))

- line.style:

  A string specifying the default line style if `data.lines$style` is
  missing/invalid.

- point.style:

  A string specifying the default point marker style if
  `data.points$style` is missing/invalid.

- line.size:

  A numeric for the line width

- point.size:

  A numeric for the point size

- xAxis.log:

  A logical for the x-axis log scale

- yAxis.log:

  A logical for the y-axis log scale

- xAxis.log.zero:

  A logical for plotting `X == 0` points on log-log plots through an
  internal positive display coordinate. Source data remain unchanged and
  negative X values are not supported.

- xAxis.log.zero.label:

  Label used in tooltips for `X == 0` points when `xAxis.log.zero` is
  active.

- xAxis.reverse:

  A logical for the x-axis reverse

- yAxis.reverse:

  A logical for the y-axis reverse

- xAxis.max:

  A numeric for the x-axis max

- yAxis.max:

  A numeric for the y-axis max

- xAxis.min:

  A numeric for the x-axis min

- yAxis.min:

  A numeric for the y-axis min

- xAxis.label:

  A logical for the x-axis label

- yAxis.label:

  A logical for the y-axis label

- legend.layout:

  A string for the legend layout

- legend.align:

  A string for the legend horizontal alignment (e.g. `"center"`,
  `"left"`, `"right"`)

- legend.valign:

  A string for the legend vertical alignment (e.g. `"top"`, `"middle"`,
  `"bottom"`)

- legend.show:

  A logical for the legend show/hide

- plot.save:

  A logical for the plot save

- plot.theme:

  A highchart theme object

- xAxis.legend.fontsize:

  A string for the x-axis legend fontsize

- yAxis.legend.fontsize:

  A string for the y-axis legend fontsize

- group.legend.fontsize:

  A string for the legend items' fontsize

- plot.title.fontsize:

  A string for the plot title fontsize

- plot.subtitle.fontsize:

  A string for the plot subtitle fontsize

- print.max.abs:

  A logical for printing max absolute Y labels as annotations (only for
  lines)

- point.dataLabels:

  A logical for whether data labels appear for points

- plot.filename:

  A string for the plot filename, if saving

- fill.opacity:

  Opacity for arearange fill (0-1).

- fill.legend:

  Optional legend label for the shaded arearange band. If NULL or empty,
  a default label is used.

- fill.max:

  ID to use for the upper envelope series when auto-envelopes are
  enabled.

- fill.min:

  ID to use for the lower envelope series when auto-envelopes are
  enabled.

- fill.minmax:

  Logical flag; if TRUE and no explicit fill == TRUE is present in
  data.lines, automatically constructs upper/lower envelope series by X
  (using fill.max / fill.min as IDs) and shades between them.

- fill.max.style:

  Line style for upper envelope (default: "Solid").

- fill.min.style:

  Line style for lower envelope (default: "Solid").

- fill.max.size:

  Line width for upper envelope (default: NULL, uses global line.size).

- fill.min.size:

  Line width for lower envelope (default: NULL, uses global line.size).

- fill.max.color:

  Color for upper envelope (default: "#00008B", dark blue).

- fill.min.color:

  Color for lower envelope (default: "#8B0000", dark red).

- interpolation.method:

  A string specifying the interpolation method used by
  [`approx()`](https://rdrr.io/r/stats/approxfun.html).

- yAxis2:

  Advanced: optional list with Highcharts `yAxis[1]` options (secondary
  axis). If provided, it overrides `yAxis2.*` convenience arguments.

- yAxis2.legend:

  Optional string for the secondary Y axis title (right axis).

- yAxis2.transform:

  Optional one-sided formula to transform primary Y tick values for
  secondary axis labels in linked mode. Use `Y` as the primary axis tick
  value (e.g. `~ 1 / Y`).

- yAxis2.decimals:

  Integer number of decimals for secondary axis labels when using
  `yAxis2.transform` (passed to `Highcharts.numberFormat`).

- data.ranges:

  A data.frame or data.table with one row per unique combination of
  `"ID"` and `"X"`. Required columns are `"ID"`, `"X"`, `"lower"`, and
  `"upper"`; bounds must be finite and satisfy `lower <= upper`.
  Optional `"size"`, `"color"`, and `"yAxis"` values must be constant
  within each ID. Optional `"custom.lower"` and `"custom.upper"`
  named-list columns attach metadata to the corresponding boundary
  points. Coincident bounds produce one solid line; distinct bounds
  produce linked solid boundary lines and a shaded range with one legend
  item.

## Value

A highchart object if at least one of `data.lines`, `data.points`, or
`data.ranges` is provided. Returns NULL if all three are NULL, with a
soft warning.
