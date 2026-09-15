# buildPlot without axis bands matches the 0.3.10 configuration

    list(chart = list(reflow = TRUE, style = list(fontFamily = "Helvetica")), 
        title = list(text = NULL), yAxis = list(title = list(text = "Y", 
            style = list(fontSize = "14px")), labels = list(enabled = TRUE), 
            type = "linear", reversed = FALSE), credits = list(enabled = FALSE), 
        exporting = list(enabled = TRUE, filename = "highchart-plot", 
            buttons = list(contextButton = list(menuItems = c("downloadPNG", 
            "downloadJPEG", "downloadPDF", "downloadSVG", "downloadCSV", 
            "downloadXLS")))), boost = list(enabled = FALSE), plotOptions = list(
            series = list(label = list(enabled = FALSE), turboThreshold = 0, 
                dataLabels = list(enabled = FALSE)), treemap = list(
                layoutAlgorithm = "squarified")), xAxis = list(labels = list(
            enabled = TRUE), title = list(text = "X", style = list(
            fontSize = "14px")), type = "linear", reversed = FALSE, 
            max = NULL, min = NULL), legend = list(enabled = TRUE, 
            align = "right", verticalAlign = "top", layout = "horizontal", 
            title = list(text = "ID", style = list(fontWeight = "bold")), 
            itemStyle = list(fontSize = "12px")), series = list(list(
            group = "group", data = list(list(ID = "A", X = 1L, Y = 1, 
                x = 1L, y = 1), list(ID = "A", X = 2L, Y = 4, x = 2L, 
                y = 4), list(ID = "A", X = 3L, Y = 9, x = 3L, y = 9)), 
            type = "line", name = "A", yAxis = 0, color = "#E16A86", 
            dashStyle = "Solid", lineWidth = 1, showInLegend = TRUE, 
            enableMouseTracking = TRUE, includeInDataExport = TRUE, 
            marker = list(enabled = FALSE)), list(group = "group", 
            data = list(list(ID = "B", X = 1L, Y = 2, x = 1L, y = 2), 
                list(ID = "B", X = 2L, Y = 3, x = 2L, y = 3), list(
                    ID = "B", X = 3L, Y = 5, x = 3L, y = 5)), type = "line", 
            name = "B", yAxis = 0, color = "#00AD9A", dashStyle = "Solid", 
            lineWidth = 1, showInLegend = TRUE, enableMouseTracking = TRUE, 
            includeInDataExport = TRUE, marker = list(enabled = FALSE))), 
        tooltip = list(split = FALSE, crosshairs = TRUE, headerFormat = "", 
            pointFormat = "ID: <b>{point.series.name}</b><br>X: {point.x}<br>Y: {point.y}"))

---

    list(chart = list(reflow = TRUE, style = list(fontFamily = "Helvetica")), 
        title = list(text = NULL), yAxis = list(list(labels = list(
            enabled = TRUE), title = list(text = "Y", style = list(
            fontSize = "14px")), type = "linear", reversed = FALSE, 
            max = NULL, min = NULL), list(opposite = TRUE, gridLineWidth = 0, 
            title = list(text = "TR", style = list(fontSize = "14px")), 
            labels = list(enabled = TRUE, formatter = structure("function() { var y = this.value; var y2 = (1e+00 / y); if (y2 === null || y2 === undefined || !isFinite(y2)) return ''; return Highcharts.numberFormat(y2, 2); }", class = "JS_EVAL")), 
            reversed = FALSE, linkedTo = 0, type = "linear")), credits = list(
            enabled = FALSE), exporting = list(enabled = TRUE, filename = "highchart-plot", 
            buttons = list(contextButton = list(menuItems = c("downloadPNG", 
            "downloadJPEG", "downloadPDF", "downloadSVG", "downloadCSV", 
            "downloadXLS")))), boost = list(enabled = FALSE), plotOptions = list(
            series = list(label = list(enabled = FALSE), turboThreshold = 0, 
                dataLabels = list(enabled = FALSE)), treemap = list(
                layoutAlgorithm = "squarified")), xAxis = list(labels = list(
            enabled = TRUE), title = list(text = "X", style = list(
            fontSize = "14px")), type = "linear", reversed = FALSE, 
            max = NULL, min = NULL), legend = list(enabled = TRUE, 
            align = "right", verticalAlign = "top", layout = "horizontal", 
            title = list(text = "ID", style = list(fontWeight = "bold")), 
            itemStyle = list(fontSize = "12px")), series = list(list(
            group = "group", data = list(list(ID = "A", X = 1L, Y = 1, 
                x = 1L, y = 1), list(ID = "A", X = 2L, Y = 4, x = 2L, 
                y = 4), list(ID = "A", X = 3L, Y = 9, x = 3L, y = 9)), 
            type = "line", name = "A", yAxis = 0, color = "#E16A86", 
            dashStyle = "Solid", lineWidth = 1, showInLegend = TRUE, 
            enableMouseTracking = TRUE, includeInDataExport = TRUE, 
            marker = list(enabled = FALSE)), list(group = "group", 
            data = list(list(ID = "B", X = 1L, Y = 2, x = 1L, y = 2), 
                list(ID = "B", X = 2L, Y = 3, x = 2L, y = 3), list(
                    ID = "B", X = 3L, Y = 5, x = 3L, y = 5)), type = "line", 
            name = "B", yAxis = 0, color = "#00AD9A", dashStyle = "Solid", 
            lineWidth = 1, showInLegend = TRUE, enableMouseTracking = TRUE, 
            includeInDataExport = TRUE, marker = list(enabled = FALSE))), 
        tooltip = list(split = FALSE, crosshairs = TRUE, headerFormat = "", 
            pointFormat = "ID: <b>{point.series.name}</b><br>X: {point.x}<br>Y: {point.y}"))

---

    list(chart = list(reflow = TRUE, style = list(fontFamily = "Helvetica")), 
        title = list(text = NULL), yAxis = list(list(labels = list(
            enabled = TRUE), title = list(text = "Y", style = list(
            fontSize = "14px")), type = "linear", reversed = FALSE, 
            max = NULL, min = NULL), list(opposite = TRUE, gridLineWidth = 0, 
            title = list(text = "Temp", style = list(fontSize = "14px")), 
            labels = list(enabled = TRUE), reversed = FALSE, type = "linear")), 
        credits = list(enabled = FALSE), exporting = list(enabled = TRUE, 
            filename = "highchart-plot", buttons = list(contextButton = list(
                menuItems = c("downloadPNG", "downloadJPEG", "downloadPDF", 
                "downloadSVG", "downloadCSV", "downloadXLS")))), 
        boost = list(enabled = FALSE), plotOptions = list(series = list(
            label = list(enabled = FALSE), turboThreshold = 0, dataLabels = list(
                enabled = FALSE)), treemap = list(layoutAlgorithm = "squarified")), 
        xAxis = list(labels = list(enabled = TRUE), title = list(
            text = "X", style = list(fontSize = "14px")), type = "linear", 
            reversed = FALSE, max = NULL, min = NULL), legend = list(
            enabled = TRUE, align = "right", verticalAlign = "top", 
            layout = "horizontal", title = list(text = "ID", style = list(
                fontWeight = "bold")), itemStyle = list(fontSize = "12px")), 
        series = list(list(group = "group", data = list(list(ID = "Pressure", 
            X = 1L, Y = 10, yAxis = 0, x = 1L, y = 10), list(ID = "Pressure", 
            X = 2L, Y = 11, yAxis = 0, x = 2L, y = 11), list(ID = "Pressure", 
            X = 3L, Y = 10.5, yAxis = 0, x = 3L, y = 10.5)), type = "line", 
            name = "Pressure", yAxis = 0L, color = "#E16A86", dashStyle = "Solid", 
            lineWidth = 1, showInLegend = TRUE, enableMouseTracking = TRUE, 
            includeInDataExport = TRUE, marker = list(enabled = FALSE)), 
            list(group = "group", data = list(list(ID = "Temp", X = 1L, 
                Y = 20, yAxis = 1, x = 1L, y = 20), list(ID = "Temp", 
                X = 2L, Y = 21, yAxis = 1, x = 2L, y = 21), list(
                ID = "Temp", X = 3L, Y = 19, yAxis = 1, x = 3L, y = 19)), 
                type = "line", name = "Temp", yAxis = 1L, color = "#00AD9A", 
                dashStyle = "Solid", lineWidth = 1, showInLegend = TRUE, 
                enableMouseTracking = TRUE, includeInDataExport = TRUE, 
                marker = list(enabled = FALSE))), tooltip = list(
            split = FALSE, crosshairs = TRUE, headerFormat = "", 
            pointFormat = "ID: <b>{point.series.name}</b><br>X: {point.x}<br>Y: {point.y}"))

---

    list(chart = list(reflow = TRUE, style = list(fontFamily = "Helvetica")), 
        title = list(text = NULL), yAxis = list(title = list(text = "Y", 
            style = list(fontSize = "14px")), labels = list(enabled = TRUE), 
            type = "logarithmic", reversed = FALSE), credits = list(
            enabled = FALSE), exporting = list(enabled = TRUE, filename = "highchart-plot", 
            buttons = list(contextButton = list(menuItems = c("downloadPNG", 
            "downloadJPEG", "downloadPDF", "downloadSVG", "downloadCSV", 
            "downloadXLS")))), boost = list(enabled = FALSE), plotOptions = list(
            series = list(label = list(enabled = FALSE), turboThreshold = 0, 
                dataLabels = list(enabled = FALSE)), treemap = list(
                layoutAlgorithm = "squarified")), xAxis = list(labels = list(
            enabled = TRUE), title = list(text = "X", style = list(
            fontSize = "14px")), type = "logarithmic", reversed = FALSE, 
            max = NULL, min = NULL), legend = list(enabled = TRUE, 
            align = "right", verticalAlign = "top", layout = "horizontal", 
            title = list(text = "ID", style = list(fontWeight = "bold")), 
            itemStyle = list(fontSize = "12px")), series = list(list(
            data = list(list(x = 0.5, y = 1, custom = list(rangeRole = "lower", 
                metadata = list(), lower = list(), upper = list()), 
                Xlabel = "0"), list(x = 1, y = 1.5, custom = list(
                rangeRole = "lower", metadata = list(), lower = list(), 
                upper = list()), Xlabel = "1"), list(x = 2, y = 2, 
                custom = list(rangeRole = "lower", metadata = list(), 
                    lower = list(), upper = list()), Xlabel = "2")), 
            type = "line", id = "ngr-range-1", name = "Interval", 
            yAxis = 0L, color = "#E16A86", dashStyle = "Solid", lineWidth = 1, 
            showInLegend = TRUE, marker = list(enabled = FALSE), 
            tooltip = list(pointFormat = "ID: <b>{point.series.name}</b><br>Bound: <b>{point.custom.rangeRole}</b><br>X: {point.Xlabel}<br>Y: {point.y}"), 
            zIndex = 1), list(data = list(list(x = 0.5, low = 1, 
            high = 1.4, Xlabel = "0"), list(x = 1, low = 1.5, high = 2, 
            Xlabel = "1"), list(x = 2, low = 2, high = 2.8, Xlabel = "2")), 
            type = "arearange", id = "ngr-range-1-fill", linkedTo = "ngr-range-1", 
            name = "Interval", yAxis = 0L, color = "#E16A86", fillOpacity = 0.3, 
            lineWidth = 0, showInLegend = FALSE, enableMouseTracking = FALSE, 
            includeInDataExport = FALSE, marker = list(enabled = FALSE), 
            zIndex = 0), list(data = list(list(x = 0.5, y = 1.4, 
            custom = list(rangeRole = "upper", metadata = list(), 
                lower = list(), upper = list()), Xlabel = "0"), list(
            x = 1, y = 2, custom = list(rangeRole = "upper", metadata = list(), 
                lower = list(), upper = list()), Xlabel = "1"), list(
            x = 2, y = 2.8, custom = list(rangeRole = "upper", metadata = list(), 
                lower = list(), upper = list()), Xlabel = "2")), 
            type = "line", id = "ngr-range-1-upper", linkedTo = "ngr-range-1", 
            name = "Interval", yAxis = 0L, color = "#E16A86", dashStyle = "Solid", 
            lineWidth = 1, showInLegend = FALSE, marker = list(enabled = FALSE), 
            tooltip = list(pointFormat = "ID: <b>{point.series.name}</b><br>Bound: <b>{point.custom.rangeRole}</b><br>X: {point.Xlabel}<br>Y: {point.y}"), 
            zIndex = 1)), tooltip = list(split = FALSE, crosshairs = TRUE, 
            headerFormat = "", pointFormat = "ID: <b>{point.series.name}</b><br>X: {point.Xlabel}<br>Y: {point.y}"))

