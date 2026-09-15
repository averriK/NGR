.prepareRangeData <- function(data) {
    RangeData <- data.table::copy(data.table::as.data.table(data))
    Required <- c("ID", "X", "lower", "upper")

    if (!all(Required %in% names(RangeData))) {
        stop(
            "buildPlot(): data.ranges must contain ID, X, lower, and upper.",
            call. = FALSE
        )
    }
    if (!nrow(RangeData)) {
        stop("buildPlot(): data.ranges must contain at least one row.", call. = FALSE)
    }
    if (!is.atomic(RangeData$ID) || anyNA(RangeData$ID) ||
        any(!nzchar(as.character(RangeData$ID)))) {
        stop("buildPlot(): data.ranges$ID must contain non-missing values.", call. = FALSE)
    }
    if (!is.numeric(RangeData$X) || !is.numeric(RangeData$lower) ||
        !is.numeric(RangeData$upper)) {
        stop(
            "buildPlot(): data.ranges$X, lower, and upper must be numeric.",
            call. = FALSE
        )
    }
    if (any(!is.finite(RangeData$X)) ||
        any(!is.finite(RangeData$lower)) ||
        any(!is.finite(RangeData$upper))) {
        stop(
            "buildPlot(): data.ranges$X, lower, and upper must be finite.",
            call. = FALSE
        )
    }
    if (anyDuplicated(RangeData[, c("ID", "X"), with = FALSE])) {
        stop(
            "buildPlot(): data.ranges requires unique combinations of ID and X.",
            call. = FALSE
        )
    }
    if (any(RangeData$lower > RangeData$upper)) {
        stop(
            "buildPlot(): data.ranges lower must not exceed upper.",
            call. = FALSE
        )
    }

    for (Column in intersect(c("custom.lower", "custom.upper"), names(RangeData))) {
        Values <- RangeData[[Column]]
        OK <- is.list(Values) && all(vapply(
            Values,
            function(Value) {
                is.null(Value) ||
                    (is.list(Value) &&
                        (!length(Value) ||
                            (!is.null(names(Value)) && all(nzchar(names(Value))))))
            },
            logical(1L)
        ))
        if (!OK) {
            stop(
                sprintf(
                    "buildPlot(): data.ranges$%s must be a named-list column.",
                    Column
                ),
                call. = FALSE
            )
        }
    }

    if ("size" %in% names(RangeData)) {
        Values <- RangeData$size
        if (!is.numeric(Values) ||
            any(!is.na(Values) & (!is.finite(Values) | Values <= 0))) {
            stop(
                "buildPlot(): data.ranges$size must contain positive numbers.",
                call. = FALSE
            )
        }
    }
    if ("color" %in% names(RangeData)) {
        Values <- as.character(RangeData$color)
        if (any(!is.na(Values) & !nzchar(Values))) {
            stop(
                "buildPlot(): data.ranges$color must contain non-empty values.",
                call. = FALSE
            )
        }
        data.table::set(RangeData, j = "color", value = Values)
    }
    if ("yAxis" %in% names(RangeData)) {
        Values <- RangeData$yAxis
        if (is.factor(Values)) {
            Values <- as.character(Values)
        }
        if (is.character(Values)) {
            suppressWarnings(Numeric <- as.numeric(Values))
            if (any(!is.na(Values) & is.na(Numeric))) {
                stop(
                    "buildPlot(): data.ranges$yAxis must be 0 or 1.",
                    call. = FALSE
                )
            }
            Values <- Numeric
        }
        if (!is.numeric(Values) || any(!is.na(Values) & !Values %in% c(0, 1))) {
            stop(
                "buildPlot(): data.ranges$yAxis must be 0 or 1.",
                call. = FALSE
            )
        }
        data.table::set(RangeData, j = "yAxis", value = Values)
    }

    RangeData
}

.rangeGroupValue <- function(data, column, default) {
    if (!column %in% names(data)) {
        return(default)
    }

    Values <- unique(data[[column]][!is.na(data[[column]])])
    if (!length(Values)) {
        return(default)
    }
    if (length(Values) != 1L) {
        stop(
            sprintf(
                "buildPlot(): data.ranges$%s must be constant within each ID.",
                column
            ),
            call. = FALSE
        )
    }

    Values[[1L]]
}

.rangeCustom <- function(data, index, role) {
    Meta.lower <- if ("custom.lower" %in% names(data)) {
        data[["custom.lower"]][[index]]
    } else {
        list()
    }
    Meta.upper <- if ("custom.upper" %in% names(data)) {
        data[["custom.upper"]][[index]]
    } else {
        list()
    }
    if (is.null(Meta.lower)) {
        Meta.lower <- list()
    }
    if (is.null(Meta.upper)) {
        Meta.upper <- list()
    }

    list(
        rangeRole = role,
        metadata = if (identical(role, "upper")) Meta.upper else Meta.lower,
        lower = Meta.lower,
        upper = Meta.upper
    )
}

.rangePoint <- function(data, index, value, role, xColumn) {
    Point <- list(
        x = data[[xColumn]][[index]],
        y = value,
        custom = .rangeCustom(data, index, role)
    )
    if ("Xlabel" %in% names(data)) {
        Point$Xlabel <- data$Xlabel[[index]]
    }

    Point
}

.buildRangeSeries <- function(
    data,
    lineType,
    lineSize,
    fillOpacity,
    colorMap,
    xColumn,
    pointFormat,
    rangePointFormat) {
    Groups <- unique(as.character(data$ID))
    OUT <- list()

    for (i in seq_along(Groups)) {
        GroupID <- Groups[[i]]
        GroupData <- data[as.character(data$ID) == GroupID]
        SeriesID <- paste0("ngr-range-", i)
        Color <- as.character(.rangeGroupValue(
            GroupData,
            "color",
            unname(colorMap[[GroupID]])
        ))
        LineWidth <- as.numeric(.rangeGroupValue(GroupData, "size", lineSize))
        Axis <- as.integer(.rangeGroupValue(GroupData, "yAxis", 0))
        Scalar <- all(GroupData$lower == GroupData$upper)
        Role <- if (Scalar) "coincident" else "lower"
        Lower <- lapply(seq_len(nrow(GroupData)), function(j) {
            .rangePoint(
                GroupData,
                j,
                GroupData$lower[[j]],
                Role,
                xColumn
            )
        })
        Master <- list(
            data = Lower,
            type = lineType,
            id = SeriesID,
            name = GroupID,
            yAxis = Axis,
            color = Color,
            dashStyle = "Solid",
            lineWidth = LineWidth,
            showInLegend = TRUE,
            marker = list(enabled = FALSE),
            tooltip = list(
                pointFormat = if (Scalar) pointFormat else rangePointFormat
            ),
            zIndex = 1
        )
        OUT[[length(OUT) + 1L]] <- Master

        if (!Scalar) {
            Fill <- lapply(seq_len(nrow(GroupData)), function(j) {
                Point <- list(
                    x = GroupData[[xColumn]][[j]],
                    low = GroupData$lower[[j]],
                    high = GroupData$upper[[j]]
                )
                if ("Xlabel" %in% names(GroupData)) {
                    Point$Xlabel <- GroupData$Xlabel[[j]]
                }
                Point
            })
            OUT[[length(OUT) + 1L]] <- list(
                data = Fill,
                type = if (identical(lineType, "spline")) {
                    "areasplinerange"
                } else {
                    "arearange"
                },
                id = paste0(SeriesID, "-fill"),
                linkedTo = SeriesID,
                name = GroupID,
                yAxis = Axis,
                color = Color,
                fillOpacity = fillOpacity,
                lineWidth = 0,
                showInLegend = FALSE,
                enableMouseTracking = FALSE,
                includeInDataExport = FALSE,
                marker = list(enabled = FALSE),
                zIndex = 0
            )
            Upper <- lapply(seq_len(nrow(GroupData)), function(j) {
                .rangePoint(
                    GroupData,
                    j,
                    GroupData$upper[[j]],
                    "upper",
                    xColumn
                )
            })
            OUT[[length(OUT) + 1L]] <- list(
                data = Upper,
                type = lineType,
                id = paste0(SeriesID, "-upper"),
                linkedTo = SeriesID,
                name = GroupID,
                yAxis = Axis,
                color = Color,
                dashStyle = "Solid",
                lineWidth = LineWidth,
                showInLegend = FALSE,
                marker = list(enabled = FALSE),
                tooltip = list(pointFormat = rangePointFormat),
                zIndex = 1
            )
        }
    }

    OUT
}
