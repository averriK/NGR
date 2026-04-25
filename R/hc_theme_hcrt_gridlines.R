# nolint start
#' @title Highcharter theme based on hc_theme_hcrt with enhanced gridlines
#' @description A professional highcharter theme based on hc_theme_hcrt() that includes
#' visible minor gridlines, particularly useful for logarithmic scales.
#' 
#' This theme is identical to hc_theme_hcrt() but adds:
#' - minorGridLineWidth for both axes (visible minor gridlines)
#' - minorTickInterval = "auto" for logarithmic scales
#' - Lighter color for minor gridlines (#E8E8E8) vs major gridlines (#F3F3F3)
#'
#' @return A highcharter theme object (list with class "hc_theme")
#' @export hc_theme_hcrt_gridlines
#' @examples
#' \dontrun{
#' library(highcharter)
#' hchart(mtcars, "scatter", hcaes(x = wt, y = mpg)) |>
#'   hc_add_theme(hc_theme_hcrt_gridlines())
#' }
hc_theme_hcrt_gridlines <- function() {
  # Start with the base hcrt theme
  theme <- highcharter::hc_theme_hcrt()
  
  # Make major gridlines slightly more visible but still subtle
  theme$xAxis$gridLineWidth <- 0.75
  theme$xAxis$gridLineColor <- "#CCCCCC"  # Medium gray for major lines
  
  theme$yAxis$gridLineWidth <- 0.75
  theme$yAxis$gridLineColor <- "#CCCCCC"  # Medium gray for major lines
  
  # Add minor gridlines - much lighter and thinner
  theme$xAxis$minorGridLineWidth <- 0.25
  theme$xAxis$minorGridLineColor <- "#EEEEEE"  # Very light gray for minor lines
  theme$xAxis$minorTickInterval <- "auto"
  
  theme$yAxis$minorGridLineWidth <- 0.25
  theme$yAxis$minorGridLineColor <- "#EEEEEE"  # Very light gray for minor lines
  theme$yAxis$minorTickInterval <- "auto"
  
  return(theme)
}

#' @title Highcharter theme based on hc_theme_flat with enhanced gridlines
#' @description A professional highcharter theme based on hc_theme_flat() that includes
#' visible minor gridlines, particularly useful for logarithmic scales.
#' 
#' This theme is identical to hc_theme_flat() but adds:
#' - minorGridLineWidth for both axes
#' - minorTickInterval = "auto" for logarithmic scales
#' - Lighter color for minor gridlines (#D5D8DC) vs major gridlines (#BDC3C7)
#'
#' @return A highcharter theme object (list with class "hc_theme")
#' @export hc_theme_flat_gridlines
#' @examples
#' \dontrun{
#' library(highcharter)
#' hchart(mtcars, "scatter", hcaes(x = wt, y = mpg)) |>
#'   hc_add_theme(hc_theme_flat_gridlines())
#' }
hc_theme_flat_gridlines <- function() {
  # Start with the base flat theme
  theme <- highcharter::hc_theme_flat()
  
  # Make major gridlines thinner and slightly darker
  theme$xAxis$gridLineWidth <- 0.75
  theme$xAxis$gridLineColor <- "#A0A0A0"  # Darker gray for major lines
  theme$xAxis$gridLineDashStyle <- "Solid"  # Solid for major
  
  theme$yAxis$gridLineWidth <- 0.75
  theme$yAxis$gridLineColor <- "#A0A0A0"  # Darker gray for major lines
  
  # Add minor gridlines - dotted and much lighter
  theme$xAxis$minorGridLineWidth <- 0.25
  theme$xAxis$minorGridLineDashStyle <- "Dot"  # Dotted style for minor lines
  theme$xAxis$minorGridLineColor <- "#E0E0E0"  # Much lighter than major gridlines
  theme$xAxis$minorTickInterval <- "auto"
  
  theme$yAxis$minorGridLineWidth <- 0.25
  theme$yAxis$minorGridLineDashStyle <- "Dot"  # Dotted style for minor lines
  theme$yAxis$minorGridLineColor <- "#E0E0E0"  # Much lighter than major gridlines
  theme$yAxis$minorTickInterval <- "auto"
  
  return(theme)
}

#' @title Highcharter theme based on FiveThirtyEight (538) with enhanced gridlines
#' @description A professional data journalism theme based on hc_theme_538() that includes
#' visible minor gridlines, particularly useful for logarithmic scales.
#' 
#' FiveThirtyEight is known for their clean, data-driven visualizations. This theme maintains
#' their signature style while adding:
#' - Optimized gridLineWidth for both major and minor lines
#' - Professional color contrast between major (#B0B0B0) and minor (#DDDDDD) gridlines
#' - minorTickInterval = "auto" for logarithmic scales
#'
#' @return A highcharter theme object (list with class "hc_theme")
#' @export hc_theme_538_gridlines
#' @examples
#' \dontrun{
#' library(highcharter)
#' hchart(mtcars, "scatter", hcaes(x = wt, y = mpg)) |>
#'   hc_add_theme(hc_theme_538_gridlines())
#' }
hc_theme_538_gridlines <- function() {
  # Start with the base 538 theme
  theme <- highcharter::hc_theme_538()
  
  # Change background to white for better visibility
  theme$chart$backgroundColor <- "#FFFFFF"
  
  # Improve major gridlines - thin and visible on white
  theme$xAxis$gridLineWidth <- 0.5
  theme$xAxis$gridLineColor <- "#CCCCCC"  # Medium gray for major lines
  
  theme$yAxis$gridLineWidth <- 0.5
  theme$yAxis$gridLineColor <- "#CCCCCC"  # Medium gray for major lines
  
  # Add optimized minor gridlines - subtle but visible on white
  theme$xAxis$minorGridLineWidth <- 0.25
  theme$xAxis$minorGridLineColor <- "#EEEEEE"  # Light gray for minor lines
  theme$xAxis$minorTickInterval <- "auto"
  
  theme$yAxis$minorGridLineWidth <- 0.25
  theme$yAxis$minorGridLineColor <- "#EEEEEE"  # Light gray for minor lines
  theme$yAxis$minorTickInterval <- "auto"
  
  return(theme)
}

#' @title Highcharter theme based on The Economist with enhanced gridlines
#' @description A professional magazine-quality theme based on hc_theme_economist() that includes
#' visible minor gridlines, particularly useful for logarithmic scales.
#' 
#' The Economist is renowned for their clean, authoritative visualizations. This theme adds:
#' - Subtle major gridlines in light gray (#D8D8D8)
#' - Very light minor gridlines (#F0F0F0)
#' - Thin line widths (0.6 for major, 0.25 for minor)
#' - minorTickInterval = "auto" for logarithmic scales
#'
#' @return A highcharter theme object (list with class "hc_theme")
#' @export hc_theme_economist_gridlines
#' @examples
#' \dontrun{
#' library(highcharter)
#' hchart(mtcars, "scatter", hcaes(x = wt, y = mpg)) |>
#'   hc_add_theme(hc_theme_economist_gridlines())
#' }
hc_theme_economist_gridlines <- function() {
  # Start with the base economist theme
  theme <- highcharter::hc_theme_economist()
  
  # Add axis configuration (economist theme has minimal axis config)
  # Major gridlines - very subtle on the distinctive blue-gray background
  theme$xAxis$gridLineWidth <- 0.6
  theme$xAxis$gridLineColor <- "#D8D8D8"  # Light gray that contrasts with background
  theme$xAxis$lineColor <- "#FFFFFF"
  theme$xAxis$tickColor <- "#D7D7D8"
  theme$xAxis$tickWidth <- 1
  
  theme$yAxis$gridLineWidth <- 0.6
  theme$yAxis$gridLineColor <- "#D8D8D8"  # Light gray that contrasts with background
  
  # Add minor gridlines - very subtle
  theme$xAxis$minorGridLineWidth <- 0.25
  theme$xAxis$minorGridLineColor <- "#F0F0F0"  # Very light, almost white
  theme$xAxis$minorTickInterval <- "auto"
  
  theme$yAxis$minorGridLineWidth <- 0.25
  theme$yAxis$minorGridLineColor <- "#F0F0F0"  # Very light, almost white
  theme$yAxis$minorTickInterval <- "auto"
  
  return(theme)
}
# nolint end
