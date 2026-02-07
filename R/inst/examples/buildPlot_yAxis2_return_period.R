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
  yAxis2 = list(
    title = list(text = "TR [yr]"),
    labels = list(
      formatter = htmlwidgets::JS(
        "function(){ var aep = this.value; if (aep <= 0) return ''; var tr = 1/aep; return tr.toFixed(0); }"
      )
    )
  )
)

# Optional structural check (depends on highcharter internals)
if (!is.null(PLOT$x$hc_opts$yAxis)) {
  cat("yAxis count:", length(PLOT$x$hc_opts$yAxis), "\n")
}

print(PLOT)
