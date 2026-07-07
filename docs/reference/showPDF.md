# Display PDF in iframe using PDF.js viewer

Display PDF in iframe using PDF.js viewer

## Usage

``` r
showPDF(
  file,
  height = "850px",
  pdfjs_path = "_pdfjs/web/viewer.html",
  pdf_base_path = "_pdfjs/web/",
  show_link = TRUE,
  pagemode = "none"
)
```

## Arguments

- file:

  PDF filename (for local files in \_pdfjs/web/) or full URL

- height:

  Height of iframe (default "850px")

- pdfjs_path:

  Path to PDF.js viewer (default "\_pdfjs/web/viewer.html")

- pdf_base_path:

  Base path for local PDF files (default "\_pdfjs/web/")

- show_link:

  Show link to open PDF in new window (default TRUE)

- pagemode:

  PDF.js pagemode: "none" (no sidebar), "thumbs", "bookmarks",
  "attachments" (default "none")

## Value

Prints iframe HTML using cat() for results: asis

## Examples

``` r
if (FALSE) { # \dontrun{
# Local PDF (assumes file in _pdfjs/web/)
showPDF("00.pdf")

# Full URL
showPDF("https://example.com/document.pdf")

# Custom height
showPDF("01.pdf", height = "600px")

# Show sidebar with thumbnails
showPDF("01.pdf", pagemode = "thumbs")
} # }
```
