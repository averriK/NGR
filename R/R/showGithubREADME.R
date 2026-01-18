#' Display GitHub README as iframe
#'
#' @param repo Repository name (e.g., "gmsp", "kashima")
#' @param user GitHub username (default "averriK")
#' @param height Height of iframe (default "500px")
#' @return Prints iframe HTML using cat() for results: asis
#' @export
showGithubREADME <- function(repo, user = "averriK", height = "500px") {
  pages_url <- paste0("https://", user, ".github.io/", repo, "/")
  github_url <- paste0("https://github.com/", user, "/", repo)
  
  # Return list from tryCatch
  result <- tryCatch({
    response <- readLines(pages_url, warn = FALSE)
    content <- paste(response, collapse = " ")
    
    # Case 1: GitHub Pages doesn't exist
    if (grepl("There isn't a GitHub Pages site here", content, ignore.case = TRUE)) {
      list(use_iframe = FALSE, 
           fallback_message = "GitHub Pages not available for this repository.",
           final_url = github_url)
    }
    
    # Case 2: Meta-refresh redirect (may block iframes)
    else if (grepl('meta.*http-equiv.*refresh.*content.*url=', content, ignore.case = TRUE)) {
      redirect_match <- regmatches(content, regexpr('url=https?://[^">]+', content, ignore.case = TRUE))
      if (length(redirect_match) > 0) {
        redirect_url <- sub('^url=', '', redirect_match[1], ignore.case = TRUE)
        
        # Check if redirect target blocks iframes
        redirect_headers <- tryCatch({
          paste(curlGetHeaders(redirect_url), collapse = " ")
        }, error = function(e) "")
        
        has_deny <- grepl("x-frame-options.*(DENY|SAMEORIGIN)", redirect_headers, ignore.case = TRUE)
        
        if (has_deny) {
          list(use_iframe = FALSE,
               fallback_message = paste0("Site redirects to external domain that blocks iframes: ", 
                                        sub("^(https?://[^/]+).*", "\\1", redirect_url)),
               final_url = redirect_url)
        } else {
          list(use_iframe = TRUE, final_url = redirect_url, fallback_message = NULL)
        }
      } else {
        list(use_iframe = TRUE, final_url = pages_url, fallback_message = NULL)
      }
    }
    # Case 3: Normal GitHub Pages
    else {
      list(use_iframe = TRUE, final_url = pages_url, fallback_message = NULL)
    }
  }, error = function(e) {
    list(use_iframe = FALSE,
         fallback_message = "Could not access GitHub Pages.",
         final_url = github_url)
  })
  
  # Extract result
  use_iframe <- result$use_iframe
  final_url <- result$final_url
  fallback_message <- result$fallback_message
  
  # Output iframe or fallback
  if (use_iframe) {
    cat('\n<iframe\n')
    cat('  src="', final_url, '"\n', sep = "")
    cat('  width="100%"\n')
    cat('  height="', height, '"\n', sep = "")
    cat('  style="border:0; max-width: 100%;"\n')
    cat('  loading="lazy"\n')
    cat('  data-external="1"\n')
    cat('></iframe>\n\n')
  } else {
    cat('\n<div style="border: 1px solid #ddd; padding: 20px; text-align: center; background: #f9f9f9;">\n')
    cat('  <p><strong>[!] ', fallback_message, '</strong></p>\n', sep = "")
    cat('  <p><a href="', final_url, '" target="_blank" style="font-size: 1.1em;">Open ', repo, ' on GitHub</a></p>\n', sep = "")
    cat('</div>\n\n')
  }
  
  cat('<p style="font-size: 0.8em; margin-top: 5px; text-align: center;">\n')
  cat('<a href="', final_url, '" target="_blank">Open in new window</a>\n', sep = "")
  cat('</p>\n\n')
}
