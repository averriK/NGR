#' Build a time-series plot
#'
#' @description
#' Builds one Highcharts Stock widget for one or more series measured against
#' calendar time. The abscissa is a real datetime axis, so the reader sees
#' dates rather than a numeric surrogate, and the widget carries a range
#' selector and a navigator for a record that spans years.
#'
#' Missing values break the line instead of being bridged, which keeps a gap
#' in the record visually distinct from a measured value. Labelled reference
#' lines can be drawn on the ordinate for design levels, thresholds, or
#' physical bounds, and an optional linked right axis restates the ordinate
#' under an affine transform.
#'
#' @param data A data frame or `data.table` with one row per plotted point.
#'   Required columns are `ID` (series identity), `X` (`Date` or `POSIXct`)
#'   and `Y` (measured value, `NA` where the record has a gap). Optional
#'   columns, constant within each `ID`: `type` (`"line"` or `"scatter"`),
#'   `style` (dash style), `size` (line width), `color` (explicit colour) and
#'   `symbol` (marker symbol). Series are drawn in order of first appearance
#'   of `ID`.
#' @param xLegend Abscissa title.
#' @param yLegend Ordinate title.
#' @param yLimits Length-two increasing numeric vector fixing the ordinate, or
#'   `NULL` to autoscale.
#' @param referenceLines A data frame of labelled horizontal reference lines,
#'   or `NULL`. Required columns are `value` and `label`; optional `color`,
#'   `width` and `style`. Drawn above the series and outside the legend.
#' @param y2Legend Title of a linked right axis, or `NULL` for none. The right
#'   axis relabels the ordinate as `y2Offset + y2Scale * value`; it is a
#'   restatement of the same measurement, valid only while that relation
#'   holds.
#' @param y2Offset Additive term of the right-axis relation.
#' @param y2Scale Multiplicative term of the right-axis relation.
#' @param y2Decimals Decimals shown on the right axis.
#' @param palette Palette name from [grDevices::hcl.pals()], used for every
#'   series without an explicit `color`.
#' @param lineSize Default line width for series without a `size` value.
#' @param markers Draw a marker at every plotted point.
#' @param markerSize Marker radius in pixels.
#' @param rangeSelector Show the range selector.
#' @param navigator Show the navigator.
#' @param dateFormat Highcharts date format used in the tooltip header.
#' @param showLegend Show the series legend.
#' @param legendTitle Legend title.
#' @param plotHeight Widget height in pixels. Width stays responsive.
#' @param theme A Highcharts theme object.
#'
#' @return A `highchart` htmlwidget of Highcharts Stock type. Inputs are not
#'   modified and no file is written.
#'
#' @examples
#' Day <- as.Date("2020-01-01") + seq(0, 720, by = 30)
#' Data <- data.frame(
#'   ID = "level",
#'   X = Day,
#'   Y = 100 + sin(seq_along(Day) / 2)
#' )
#' buildPlot.Time(
#'   data = Data,
#'   xLegend = "Date",
#'   yLegend = "Level (m)",
#'   referenceLines = data.frame(value = 101.5, label = "threshold")
#' )
#'
#' @export
buildPlot.Time <- function(
  data,
  xLegend = "Date",
  yLegend = "Y",
  yLimits = NULL,
  referenceLines = NULL,
  y2Legend = NULL,
  y2Offset = 0,
  y2Scale = 1,
  y2Decimals = 1,
  palette = "Dark 3",
  lineSize = 2,
  markers = TRUE,
  markerSize = 3,
  rangeSelector = TRUE,
  navigator = TRUE,
  dateFormat = "%d/%m/%Y",
  showLegend = TRUE,
  legendTitle = "ID",
  plotHeight = 430,
  theme = NULL
) {
  DT <- .timeValidate(data)
  if (!is.character(xLegend) || length(xLegend) != 1L) {
    stop("xLegend must be a single string.", call. = FALSE)
  }
  if (!is.character(yLegend) || length(yLegend) != 1L) {
    stop("yLegend must be a single string.", call. = FALSE)
  }
  if (!is.null(yLimits)) {
    if (!is.numeric(yLimits) || length(yLimits) != 2L ||
      !all(is.finite(yLimits)) || yLimits[[1L]] >= yLimits[[2L]]) {
      stop("yLimits must be two increasing numbers or NULL.", call. = FALSE)
    }
  }
  if (!is.numeric(plotHeight) || length(plotHeight) != 1L ||
    !is.finite(plotHeight) || plotHeight <= 0) {
    stop("plotHeight must be one positive number.", call. = FALSE)
  }

  IDS <- unique(as.character(DT$ID))
  COLOR <- .timeColors(DT, IDS, palette)
  AXIS <- list(
    title = list(text = yLegend),
    opposite = FALSE,
    plotLines = .timeReferenceLines(referenceLines)
  )
  if (!is.null(yLimits)) {
    AXIS$min <- yLimits[[1L]]
    AXIS$max <- yLimits[[2L]]
  }

  PLOT <- highcharter::highchart(type = "stock") |>
    highcharter::hc_chart(zoomType = "x") |>
    highcharter::hc_title(text = NULL) |>
    highcharter::hc_xAxis(
      type = "datetime",
      title = list(text = xLegend),
      ordinal = FALSE
    )

  if (is.null(y2Legend)) {
    PLOT <- do.call(highcharter::hc_yAxis, c(list(PLOT), AXIS))
  } else {
    PLOT <- highcharter::hc_yAxis_multiples(
      PLOT,
      AXIS,
      list(
        title = list(text = y2Legend),
        linkedTo = 0,
        opposite = TRUE,
        gridLineWidth = 0,
        labels = list(formatter = highcharter::JS(sprintf(
          "function(){ return (%.6f + %.6f * this.value).toFixed(%d); }",
          y2Offset, y2Scale, as.integer(y2Decimals)
        )))
      )
    )
  }

  for (i in seq_along(IDS)) {
    AUX <- DT[as.character(DT$ID) == IDS[[i]], ]
    AUX <- AUX[order(AUX$t), ]
    TYPE <- if (is.na(AUX$type[[1L]])) "line" else
      as.character(AUX$type[[1L]])
    if (!TYPE %in% c("line", "scatter")) TYPE <- "line"
    PLOT <- highcharter::hc_add_series(
      PLOT,
      data = lapply(seq_len(nrow(AUX)), function(j) {
        list(AUX$t[[j]], if (is.na(AUX$Y[[j]])) NULL else AUX$Y[[j]])
      }),
      type = TYPE,
      name = IDS[[i]],
      color = COLOR[[i]],
      dashStyle = .profileDash(AUX$style[[1L]]),
      lineWidth = if (TYPE == "scatter") 0 else {
        if (is.na(AUX$size[[1L]])) lineSize else AUX$size[[1L]]
      },
      connectNulls = FALSE,
      showInLegend = isTRUE(showLegend),
      marker = list(
        enabled = isTRUE(markers) || TYPE == "scatter",
        radius = markerSize,
        symbol = .profileSymbol(AUX$symbol[[1L]], i)
      )
    )
  }

  PLOT <- PLOT |>
    highcharter::hc_rangeSelector(enabled = isTRUE(rangeSelector)) |>
    highcharter::hc_navigator(enabled = isTRUE(navigator)) |>
    highcharter::hc_scrollbar(enabled = FALSE) |>
    highcharter::hc_legend(
      enabled = isTRUE(showLegend),
      align = "center",
      verticalAlign = "bottom",
      layout = "horizontal",
      title = list(text = legendTitle)
    ) |>
    highcharter::hc_tooltip(
      shared = TRUE,
      xDateFormat = dateFormat,
      headerFormat = "<b>{point.key}</b><br/>"
    ) |>
    highcharter::hc_credits(enabled = FALSE) |>
    highcharter::hc_size(height = plotHeight)
  if (!is.null(theme)) PLOT <- highcharter::hc_add_theme(PLOT, theme)
  PLOT
}

# Coerce and validate the time input. Y may carry NA: a gap in the record is
# not a measurement and must not be bridged.
.timeValidate <- function(data) {
  if (!is.data.frame(data) || nrow(data) == 0L) {
    stop("data must be a non-empty data frame.", call. = FALSE)
  }
  if (!all(c("ID", "X", "Y") %in% names(data))) {
    stop("data must contain columns ID, X and Y.", call. = FALSE)
  }
  DT <- as.data.frame(data, stringsAsFactors = FALSE)
  if (!inherits(DT$X, "Date") && !inherits(DT$X, "POSIXct")) {
    stop("data$X must be Date or POSIXct.", call. = FALSE)
  }
  if (anyNA(DT$X)) {
    stop("data$X must not contain NA.", call. = FALSE)
  }
  if (!is.numeric(DT$Y)) {
    stop("data$Y must be numeric.", call. = FALSE)
  }
  DT$t <- as.numeric(as.POSIXct(DT$X, tz = "UTC")) * 1000
  for (COL in c("type", "style", "size", "color", "symbol")) {
    if (!COL %in% names(DT)) DT[[COL]] <- NA
  }
  DT
}

.timeColors <- function(DT, IDS, palette) {
  if (!palette %in% grDevices::hcl.pals()) {
    warning("Invalid palette. Using default.", call. = FALSE)
    palette <- "Dark 3"
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

.timeReferenceLines <- function(referenceLines) {
  if (is.null(referenceLines)) return(list())
  if (!is.data.frame(referenceLines) || nrow(referenceLines) == 0L) {
    stop("referenceLines must be a non-empty data frame or NULL.",
      call. = FALSE
    )
  }
  if (!all(c("value", "label") %in% names(referenceLines))) {
    stop("referenceLines must contain columns value and label.",
      call. = FALSE
    )
  }
  DT <- as.data.frame(referenceLines, stringsAsFactors = FALSE)
  if (!is.numeric(DT$value) || anyNA(DT$value)) {
    stop("referenceLines$value must be numeric and complete.", call. = FALSE)
  }
  lapply(seq_len(nrow(DT)), function(i) {
    list(
      value = DT$value[[i]],
      color = if ("color" %in% names(DT)) as.character(DT$color[[i]]) else
        "#6B7280",
      width = if ("width" %in% names(DT)) DT$width[[i]] else 2,
      dashStyle = if ("style" %in% names(DT)) .profileDash(DT$style[[i]]) else
        "Solid",
      zIndex = 3,
      label = list(
        text = as.character(DT$label[[i]]),
        style = list(fontSize = "10px")
      )
    )
  })
}
