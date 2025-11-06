#' Display GitHub README as iframe
#'
#' @param repo Repository name (e.g., "gmsp", "kashima")
#' @param user GitHub username (default "averriK")
#' @param height Height of iframe (default "500px")
#' @return Prints iframe HTML using cat() for results: asis
#' @export
showGithubREADME <- function(repo, user = "averriK", height = "500px") {
  url <- paste0("https://github.com/", user, "/", repo, "#readme")
  
  cat('\n<iframe\n')
  cat('  src="', url, '"\n', sep = "")
  cat('  width="100%"\n')
  cat('  height="', height, '"\n', sep = "")
  cat('  style="border:0; max-width: 100%;"\n')
  cat('  loading="lazy"\n')
  cat('  data-external="1"\n')
  cat('></iframe>\n\n')
  
  cat('<p style="font-size: 0.8em; margin-top: 5px; text-align: center;">\n')
  cat('<a href="', url, '" target="_blank">Open in new window</a>\n', sep = "")
  cat('</p>\n\n')
}
