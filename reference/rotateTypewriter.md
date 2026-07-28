# Generate rotating typewriter effect from multiple text files or text strings

Generate rotating typewriter effect from multiple text files or text
strings

## Usage

``` r
rotateTypewriter(
  filePaths = NULL,
  texts = NULL,
  speed = 5,
  rotateDelay = 3000,
  font = "vt323",
  fontSize = NULL,
  color = "#00ff00",
  bgColor = "#000",
  terminalWidth = 80,
  height = "300px"
)
```

## Arguments

- filePaths:

  Vector of paths to .txt files with ASCII content (optional if texts is
  provided)

- texts:

  Vector of text strings to rotate through (optional if filePaths is
  provided)

- speed:

  Speed in milliseconds per character (default 5)

- rotateDelay:

  Delay in milliseconds before rotating to next file (default 3000)

- font:

  Font name: "vt323", "ibm", "courier", "space", "anonymous", "press",
  "silkscreen", "atari", "c64", "dotgothic", "overpass", "nova", "syne",
  "orbitron", "electrolize", "printchar21", "prnumber3", "data70"
  (default "vt323")

- fontSize:

  Font size in em units (default 0.9)

- color:

  Text color in hex (default "#00ff00")

- bgColor:

  Background color in hex (default "#000")

- terminalWidth:

  Terminal width in columns: 40, 60, 80. Default 80. fontSize will be
  auto-calculated to fit.

- height:

  Height of the container (default "300px")

## Value

Prints HTML with rotating typewriter effect
