test_that("buildPlot.Profile returns a highchart with one series per ID", {
  DT <- rbind(
    data.frame(ID = "a", X = c(0, 1, 2), Y = c(1, 2, 3)),
    data.frame(ID = "b", X = c(0, -1, -2), Y = c(1, 2, 3))
  )
  PLOT <- buildPlot.Profile(DT, xLimit = 25)
  expect_s3_class(PLOT, "highchart")
  expect_length(PLOT$x$hc_opts$series, 2L)
  expect_equal(PLOT$x$hc_opts$series[[1]]$name, "a")
})

test_that("the depth axis is reversed and the abscissa is symmetric", {
  DT <- data.frame(ID = "a", X = c(0, 3), Y = c(1, 8))
  PLOT <- buildPlot.Profile(DT, xLimit = 25, yMax = 10)
  expect_true(PLOT$x$hc_opts$yAxis$reversed)
  expect_equal(PLOT$x$hc_opts$yAxis$min, 0)
  expect_equal(PLOT$x$hc_opts$yAxis$max, 10)
  expect_equal(PLOT$x$hc_opts$xAxis$min, -25)
  expect_equal(PLOT$x$hc_opts$xAxis$max, 25)
})

test_that("xLimit is derived from the data when absent", {
  DT <- data.frame(ID = "a", X = c(-4, 7), Y = c(1, 2))
  PLOT <- buildPlot.Profile(DT)
  expect_equal(PLOT$x$hc_opts$xAxis$max, 7)
  expect_equal(PLOT$x$hc_opts$xAxis$min, -7)
})

test_that("an explicit colour overrides the palette", {
  DT <- rbind(
    data.frame(ID = "a", X = 0, Y = 1, color = "#123456"),
    data.frame(ID = "b", X = 1, Y = 1, color = NA)
  )
  PLOT <- buildPlot.Profile(DT)
  expect_equal(PLOT$x$hc_opts$series[[1]]$color, "#123456")
  expect_true(grepl("^#", PLOT$x$hc_opts$series[[2]]$color))
})

test_that("every series carries the legend so a composed pair stays labelled", {
  DT <- rbind(
    data.frame(ID = "a", X = 0, Y = 1),
    data.frame(ID = "b", X = 1, Y = 1)
  )
  PLOT <- buildPlot.Profile(DT)
  expect_true(all(vapply(PLOT$x$hc_opts$series, function(s) {
    isTRUE(s$showInLegend)
  }, logical(1))))
  PLOT <- buildPlot.Profile(DT, showLegend = FALSE)
  expect_false(PLOT$x$hc_opts$legend$enabled)
})

test_that("per-series style and size reach the widget", {
  DT <- data.frame(ID = "a", X = c(0, 1), Y = c(1, 2),
    style = "longdashdotdot", size = 1)
  PLOT <- buildPlot.Profile(DT)
  expect_equal(PLOT$x$hc_opts$series[[1]]$dashStyle, "LongDashDotDot")
  expect_equal(PLOT$x$hc_opts$series[[1]]$lineWidth, 1)
})

test_that("invalid input is rejected with a named reason", {
  expect_error(buildPlot.Profile(data.frame()), "non-empty")
  expect_error(
    buildPlot.Profile(data.frame(ID = "a", X = 1)),
    "columns ID, X and Y"
  )
  expect_error(
    buildPlot.Profile(data.frame(ID = "a", X = NA_real_, Y = 1)),
    "must not contain NA"
  )
  expect_error(
    buildPlot.Profile(data.frame(ID = "a", X = 1, Y = 1), xLimit = -1),
    "positive number"
  )
})
