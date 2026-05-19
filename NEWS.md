# NGR 0.3.7

## Visual

* `hc_theme_*_gridlines()`: bump minor gridline visibility from
  `#EEEEEE` / `#E0E0E0` @ width 0.25 to `#D8D8D8` / `#C8C8C8` @
  width 0.5. The previous very-faint settings were essentially
  invisible against white backgrounds, defeating the purpose of
  the `_gridlines` variants (which exist specifically to provide
  auxiliary subdivisions between major ticks on logarithmic
  axes). New settings remain clearly subordinate to major
  gridlines but are now readable.

# NGR 0.3.6

## Bug fixes

* `buildPlot()`: revert the `tickPositioner` injection added in 0.3.4.
  Highcharts treats `tickPositioner` positions as linear coordinates
  on a logarithmic axis, which collapsed our custom positions to the
  right edge of the plot and suppressed minor gridlines. Tick
  *placement* is now left entirely to Highcharts' native log
  autoplacing; the offset compensation is done by the label formatter
  alone. Two snap rules in the formatter:
  - `|val| < 1.5 * offset` -> label `"0"` (the un-shifted position
    of the original `X=0` cluster).
  - `val` within 10% (relative) of a power of ten -> snap to that
    power (catches the typical `0.0092 -> 0.01` case where the
    offset shift introduces an ~8% error in the un-shifted value).
  No more ugly tail digits, minor gridlines restored.

# NGR 0.3.5

## Bug fixes

* `buildPlot()`: change default `plot.theme` from `hc_theme_flat()` to
  `hc_theme_flat_gridlines()`. The previous default silently broke the
  log-axis `tickPositioner` callback (see 0.3.4) because it omitted
  `minorTickInterval = "auto"` — without that, Highcharts skips the
  custom tick positions entirely and renders no major ticks on a
  logarithmic axis with offset shift. The `_gridlines` variant is a
  strict superset (everything from `hc_theme_flat()` plus minor
  gridlines + minorTickInterval) and lets the tickPositioner take
  effect. Callers that explicitly pass `plot.theme = ...` are
  unaffected.

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
