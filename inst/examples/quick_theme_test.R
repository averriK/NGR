# Quick test of new gridline themes
# Run this to see the improved gridlines in logarithmic scales

library(NGR)
library(data.table)

# Sample log-scale data
x <- 10^seq(-1, 3, length.out = 50)
data_lines <- data.table(
  ID = "Test Line",
  X = x,
  Y = x^1.5 * rnorm(50, 1, 0.05)
)

# Test the improved HCRT theme
cat("Testing hc_theme_hcrt_gridlines()...\n")
plot1 <- buildPlot(
  data.lines = data_lines,
  plot.title = "HCRT Theme with Gridlines",
  xAxis.log = TRUE,
  yAxis.log = TRUE,
  plot.theme = hc_theme_hcrt_gridlines()
)
print(plot1)

# Test the FiveThirtyEight theme
cat("Testing hc_theme_538_gridlines()...\n")
plot2 <- buildPlot(
  data.lines = data_lines,
  plot.title = "FiveThirtyEight Theme with Gridlines",
  xAxis.log = TRUE,
  yAxis.log = TRUE,
  plot.theme = hc_theme_538_gridlines()
)
print(plot2)

# Test the Economist theme
cat("Testing hc_theme_economist_gridlines()...\n")
plot3 <- buildPlot(
  data.lines = data_lines,
  plot.title = "Economist Theme with Gridlines",
  xAxis.log = TRUE,
  yAxis.log = TRUE,
  plot.theme = hc_theme_economist_gridlines()
)
print(plot3)

cat("\n✓ All themes loaded successfully!\n")
cat("\nGridline configuration:\n")
cat("- Major lines: 0.6-0.75 width, medium gray\n")
cat("- Minor lines: 0.25-0.3 width, very light gray\n")
cat("- Both optimized for logarithmic scales\n")
