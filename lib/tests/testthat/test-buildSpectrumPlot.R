test_that("prepared acceleration spectra retain their display and input", {
  DATA <- data.table::data.table(
    ID = rep(c("lower", "upper"), each = 3L),
    X = rep(c(0, 0.1, 1), 2L),
    Y = c(0.1, 0.2, 0.15, 0.2, 0.4, 0.3),
    style = rep(c("Dot", "Solid"), each = 3L),
    size = rep(c(0.75, 3.5), each = 3L)
  )
  Before <- data.table::copy(DATA)
  Plot <- buildSpectrumPlot(DATA, logScale = TRUE, fill = TRUE, fillSize = 0.75)
  expect_s3_class(Plot, "highchart")
  expect_identical(DATA, Before)
  expect_length(Plot$x$hc_opts$series, 5L)
  expect_identical(Plot$x$hc_opts$xAxis$title$text, "Tn [s]")
  expect_identical(Plot$x$hc_opts$yAxis$title$text, "Sa [g]")
  expect_identical(Plot$x$hc_opts$xAxis$type, "logarithmic")
  expect_identical(Plot$x$hc_opts$yAxis$type, "logarithmic")
  expect_identical(Plot$x$hc_opts$series[[1L]]$data[[1L]]$Xlabel, "PGA")
  expect_identical(Plot$x$hc_opts$series[[1L]]$dashStyle, "Dot")
  expect_identical(Plot$x$hc_opts$series[[2L]]$lineWidth, 3.5)
  expect_identical(Plot$x$hc_opts$series[[3L]]$lineWidth, 0.75)
  Plot <- buildSpectrumPlot(DATA, logScale = FALSE, fill = FALSE, fillSize = 0.75)
  expect_length(Plot$x$hc_opts$series, 2L)
  expect_identical(Plot$x$hc_opts$yAxis$type, "linear")
  expect_identical(DATA, Before)
})
