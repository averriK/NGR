test_that("buildHeatmap keeps raw axis values for tooltips", {
  data <- data.table::data.table(
    X = c(50, 100),
    Y = c(5.5, 6.0),
    Z = c(12.345, 45.678)
  )

  plot <- buildHeatmap(
    data,
    xAxis.legend = "R [km]",
    yAxis.legend = "Mw",
    series.name = "Contribution [%]"
  )

  points <- plot$x$hc_opts$series[[1]]$data

  expect_equal(points[[1]]$x, 0L)
  expect_equal(points[[1]]$y, 0L)
  expect_equal(points[[1]]$xLabel, "50")
  expect_equal(points[[1]]$yLabel, "5.5")
  expect_equal(points[[1]]$value, 12.35)

  expect_equal(plot$x$hc_opts$xAxis$categories, c("50", "100"))
  expect_equal(plot$x$hc_opts$yAxis$categories, c("5.5", "6"))
  expect_match(plot$x$hc_opts$tooltip$pointFormat, "point\\.xLabel")
  expect_match(plot$x$hc_opts$tooltip$pointFormat, "point\\.yLabel")
})
