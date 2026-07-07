# Display HTML content in iframe

Display HTML content in iframe

## Usage

``` r
showHTML(
  url,
  height = "600px",
  width = "100%",
  show_link = TRUE,
  link_text = "URL"
)
```

## Arguments

- url:

  URL of the HTML content to display

- height:

  Height of iframe (default "600px")

- width:

  Width of iframe (default "100%")

- show_link:

  Show link to open in new window (default TRUE)

- link_text:

  Custom link text (default "URL")

## Value

Prints iframe HTML using cat() for results: asis
