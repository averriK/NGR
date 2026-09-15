test_that("buildPlot.Time returns a stock highchart on a datetime axis", {
  DAY <- as.Date("2020-01-01") + c(0, 30, 60)
  PLOT <- buildPlot.Time(data.frame(ID = "a", X = DAY, Y = c(1, 2, 3)))
  expect_s3_class(PLOT, "highchart")
  expect_equal(PLOT$x$type, "stock")
  expect_equal(PLOT$x$hc_opts$xAxis$type, "datetime")
})

test_that("a gap in the record serialises as null and is not bridged", {
  DAY <- as.Date("2020-01-01") + c(0, 30, 60, 90)
  PLOT <- buildPlot.Time(data.frame(ID = "a", X = DAY, Y = c(1, NA, NA, 4)))
  DATA <- PLOT$x$hc_opts$series[[1]]$data
  expect_null(DATA[[2]][[2]])
  expect_null(DATA[[3]][[2]])
  expect_equal(DATA[[4]][[2]], 4)
  expect_false(PLOT$x$hc_opts$series[[1]]$connectNulls)
})

test_that("POSIXct input is accepted and Date input is not required", {
  T0 <- as.POSIXct("2020-01-01 06:00:00", tz = "UTC") + c(0, 86400)
  PLOT <- buildPlot.Time(data.frame(ID = "a", X = T0, Y = c(1, 2)))
  expect_equal(
    PLOT$x$hc_opts$series[[1]]$data[[1]][[1]],
    as.numeric(T0[[1]]) * 1000
  )
})

test_that("reference lines land on the ordinate, outside the legend", {
  DAY <- as.Date("2020-01-01") + c(0, 30)
  PLOT <- buildPlot.Time(
    data.frame(ID = "a", X = DAY, Y = c(1, 2)),
    referenceLines = data.frame(
      value = c(1.5, 1.8), label = c("low", "high"),
      color = c("#111111", "#222222"), style = c("dash", "solid")
    )
  )
  LINES <- PLOT$x$hc_opts$yAxis$plotLines
  expect_length(LINES, 2L)
  expect_equal(LINES[[1]]$value, 1.5)
  expect_equal(LINES[[1]]$color, "#111111")
  expect_equal(LINES[[1]]$dashStyle, "Dash")
  expect_equal(LINES[[2]]$label$text, "high")
})

test_that("the linked right axis restates the ordinate affinely", {
  DAY <- as.Date("2020-01-01") + c(0, 30)
  PLOT <- buildPlot.Time(
    data.frame(ID = "a", X = DAY, Y = c(1, 2)),
    y2Legend = "Depth", y2Offset = 100, y2Scale = -1, y2Decimals = 2
  )
  expect_length(PLOT$x$hc_opts$yAxis, 2L)
  expect_equal(PLOT$x$hc_opts$yAxis[[2]]$linkedTo, 0)
  expect_true(PLOT$x$hc_opts$yAxis[[2]]$opposite)
  expect_true(grepl("toFixed\\(2\\)", PLOT$x$hc_opts$yAxis[[2]]$labels$formatter))
})

test_that("a scatter series draws no line", {
  DAY <- as.Date("2020-01-01") + c(0, 30)
  PLOT <- buildPlot.Time(
    data.frame(ID = "a", X = DAY, Y = c(1, 2), type = "scatter")
  )
  expect_equal(PLOT$x$hc_opts$series[[1]]$type, "scatter")
  expect_equal(PLOT$x$hc_opts$series[[1]]$lineWidth, 0)
})

test_that("invalid input is rejected with a named reason", {
  expect_warning(OUT <- buildPlot.Time(data.frame()), "no data to plot")
  expect_null(OUT)
  expect_error(
    buildPlot.Time(data.frame(ID = "a", X = 1, Y = 1)),
    "Date or POSIXct"
  )
  expect_error(
    buildPlot.Time(
      data.frame(ID = "a", X = as.Date("2020-01-01"), Y = 1),
      yLimits = c(5, 1)
    ),
    "two increasing numbers"
  )
  expect_error(
    buildPlot.Time(
      data.frame(ID = "a", X = as.Date("2020-01-01"), Y = 1),
      referenceLines = data.frame(value = 1)
    ),
    "value and label"
  )
})
