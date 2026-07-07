# Build a model plot

This function creates a model plot with data lines and points.

## Usage

``` r
buildPlot.Model(
  data.lines,
  data.points,
  xAxis.legend,
  yAxis.legend,
  line.width = 1.5,
  point.size = 2,
  point.shape = "circle"
)
```

## Arguments

- data.lines:

  A data.table with at least three columns: X (numeric), Y (numeric),
  and ID (factor).

- data.points:

  A data.table with at least three columns: X (numeric), Y (numeric),
  and ID (factor).

- xAxis.legend:

  The title for the x-axis.

- yAxis.legend:

  The title for the y-axis.

- line.width:

  The width of the line.

- point.size:

  The size of the points.

- point.shape:

  The shape of the points.

## Value

A highchart object representing the model plot.
