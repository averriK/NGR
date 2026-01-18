# Example: Using custom themes with gridlines for logarithmic scales
# 
# This example demonstrates the difference between standard themes and
# the enhanced gridline themes, especially useful for logarithmic scales.

library(data.table)
library(highcharter)

# Ensure NGR is loaded
if (!require("NGR", character.only = TRUE)) {
  devtools::load_all()
}

# Generate sample data for logarithmic scale
set.seed(123)
x_vals <- 10^seq(-2, 4, length.out = 100)
data_lines <- data.table(
  ID = rep(c("Curve A", "Curve B", "Curve C"), each = 100),
  X = rep(x_vals, 3),
  Y = c(
    x_vals^1.5 * rnorm(100, mean = 1, sd = 0.1),
    x_vals^1.2 * rnorm(100, mean = 1.5, sd = 0.15),
    x_vals^1.8 * rnorm(100, mean = 0.8, sd = 0.12)
  )
)

data_points <- data.table(
  ID = rep(c("Data Set 1", "Data Set 2"), each = 20),
  X = rep(10^seq(-1, 3.5, length.out = 20), 2),
  Y = c(
    (10^seq(-1, 3.5, length.out = 20))^1.5 * rnorm(20, mean = 1.1, sd = 0.2),
    (10^seq(-1, 3.5, length.out = 20))^1.2 * rnorm(20, mean = 1.6, sd = 0.25)
  )
)

# Example 1: Standard hc_theme_hcrt (NO visible minor gridlines)
cat("Creating plot with standard hc_theme_hcrt()...\n")
plot1 <- buildPlot(
  data.lines = data_lines,
  data.points = data_points,
  plot.title = "Standard hc_theme_hcrt",
  plot.subtitle = "Minor gridlines are NOT visible in log scale",
  xAxis.legend = "X (log scale)",
  yAxis.legend = "Y (log scale)",
  xAxis.log = TRUE,
  yAxis.log = TRUE,
  plot.theme = hc_theme_hcrt()
)
print(plot1)

# Example 2: Enhanced hc_theme_hcrt_gridlines (WITH visible minor gridlines)
cat("Creating plot with hc_theme_hcrt_gridlines()...\n")
plot2 <- buildPlot(
  data.lines = data_lines,
  data.points = data_points,
  plot.title = "Enhanced hc_theme_hcrt_gridlines",
  plot.subtitle = "Minor gridlines ARE visible in log scale",
  xAxis.legend = "X (log scale)",
  yAxis.legend = "Y (log scale)",
  xAxis.log = TRUE,
  yAxis.log = TRUE,
  plot.theme = hc_theme_hcrt_gridlines()
)
print(plot2)

# Example 3: Standard hc_theme_flat (NO visible minor gridlines)
cat("Creating plot with standard hc_theme_flat()...\n")
plot3 <- buildPlot(
  data.lines = data_lines,
  data.points = data_points,
  plot.title = "Standard hc_theme_flat",
  plot.subtitle = "Minor gridlines are NOT visible in log scale",
  xAxis.legend = "X (log scale)",
  yAxis.legend = "Y (log scale)",
  xAxis.log = TRUE,
  yAxis.log = TRUE,
  plot.theme = hc_theme_flat()
)
print(plot3)

# Example 4: Enhanced hc_theme_flat_gridlines (WITH visible minor gridlines)
cat("Creating plot with hc_theme_flat_gridlines()...\n")
plot4 <- buildPlot(
  data.lines = data_lines,
  data.points = data_points,
  plot.title = "Enhanced hc_theme_flat_gridlines",
  plot.subtitle = "Minor gridlines ARE visible (dotted) in log scale",
  xAxis.legend = "X (log scale)",
  yAxis.legend = "Y (log scale)",
  xAxis.log = TRUE,
  yAxis.log = TRUE,
  plot.theme = hc_theme_flat_gridlines()
)
print(plot4)

cat("\nAll examples completed!\n")
cat("Note: Minor gridlines are particularly useful in logarithmic scales\n")
cat("      to help read intermediate values between major tick marks.\n")
