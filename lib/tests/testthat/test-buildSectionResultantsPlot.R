.sectionResultantsFixture <- function(caseCount = 2L) {
  Theta <- seq(0, 2 * pi, length.out = 13L)
  Cases <- c("complete", "normal-only")[seq_len(caseCount)]
  Prescriptions <- c(
    complete = "Complete projection",
    `normal-only` = "Normal load only"
  )
  Amplitudes <- c(N = 0.10, M = 0.18, Q = 0.14)
  Curves <- do.call(rbind, lapply(seq_along(Cases), function(i) {
    Case <- Cases[i]
    do.call(rbind, lapply(names(Amplitudes), function(Resultant) {
      Value <- cos(2 * Theta + (i - 1L) * pi / 12)
      Radius <- 1 + Amplitudes[[Resultant]] * Value
      data.frame(
        case = Case,
        prescription = unname(Prescriptions[[Case]]),
        resultant = Resultant,
        thetaDeg = Theta * 180 / pi,
        value = Value,
        unit = paste0(Resultant, "-unit"),
        x = Radius * sin(Theta),
        y = Radius * cos(Theta),
        radialFraction = Amplitudes[[Resultant]],
        stringsAsFactors = FALSE
      )
    }))
  }))
  RowIndex <- which(Curves$thetaDeg < 360 & Curves$thetaDeg %% 60 == 0)
  Rays <- Curves[RowIndex, c("case", "resultant", "thetaDeg", "value", "x", "y")]
  Rays$xSection <- sin(Rays$thetaDeg * pi / 180)
  Rays$ySection <- cos(Rays$thetaDeg * pi / 180)
  Rays$sign <- ifelse(Rays$value >= 0, "positive", "negative")
  list(curves = Curves, rays = Rays)
}

.buildFixturePlot <- function(Fixture) {
  buildSectionResultantsPlot(
    curves = Fixture$curves,
    rays = Fixture$rays,
    referenceRadius = 1,
    panelTitles = c(
      N = "Normal force, N [N/m]",
      M = "Bending moment, M [N m/m]",
      Q = "Shear force, Q [N/m]"
    ),
    positionLabels = c(
      top = "Top",
      right = "Right",
      bottom = "Bottom",
      left = "Left"
    ),
    subtitle = "Toggle complete formulations in the legend."
  )
}

test_that("buildSectionResultantsPlot preserves prepared geometry", {
  Fixture <- .sectionResultantsFixture()
  CurvesBefore <- Fixture$curves
  RaysBefore <- Fixture$rays

  Plot <- .buildFixturePlot(Fixture)
  Series <- Plot$x$hc_opts$series

  expect_s3_class(Plot, "highchart")
  expect_s3_class(Plot, "htmlwidget")
  expect_identical(Fixture$curves, CurvesBefore)
  expect_identical(Fixture$rays, RaysBefore)
  expect_null(Plot$width)
  expect_identical(Plot$height, 560)
  expect_null(Plot$x$hc_opts$chart$width)
  expect_identical(Plot$x$hc_opts$chart$height, 560)
  expect_true(Plot$x$hc_opts$chart$reflow)
  expect_identical(attr(Plot, "sectionLayout"), "responsive-square-panels")
  expect_match(Plot$x$hc_opts$chart$events$render, "xAxis.update", fixed = TRUE)
  expect_match(Plot$x$hc_opts$chart$events$render, "yAxis.update", fixed = TRUE)
  expect_length(Plot$x$hc_opts$xAxis, 3L)
  expect_length(Plot$x$hc_opts$yAxis, 3L)
  expect_identical(
    vapply(Plot$x$hc_opts$xAxis, `[[`, numeric(1), "width"),
    vapply(Plot$x$hc_opts$yAxis, `[[`, numeric(1), "height")
  )
  expect_identical(
    vapply(Plot$x$hc_opts$xAxis, function(Axis) Axis$title$text, character(1)),
    c(
      "Normal force, N [N/m]",
      "Bending moment, M [N m/m]",
      "Shear force, Q [N/m]"
    )
  )
  expect_equal(
    sum(vapply(Series, function(Current) isTRUE(Current$showInLegend), logical(1))),
    2L
  )
  ReferenceSeries <- Filter(function(Current) {
    identical(Current$name, "Reference section")
  }, Series)
  expect_length(ReferenceSeries, 3L)
  expect_true(all(vapply(ReferenceSeries, function(Current) {
    identical(Current$dashStyle, "Solid") &&
      identical(Current$lineWidth, 2.4)
  }, logical(1))))

  CurveSeries <- Filter(function(Current) {
    length(Current$data) > 0L && !is.null(Current$data[[1L]]$custom)
  }, Series)
  expect_length(CurveSeries, 6L)
  expect_setequal(
    unique(vapply(CurveSeries, `[[`, character(1), "dashStyle")),
    c("ShortDash", "Dash")
  )
  expect_setequal(
    unique(vapply(CurveSeries, `[[`, character(1), "color")),
    c("#0072B2", "#D55E00")
  )
  expect_true(all(vapply(CurveSeries, function(Current) {
    identical(Current$lineWidth, 1.6)
  }, logical(1))))
  for (Current in CurveSeries) {
    Resultant <- Current$data[[1L]]$custom$resultant
    Expected <- Fixture$curves[
      Fixture$curves$prescription == Current$name &
        Fixture$curves$resultant == Resultant,
      ,
      drop = FALSE
    ]
    expect_identical(
      vapply(Current$data, `[[`, numeric(1), "x"),
      Expected$x
    )
    expect_identical(
      vapply(Current$data, `[[`, numeric(1), "y"),
      Expected$y
    )
    expect_identical(
      vapply(Current$data, function(Point) Point$custom$value, numeric(1)),
      Expected$value
    )
  }

  RaySeries <- Filter(function(Current) {
    !is.null(Current$linkedTo) && isFALSE(Current$enableMouseTracking)
  }, Series)
  expect_gt(length(RaySeries), 0L)
  expect_true(all(vapply(RaySeries, function(Current) {
    isFALSE(Current$requireSorting)
  }, logical(1))))
  for (Current in RaySeries) {
    NullPositions <- which(vapply(Current$data, is.null, logical(1)))
    expect_identical(
      NullPositions,
      seq(3L, length(Current$data), by = 3L)
    )
    expect_false(Current$connectNulls)
  }
})

test_that("case identifiers remain unique for similar labels", {
  Fixture <- .sectionResultantsFixture()
  CaseMap <- c(complete = "case a", `normal-only` = "case-a")
  Fixture$curves$case <- unname(CaseMap[Fixture$curves$case])
  Fixture$rays$case <- unname(CaseMap[Fixture$rays$case])

  Plot <- .buildFixturePlot(Fixture)
  GroupIDs <- attr(Plot, "sectionCaseIDs")
  MasterIDs <- vapply(
    Filter(function(Current) isTRUE(Current$showInLegend), Plot$x$hc_opts$series),
    `[[`,
    character(1),
    "id"
  )

  expect_named(GroupIDs, unname(CaseMap))
  expect_length(unique(unname(GroupIDs)), 2L)
  expect_setequal(MasterIDs, unname(GroupIDs))
})

test_that("buildSectionResultantsPlot accepts one prepared case", {
  Fixture <- .sectionResultantsFixture(caseCount = 1L)
  Plot <- .buildFixturePlot(Fixture)
  Series <- Plot$x$hc_opts$series

  expect_equal(
    sum(vapply(Series, function(Current) isTRUE(Current$showInLegend), logical(1))),
    1L
  )
})

test_that("buildSectionResultantsPlot accepts one prepared resultant", {
  Fixture <- .sectionResultantsFixture()
  Fixture$curves <- Fixture$curves[Fixture$curves$resultant == "M", ]
  Fixture$rays <- Fixture$rays[Fixture$rays$resultant == "M", ]

  Plot <- .buildFixturePlot(Fixture)
  Series <- Plot$x$hc_opts$series

  expect_length(Plot$x$hc_opts$xAxis, 1L)
  expect_length(Plot$x$hc_opts$yAxis, 1L)
  expect_identical(
    Plot$x$hc_opts$xAxis[[1L]]$title$text,
    "Bending moment, M [N m/m]"
  )
  expect_length(Filter(function(Current) {
    identical(Current$name, "Reference section")
  }, Series), 1L)
  expect_equal(
    sum(vapply(Series, function(Current) isTRUE(Current$showInLegend), logical(1))),
    2L
  )
  expect_identical(attr(Plot, "sectionLayout"), "responsive-square-panels")
})

test_that("buildSectionResultantsPlot rejects invalid display layers", {
  Fixture <- .sectionResultantsFixture()

  Missing <- Fixture$curves
  Missing$unit <- NULL
  expect_error(
    buildSectionResultantsPlot(Missing, Fixture$rays, 1),
    "missing required columns: unit"
  )

  Open <- Fixture$curves
  Open$x[nrow(Open)] <- Open$x[nrow(Open)] + 0.1
  expect_error(
    buildSectionResultantsPlot(Open, Fixture$rays, 1),
    "explicitly closed"
  )

  BadSign <- Fixture$rays
  BadSign$sign[1L] <- "zero"
  expect_error(
    buildSectionResultantsPlot(Fixture$curves, BadSign, 1),
    "only positive or negative"
  )

  BadOrigin <- Fixture$rays
  BadOrigin$xSection[1L] <- 0.5
  expect_error(
    buildSectionResultantsPlot(Fixture$curves, BadOrigin, 1),
    "start on the reference circle"
  )

  expect_error(
    buildSectionResultantsPlot(
      Fixture$curves,
      Fixture$rays,
      1,
      panelTitles = c(N = "N", M = "M")
    ),
    "panelTitles"
  )

  InvalidResultant <- Fixture$curves
  InvalidResultant$resultant[InvalidResultant$resultant == "Q"] <- "V"
  expect_error(
    buildSectionResultantsPlot(InvalidResultant, Fixture$rays, 1),
    "only N, M, and Q"
  )
})
