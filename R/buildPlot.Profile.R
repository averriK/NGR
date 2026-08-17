#' Build a depth-profile plot
#'
#' @description
#' Builds one Highcharts widget for a quantity measured along a borehole or
#' any other downward axis: the ordinate is depth, growing downward, and the
#' abscissa is the measured quantity on a fixed symmetric scale. One series is
#' drawn per `ID`.
#'
#' The function renders a single panel. Composing several panels — for example
#' the two orthogonal axes of an inclinometer side by side — belongs to the
#' caller, which calls this function once per panel and lays the widgets out.
#'
#' Compared with [buildPlot()] this builder adds explicit per-series colour,
#' per-series marker symbols, and a legend switch, and it defaults to a fixed
#' symmetric abscissa. It does not select surveys, order series, or decide the
#' reference: the caller owns all of that.
#'
#' @param data A data frame or `data.table` with one row per plotted point.
#'   Required columns are `ID` (series identity), `X` (measured quantity) and
#'   `Y` (depth, positive downward). Optional columns, constant within each
#'   `ID`: `style` (a dash style accepted by [buildPlot()]), `size` (line
#'   width), `color` (explicit series colour) and `symbol` (marker symbol,
#'   one of `circle`, `square`, `diamond`, `triangle`, `triangle-down`).
#'   Series are drawn in order of first appearance of `ID`, which also fixes
#'   palette assignment when `color` is absent.
#' @param xLegend Abscissa title.
#' @param yLegend Ordinate title.
#' @param xLimit Positive half-range of the symmetric abscissa: the axis spans
#'   `-xLimit` to `xLimit`. `NULL` derives it from `data`. A fixed scale is the
#'   normal choice, because autoscaling a profile of good data renders
#'   measurement noise at full width.
#' @param yMax Maximum depth of the ordinate. `NULL` derives it from `data`.
#' @param palette Palette name from [grDevices::hcl.pals()], used for every
#'   series without an explicit `color`.
#' @param lineType Series geometry, `"spline"` or `"line"`.
#' @param lineSize Default line width for series without a `size` value.
#' @param markers Draw a marker at every plotted point.
#' @param markerSize Marker radius in pixels.
#' @param showLegend Show the series legend. Keep it enabled on every panel of
#'   a composed figure: a legend attached to one panel of a pair shortens that
#'   panel and leaves the other unlabelled.
#' @param legendTitle Legend title.
#' @param plotHeight Widget height in pixels. Width stays responsive.
#' @param theme A Highcharts theme object.
#'
#' @return A `highchart` htmlwidget. Inputs are not modified and no file is
#'   written.
#'
#' @examples
#' Depth <- seq(0.5, 20, by = 0.5)
#' Data <- rbind(
#'   data.frame(ID = "baseline", X = 0, Y = Depth, style = "longdashdotdot",
#'     size = 1),
#'   data.frame(ID = "2026-04-01", X = 12 * (1 - Depth / 20)^2, Y = Depth,
#'     style = "solid", size = 1.6)
#' )
#' buildPlot.Profile(
#'   data = Data,
#'   xLegend = "Displacement (mm)",
#'   yLegend = "Depth (m)",
#'   xLimit = 25
#' )
#'
#' @export
buildPlot.Profile <- function(
  data,
  xLegend = "X",
  yLegend = "Y",
  xLimit = NULL,
  yMax = NULL,
  palette = "Batlow",
  lineType = "spline",
  lineSize = 1.6,
  markers = FALSE,
  markerSize = 3,
  showLegend = TRUE,
  legendTitle = "ID",
  plotHeight = 760,
  theme = NULL
) {
  DT <- .profileValidate(data)
  if (!is.character(xLegend) || length(xLegend) != 1L) {
    stop("xLegend must be a single string.", call. = FALSE)
  }
  if (!is.character(yLegend) || length(yLegend) != 1L) {
    stop("yLegend must be a single string.", call. = FALSE)
  }
  if (!lineType %in% c("spline", "line")) {
    stop("lineType must be \"spline\" or \"line\".", call. = FALSE)
  }
  if (is.null(xLimit)) {
    xLimit <- max(abs(DT$X))
    if (!is.finite(xLimit) || xLimit == 0) xLimit <- 1
  }
  if (!is.numeric(xLimit) || length(xLimit) != 1L || !is.finite(xLimit) ||
    xLimit <= 0) {
    stop("xLimit must be one positive number or NULL.", call. = FALSE)
  }
  if (is.null(yMax)) yMax <- max(DT$Y)
  if (!is.numeric(yMax) || length(yMax) != 1L || !is.finite(yMax) ||
    yMax <= 0) {
    stop("yMax must be one positive number or NULL.", call. = FALSE)
  }
  if (!is.numeric(plotHeight) || length(plotHeight) != 1L ||
    !is.finite(plotHeight) || plotHeight <= 0) {
    stop("plotHeight must be one positive number.", call. = FALSE)
  }

  IDS <- unique(as.character(DT$ID))
  COLOR <- .profileColors(DT, IDS, palette)

  PLOT <- highcharter::highchart() |>
    highcharter::hc_chart(zoomType = "xy") |>
    highcharter::hc_xAxis(
      title = list(text = xLegend),
      min = -xLimit,
      max = xLimit,
      startOnTick = FALSE,
      endOnTick = FALSE,
      plotLines = list(list(value = 0, width = 1.5, color = "#4B5563",
        zIndex = 2))
    ) |>
    highcharter::hc_yAxis(
      title = list(text = yLegend),
      reversed = TRUE,
      min = 0,
      max = yMax
    )

  for (i in seq_along(IDS)) {
    AUX <- DT[as.character(DT$ID) == IDS[[i]], ]
    AUX <- AUX[order(AUX$Y), ]
    PLOT <- highcharter::hc_add_series(
      PLOT,
      data = lapply(seq_len(nrow(AUX)), function(j) {
        list(AUX$X[[j]], AUX$Y[[j]])
      }),
      type = lineType,
      name = IDS[[i]],
      color = COLOR[[i]],
      dashStyle = .profileDash(AUX$style[[1L]]),
      lineWidth = if ("size" %in% names(AUX)) AUX$size[[1L]] else lineSize,
      showInLegend = isTRUE(showLegend),
      marker = list(
        enabled = isTRUE(markers),
        radius = markerSize,
        symbol = .profileSymbol(AUX$symbol[[1L]], i)
      )
    )
  }

  PLOT <- PLOT |>
    highcharter::hc_legend(
      enabled = isTRUE(showLegend),
      align = "center",
      verticalAlign = "bottom",
      layout = "horizontal",
      title = list(text = legendTitle)
    ) |>
    highcharter::hc_tooltip(
      crosshairs = TRUE,
      headerFormat = "",
      pointFormat = paste0(
        "<b>{series.name}</b><br/>", xLegend, ": {point.x}<br/>",
        yLegend, ": {point.y}"
      )
    ) |>
    highcharter::hc_size(height = plotHeight)
  if (!is.null(theme)) PLOT <- highcharter::hc_add_theme(PLOT, theme)
  PLOT
}

# Coerce and validate the profile input, returning a plain data.frame whose
# optional columns are always present so the series loop stays branch-free.
.profileValidate <- function(data) {
  if (!is.data.frame(data) || nrow(data) == 0L) {
    stop("data must be a non-empty data frame.", call. = FALSE)
  }
  COLS <- c("ID", "X", "Y")
  if (!all(COLS %in% names(data))) {
    stop("data must contain columns ID, X and Y.", call. = FALSE)
  }
  DT <- as.data.frame(data, stringsAsFactors = FALSE)
  if (!is.numeric(DT$X) || !is.numeric(DT$Y)) {
    stop("data$X and data$Y must be numeric.", call. = FALSE)
  }
  if (anyNA(DT$X) || anyNA(DT$Y)) {
    stop("data$X and data$Y must not contain NA.", call. = FALSE)
  }
  for (COL in c("style", "size", "color", "symbol")) {
    if (!COL %in% names(DT)) DT[[COL]] <- NA
  }
  DT
}

# Explicit colour wins; the palette fills the rest by order of appearance.
.profileColors <- function(DT, IDS, palette) {
  if (!palette %in% grDevices::hcl.pals()) {
    warning("Invalid palette. Using default.", call. = FALSE)
    palette <- "Batlow"
  }
  OUT <- grDevices::hcl.colors(n = length(IDS), palette = palette)
  for (i in seq_along(IDS)) {
    AUX <- DT$color[as.character(DT$ID) == IDS[[i]]]
    if (length(AUX) && !is.na(AUX[[1L]]) && nzchar(as.character(AUX[[1L]]))) {
      OUT[[i]] <- as.character(AUX[[1L]])
    }
  }
  OUT
}

.profileDash <- function(style) {
  MAP <- list(
    solid = "Solid", dashed = "Dash", dash = "Dash", dot = "Dot",
    dotted = "Dot", dashdot = "DashDot", dotdash = "DashDot",
    longdash = "LongDash", shortdash = "ShortDash", shortdot = "ShortDot",
    shortdashdot = "ShortDashDot", longdashdotdot = "LongDashDotDot"
  )
  if (is.na(style)) return("Solid")
  OUT <- MAP[[tolower(as.character(style))]]
  if (is.null(OUT)) "Solid" else OUT
}

# Without an explicit symbol, cycle the five Highcharts marker shapes so a
# monochrome print still separates the series.
.profileSymbol <- function(symbol, i) {
  SHAPES <- c("circle", "square", "diamond", "triangle", "triangle-down")
  if (is.na(symbol)) return(SHAPES[[((i - 1L) %% length(SHAPES)) + 1L]])
  OUT <- as.character(symbol)
  if (!OUT %in% SHAPES) SHAPES[[((i - 1L) %% length(SHAPES)) + 1L]] else OUT
}
