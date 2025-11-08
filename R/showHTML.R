#' Display HTML content in iframe
#'
#' @param url URL of the HTML content to display
#' @param height Height of iframe (default "600px")
#' @param width Width of iframe (default "100%")
#' @param show_link Show link to open in new window (default TRUE)
#' @param link_text Custom link text (default "URL")
#' @return Prints iframe HTML using cat() for results: asis
#' @export
showHTML <- function(
  url,
  height = "600px",
  width = "100%",
  show_link = TRUE,
  link_text = "URL"
) {
  
  # Output iframe
  cat('<iframe\n')
  cat('  src="', url, '"\n', sep = "")
  cat('  width="', width, '"\n', sep = "")
  cat('  height="', height, '"\n', sep = "")
  cat('  style="border:0; max-width: 100%;"\n')
  cat('  loading="lazy"\n')
  cat('  allow="fullscreen; autoplay"\n')
  cat('  data-external="1"\n')
  cat('></iframe>\n\n')
  
  # Optional link
  if (show_link) {
    cat('<p style="font-size: 0.8em; margin-top: 5px; text-align: center;">Source:\n')
    cat('<a href="', url, '">', link_text, '</a>\n', sep = "")
    cat('</p>\n\n')
  }
  
  invisible(NULL)
}
