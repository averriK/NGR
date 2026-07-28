# Display source code with syntax highlighting

Display source code with syntax highlighting

## Usage

``` r
showCode(
  filePath,
  language = NULL,
  lineNumbers = TRUE,
  cleanWolfram = TRUE,
  height = "400px"
)
```

## Arguments

- filePath:

  Path to the source code file

- language:

  Programming language (auto-detected from extension if NULL)

- lineNumbers:

  Show line numbers (default TRUE)

- cleanWolfram:

  Convert Mathematica Unicode notation to plain ASCII (default TRUE)

- height:

  Fixed height with scrollbar (default "400px" for slide compatibility).
  Use NULL for full expansion without scroll.

## Value

Prints formatted code block using cat() for results: asis

## Examples

``` r
if (FALSE) { # \dontrun{
showCode("script.py")                    # Default: 400px with scroll
showCode("script.wls", cleanWolfram = TRUE)
showCode("long_file.R", height = "300px") # Custom height
showCode("short.R", height = NULL)        # No scroll, full expansion
} # }
```
