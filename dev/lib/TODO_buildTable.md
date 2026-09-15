# TODOs pendientes — DOCX pipeline

## 1. Reduce row spacing in buildTable() flextable output

### Problem
Flextable's default cell padding (5pt top + 5pt bottom per cell) makes table rows too spacious in DOCX output.

### Location
`~/github/libraries/NGR/R/R/buildTable.R`, function `.buildTable.ft` (around line 138)

### Change
After the alignment block:
```r
TABLE <- flextable::align(TABLE, align = align.body, part = "body")
```

Add:
```r
# Compact cell padding for DOCX
TABLE <- flextable::padding(TABLE, padding.top = 2, padding.bottom = 2, part = "body")
TABLE <- flextable::padding(TABLE, padding.top = 3, padding.bottom = 3, part = "header")
```

### After
1. Commit + push in NGR
2. Reinstall: `devtools::install("~/github/libraries/NGR/R")` or `R CMD INSTALL ~/github/libraries/NGR/R`
3. Re-render test from AR-S2J2H
4. Verify rows are compact in Word

---

## 2. Heading styles: section numbers in margin

### Problem
Modern documents have section numbers (1, 1.1, 1.1.1) hanging into the left margin, with heading text aligned to the same left edge as body text. Currently headings have no hanging indent (we removed the broken one). Pandoc puts a SPACE (not tab) between the number and the title, so tab-based hanging indent alone won't work.

### Solution (requires two parts)
**Part A — reference.docx**: Set Heading 1-4 styles with:
- `left` indent = width of widest number at that level (e.g., H1=0.8cm, H2=1.2cm, H3=1.6cm)
- `hanging` = same value
- Tab stop at the left indent position

**Part B — post-processing or Quarto Lua filter**: Replace the space between section number and title with a tab character (`<w:tab/>`) in the DOCX XML. Without this, the tab stop has no effect.

### Notes
- Test with `number-sections: true` in memo config
- The Lua filter approach is cleaner than post-processing (modifies at render time)
- Alternative: use Pandoc's `--number-offset` and custom header templates

---

## 3. Figure height for highcharter widgets

### Problem
Highcharter plots set their own height via `plot.height` in R (e.g., `plot.height = 1000`). When Quarto converts to docx via webshot2, the widget height overrides `fig-height` from YAML config. Result: images are 1890x700px instead of 1890x1350px.

### Location
`~/github/libraries/psha/_fig/DEQ.R` and other `_fig/*.R` files that use `buildPlot()`.

### Options
- **Option A**: Remove `plot.height` from buildPlot calls, let Quarto's `fig-height` control it
- **Option B**: Set `plot.height` to match the configured aspect ratio (fig-width/fig-height × dpi)
- **Option C**: Fix in `buildPlot()` or `.buildFigure()` in `~/github/libraries/NGR/R` to respect Quarto's figure dimensions

### Investigation needed
Check how webshot2 captures the widget — does it respect `fig-height` at all for HTML widgets? If not, the fix must be in the R code.

---

## 4. Sync cover.docx styles with reference.docx

### Problem
After tuning styles in `styles/reference.docx`, `styles/cover.docx` must be updated to have compatible styles. When `merge_cover.py` merges cover + body via docxcompose, conflicting style definitions in cover.docx can overwrite the tuned body styles.

### Solution
After ALL reference.docx style tuning is finalized:
1. Extract `word/styles.xml` from the final reference.docx
2. Replace `word/styles.xml` in cover.docx with the same one (or at minimum ensure heading, caption, body text styles match)
3. Re-test the full pipeline: render → fix_docx → merge_cover
4. Verify styles survive the merge

### Notes
- Do this LAST, after all other style changes are stable
- docxcompose merges styles from both documents — if cover.docx defines "Heading 1" differently, it wins
- Alternative: modify merge_cover.py to preserve body styles.xml after merge
