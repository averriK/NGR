test_that("buildPlot preserves legacy output when ranges are absent", {
  DataLines <- data.table::data.table(
    ID = rep(c("A", "B"), each = 3),
    X = rep(1:3, 2),
    Y = c(1:3, 2:4)
  )

  Baseline <- buildPlot(data.lines = DataLines)
  Candidate <- buildPlot(data.lines = DataLines, data.ranges = NULL)

  expect_identical(Candidate$x$hc_opts, Baseline$x$hc_opts)
})

test_that("buildPlot collapses coincident ranges to one scalar series", {
  DataRanges <- data.table::data.table(
    ID = "Scalar",
    X = c(0, 1, 2),
    lower = c(0.5, 1.0, 1.5),
    upper = c(0.5, 1.0, 1.5),
    size = 3,
    color = "#336699",
    custom.lower = list(
      list(origin = "L0"),
      list(origin = "L1"),
      list(origin = "L2")
    ),
    custom.upper = list(
      list(origin = "U0"),
      list(origin = "U1"),
      list(origin = "U2")
    )
  )
  Before <- data.table::copy(DataRanges)

  Plot <- buildPlot(
    data.ranges = DataRanges,
    xAxis.log = TRUE,
    yAxis.log = TRUE
  )
  Series <- Plot$x$hc_opts$series

  expect_identical(DataRanges, Before)
  expect_length(Series, 1L)
  expect_identical(Series[[1L]]$type, "line")
  expect_identical(Series[[1L]]$name, "Scalar")
  expect_identical(Series[[1L]]$color, "#336699")
  expect_identical(Series[[1L]]$dashStyle, "Solid")
  expect_equal(Series[[1L]]$lineWidth, 3)
  expect_true(Series[[1L]]$showInLegend)
  expect_match(Series[[1L]]$id, "^ngr-range-[0-9]+$")
  expect_gt(Series[[1L]]$data[[1L]]$x, 0)
  expect_identical(Series[[1L]]$data[[1L]]$Xlabel, "0")
  expect_equal(vapply(Series[[1L]]$data, `[[`, numeric(1L), "y"), DataRanges$lower)
  expect_identical(Series[[1L]]$data[[1L]]$custom$rangeRole, "coincident")
  expect_identical(Series[[1L]]$data[[1L]]$custom$lower$origin, "L0")
  expect_identical(Series[[1L]]$data[[1L]]$custom$upper$origin, "U0")
  expect_false(grepl("rangeRole", Series[[1L]]$tooltip$pointFormat, fixed = TRUE))
  expect_identical(
    Series[[1L]]$tooltip$pointFormat,
    Plot$x$hc_opts$tooltip$pointFormat
  )
})

test_that("buildPlot adds one linked range group with bound metadata", {
  DataRanges <- data.table::data.table(
    ID = "Interval",
    X = c(0.5, 1.0, 2.0),
    lower = c(1.0, 1.5, 2.0),
    upper = c(1.4, 2.0, 2.8),
    size = 0.75,
    color = "#884422",
    custom.lower = list(
      list(origin = "A", statistic = "m"),
      list(origin = "B", statistic = "m"),
      list(origin = "A", statistic = "m")
    ),
    custom.upper = list(
      list(origin = "B", statistic = "m"),
      list(origin = "A", statistic = "m"),
      list(origin = "B", statistic = "m")
    )
  )

  Plot <- buildPlot(
    data.ranges = DataRanges,
    line.type = "spline",
    fill.opacity = 0.2
  )
  Series <- Plot$x$hc_opts$series
  MasterID <- Series[[1L]]$id

  expect_length(Series, 3L)
  expect_identical(
    vapply(Series, `[[`, character(1L), "type"),
    c("spline", "areasplinerange", "spline")
  )
  expect_identical(
    vapply(Series, `[[`, logical(1L), "showInLegend"),
    c(TRUE, FALSE, FALSE)
  )
  expect_identical(Series[[2L]]$linkedTo, MasterID)
  expect_identical(Series[[3L]]$linkedTo, MasterID)
  expect_equal(Series[[1L]]$lineWidth, 0.75)
  expect_equal(Series[[3L]]$lineWidth, 0.75)
  expect_identical(Series[[1L]]$dashStyle, "Solid")
  expect_identical(Series[[3L]]$dashStyle, "Solid")
  expect_equal(Series[[2L]]$fillOpacity, 0.2)
  expect_equal(Series[[2L]]$data[[2L]]$low, 1.5)
  expect_equal(Series[[2L]]$data[[2L]]$high, 2.0)
  expect_identical(Series[[1L]]$data[[2L]]$custom$rangeRole, "lower")
  expect_identical(Series[[1L]]$data[[2L]]$custom$metadata$origin, "B")
  expect_identical(Series[[3L]]$data[[2L]]$custom$rangeRole, "upper")
  expect_identical(Series[[3L]]$data[[2L]]$custom$metadata$origin, "A")
  expect_match(
    Series[[1L]]$tooltip$pointFormat,
    "\\{point\\.custom\\.rangeRole\\}"
  )
  expect_identical(
    Series[[1L]]$tooltip$pointFormat,
    Series[[3L]]$tooltip$pointFormat
  )
  expect_null(Series[[2L]]$tooltip)
})

test_that("buildPlot rejects duplicate and unordered range points", {
  Duplicate <- data.table::data.table(
    ID = c("A", "A"),
    X = c(1, 1),
    lower = c(1, 2),
    upper = c(2, 3)
  )
  Unordered <- data.table::data.table(
    ID = "A",
    X = 1,
    lower = 2,
    upper = 1
  )

  expect_error(
    buildPlot(data.ranges = Duplicate),
    "unique combinations of ID and X"
  )
  expect_error(
    buildPlot(data.ranges = Unordered),
    "lower must not exceed upper"
  )
})

test_that("buildPlot requires named-list range metadata", {
  BadCustom <- data.table::data.table(
    ID = "A",
    X = 1,
    lower = 1,
    upper = 2,
    custom.lower = "not-a-list"
  )

  expect_error(buildPlot(data.ranges = BadCustom), "custom.lower")
})
