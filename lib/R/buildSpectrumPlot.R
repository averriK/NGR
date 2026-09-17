#' Build an acceleration response spectrum plot
#'
#' Draws prepared acceleration spectra using [buildPlot()]. Periods are in
#' seconds and spectral accelerations in g. The caller owns selection,
#' calculation, series names, order, line styles and widths. This function
#' applies the shared spectrum presentation: spline lines, logarithmic period
#' axis, a horizontal legend, gridlines and an optional minimum--maximum band.
#'
#' @param data Prepared line data with the `ID`, `X`, `Y`, and optional
#'   `style` and `size` columns accepted by [buildPlot()]. `X` is period in
#'   seconds; `Y` is acceleration in g. The input is not modified.
#' @param logScale Whether the acceleration axis is logarithmic. When true,
#'   zero-period points are displayed with the PGA label using the zero-period
#'   convention of [buildPlot()].
#' @param fill Whether to draw the minimum--maximum band across supplied
#'   series. The caller decides which series may be enveloped together.
#' @param fillSize Width of the dotted minimum and maximum boundary lines.
#'
#' @return A `highchart` htmlwidget, with the same empty-input and validation
#'   behavior as [buildPlot()]. No file is written and no project data or
#'   session variables are read.
#' @export
buildSpectrumPlot <- function(data, logScale, fill, fillSize) {
  buildPlot(
    data.lines = data,
    line.type = "spline",
    plot.height = 500,
    legend.layout = "horizontal",
    legend.show = TRUE,
    xAxis.log = TRUE,
    yAxis.log = logScale,
    xAxis.log.zero.label = "PGA",
    xAxis.legend = "Tn [s]",
    yAxis.legend = "Sa [g]",
    group.legend = "ID",
    plot.theme = hc_theme_538_gridlines(),
    fill.legend = "min\u2013max",
    fill.minmax = fill,
    fill.max.style = "Dot",
    fill.min.style = "Dot",
    fill.max.size = fillSize,
    fill.min.size = fillSize
  )
}
