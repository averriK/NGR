# Build an acceleration response spectrum plot

Draws prepared acceleration spectra using
[`buildPlot()`](https://averriK.github.io/NGR/reference/buildPlot.md).
Periods are in seconds and spectral accelerations in g. The caller owns
selection, calculation, series names, order, line styles and widths.
This function applies the shared spectrum presentation: spline lines,
logarithmic period axis, a horizontal legend, gridlines and an optional
minimum–maximum band.

## Usage

``` r
buildSpectrumPlot(data, logScale, fill, fillSize)
```

## Arguments

- data:

  Prepared line data with the `ID`, `X`, `Y`, and optional `style` and
  `size` columns accepted by
  [`buildPlot()`](https://averriK.github.io/NGR/reference/buildPlot.md).
  `X` is period in seconds; `Y` is acceleration in g. The input is not
  modified.

- logScale:

  Whether the acceleration axis is logarithmic. When true, zero-period
  points are displayed with the PGA label using the zero-period
  convention of
  [`buildPlot()`](https://averriK.github.io/NGR/reference/buildPlot.md).

- fill:

  Whether to draw the minimum–maximum band across supplied series. The
  caller decides which series may be enveloped together.

- fillSize:

  Width of the dotted minimum and maximum boundary lines.

## Value

A `highchart` htmlwidget, with the same empty-input and validation
behavior as
[`buildPlot()`](https://averriK.github.io/NGR/reference/buildPlot.md).
No file is written and no project data or session variables are read.
