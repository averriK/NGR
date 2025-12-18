#' Display PDF in iframe using PDF.js viewer
#'
#' @param file PDF filename (for local files in _pdfjs/web/) or full URL
#' @param height Height of iframe (default "850px")
#' @param pdfjs_path Path to PDF.js viewer (default "_pdfjs/web/viewer.html")
#' @param pdf_base_path Base path for local PDF files (default "_pdfjs/web/")
#' @param show_link Show link to open PDF in new window (default TRUE)
#' @param pagemode PDF.js pagemode: "none" (no sidebar), "thumbs", "bookmarks", "attachments" (default "none")
#' @return Prints iframe HTML using cat() for results: asis
#' @export
#' @examples
#' \dontrun{
#' # Local PDF (assumes file in _pdfjs/web/)
#' showPDF("00.pdf")
#' 
#' # Full URL
#' showPDF("https://example.com/document.pdf")
#' 
#' # Custom height
#' showPDF("01.pdf", height = "600px")
#' 
#' # Show sidebar with thumbnails
#' showPDF("01.pdf", pagemode = "thumbs")
#' }
showPDF <- function(
  file,
  height = "850px",
  pdfjs_path = "_pdfjs/web/viewer.html",
  pdf_base_path = "_pdfjs/web/",
  show_link = TRUE,
  pagemode = "none"
) {
  
  # Determine if file is URL or local
  is_url <- grepl("^https?://", file)
  
  if (is_url) {
    # Full URL provided
    viewer_src <- paste0(pdfjs_path, "?file=", URLencode(file, reserved = TRUE))
    pdf_link <- file
    pdf_name <- basename(file)
  } else {
    # Local file - PDFs are in same directory as viewer, so just use filename
    viewer_src <- paste0(pdfjs_path, "?file=", file)
    pdf_link <- paste0(pdf_base_path, file)
    pdf_name <- tools::file_path_sans_ext(file)
  }
  
  # Add pagemode and sidebar parameters
  if (!is.null(pagemode) && pagemode != "") {
    viewer_src <- paste0(viewer_src, "#pagemode=", pagemode)
  }
  
  # Output iframe
  cat('<iframe\n')
  cat('  src="', viewer_src, '"\n', sep = "")
  cat('  width="100%"\n')
  cat('  height="', height, '"\n', sep = "")
  cat('  style="border:0;"\n')
  cat('  loading="lazy">\n')
  cat('</iframe>\n\n')
  
  # Optional link
  if (show_link) {
    cat('<p style="font-size: 0.8em; margin-top: 5px; text-align: center;">\n')
    cat('<strong>Viewer:</strong> PDF.js (Local) |\n')
    cat('<a href="', pdf_link, '" target="_blank">View full PDF</a>\n', sep = "")
    cat('</p>\n\n')
  }
  
  invisible(NULL)
}
