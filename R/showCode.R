#' Display source code with syntax highlighting
#'
#' @param filePath Path to the source code file
#' @param language Programming language (auto-detected from extension if NULL)
#' @param lineNumbers Show line numbers (default TRUE)
#' @param cleanWolfram Convert Mathematica Unicode notation to plain ASCII (default TRUE)
#' @param height Optional fixed height with scrollbar (e.g., "400px", "20em"). If NULL, uses default Quarto rendering.
#' @return Prints formatted code block using cat() for results: asis
#' @export
#' @examples
#' \dontrun{
#' showCode("script.py")
#' showCode("script.wls", cleanWolfram = TRUE)
#' showCode("long_file.R", height = "300px")  # Fixed height with scroll
#' }
showCode <- function(
  filePath,
  language = NULL,
  lineNumbers = TRUE,
  cleanWolfram = TRUE,
  height = NULL
) {
  
  # Validate file exists
  if (!file.exists(filePath)) {
    stop(paste("File not found:", filePath))
  }
  
  # Read file content
  CONTENT <- readLines(filePath, warn = FALSE)
  
  # Ensure UTF-8 encoding
  CONTENT <- iconv(CONTENT, to = "UTF-8", sub = "byte")

  # Auto-detect language from file extension if not provided
  if (is.null(language)) {
    EXT <- tolower(tools::file_ext(filePath))
    language <- switch(
      EXT,
      "r" = "r",
      "py" = "python",
      "js" = "javascript",
      "ts" = "typescript",
      "jsx" = "jsx",
      "tsx" = "tsx",
      "cpp" = "cpp",
      "c" = "c",
      "java" = "java",
      "go" = "go",
      "rs" = "rust",
      "rb" = "ruby",
      "php" = "php",
      "sh" = "bash",
      "bash" = "bash",
      "zsh" = "bash",
      "sql" = "sql",
      "css" = "css",
      "scss" = "scss",
      "html" = "html",
      "xml" = "xml",
      "json" = "json",
      "yaml" = "yaml",
      "yml" = "yaml",
      "toml" = "toml",
      "md" = "markdown",
      "rmd" = "markdown",
      "qmd" = "markdown",
      "tex" = "latex",
      "jl" = "julia",
      "m" = "octave",        # MATLAB syntax (highlight.js uses octave)
      "wls" = "mathematica", # Wolfram Language
      "wl" = "mathematica",
      "nb" = "mathematica",
      "f" = "fortran",       # Fortran
      "f90" = "fortran",
      "f95" = "fortran",
      "for" = "fortran",
      "f77" = "fortran",     # Fortran 77
      "fs" = "forth",        # Forth
      "fth" = "forth",
      "bas" = "basic",       # BASIC
      "basic" = "basic",
      "lisp" = "lisp",       # Lisp/Common Lisp
      "cl" = "lisp",
      "el" = "lisp",
      "scm" = "scheme",      # Scheme
      "pascal" = "pascal",   # Pascal
      "pas" = "pascal",
      "prolog" = "prolog",   # Prolog
      "pl" = "prolog",
      "pro" = "prolog",
      "scala" = "scala",
      "kt" = "kotlin",
      "swift" = "swift",
      "dart" = "dart",
      "default" # Unknown extension
    )
  }

  # Clean Wolfram Language Unicode notation if requested
  if (cleanWolfram && language == "mathematica") {
    # Common Mathematica Unicode -> ASCII conversions
    CONTENT <- gsub("\\\\\\[Lambda\\]", "lambda", CONTENT)
    CONTENT <- gsub("\\\\\\[NotEqual\\]", "!=", CONTENT)
    CONTENT <- gsub("\\\\\\[CapitalDelta\\]", "Delta", CONTENT)
    CONTENT <- gsub("\\\\\\[Alpha\\]", "alpha", CONTENT)
    CONTENT <- gsub("\\\\\\[Beta\\]", "beta", CONTENT)
    CONTENT <- gsub("\\\\\\[Gamma\\]", "gamma", CONTENT)
    CONTENT <- gsub("\\\\\\[Delta\\]", "delta", CONTENT)
    CONTENT <- gsub("\\\\\\[Epsilon\\]", "epsilon", CONTENT)
    CONTENT <- gsub("\\\\\\[Theta\\]", "theta", CONTENT)
    CONTENT <- gsub("\\\\\\[Mu\\]", "mu", CONTENT)
    CONTENT <- gsub("\\\\\\[Pi\\]", "pi", CONTENT)
    CONTENT <- gsub("\\\\\\[Sigma\\]", "sigma", CONTENT)
    CONTENT <- gsub("\\\\\\[Tau\\]", "tau", CONTENT)
    CONTENT <- gsub("\\\\\\[Phi\\]", "phi", CONTENT)
    CONTENT <- gsub("\\\\\\[Omega\\]", "omega", CONTENT)
  }
  
  # Output code block
  if (!is.null(height)) {
    # Use HTML pre/code with fixed height and scroll
    # Escape HTML entities manually
    escaped_content <- gsub("&", "&amp;", paste(CONTENT, collapse = "\n"))
    escaped_content <- gsub("<", "&lt;", escaped_content)
    escaped_content <- gsub(">", "&gt;", escaped_content)
    
    cat('<div style="max-height: ', height, '; overflow-y: auto; border: 1px solid #ddd; border-radius: 4px; margin: 1em 0;">\n', sep = "")
    cat('<pre style="margin: 0; padding: 1em; background: #f5f5f5;"><code class="language-', language, '">', sep = "")
    cat(escaped_content)
    cat('</code></pre>\n')
    cat('</div>\n\n')
  } else {
    # Standard Quarto markdown code block (default behavior)
    cat("```", language, "\n", sep = "")
    cat(paste(CONTENT, collapse = "\n"), "\n", sep = "")
    cat("```\n\n")
  }

  invisible(NULL)
}
