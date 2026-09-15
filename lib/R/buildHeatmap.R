#' @title Build a heatmap plot (Highcharts)
#' @description Build a Highcharts heatmap from a data.table with columns X, Y, Z.
#'
#' X and Y are treated as categorical axes: unique values are sorted and used as
#' category labels. Z is the numeric value mapped to the color axis. The function
#' converts the raw X/Y values to 0-based integer indices internally, and stores
#' the original labels in each point as `xLabel` and `yLabel`.
#'
#' Color axis defaults to the Inferno palette (10 stops). Supply `color.stops`
#' to override. `colorAxis.max` defaults to `ceiling(max(Z))` when NULL.
#'
#' @param .data A data.table with columns X, Y (raw category values) and Z (numeric).
#' @param xAxis.legend Character; x-axis title. Default `"X"`.
#' @param yAxis.legend Character; y-axis title. Default `"Y"`.
#' @param plot.title Character or NULL; chart title. Default NULL (no title).
#' @param colorAxis.min Numeric; lower bound of the color axis. Default `0`.
#' @param colorAxis.max Numeric or NULL; upper bound of the color axis.
#'   NULL (default) uses `ceiling(max(.data$Z))`.
#' @param color.stops List of Highcharts color-axis stops, each a `list(position, color)`.
#'   NULL (default) uses a 10-stop Inferno palette.
#' @param series.name Character; legend label for the series. Default `"Value"`.
#' @param border.width Numeric; cell border width in pixels. Default `1`.
#' @param border.color Character; cell border color. Default `"#333333"`.
#' @param dataLabels.show Logical; show value labels inside cells. Default `FALSE`.
#' @param tooltip.format Character; Highcharts `pointFormat` string. NULL (default)
#'   generates a format using `xAxis.legend`, `yAxis.legend`, `series.name`,
#'   `{point.xLabel}`, and `{point.yLabel}`. For custom tooltips, use
#'   `{point.xLabel}` and `{point.yLabel}` for the original `.data$X` and
#'   `.data$Y` values; `{point.x}` and `{point.y}` are internal 0-based indices.
#' @param legend.align Character; horizontal legend alignment. Default `"right"`.
#' @param legend.layout Character; legend layout direction. Default `"vertical"`.
#' @param legend.valign Character; vertical legend alignment. Default `"middle"`.
#' @param plot.theme Optional Highcharts theme object (e.g. `hc_theme_538_gridlines()`).
#'   Default NULL applies no theme.
#'
#' @return A highchart object.
#'
#' @import highcharter
#' @import data.table
#' @export buildHeatmap
buildHeatmap <- function(
    .data,
    xAxis.legend    = "X",
    yAxis.legend    = "Y",
    plot.title      = NULL,
    colorAxis.min   = 0,
    colorAxis.max   = NULL,
    color.stops     = NULL,
    series.name     = "Value",
    border.width    = 1,
    border.color    = "#333333",
    dataLabels.show = FALSE,
    tooltip.format  = NULL,
    legend.align    = "right",
    legend.layout   = "vertical",
    legend.valign   = "middle",
    plot.theme      = NULL
) {
  if (!inherits(.data, "data.table"))
    stop("`.data` must be a data.table.")
  if (!all(c("X", "Y", "Z") %in% names(.data)))
    stop("`.data` must have columns X, Y, Z.")
  if (!is.numeric(.data$Z))
    stop("Column Z must be numeric.")

  XCats <- as.character(sort(unique(.data$X)))
  YCats <- as.character(sort(unique(.data$Y)))

  DATA <- lapply(seq_len(nrow(.data)), function(i) {
    list(
      x      = match(as.character(.data$X[i]), XCats) - 1L,
      y      = match(as.character(.data$Y[i]), YCats) - 1L,
      value  = round(.data$Z[i], 2),
      xLabel = as.character(.data$X[i]),
      yLabel = as.character(.data$Y[i])
    )
  })

  Zmax <- if (is.null(colorAxis.max)) ceiling(max(.data$Z, na.rm = TRUE)) else colorAxis.max

  Stops <- if (is.null(color.stops)) {
    list(
      list(0,   "#000004"), list(0.1, "#1B0C41"), list(0.2, "#4A0C6B"),
      list(0.3, "#781C6D"), list(0.4, "#A52C60"), list(0.5, "#CF4446"),
      list(0.6, "#ED6925"), list(0.7, "#FB9B06"), list(0.8, "#F7D13D"),
      list(1,   "#FCFFA4")
    )
  } else {
    color.stops
  }

  TipFormat <- if (is.null(tooltip.format)) {
    sprintf(
      "%s: <b>{point.xLabel}</b> | %s: <b>{point.yLabel}</b><br>%s: <b>{point.value}</b>",
      xAxis.legend, yAxis.legend, series.name
    )
  } else {
    tooltip.format
  }

  hc <- highcharter::highchart() |>
    highcharter::hc_chart(type = "heatmap") |>
    highcharter::hc_xAxis(title = list(text = xAxis.legend), categories = XCats) |>
    highcharter::hc_yAxis(title = list(text = yAxis.legend), categories = YCats, reversed = FALSE) |>
    highcharter::hc_colorAxis(min = colorAxis.min, max = Zmax, stops = Stops) |>
    highcharter::hc_add_series(
      data        = DATA,
      name        = series.name,
      borderWidth = border.width,
      borderColor = border.color,
      dataLabels  = list(enabled = dataLabels.show)
    ) |>
    highcharter::hc_tooltip(headerFormat = "", pointFormat = TipFormat) |>
    highcharter::hc_legend(align = legend.align, layout = legend.layout, verticalAlign = legend.valign)

  if (!is.null(plot.title)) hc <- hc |> highcharter::hc_title(text = plot.title)
  if (!is.null(plot.theme)) hc <- hc |> highcharter::hc_add_theme(plot.theme)

  hc
}
