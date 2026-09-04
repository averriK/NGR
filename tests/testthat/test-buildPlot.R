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

# Axis bands -----------------------------------------------------------------
# The outer regions of the `cuts` form are open-ended: their bound is the
# finite sentinel 1e100 (1e-100 below a logarithmic axis), which Highcharts
# clamps to the axis.

test_that("buildPlot without axis bands matches the 0.3.10 configuration", {
  # Snapshots recorded from NGR 0.3.10 (commit 0f7c461), before axis bands
  # existed. Any drift here means a call without bands changed.
  Lines <- data.table::data.table(
    ID = rep(c("A", "B"), each = 3),
    X = rep(1:3, 2),
    Y = c(1, 4, 9, 2, 3, 5)
  )
  Axis2 <- data.table::rbindlist(list(
    data.table::data.table(ID = "Pressure", X = 1:3, Y = c(10, 11, 10.5), yAxis = 0),
    data.table::data.table(ID = "Temp", X = 1:3, Y = c(20, 21, 19), yAxis = 1)
  ))
  Ranges <- data.table::data.table(
    ID = "Interval",
    X = c(0, 1, 2),
    lower = c(1.0, 1.5, 2.0),
    upper = c(1.4, 2.0, 2.8)
  )

  expect_snapshot_value(
    buildPlot(data.lines = Lines)$x$hc_opts,
    style = "deparse"
  )
  expect_snapshot_value(
    buildPlot(
      data.lines = Lines,
      yAxis2.legend = "TR",
      yAxis2.transform = ~ 1 / Y,
      yAxis2.decimals = 2
    )$x$hc_opts,
    style = "deparse"
  )
  expect_snapshot_value(
    buildPlot(data.lines = Axis2, yAxis2.legend = "Temp")$x$hc_opts,
    style = "deparse"
  )
  expect_snapshot_value(
    buildPlot(data.ranges = Ranges, xAxis.log = TRUE, yAxis.log = TRUE)$x$hc_opts,
    style = "deparse"
  )
})

test_that("buildPlot treats NULL axis bands as absent", {
  Lines <- data.table::data.table(ID = "A", X = 1:3, Y = c(1, 4, 9))

  Baseline <- buildPlot(data.lines = Lines)
  Candidate <- buildPlot(data.lines = Lines, xAxis.bands = NULL, yAxis.bands = NULL)

  expect_identical(Candidate$x, Baseline$x)
})

test_that("buildPlot emits open-ended axis bands from cuts", {
  Lines <- data.table::data.table(ID = "A", X = 1:4, Y = c(0.05, 0.5, 2, 8))
  Colors <- c("rgba(251,146,60,0.07)", "rgba(249,115,22,0.15)", "rgba(220,38,38,0.19)")

  Plot <- buildPlot(
    data.lines = Lines,
    xAxis.bands = list(cuts = c(2, 3), colors = c("#AAAAAA", "#BBBBBB", "#CCCCCC")),
    yAxis.bands = list(cuts = c(0.1, 1), colors = Colors)
  )
  XBands <- Plot$x$hc_opts$xAxis$plotBands
  YBands <- Plot$x$hc_opts$yAxis$plotBands

  expect_length(XBands, 3L)
  expect_identical(vapply(XBands, `[[`, numeric(1L), "from"), c(-1e100, 2, 3))
  expect_identical(vapply(XBands, `[[`, numeric(1L), "to"), c(2, 3, 1e100))
  expect_identical(
    vapply(XBands, `[[`, character(1L), "color"),
    c("#AAAAAA", "#BBBBBB", "#CCCCCC")
  )
  expect_identical(vapply(XBands, `[[`, numeric(1L), "zIndex"), c(0, 0, 0))

  expect_length(YBands, 3L)
  expect_identical(vapply(YBands, `[[`, numeric(1L), "from"), c(-1e100, 0.1, 1))
  expect_identical(vapply(YBands, `[[`, numeric(1L), "to"), c(0.1, 1, 1e100))
  expect_identical(vapply(YBands, `[[`, character(1L), "color"), Colors)
  expect_null(Plot$x$hc_opts$yAxis$plotLines)
})

test_that("buildPlot serialises axis bands as numeric bounds", {
  # jsonlite turns Inf into null, so the widget HTML is the observable that
  # proves the bounds reach the browser as numbers.
  Lines <- data.table::data.table(ID = "A", X = 1:3, Y = c(1, 4, 9))
  File <- tempfile(fileext = ".html")
  on.exit(unlink(c(File, sub("\\.html$", "_files", File)), recursive = TRUE), add = TRUE)

  htmlwidgets::saveWidget(
    buildPlot(data.lines = Lines, xAxis.bands = list(cuts = 2, colors = c("#111111", "#222222"))),
    File,
    selfcontained = FALSE
  )
  Html <- paste(readLines(File, warn = FALSE), collapse = "\n")

  expect_match(
    Html,
    '"plotBands":\\[\\{"from":-1e\\+100,"to":2,"color":"#111111","zIndex":0\\},\\{"from":2,"to":1e\\+100,"color":"#222222","zIndex":0\\}\\]',
    fixed = FALSE
  )
  # Scan the serialised band block itself: the surrounding widget always
  # carries unrelated nulls in the Highcharts global config.
  Bands <- regmatches(Html, regexpr('"plotBands":\\[[^]]*\\]', Html))
  expect_length(Bands, 1L)
  expect_false(grepl("null", Bands))
})

test_that("buildPlot bands beyond the axis range stay well formed", {
  # The axis reaches 0.5 while the cuts sit at 1 and 2: Highcharts clips the
  # bands to the axis, so the only requirement is from < to for every band.
  Lines <- data.table::data.table(ID = "A", X = c(0, 0.25, 0.5), Y = c(1, 2, 3))

  Plot <- buildPlot(
    data.lines = Lines,
    xAxis.max = 0.5,
    xAxis.bands = list(cuts = c(1, 2), colors = c("#111111", "#222222", "#333333"))
  )
  Bands <- Plot$x$hc_opts$xAxis$plotBands
  From <- vapply(Bands, `[[`, numeric(1L), "from")
  To <- vapply(Bands, `[[`, numeric(1L), "to")

  expect_length(Bands, 3L)
  expect_true(all(From < To))
  expect_true(From[[1L]] < min(Lines$X))
  expect_true(To[[3L]] > max(Lines$X))
  expect_identical(From[2:3], c(1, 2))
  expect_identical(To[1:2], c(1, 2))
})

test_that("buildPlot rejects malformed axis bands", {
  Lines <- data.table::data.table(ID = "A", X = 1:3, Y = c(1, 4, 9))
  Three <- c("#111111", "#222222", "#333333")

  expect_error(
    buildPlot(data.lines = Lines, xAxis.bands = list(cuts = c(2, 1), colors = Three)),
    "buildPlot\\(\\): xAxis.bands\\$cuts must be strictly increasing"
  )
  expect_error(
    buildPlot(data.lines = Lines, xAxis.bands = list(cuts = c(1, NA), colors = Three)),
    "buildPlot\\(\\): xAxis.bands\\$cuts must be finite numbers"
  )
  expect_error(
    buildPlot(data.lines = Lines, xAxis.bands = list(cuts = c("1", "2"), colors = Three)),
    "buildPlot\\(\\): xAxis.bands\\$cuts must be finite numbers"
  )
  expect_error(
    buildPlot(data.lines = Lines, yAxis.bands = list(cuts = c(1, 2), colors = Three[1:2])),
    "buildPlot\\(\\): yAxis.bands\\$colors must have length\\(cuts\\) \\+ 1 entries"
  )
  expect_error(
    buildPlot(data.lines = Lines, yAxis.bands = "red"),
    "buildPlot\\(\\): yAxis.bands must be"
  )
  expect_error(
    buildPlot(data.lines = Lines, xAxis.bands = list(list(from = 2, to = 1, color = "#111111"))),
    "buildPlot\\(\\): xAxis.bands entries must satisfy from < to"
  )
})

test_that("buildPlot rejects non-positive cuts on a logarithmic axis", {
  Lines <- data.table::data.table(ID = "A", X = c(0.1, 1, 10), Y = c(1, 4, 9))
  Three <- c("#111111", "#222222", "#333333")

  expect_error(
    buildPlot(data.lines = Lines, xAxis.log = TRUE, xAxis.bands = list(cuts = c(0, 1), colors = Three)),
    "buildPlot\\(\\): xAxis.bands\\$cuts must be positive on a logarithmic axis"
  )
  expect_error(
    buildPlot(data.lines = Lines, yAxis.log = TRUE, yAxis.bands = list(cuts = c(-1, 1), colors = Three)),
    "buildPlot\\(\\): yAxis.bands\\$cuts must be positive on a logarithmic axis"
  )

  # A logarithmic axis opens at a positive bound: log10 of 0 or of a
  # negative number is not a coordinate Highcharts can place.
  Plot <- buildPlot(
    data.lines = Lines,
    xAxis.log = TRUE,
    xAxis.bands = list(cuts = c(0.5, 5), colors = Three)
  )
  Bands <- Plot$x$hc_opts$xAxis$plotBands
  expect_identical(Bands[[1L]]$from, 1e-100)
  expect_identical(Bands[[3L]]$to, 1e100)
})

test_that("buildPlot passes prebuilt axis bands through unchanged", {
  Lines <- data.table::data.table(ID = "A", X = 1:3, Y = c(1, 4, 9))
  Spec <- list(
    list(from = 0, to = 1, color = "#EEEEEE"),
    list(from = 1, to = 2, color = "#DDDDDD", zIndex = 5, label = list(text = "two"))
  )

  Plot <- buildPlot(data.lines = Lines, xAxis.bands = Spec, yAxis.bands = Spec)

  expect_identical(Plot$x$hc_opts$xAxis$plotBands, Spec)
  expect_identical(Plot$x$hc_opts$yAxis$plotBands, Spec)
})

test_that("buildPlot wires axis bands into the secondary-axis branch", {
  Lines <- data.table::data.table(ID = "A", X = 1:3, Y = c(1, 4, 9))
  Axis2 <- data.table::rbindlist(list(
    data.table::data.table(ID = "Pressure", X = 1:3, Y = c(10, 11, 10.5), yAxis = 0),
    data.table::data.table(ID = "Temp", X = 1:3, Y = c(20, 21, 19), yAxis = 1)
  ))
  XSpec <- list(cuts = 2, colors = c("#111111", "#222222"))
  YSpec <- list(cuts = c(2, 5), colors = c("#AAAAAA", "#BBBBBB", "#CCCCCC"))

  Linked <- buildPlot(
    data.lines = Lines,
    yAxis2.legend = "TR",
    yAxis2.transform = ~ 1 / Y,
    xAxis.bands = XSpec,
    yAxis.bands = YSpec
  )
  Independent <- buildPlot(
    data.lines = Axis2,
    yAxis2.legend = "Temp",
    xAxis.bands = XSpec,
    yAxis.bands = YSpec
  )

  for (Plot in list(Linked, Independent)) {
    expect_length(Plot$x$hc_opts$yAxis, 2L)
    expect_length(Plot$x$hc_opts$xAxis$plotBands, 2L)
    expect_length(Plot$x$hc_opts$yAxis[[1L]]$plotBands, 3L)
    expect_null(Plot$x$hc_opts$yAxis[[2L]]$plotBands)
    expect_equal(Plot$x$hc_opts$yAxis[[1L]]$plotBands[[2L]]$from, 2)
    expect_equal(Plot$x$hc_opts$yAxis[[1L]]$plotBands[[2L]]$to, 5)
  }
})
