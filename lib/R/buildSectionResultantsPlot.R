#' Build circular-section resultant diagrams
#'
#' @description
#' Builds one responsive Highcharts widget with square Cartesian panels for
#' any non-empty subset of the `N`, `M`, and `Q` resultants of a circular
#' section. The caller supplies
#' display coordinates for the closed curves and for the independent radial
#' ordinates. The function only renders those layers: it does not calculate
#' resultants, select ordinate angles, classify signs, or transform physical
#' values into display radii.
#'
#' @param curves A data frame for one or two cases, with one ordered,
#'   explicitly closed curve for every `case` and `resultant`. Required
#'   columns are `case`, `prescription`, `resultant`, `thetaDeg`, `value`,
#'   `unit`, `x`, `y`, and `radialFraction`. Character columns must be
#'   non-empty; each case must have one `prescription`, and each resultant one
#'   `unit`. Numeric columns must be finite. `resultant` must contain one or
#'   more of `N`, `M`, and `Q`. The first and last `x`, `y` coordinates of
#'   every curve must coincide. `radialFraction` is a non-negative,
#'   dimensionless upper
#'   bound on the absolute display-radius offset divided by
#'   `referenceRadius`; it is used only to set panel limits.
#' @param rays A data frame with one row per independent radial ordinate.
#'   Required columns are `case`, `resultant`, `sign`, `xSection`, `ySection`,
#'   `x`, and `y`. Character columns must be non-empty and numeric columns
#'   finite. Every case-resultant combination in `curves` must occur in
#'   `rays`, and every ordinate must start on the reference circle.
#'   `sign` must be `"positive"` or `"negative"`; the caller owns that
#'   classification and the angular sampling.
#' @param referenceRadius Positive radius of the reference circle, in the same
#'   display-coordinate units as `x` and `y`.
#' @param panelTitles Character vector whose names include every resultant
#'   present in `curves`. Values are the visible panel titles and should
#'   include physical units where applicable.
#' @param positionLabels Character vector named `top`, `right`, `bottom`, and
#'   `left`. Values label the four cardinal positions of the section.
#' @param subtitle Optional character scalar displayed above the panels.
#' @param plotHeight Positive widget height of at least 360 pixels. Width
#'   remains responsive, following the sizing contract used by [buildPlot()].
#'
#' @return A `highchart` htmlwidget. Inputs are not modified and no file is
#'   written.
#'
#' @examples
#' Theta <- seq(0, 2 * pi, length.out = 9)
#' Amplitudes <- c(N = 0.20, M = 0.15, Q = 0.10)
#' Curves <- do.call(rbind, lapply(names(Amplitudes), function(Resultant) {
#'   Amplitude <- Amplitudes[[Resultant]]
#'   Radius <- 1 + Amplitude * cos(2 * Theta)
#'   data.frame(
#'     case = "example",
#'     prescription = "Example",
#'     resultant = Resultant,
#'     thetaDeg = Theta * 180 / pi,
#'     value = cos(2 * Theta),
#'     unit = "unit",
#'     x = Radius * sin(Theta),
#'     y = Radius * cos(Theta),
#'     radialFraction = abs(Amplitude)
#'   )
#' }))
#' Rays <- Curves[Curves$thetaDeg < 360, c("case", "resultant", "x", "y")]
#' Rays$xSection <- sin(Curves$thetaDeg[Curves$thetaDeg < 360] * pi / 180)
#' Rays$ySection <- cos(Curves$thetaDeg[Curves$thetaDeg < 360] * pi / 180)
#' Rays$sign <- ifelse(Curves$value[Curves$thetaDeg < 360] >= 0, "positive", "negative")
#' buildSectionResultantsPlot(
#'   curves = Curves,
#'   rays = Rays,
#'   referenceRadius = 1,
#'   panelTitles = c(N = "N [unit]", M = "M [unit]", Q = "Q [unit]"),
#'   positionLabels = c(top = "Top", right = "Right", bottom = "Bottom", left = "Left")
#' )
#'
#' @export
buildSectionResultantsPlot <- function(
  curves,
  rays,
  referenceRadius,
  panelTitles = c(N = "N", M = "M", Q = "Q"),
  positionLabels = c(
    top = "Top",
    right = "Right",
    bottom = "Bottom",
    left = "Left"
  ),
  subtitle = NULL,
  plotHeight = 560
) {
  if (!is.data.frame(curves) || nrow(curves) == 0L) {
    stop("curves must be a non-empty data frame.", call. = FALSE)
  }
  if (!is.data.frame(rays) || nrow(rays) == 0L) {
    stop("rays must be a non-empty data frame.", call. = FALSE)
  }
  .sectionAssertColumns(
    curves,
    c(
      "case", "prescription", "resultant", "thetaDeg", "value", "unit",
      "x", "y", "radialFraction"
    ),
    "curves"
  )
  .sectionAssertColumns(
    rays,
    c("case", "resultant", "sign", "xSection", "ySection", "x", "y"),
    "rays"
  )
  .sectionAssertStrings(
    curves,
    c("case", "prescription", "resultant", "unit"),
    "curves"
  )
  .sectionAssertStrings(rays, c("case", "resultant", "sign"), "rays")
  .sectionAssertFinite(
    curves,
    c("thetaDeg", "value", "x", "y", "radialFraction"),
    "curves"
  )
  .sectionAssertFinite(
    rays,
    c("xSection", "ySection", "x", "y"),
    "rays"
  )
  if (any(curves$radialFraction < 0)) {
    stop("curves$radialFraction must be non-negative.", call. = FALSE)
  }
  if (!is.numeric(referenceRadius) || length(referenceRadius) != 1L ||
      !is.finite(referenceRadius) || referenceRadius <= 0) {
    stop("referenceRadius must be one positive finite number.", call. = FALSE)
  }
  if (!is.numeric(plotHeight) || length(plotHeight) != 1L ||
      !is.finite(plotHeight) || plotHeight < 360) {
    stop("plotHeight must be one finite number of at least 360 pixels.", call. = FALSE)
  }
  if (!is.null(subtitle) &&
      (!is.character(subtitle) || length(subtitle) != 1L || is.na(subtitle))) {
    stop("subtitle must be NULL or one non-missing character value.", call. = FALSE)
  }

  AllowedResultants <- c("N", "M", "Q")
  ObservedResultants <- unique(as.character(curves$resultant))
  if (any(!ObservedResultants %in% AllowedResultants)) {
    stop(
      "curves$resultant must contain only N, M, and Q.",
      call. = FALSE
    )
  }
  Resultants <- AllowedResultants[AllowedResultants %in% ObservedResultants]
  Cases <- unique(as.character(curves$case))
  if (!length(Cases) %in% 1:2) {
    stop("curves must contain one or two cases.", call. = FALSE)
  }
  for (Case in Cases) {
    Prescriptions <- unique(as.character(curves$prescription[curves$case == Case]))
    if (length(Prescriptions) != 1L) {
      stop("Each case must have exactly one prescription.", call. = FALSE)
    }
    for (Resultant in Resultants) {
      DATA <- curves[
        curves$case == Case & curves$resultant == Resultant,
        ,
        drop = FALSE
      ]
      if (nrow(DATA) < 2L) {
        stop("Every case and resultant requires a curve.", call. = FALSE)
      }
      Closed <- isTRUE(all.equal(DATA$x[1L], DATA$x[nrow(DATA)], tolerance = 1e-12)) &&
        isTRUE(all.equal(DATA$y[1L], DATA$y[nrow(DATA)], tolerance = 1e-12))
      if (!Closed) {
        stop("Every curve must be explicitly closed in x and y.", call. = FALSE)
      }
    }
  }
  UnitsPerResultant <- vapply(Resultants, function(Resultant) {
    length(unique(as.character(curves$unit[curves$resultant == Resultant])))
  }, integer(1))
  if (any(UnitsPerResultant != 1L)) {
    stop("Each resultant must have exactly one non-empty unit.", call. = FALSE)
  }
  if (!setequal(unique(as.character(rays$case)), Cases) ||
      !setequal(unique(as.character(rays$resultant)), Resultants)) {
    stop("rays must contain the same cases and resultants as curves.", call. = FALSE)
  }
  if (any(!rays$sign %in% c("positive", "negative"))) {
    stop("rays$sign must contain only positive or negative.", call. = FALSE)
  }
  RayGroups <- interaction(rays$case, rays$resultant, drop = TRUE)
  if (length(unique(RayGroups)) != length(Cases) * length(Resultants)) {
    stop("Every case and resultant requires at least one ray.", call. = FALSE)
  }
  RadiusResidual <- abs(
    sqrt(rays$xSection^2 + rays$ySection^2) - referenceRadius
  )
  if (max(RadiusResidual) > 1e-10 * max(1, referenceRadius)) {
    stop("Every ray must start on the reference circle.", call. = FALSE)
  }
  if (!is.character(panelTitles) || is.null(names(panelTitles)) ||
      anyDuplicated(names(panelTitles)) ||
      !all(Resultants %in% names(panelTitles)) ||
      anyNA(panelTitles[Resultants]) ||
      any(!nzchar(trimws(panelTitles[Resultants])))) {
    stop(
      sprintf(
        "panelTitles must include non-empty values named %s.",
        paste(Resultants, collapse = ", ")
      ),
      call. = FALSE
    )
  }
  PanelTitles <- panelTitles[Resultants]
  PositionLabels <- .sectionValidateLabels(
    positionLabels,
    c("top", "right", "bottom", "left"),
    "positionLabels"
  )

  Limits <- vapply(Resultants, function(Resultant) {
    referenceRadius * (
      1 + max(curves$radialFraction[curves$resultant == Resultant]) + 0.18
    )
  }, numeric(1))
  DesignWidth <- 1200
  OuterGap <- 24
  PanelGap <- 42
  PanelTop <- 60
  PanelCount <- length(Resultants)
  PanelSize <- min(
    floor(
      (DesignWidth - 2 * OuterGap - (PanelCount - 1L) * PanelGap) /
        PanelCount
    ),
    floor(plotHeight - PanelTop - 115)
  )
  if (PanelSize < 80) {
    stop("plotHeight leaves insufficient space for the panels.", call. = FALSE)
  }
  Left <- OuterGap + (seq_along(Resultants) - 1L) * (PanelSize + PanelGap)
  Xaxes <- Map(
    function(x, limit, Resultant) {
      .sectionPanelAxis(
        x,
        PanelTop,
        PanelSize,
        limit,
        unname(PanelTitles[[Resultant]])
      )
    },
    Left,
    Limits,
    Resultants
  )
  Yaxes <- Map(function(x, limit) {
    Axis <- .sectionPanelAxis(x, PanelTop, PanelSize, limit)
    Axis$title <- list(text = NULL)
    Axis
  }, Left, Limits)

  Chart <- highcharter::highchart() |>
    highcharter::hc_size(height = plotHeight) |>
    highcharter::hc_chart(
      reflow = TRUE,
      animation = FALSE,
      backgroundColor = "#FFFFFF",
      spacing = c(10, 10, 52, 10),
      events = list(render = .sectionLayoutHandler(length(Resultants)))
    ) |>
    highcharter::hc_title(text = NULL)
  if (!is.null(subtitle)) {
    Chart <- highcharter::hc_subtitle(
      Chart,
      text = subtitle,
      style = list(color = "#4B5563", fontSize = "11px")
    )
  }
  Chart <- Chart |>
    highcharter::hc_legend(
      align = "center",
      verticalAlign = "bottom",
      layout = "horizontal",
      symbolWidth = 30
    ) |>
    highcharter::hc_plotOptions(
      series = list(
        animation = FALSE,
        marker = list(enabled = FALSE),
        states = list(inactive = list(opacity = 1)),
        turboThreshold = 0
      )
    ) |>
    highcharter::hc_tooltip(
      useHTML = TRUE,
      formatter = htmlwidgets::JS(paste0(
        "function () {",
        "if (!this.point.custom) return false;",
        "return '<b>' + this.series.name + '</b><br/>' +",
        "'&theta; = ' + Highcharts.numberFormat(this.point.custom.thetaDeg, 1) + '&deg;<br/>' +",
        "this.point.custom.resultant + ' = ' + Highcharts.numberFormat(this.point.custom.value, 3) + ' ' + this.point.custom.unit;",
        "}"
      ))
    ) |>
    highcharter::hc_credits(enabled = FALSE)
  Chart <- do.call(
    highcharter::hc_xAxis_multiples,
    c(list(hc = Chart), unname(Xaxes))
  )
  Chart <- do.call(
    highcharter::hc_yAxis_multiples,
    c(list(hc = Chart), unname(Yaxes))
  )

  CircleTheta <- seq(0, 2 * pi, length.out = 361L)
  CircleData <- lapply(CircleTheta, function(Theta) {
    list(x = referenceRadius * sin(Theta), y = referenceRadius * cos(Theta))
  })
  for (j in seq_along(Resultants)) {
    AxisIndex <- j - 1L
    Chart <- highcharter::hc_add_series(
      Chart,
      data = CircleData,
      type = "line",
      xAxis = AxisIndex,
      yAxis = AxisIndex,
      name = "Reference section",
      color = "#374151",
      dashStyle = "Solid",
      lineWidth = 2.4,
      marker = list(enabled = FALSE),
      enableMouseTracking = FALSE,
      showInLegend = FALSE,
      zIndex = 4
    )
    LabelRadius <- Limits[j] - 0.07 * referenceRadius
    Cardinal <- data.frame(
      x = c(0, 1, 0, -1) * LabelRadius,
      y = c(1, 0, -1, 0) * LabelRadius,
      label = unname(PositionLabels[c("top", "right", "bottom", "left")]),
      stringsAsFactors = FALSE
    )
    Chart <- highcharter::hc_add_series(
      Chart,
      data = lapply(seq_len(nrow(Cardinal)), function(i) {
        list(x = Cardinal$x[i], y = Cardinal$y[i], name = Cardinal$label[i])
      }),
      type = "scatter",
      xAxis = AxisIndex,
      yAxis = AxisIndex,
      name = "Positions",
      marker = list(enabled = FALSE),
      dataLabels = list(
        enabled = TRUE,
        format = "{point.name}",
        crop = FALSE,
        overflow = "allow",
        style = list(
          color = "#6B7280",
          fontSize = "9px",
          fontWeight = "400",
          textOutline = "none"
        )
      ),
      enableMouseTracking = FALSE,
      showInLegend = FALSE,
      zIndex = 4
    )
  }

  Styles <- list(
    list(
      line = "#0072B2",
      positive = "rgba(0,114,178,0.72)",
      negative = "rgba(213,94,0,0.70)",
      dash = "ShortDash"
    ),
    list(
      line = "#D55E00",
      positive = "rgba(0,114,178,0.52)",
      negative = "rgba(213,94,0,0.50)",
      dash = "Dash"
    )
  )
  GroupIDs <- paste0("section-case-", seq_along(Cases))
  names(GroupIDs) <- Cases
  for (i in seq_along(Cases)) {
    GroupID <- unname(GroupIDs[i])
    Style <- Styles[[i]]
    Prescription <- unique(curves$prescription[curves$case == Cases[i]])
    for (j in seq_along(Resultants)) {
      AxisIndex <- j - 1L
      DATA <- curves[
        curves$case == Cases[i] & curves$resultant == Resultants[j],
        ,
        drop = FALSE
      ]
      AUX <- rays[
        rays$case == Cases[i] & rays$resultant == Resultants[j],
        ,
        drop = FALSE
      ]
      IsMaster <- j == 1L
      Options <- list(
        hc = Chart,
        data = .sectionPointData(DATA),
        type = "line",
        xAxis = AxisIndex,
        yAxis = AxisIndex,
        id = if (IsMaster) GroupID else paste0(GroupID, "-", Resultants[j]),
        name = Prescription,
        color = Style$line,
        dashStyle = Style$dash,
        lineWidth = 1.6,
        marker = list(enabled = FALSE),
        requireSorting = FALSE,
        findNearestPointBy = "xy",
        showInLegend = IsMaster,
        zIndex = 3
      )
      if (!IsMaster) {
        Options$linkedTo <- GroupID
      }
      Chart <- do.call(highcharter::hc_add_series, Options)
      for (Sign in c("positive", "negative")) {
        CurrentRays <- AUX[AUX$sign == Sign, , drop = FALSE]
        if (nrow(CurrentRays) == 0L) {
          next
        }
        Chart <- highcharter::hc_add_series(
          Chart,
          data = .sectionSegmentData(CurrentRays),
          type = "line",
          xAxis = AxisIndex,
          yAxis = AxisIndex,
          name = Prescription,
          color = Style[[Sign]],
          dashStyle = Style$dash,
          lineWidth = 0.55,
          marker = list(enabled = FALSE),
          requireSorting = FALSE,
          enableMouseTracking = FALSE,
          showInLegend = FALSE,
          connectNulls = FALSE,
          linkedTo = GroupID,
          zIndex = 1
        )
      }
    }
  }
  attr(Chart, "sectionPanelSize") <- PanelSize
  attr(Chart, "sectionLayout") <- "responsive-square-panels"
  attr(Chart, "sectionCaseIDs") <- GroupIDs
  Chart
}

.sectionAssertColumns <- function(data, columns, label) {
  Missing <- setdiff(columns, names(data))
  if (length(Missing)) {
    stop(
      sprintf("%s is missing required columns: %s.", label, paste(Missing, collapse = ", ")),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

.sectionAssertStrings <- function(data, columns, label) {
  Invalid <- vapply(columns, function(Column) {
    Values <- data[[Column]]
    !(is.character(Values) || is.factor(Values)) || anyNA(Values) ||
      any(!nzchar(trimws(as.character(Values))))
  }, logical(1))
  if (any(Invalid)) {
    stop(
      sprintf("%s columns must contain non-empty character values: %s.", label, paste(columns[Invalid], collapse = ", ")),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

.sectionAssertFinite <- function(data, columns, label) {
  Invalid <- vapply(columns, function(Column) {
    Values <- data[[Column]]
    !is.numeric(Values) || any(!is.finite(Values))
  }, logical(1))
  if (any(Invalid)) {
    stop(
      sprintf("%s columns must contain finite numbers: %s.", label, paste(columns[Invalid], collapse = ", ")),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

.sectionValidateLabels <- function(labels, requiredNames, label) {
  if (!is.character(labels) || is.null(names(labels)) ||
      !setequal(names(labels), requiredNames) || anyNA(labels) ||
      any(!nzchar(trimws(labels)))) {
    stop(
      sprintf("%s must be a non-empty character vector named %s.", label, paste(requiredNames, collapse = ", ")),
      call. = FALSE
    )
  }
  labels[requiredNames]
}

.sectionPointData <- function(data) {
  lapply(seq_len(nrow(data)), function(i) {
    list(
      x = data$x[i],
      y = data$y[i],
      custom = list(
        thetaDeg = data$thetaDeg[i] %% 360,
        value = data$value[i],
        unit = data$unit[i],
        resultant = data$resultant[i]
      )
    )
  })
}

.sectionSegmentData <- function(data) {
  OUT <- vector("list", nrow(data) * 3L)
  k <- 1L
  for (i in seq_len(nrow(data))) {
    OUT[k] <- list(list(x = data$xSection[i], y = data$ySection[i]))
    OUT[k + 1L] <- list(list(x = data$x[i], y = data$y[i]))
    OUT[k + 2L] <- list(NULL)
    k <- k + 3L
  }
  OUT[-length(OUT)]
}

.sectionPanelAxis <- function(left, top, size, limit, title = NULL) {
  list(
    min = -limit,
    max = limit,
    left = left,
    top = top,
    width = size,
    height = size,
    offset = 0,
    minPadding = 0,
    maxPadding = 0,
    startOnTick = FALSE,
    endOnTick = FALSE,
    tickLength = 0,
    lineWidth = 0,
    gridLineWidth = 0,
    labels = list(enabled = FALSE),
    title = list(
      text = title,
      margin = 8,
      style = list(
        color = "#1F2933",
        fontSize = "13px",
        fontWeight = "600"
      )
    )
  )
}

.sectionLayoutHandler <- function(panelCount) {
  htmlwidgets::JS(paste0(
    "function () {",
    "var chart = this, count = ", panelCount, ";",
    "if (chart.__sectionLayoutActive || chart.xAxis.length < count || chart.yAxis.length < count) return;",
    "var outerGap = Math.max(10, Math.min(24, chart.plotWidth * 0.025));",
    "var panelGap = Math.max(12, Math.min(42, chart.plotWidth * 0.035));",
    "var topSpace = chart.subtitle && chart.subtitle.textStr ? 40 : 10;",
    "var bottomSpace = 30;",
    "var availableWidth = chart.plotWidth - 2 * outerGap - (count - 1) * panelGap;",
    "var availableHeight = chart.plotHeight - topSpace - bottomSpace;",
    "var size = Math.floor(Math.min(availableWidth / count, availableHeight));",
    "if (!Number.isFinite(size) || size <= 0) return;",
    "var totalWidth = count * size + (count - 1) * panelGap;",
    "var left = chart.plotLeft + (chart.plotWidth - totalWidth) / 2;",
    "var top = chart.plotTop + topSpace + Math.max(0, (availableHeight - size) / 2);",
    "var changed = false;",
    "chart.__sectionLayoutActive = true;",
    "for (var i = 0; i < count; i += 1) {",
    "var options = {left: Math.round(left + i * (size + panelGap)), top: Math.round(top), width: size, height: size};",
    "var xAxis = chart.xAxis[i], yAxis = chart.yAxis[i];",
    "if (Math.abs(xAxis.left - options.left) > 0.5 || Math.abs(xAxis.top - options.top) > 0.5 || Math.abs(xAxis.width - size) > 0.5 || Math.abs(xAxis.height - size) > 0.5) {",
    "xAxis.update(options, false);",
    "yAxis.update(options, false);",
    "changed = true;",
    "}",
    "}",
    "if (changed) chart.redraw(false);",
    "chart.__sectionLayoutActive = false;",
    "}"
  ))
}
