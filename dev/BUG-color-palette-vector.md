# BUG: buildPlot() rejects a vector of hex colors in color.palette

Reported: 2026-08-20 (found while plotting from the OPAL project).

## Symptom

```r
NGR::buildPlot(data.lines = L, data.points = P,
  color.palette = c("#9CA3AF", "#B91C1C"))
#> Error in if (!color.palette %in% grDevices::hcl.pals()) { :
#>   the condition has length > 1
```

## Location

`R/buildPlot.R:200`:

```r
if (!color.palette %in% grDevices::hcl.pals()) {
```

With a vector argument, `%in%` returns a logical vector and `if()` aborts
(error on R >= 4.2, silent first-element use before that).

## Inconsistency

The sibling builder documents vector support explicitly
(`R/buildPlot.Bar.R`, `@param color.palette "Either a character vector of
hex colors or a single string matching a known palette"`), so callers
reasonably expect `buildPlot()` to accept one too.

## Suggested fix

Branch on length before the palette lookup:

```r
if (length(color.palette) == 1L && color.palette %in% grDevices::hcl.pals()) {
  COLORS <- grDevices::hcl.colors(n, palette = color.palette)
} else {
  COLORS <- color.palette   # literal colors, recycled/validated as needed
}
```

## Workaround

Pass a palette name (e.g. `"Dark 3"`) instead of literal colors.
