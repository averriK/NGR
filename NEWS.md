# NGR 0.3.4

## Bug fixes

* `buildPlot()`: fix major-tick labels on logarithmic axes when the data
  contains non-positive values (e.g. `Tn = 0` for PGA in response
  spectra). The existing `xAxis.log.offset` / `yAxis.log.offset`
  mechanism shifts the data so non-positive points become plottable on
  a `type = "logarithmic"` axis, and a JS label formatter subtracts
  the offset to render labels in original space. Previously Highcharts
  auto-placed ticks at clean powers of ten in the *shifted* axis space,
  so the label formatter turned them into ugly values
  (`0.009 / 0.099 / 0.999 / 9.999`). This release adds a
  `tickPositioner` JS callback (auto-injected when `x_offset > 0` or
  `y_offset > 0`) that picks tick positions at `10^n + offset` in the
  shifted axis, so the formatter renders clean decades
  (`0.01 / 0.1 / 1 / 10`) plus a `"0"` tick at the offset position
  itself. The positioner derives the exponent range from the actual
  axis `dataMin` / `dataMax` at render time — no R-side hardcoded
  tick positions, adapts to any data range. No change for users who
  pass `*.log.offset = FALSE` or for data without non-positive values.
