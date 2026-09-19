# nolint start
# setup.R — sourced by all Quarto manifests. Safe to source multiple times.
#
# Responsibilities:
#   1) packages / libraries
#   2) helpers (utils.R)
#   3) project contracts (hazard.json, newmark.json)
#   4) params.yml
#   5) plotting / formatting defaults
#   6) OQ table loading (global.R)

stopifnot(exists("root"))

# ── 1) Packages ────────────────────────────────────────────────────────
Packages <- c(
  "data.table", "yaml", "knitr", "highcharter", "htmlwidgets", "webshot2",
  "ggplot2", "flextable", "dsra", "newmark", "NGR"
)
OK <- vapply(Packages, function(PKG) requireNamespace(PKG, quietly = TRUE), logical(1))
Missing <- Packages[!OK]
if (length(Missing)) {
  stop(
    sprintf(
      "Missing required R packages: %s. Install them before rendering.",
      paste(Missing, collapse = ", ")
    ),
    call. = FALSE
  )
}

library(dsra)
library(NGR)
library(data.table)
library(knitr)
library(highcharter)
library(htmlwidgets)
library(webshot2)

# ── 2) Helpers ─────────────────────────────────────────────────────────
source(file.path(root, "scripts", "setup", "utils.R"))
.installSiteChunkLabelHook()
ID_max <- "max"

# ── 3) Project contracts (hazard.json, newmark.json) ───────────────────
source(file.path(root, "scripts", "setup", "contracts.R"))
ID.gmdp    <- .contractValue(Contracts$newmark, "ID.gmdp")
IDm        <- .contractValue(Contracts$newmark, "IDm")
TR.gmdp    <- .contractValue(Contracts$newmark, "TR.gmdp")
Vref.gmdp  <- .contractValue(Contracts$newmark, "Vref.gmdp")
Hs         <- .contractValue(Contracts$newmark, "Hs")
DaH.gmdp   <- .contractValue(Contracts$newmark, "DaH.gmdp")
uscs       <- .contractValue(Contracts$newmark, "uscs", required = FALSE)
subduction <- .contractValue(Contracts$newmark, "subduction", required = FALSE)

# ── 4) params.yml ──────────────────────────────────────────────────────
FILE <- file.path(root, "params.yml")
if (!file.exists(FILE)) FILE <- file.path(root, "yml", "params.yml")
params <- readFile(FILE, "Missing params.yml", yaml::read_yaml)$params

if (is.list(params$consultant)) params$SRK_short <- "SRK"

# ── 5) Plotting / formatting defaults ──────────────────────────────────
if (!exists("p.target",      inherits = FALSE)) p.target      <- NULL
if (!exists("S.target",      inherits = FALSE)) S.target      <- NULL
if (!exists("NMAX",          inherits = FALSE)) NMAX          <- 2500
if (!exists("PALETTE",       inherits = FALSE)) PALETTE       <- "Set1"
if (!exists("DELAY",         inherits = FALSE)) DELAY         <- 0.3
if (!exists("PAGE_WIDTH",    inherits = FALSE)) PAGE_WIDTH    <- 8.27
if (!exists("PAGE_HEIGHT",   inherits = FALSE)) PAGE_HEIGHT   <- 11.69
if (!exists("FACTOR_WIDTH",  inherits = FALSE)) FACTOR_WIDTH  <- 1
if (!exists("FACTOR_HEIGHT", inherits = FALSE)) FACTOR_HEIGHT <- 0.5
if (!exists("THIN_LINE_SIZE",  inherits = FALSE)) THIN_LINE_SIZE  <- 0.75
if (!exists("MID_LINE_SIZE",   inherits = FALSE)) MID_LINE_SIZE   <- 1.5
if (!exists("THICK_LINE_SIZE", inherits = FALSE)) THICK_LINE_SIZE <- 3.5
# Height of the Newmark panels; a project may override it.
if (!exists("PLOT.HEIGHT", inherits = FALSE)) PLOT.HEIGHT <- 1000
if (!exists("GG_THEME", inherits = FALSE)) GG_THEME <- ggplot2::theme_light()
if (!exists("HC.THEME", inherits = FALSE)) HC.THEME <- NGR::hc_theme_538_gridlines()

if (knitr::is_html_output()) {
  if (!exists("FONT.SIZE.BODY",   inherits = FALSE)) FONT.SIZE.BODY   <- 11
  if (!exists("FONT.SIZE.HEADER", inherits = FALSE)) FONT.SIZE.HEADER <- 12
} else {
  if (!exists("FONT.SIZE.BODY",   inherits = FALSE)) FONT.SIZE.BODY   <- 10
  if (!exists("FONT.SIZE.HEADER", inherits = FALSE)) FONT.SIZE.HEADER <- 10
}

# Damage-level thresholds on the relative permanent displacement, in percent of
# the dam-foundation height, after Aliberti, Biondi, Cascone & Rampello (2019),
# Table 3:
# the crest-settlement ratios that mark the Operational, Damage, Life Safety and
# Collapse limit states of the Italian dam code NTD14. Their denominator is the
# embankment height plus the deformable foundation thickness, which is the slope
# height used here. A project may override both values before setup.
if (!exists("DAMAGE.CUTS", inherits = FALSE)) DAMAGE.CUTS <- c(0.1, 0.4, 1.0, 2.5)
if (!exists("DAMAGE.COLORS", inherits = FALSE)) {
  DAMAGE.COLORS <- c(
    "rgba(251,146,60,0.05)", "rgba(251,146,60,0.11)", "rgba(249,115,22,0.17)",
    "rgba(220,38,38,0.15)", "rgba(220,38,38,0.26)"
  )
}

# The demand the report calls MDE is the 10,000-year probabilistic one; the
# Newmark products carry the return period, never that label. A project may
# override it before setup.
if (!exists("TR.MDE", inherits = FALSE)) TR.MDE <- 10000

# ── 6) OQ tables ───────────────────────────────────────────────────────
source(file.path(root, "scripts", "setup", "global.R"))

# nolint end
