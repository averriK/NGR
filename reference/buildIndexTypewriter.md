# Build and display typewriter index from chapter list

Build and display typewriter index from chapter list

## Usage

``` r
buildIndexTypewriter(
  index,
  speed = 5,
  font = "vt323",
  fontSize = 0.9,
  color = "#00ff00",
  bgColor = "#000"
)
```

## Arguments

- index:

  Character vector with chapter/section names

- speed:

  Speed in milliseconds per character (default 5)

- font:

  Font name (default "vt323")

- fontSize:

  Font size in em units (default 0.9)

- color:

  Text color in hex (default "#00ff00")

- bgColor:

  Background color in hex (default "#000")

## Value

Prints HTML with typewriter effect
