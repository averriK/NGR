# Example: buildPlot() with optional secondary Y axis (linked to primary)
# Use case: right axis shows Return Period (TR) when left axis is AEP.

# Load NGR from source (dev)
# Run this example from the package root.
devtools::load_all()

library(data.table)

# Sample hazard-like curve: AEP decreases with X
x <- 10^seq(-1, 2, length.out = 60)
aep <- 10^seq(-1, -4, length.out = 60)

data_lines <- data.table(
  ID = "Curve",
  X = x,
  Y = aep
)

PLOT <- buildPlot(
  data.lines = data_lines,
  plot.title = "AEP with secondary axis for Return Period (TR)",
  xAxis.legend = "Intensity",
  yAxis.legend = "AEP",
  xAxis.log = TRUE,
  yAxis.log = TRUE,
  yAxis2.legend = "TR [yr]",
  yAxis2.transform = ~ 1 / Y,
  yAxis2.decimals = 0
)

# Optional structural check (depends on highcharter internals)
if (!is.null(PLOT$x$hc_opts$yAxis)) {
  cat("yAxis count:", length(PLOT$x$hc_opts$yAxis), "\n")
}

print(PLOT)
