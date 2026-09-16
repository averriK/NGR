# Build a time-series plot

Builds one Highcharts Stock widget for one or more series measured
against calendar time. The abscissa is a real datetime axis, so the
reader sees dates rather than a numeric surrogate, and the widget
carries a range selector and a navigator for a record that spans years.

Missing values break the line instead of being bridged, which keeps a
gap in the record visually distinct from a measured value. Labelled
reference lines can be drawn on the ordinate for design levels,
thresholds, or physical bounds, and an optional linked right axis
restates the ordinate under an affine transform.

## Usage

``` r
buildPlot.Time(
  data,
  xLegend = "Date",
  yLegend = "Y",
  yLimits = NULL,
  referenceLines = NULL,
  y2Legend = NULL,
  y2Offset = 0,
  y2Scale = 1,
  y2Decimals = 1,
  palette = "Dark 3",
  lineSize = 2,
  markers = TRUE,
  markerSize = 3,
  rangeSelector = TRUE,
  navigator = TRUE,
  dateFormat = "%d/%m/%Y",
  showLegend = TRUE,
  legendTitle = "ID",
  plotHeight = 430,
  theme = NULL
)
```

## Arguments

- data:

  A data frame or `data.table` with one row per plotted point. Required
  columns are `ID` (series identity), `X` (`Date` or `POSIXct`) and `Y`
  (measured value, `NA` where the record has a gap). Optional columns,
  constant within each `ID`: `type` (`"line"` or `"scatter"`), `style`
  (dash style), `size` (line width), `color` (explicit colour) and
  `symbol` (marker symbol). Series are drawn in order of first
  appearance of `ID`.

- xLegend:

  Abscissa title.

- yLegend:

  Ordinate title.

- yLimits:

  Length-two increasing numeric vector fixing the ordinate, or `NULL` to
  autoscale.

- referenceLines:

  A data frame of labelled horizontal reference lines, or `NULL`.
  Required columns are `value` and `label`; optional `color`, `width`
  and `style`. Drawn above the series and outside the legend.

- y2Legend:

  Title of a linked right axis, or `NULL` for none. The right axis
  relabels the ordinate as `y2Offset + y2Scale * value`; it is a
  restatement of the same measurement, valid only while that relation
  holds.

- y2Offset:

  Additive term of the right-axis relation.

- y2Scale:

  Multiplicative term of the right-axis relation.

- y2Decimals:

  Decimals shown on the right axis.

- palette:

  Palette name from
  [`grDevices::hcl.pals()`](https://rdrr.io/r/grDevices/palettes.html),
  used for every series without an explicit `color`.

- lineSize:

  Default line width for series without a `size` value.

- markers:

  Draw a marker at every plotted point.

- markerSize:

  Marker radius in pixels.

- rangeSelector:

  Show the range selector.

- navigator:

  Show the navigator.

- dateFormat:

  Highcharts date format used in the tooltip header.

- showLegend:

  Show the series legend.

- legendTitle:

  Legend title.

- plotHeight:

  Widget height in pixels. Width stays responsive.

- theme:

  A Highcharts theme object.

## Value

A `highchart` htmlwidget of Highcharts Stock type. Inputs are not
modified and no file is written.

## Examples

``` r
Day <- as.Date("2020-01-01") + seq(0, 720, by = 30)
Data <- data.frame(
  ID = "level",
  X = Day,
  Y = 100 + sin(seq_along(Day) / 2)
)
buildPlot.Time(
  data = Data,
  xLegend = "Date",
  yLegend = "Level (m)",
  referenceLines = data.frame(value = 101.5, label = "threshold")
)

{"x":{"hc_opts":{"chart":{"reflow":true,"zoomType":"x","height":430},"title":[],"yAxis":{"title":{"text":"Level (m)"},"opposite":false,"plotLines":[{"value":101.5,"color":"#6B7280","width":2,"dashStyle":"Solid","zIndex":3,"label":{"text":"threshold","style":{"fontSize":"10px"}}}]},"credits":{"enabled":false},"exporting":{"enabled":false},"boost":{"enabled":false},"plotOptions":{"series":{"label":{"enabled":false},"turboThreshold":0},"treemap":{"layoutAlgorithm":"squarified"}},"xAxis":{"type":"datetime","title":{"text":"Date"},"ordinal":false},"series":[{"data":[[1577836800000,100.4794255386042],[1580428800000,100.8414709848079],[1583020800000,100.9974949866041],[1585612800000,100.9092974268257],[1588204800000,100.598472144104],[1590796800000,100.1411200080599],[1593388800000,99.64921677231038],[1595980800000,99.24319750469208],[1598572800000,99.0224698823349],[1601164800000,99.04107572533687],[1603756800000,99.2944596744296],[1606348800000,99.72058450180107],[1608940800000,100.2151199880878],[1611532800000,100.6569865987188],[1614124800000,100.9379999767747],[1616716800000,100.9893582466234],[1619308800000,100.7984871126235],[1621900800000,100.4121184852418],[1624492800000,99.92484887953819],[1627084800000,99.45597888911063],[1629676800000,99.12030424002833],[1632268800000,99.00000979344929],[1634860800000,99.12454782531157],[1637452800000,99.46342708199957],[1640044800000,99.9336781026488]],"type":"line","name":"level","color":"#E16A86","dashStyle":"Solid","lineWidth":2,"connectNulls":false,"showInLegend":true,"marker":{"enabled":true,"radius":3,"symbol":"circle"}}],"rangeSelector":{"enabled":true},"navigator":{"enabled":true},"scrollbar":{"enabled":false},"legend":{"enabled":true,"align":"center","verticalAlign":"bottom","layout":"horizontal","title":{"text":"ID"}},"tooltip":{"shared":true,"xDateFormat":"%d/%m/%Y","headerFormat":"<b>{point.key}<\/b><br/>"}},"theme":{"chart":{"backgroundColor":"transparent"},"colors":["#7cb5ec","#434348","#90ed7d","#f7a35c","#8085e9","#f15c80","#e4d354","#2b908f","#f45b5b","#91e8e1"]},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadCSV":"Download CSV","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","downloadXLS":"Download XLS","drillUpText":"◁ Back to {series.name}","exitFullscreen":"Exit from full screen","exportData":{"annotationHeader":"Annotations","categoryDatetimeHeader":"DateTime","categoryHeader":"Category"},"hideData":"Hide data table","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbolMagnitude":1000,"numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"shortWeekdays":["Sat","Sun","Mon","Tue","Wed","Thu","Fri"],"thousandsSep":" ","viewData":"View data table","viewFullscreen":"View in full screen","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"type":"stock","fonts":[],"debug":false},"evals":[],"jsHooks":[]}
```
