# nolint start
#' @title Build a highchart plot
#' @description Build a highchart plot using separate data sources for lines and points.
#'
#' Supports the plotting of line and scatter series. Includes optional arearange shading between
#' two line groups if indicated in `data.lines$fill`, and interpolation is handled via the `approx` function
#' (which can be customized using the `interpolation.method` argument). Fallback behaviors:
#' if an invalid `line.type` is provided, `"line"` is used; if an invalid or missing line style is found,
#' `"solid"` is used; if an invalid `color.palette` is provided, a default Highcharts palette is chosen.
#'
#' @param library DEPRECATED. A placeholder parameter that triggers a warning if used.
#' @param plot.type DEPRECATED. A placeholder parameter that triggers a warning if used.
#' @param data.lines A data.table containing columns "ID", "X", "Y", optional "style", optional "size", optional "fill", optional "yAxis" (0 or 1).
#'                   If NULL, no lines will be plotted.
#' @param data.points A data.table containing columns "ID", "X", "Y", optional "style", optional "yAxis" (0 or 1).
#'                    If NULL, no scatter points will be plotted.
#' @param line.type A string indicating the line series type. Options might include `"line"` or `"spline"`.
#'                  If invalid, `"line"` is used.
#' @param plot.title A string for the plot title
#' @param plot.subtitle A string for the plot subtitle
#' @param plot.height A numeric for the plot height
#' @param plot.width A numeric for the plot width
#' @param xAxis.legend A string for the x-axis legend
#' @param yAxis.legend A string for the y-axis legend
#' @param group.legend A string for the legend title
#' @param color.palette A string for the color palette (must exist in `grDevices::hcl.pals()`)
#' @param line.style A string specifying the default line style if `data.lines$style` is missing/invalid.
#' @param point.style A string specifying the default point marker style if `data.points$style` is missing/invalid.
#' @param line.size A numeric for the line width
#' @param point.size A numeric for the point size
#' @param xAxis.log A logical for the x-axis log scale
#' @param yAxis.log A logical for the y-axis log scale
#' @param xAxis.log.offset Offset value for X when xAxis.log=TRUE and data contains X<=0. NULL (default) calculates automatically as min of positive X values times 0.1. FALSE disables transformation. Numeric value uses that as offset.
#' @param yAxis.log.offset Offset value for Y when yAxis.log=TRUE and data contains Y<=0. NULL (default) calculates automatically as min of positive Y values times 0.1. FALSE disables transformation. Numeric value uses that as offset.
#' @param xAxis.reverse A logical for the x-axis reverse
#' @param yAxis.reverse A logical for the y-axis reverse
#' @param xAxis.max A numeric for the x-axis max
#' @param yAxis.max A numeric for the y-axis max
#' @param xAxis.min A numeric for the x-axis min
#' @param yAxis.min A numeric for the y-axis min
#' @param xAxis.label A logical for the x-axis label
#' @param yAxis.label A logical for the y-axis label
#' @param yAxis2 Advanced: optional list with Highcharts `yAxis[1]` options (secondary axis). If provided, it overrides `yAxis2.*` convenience arguments.
#' @param yAxis2.legend Optional string for the secondary Y axis title (right axis).
#' @param yAxis2.transform Optional one-sided formula to transform primary Y tick values for secondary axis labels in linked mode. Use `Y` as the primary axis tick value (e.g. `~ 1 / Y`).
#' @param yAxis2.decimals Integer number of decimals for secondary axis labels when using `yAxis2.transform` (passed to `Highcharts.numberFormat`).
#' @param legend.layout A string for the legend layout
#' @param legend.align A string for the legend horizontal alignment (e.g. `"center"`, `"left"`, `"right"`)
#' @param legend.valign A string for the legend vertical alignment (e.g. `"top"`, `"middle"`, `"bottom"`)
#' @param legend.show A logical for the legend show/hide
#' @param plot.save A logical for the plot save
#' @param plot.theme A highchart theme object
#' @param xAxis.legend.fontsize A string for the x-axis legend fontsize
#' @param yAxis.legend.fontsize A string for the y-axis legend fontsize
#' @param group.legend.fontsize A string for the legend items' fontsize
#' @param plot.title.fontsize A string for the plot title fontsize
#' @param plot.subtitle.fontsize A string for the plot subtitle fontsize
#' @param print.max.abs A logical for printing max absolute Y labels as annotations (only for lines)
#' @param point.dataLabels A logical for whether data labels appear for points
#' @param plot.filename A string for the plot filename, if saving
#' @param interpolation.method A string specifying the interpolation method used by `approx()`.
#' @param fill.opacity Opacity for arearange fill (0-1).
#' @param fill.legend Optional legend label for the shaded arearange band. If NULL or empty, a default label is used.
#' @param fill.max ID to use for the upper envelope series when auto-envelopes are enabled.
#' @param fill.min ID to use for the lower envelope series when auto-envelopes are enabled.
#' @param fill.minmax Logical flag; if TRUE and no explicit fill == TRUE is present in data.lines, automatically
#'   constructs upper/lower envelope series by X (using fill.max / fill.min as IDs) and shades between them.
#' @param fill.max.style Line style for upper envelope (default: "Solid").
#' @param fill.min.style Line style for lower envelope (default: "Solid").
#' @param fill.max.size Line width for upper envelope (default: NULL, uses global line.size).
#' @param fill.min.size Line width for lower envelope (default: NULL, uses global line.size).
#' @param fill.max.color Color for upper envelope (default: "#00008B", dark blue).
#' @param fill.min.color Color for lower envelope (default: "#8B0000", dark red).
#'
#' @return A highchart object if either `data.lines` or `data.points` is provided.
#'         Returns NULL if both are NULL, with a soft warning.
#' @importFrom grDevices hcl.pals hcl.colors
#' @importFrom stats setNames approx spline
#' @import highcharter
#' @importFrom htmlwidgets saveWidget
#' @export buildPlot
#'
buildPlot <- function(
    library = NULL, # DEPRECATED: triggers a warning if explicitly used
    plot.type = NULL, # DEPRECATED: triggers a warning if explicitly used
    data.lines = NULL,
    data.points = NULL,
    line.type = "line", # e.g. "line", "spline", or fallback
    plot.title = NULL,
    plot.subtitle = NULL,
    plot.height = NULL,
    plot.width = NULL,
    xAxis.legend = "X",
    yAxis.legend = "Y",
    group.legend = "ID",
    color.palette = "Dark 3",
    line.style = "solid", # default fallback for lines if style is missing or invalid
    point.style = "circle", # default fallback for points if style is missing or invalid
    line.size = 1,
    point.size = 3,
    xAxis.log = FALSE,
    yAxis.log = FALSE,
    xAxis.reverse = FALSE,
    yAxis.reverse = FALSE,
    xAxis.max = NA,
    yAxis.max = NA,
    xAxis.min = NA,
    yAxis.min = NA,
    xAxis.label = TRUE,
    yAxis.label = TRUE,
    legend.layout = "horizontal",
    legend.align = "right",
    legend.valign = "top",
    legend.show = TRUE,
    plot.save = FALSE,
    plot.theme = NULL,
    xAxis.legend.fontsize = "14px",
    yAxis.legend.fontsize = "14px",
    group.legend.fontsize = "12px",
    plot.title.fontsize = "24px",
    plot.subtitle.fontsize = "18px",
    print.max.abs = FALSE,
    point.dataLabels = FALSE,
    plot.filename = NULL,
    fill.opacity = 0.3,
    fill.legend = NULL,
    fill.max = ".max",
    fill.min = ".min",
    fill.minmax = FALSE,
    fill.max.style = "Solid",
    fill.min.style = "Solid",
    fill.max.size = NULL,
    fill.min.size = NULL,
    fill.max.color = "#00008B",
    fill.min.color = "#8B0000",
    xAxis.log.offset = NULL,
    yAxis.log.offset = NULL,
    interpolation.method = "linear",
    yAxis2 = NULL,
    yAxis2.legend = NULL,
    yAxis2.transform = NULL,
    yAxis2.decimals = 0) {
    ## 0. Declare data.table columns to avoid R CMD check NOTEs
    style <- size <- yAxis <- NULL  # data.table columns
    
    ## 1. Deprecation warnings for library, plot.type
    #    only trigger if the user explicitly set them (i.e. not missing)
    if (!missing(library)) {
        warning("'library' is deprecated and will be ignored.")
    }
    if (!missing(plot.type)) {
        warning("'plot.type' is deprecated and will be ignored.")
    }

    ## 2. Soft check if both data.lines and data.points are NULL
    if (is.null(data.lines) && is.null(data.points)) {
        warning("No data provided for lines or points. Returning NULL.")
        return(NULL)
    }

    ## 3. Validate numeric inputs (warn & set default, instead of stop)
    if (!is.numeric(line.size) || line.size <= 0) {
        warning(
            sprintf("line.size should be a positive numeric. Using default (1) instead of '%s'.", line.size)
        )
        line.size <- 1
    }
    if (!is.numeric(point.size) || point.size <= 0) {
        warning(
            sprintf("point.size should be a positive numeric. Using default (3) instead of '%s'.", point.size)
        )
        point.size <- 3
    }

    ## 4. Validate color palette
    if (!color.palette %in% grDevices::hcl.pals()) {
        warning("Invalid color palette. Using default.")
        # pick some default from the list
        color.palette <- grDevices::hcl.pals()[4]
    }

    ## 5. Name mappings for line dash styles (all-lowercase keys)
    #    The final Highcharts dashStyle strings are typically capitalized, but
    #    we keep the map keys in lowercase for consistent matching.
    LINE.STYLE <- list(
        "solid" = "Solid",
        "dashed" = "Dash",
        "dash" = "Dash",
        "twodash" = "Dash",
        "dot" = "Dot",
        "dotted" = "Dot",
        "dashdot" = "DashDot",
        "dotdash" = "DashDot",
        "longdash" = "LongDash",
        "shortdash" = "ShortDash",
        "shortdot" = "ShortDot",
        "shortdashdot" = "ShortDashDot",
        "longdashdotdot" = "LongDashDotDot"
    )

    ## 6. Name mappings for point marker styles (lowercase keys)
    POINT.STYLE <- list(
        "circle"        = "circle",
        "square"        = "square",
        "diamond"       = "diamond",
        "triangle"      = "triangle",
        "triangle-down" = "triangle-down"
    )

    ## 7. Validate line.type
    line.type <- tolower(line.type)
    # Potentially allow more than "line"/"spline" if you like:
    VALID.LINE.TYPES <- c("line", "spline")
    if (!line.type %in% VALID.LINE.TYPES) {
        warning(sprintf("Provided line.type='%s' is invalid. Using 'line' by default.", line.type))
        line.type <- "line"
    }

    ## 8. Validate data inputs
    validateData <- function(data, data_name) {
        if (!is.null(data)) {
            if (!all(c("ID", "X", "Y") %in% colnames(data))) {
                stop(sprintf("%s must contain columns named ID, X, and Y if not NULL.", data_name))
            }
            if (!is.numeric(data$Y)) {
                stop(sprintf("Error in buildPlot(): %s$Y must be numeric.", data_name))
            }
        }
    }
    validateData(data.lines, "data.lines")
    validateData(data.points, "data.points")

    validateYAxisCol <- function(data, data_name) {
        if (!is.null(data) && "yAxis" %in% names(data)) {
            vals <- data$yAxis
            if (is.factor(vals)) {
                vals <- as.character(vals)
            }
            if (is.character(vals)) {
                suppressWarnings(vals_num <- as.numeric(vals))
                if (any(!is.na(vals) & is.na(vals_num))) {
                    stop(sprintf("Error in buildPlot(): %s$yAxis must be numeric (0 or 1).", data_name))
                }
                vals <- vals_num
            }
            if (any(!is.na(vals) & !(vals %in% c(0, 1)))) {
                stop(sprintf("Error in buildPlot(): %s$yAxis must be 0 or 1 (or NA).", data_name))
            }
        }
    }
    validateYAxisCol(data.lines, "data.lines")
    validateYAxisCol(data.points, "data.points")

    ## 9. Validate interpolation.method
    # stats::approx only supports "linear" and "constant"
    valid.methods <- c("linear", "constant")
    if (!interpolation.method %in% valid.methods) {
        warning(sprintf(
            "Provided interpolation.method='%s' is invalid. Using 'linear' by default.",
            interpolation.method
        ))
        interpolation.method <- "linear"
    }

    ## 9b. Validate yAxis2 / yAxis2.*
    if (!is.null(yAxis2) && !is.list(yAxis2)) {
        stop("buildPlot(): yAxis2 must be a list or NULL")
    }
    if (!is.null(yAxis2.legend) && (!is.character(yAxis2.legend) || length(yAxis2.legend) != 1)) {
        stop("buildPlot(): yAxis2.legend must be a single string or NULL")
    }
    if (!is.null(yAxis2.transform) && !inherits(yAxis2.transform, "formula")) {
        stop("buildPlot(): yAxis2.transform must be a formula like ~ 1 / Y (or NULL)")
    }
    if (!is.null(yAxis2.decimals)) {
        if (!is.numeric(yAxis2.decimals) || length(yAxis2.decimals) != 1 || is.na(yAxis2.decimals) || yAxis2.decimals < 0) {
            stop("buildPlot(): yAxis2.decimals must be a single non-negative number")
        }
        yAxis2.decimals <- as.integer(yAxis2.decimals)
    }

    ## 10. Build color mapping (collect all IDs for consistent color usage)
    ALL.IDS <- unique(c(
        if (!is.null(data.lines)) data.lines$ID,
        if (!is.null(data.points)) data.points$ID
    ))
    ID.COLOR.MAP <- stats::setNames(
        grDevices::hcl.colors(
            n = length(ALL.IDS),
            palette = color.palette
        ),
        as.character(ALL.IDS)
    )

    ## 10b. Handle logarithmic axis transformation for X<=0 or Y<=0
    x_offset <- 0
    y_offset <- 0
    
    # X-axis transformation
    if (xAxis.log && !isFALSE(xAxis.log.offset)) {
        all_x <- c(
            if (!is.null(data.lines)) data.lines$X,
            if (!is.null(data.points)) data.points$X
        )
        if (any(all_x <= 0, na.rm = TRUE)) {
            if (is.null(xAxis.log.offset)) {
                # Auto-calculate offset
                x_positive <- all_x[all_x > 0]
                if (length(x_positive) > 0) {
                    x_offset <- min(x_positive, na.rm = TRUE) * 0.1
                }
            } else if (is.numeric(xAxis.log.offset)) {
                x_offset <- xAxis.log.offset
            }
            
            if (x_offset > 0) {
                if (!is.null(data.lines)) {
                    if (!inherits(data.lines, "data.table")) {
                        data.lines <- data.table::as.data.table(data.lines)
                    }
                    data.lines[, X := X + x_offset]
                }
                if (!is.null(data.points)) {
                    if (!inherits(data.points, "data.table")) {
                        data.points <- data.table::as.data.table(data.points)
                    }
                    data.points[, X := X + x_offset]
                }
            }
        }
    }
    
    # Y-axis transformation (only affects yAxis == 0 series)
    if (yAxis.log && !isFALSE(yAxis.log.offset)) {
        get_axis0_y <- function(data) {
            if (is.null(data)) {
                return(numeric(0))
            }
            if ("yAxis" %in% names(data)) {
                idx0 <- is.na(data$yAxis) | data$yAxis == 0
                return(data$Y[idx0])
            }
            data$Y
        }

        all_y <- c(get_axis0_y(data.lines), get_axis0_y(data.points))
        if (any(all_y <= 0, na.rm = TRUE)) {
            if (is.null(yAxis.log.offset)) {
                # Auto-calculate offset
                y_positive <- all_y[all_y > 0]
                if (length(y_positive) > 0) {
                    y_offset <- min(y_positive, na.rm = TRUE) * 0.1
                }
            } else if (is.numeric(yAxis.log.offset)) {
                y_offset <- yAxis.log.offset
            }

            if (y_offset > 0) {
                if (!is.null(data.lines)) {
                    if (!inherits(data.lines, "data.table")) {
                        data.lines <- data.table::as.data.table(data.lines)
                    }
                    if ("yAxis" %in% names(data.lines)) {
                        data.lines[is.na(yAxis) | yAxis == 0, Y := Y + y_offset]
                    } else {
                        data.lines[, Y := Y + y_offset]
                    }
                }
                if (!is.null(data.points)) {
                    if (!inherits(data.points, "data.table")) {
                        data.points <- data.table::as.data.table(data.points)
                    }
                    if ("yAxis" %in% names(data.points)) {
                        data.points[is.na(yAxis) | yAxis == 0, Y := Y + y_offset]
                    } else {
                        data.points[, Y := Y + y_offset]
                    }
                }
            }
        }
    }

    ## 11. Initialize plot object
    # Build axis label formatters if offset was applied
    # Label formatter for offset-shifted log axes. The naive
    # `(this.value - offset).toString()` produces ugly tail digits
    # (e.g. "0.010000000000000002") because of IEEE 754 subtraction
    # noise. Since `tickPositioner` (below) places ticks at
    # `10^n + offset`, the un-shifted value is always within FP noise
    # of a power of ten; snap to it whenever close enough.
    .logLabelFormatterJS <- function(offset) {
        htmlwidgets::JS(sprintf(
            paste0(
                "function() { ",
                "var val = this.value - %s; ",
                "if (Math.abs(val) < 1e-10) return '0'; ",
                "var n = Math.round(Math.log(Math.abs(val)) / Math.LN10); ",
                "var snap = Math.pow(10, n) * (val < 0 ? -1 : 1); ",
                "if (Math.abs(val - snap) / Math.abs(snap) < 1e-6) return snap.toString(); ",
                "return val.toString(); }"
            ),
            format(offset, digits = 17)
        ))
    }

    xAxis_labels <- list(enabled = xAxis.label)
    if (x_offset > 0) xAxis_labels$formatter <- .logLabelFormatterJS(x_offset)

    yAxis_labels <- list(enabled = yAxis.label)
    if (y_offset > 0) yAxis_labels$formatter <- .logLabelFormatterJS(y_offset)

    # Tick positioners for log axes with offset: ensure major ticks land at
    # `10^n + offset`, so the JS label formatter (above) renders clean powers
    # of ten in original space (0.01, 0.1, 1, 10, ...) plus the special "0"
    # tick at the offset position itself. Auto-derives the exponent range
    # from the actual axis dataMin/dataMax at render time -- no R-side
    # hardcoded positions, adapts to any data range. Without this, Highcharts
    # autoplaces ticks at powers of 10 in the *shifted* axis and the label
    # formatter ends up showing "0.009 / 0.099 / 0.999" instead of clean
    # decades.
    .logTickPositionerJS <- function(offset) {
        # offset is round-tripped via format(digits = 17): IEEE 754 spec
        # guarantees a double recovers exactly from 17 significant decimals.
        # Number.MIN_VALUE is the JS-native smallest positive double, used
        # only as a sentinel so Math.log never sees a non-positive argument
        # when the data spans down to the offset itself.
        htmlwidgets::JS(sprintf(
            paste0(
                "function() { ",
                "var off = %s; ",
                "var dMin = Math.max(this.dataMin - off, Number.MIN_VALUE); ",
                "var dMax = this.dataMax - off; ",
                "if (!isFinite(dMax) || dMax <= 0) return null; ",
                "var eLo = Math.floor(Math.log(dMin) / Math.LN10); ",
                "var eHi = Math.ceil(Math.log(dMax) / Math.LN10); ",
                "var pos = [off]; ",
                "for (var e = eLo; e <= eHi; e++) pos.push(Math.pow(10, e) + off); ",
                "return pos; }"
            ),
            format(offset, digits = 17)
        ))
    }
    x_tickPositioner <- if (x_offset > 0) .logTickPositionerJS(x_offset) else NULL
    y_tickPositioner <- if (y_offset > 0) .logTickPositionerJS(y_offset) else NULL
    
    has_axis2_series <- FALSE
    if (!is.null(data.lines) && "yAxis" %in% names(data.lines)) {
        has_axis2_series <- any(data.lines$yAxis == 1, na.rm = TRUE)
    }
    if (!has_axis2_series && !is.null(data.points) && "yAxis" %in% names(data.points)) {
        has_axis2_series <- any(data.points$yAxis == 1, na.rm = TRUE)
    }

    needs_secondary_axis <- has_axis2_series ||
        !is.null(yAxis2) ||
        !is.null(yAxis2.legend) ||
        !is.null(yAxis2.transform)

    if (has_axis2_series && !is.null(yAxis2.transform)) {
        stop("buildPlot(): yAxis2.transform is only supported in linked mode (no series assigned to yAxis=1)")
    }

    if (!needs_secondary_axis) {
        plot.object <- highchart() |>
            hc_xAxis(
                labels = xAxis_labels,
                tickPositioner = x_tickPositioner,
                title = list(
                    text = xAxis.legend,
                    style = list(fontSize = xAxis.legend.fontsize)
                ),
                type = if (xAxis.log) "logarithmic" else "linear",
                reversed = xAxis.reverse,
                max = if (!is.na(xAxis.max)) xAxis.max else NULL,
                min = if (!is.na(xAxis.min)) xAxis.min else NULL
            ) |>
            hc_yAxis(
                labels = yAxis_labels,
                tickPositioner = y_tickPositioner,
                title = list(
                    text = yAxis.legend,
                    style = list(fontSize = yAxis.legend.fontsize)
                ),
                type = if (yAxis.log) "logarithmic" else "linear",
                reversed = yAxis.reverse,
                max = if (!is.na(yAxis.max)) yAxis.max else NULL,
                min = if (!is.na(yAxis.min)) yAxis.min else NULL
            ) |>
            hc_exporting(
                enabled = TRUE,
                filename = if (!is.null(plot.filename)) plot.filename else "highchart-plot",
                buttons = list(
                    contextButton = list(
                        menuItems = c("downloadPNG", "downloadJPEG", "downloadPDF", "downloadSVG", "downloadCSV", "downloadXLS")
                    )
                )
            )
    } else {
        yAxis_primary <- list(
            labels = yAxis_labels,
            tickPositioner = y_tickPositioner,
            title = list(
                text = yAxis.legend,
                style = list(fontSize = yAxis.legend.fontsize)
            ),
            type = if (yAxis.log) "logarithmic" else "linear",
            reversed = yAxis.reverse,
            max = if (!is.na(yAxis.max)) yAxis.max else NULL,
            min = if (!is.na(yAxis.min)) yAxis.min else NULL
        )

        # Convert simple math formulas (in terms of Y) into JavaScript.
        # Example: yAxis2.transform = ~ 1 / Y
        transform_env <- if (!is.null(yAxis2.transform)) environment(yAxis2.transform) else NULL
        expr_to_js <- function(expr) {
            if (is.null(expr)) {
                stop("buildPlot(): yAxis2.transform formula RHS is missing")
            }

            if (is.numeric(expr)) {
                return(format(expr, scientific = TRUE, digits = 17))
            }

            if (is.symbol(expr)) {
                nm <- as.character(expr)
                if (nm %in% c("Y", ".")) {
                    return("y")
                }
                if (nm == "pi") {
                    return("Math.PI")
                }

                # Allow scalar numeric constants defined in the formula environment.
                # Example: yAxis2.transform = ~ ITo / (-log(1 - Y)) with ITo = 50
                if (!is.null(transform_env) && exists(nm, envir = transform_env, inherits = TRUE)) {
                    val <- get(nm, envir = transform_env, inherits = TRUE)
                    if (is.numeric(val) && length(val) == 1 && is.finite(val)) {
                        return(format(val, scientific = TRUE, digits = 17))
                    }
                }

                stop(sprintf("buildPlot(): Unsupported symbol in yAxis2.transform: %s", nm))
            }

            if (is.call(expr)) {
                op <- as.character(expr[[1]])

                # Parentheses/grouping: (x)
                if (op == "(") {
                    if (length(expr) != 2) {
                        stop("buildPlot(): Unsupported arity for parentheses in yAxis2.transform")
                    }
                    return(expr_to_js(expr[[2]]))
                }

                # Binary operators
                if (op %in% c("+", "-", "*", "/")) {
                    # unary -
                    if (op == "-" && length(expr) == 2) {
                        return(paste0("(-", expr_to_js(expr[[2]]), ")"))
                    }
                    if (length(expr) != 3) {
                        stop(sprintf("buildPlot(): Unsupported arity for operator %s in yAxis2.transform", op))
                    }
                    lhs <- expr_to_js(expr[[2]])
                    rhs <- expr_to_js(expr[[3]])
                    return(paste0("(", lhs, " ", op, " ", rhs, ")"))
                }

                if (op == "^") {
                    if (length(expr) != 3) {
                        stop("buildPlot(): Unsupported arity for ^ in yAxis2.transform")
                    }
                    base <- expr_to_js(expr[[2]])
                    expo <- expr_to_js(expr[[3]])
                    return(paste0("Math.pow(", base, ", ", expo, ")"))
                }

                # Math functions
                if (op %in% c("abs", "sqrt", "exp", "sin", "cos", "tan")) {
                    if (length(expr) != 2) {
                        stop(sprintf("buildPlot(): Unsupported arity for %s in yAxis2.transform", op))
                    }
                    arg <- expr_to_js(expr[[2]])
                    return(paste0("Math.", op, "(", arg, ")"))
                }

                if (op %in% c("floor", "ceiling", "round")) {
                    if (length(expr) < 2) {
                        stop(sprintf("buildPlot(): Unsupported arity for %s in yAxis2.transform", op))
                    }
                    arg <- expr_to_js(expr[[2]])

                    if (op == "floor") {
                        return(paste0("Math.floor(", arg, ")"))
                    }
                    if (op == "ceiling") {
                        return(paste0("Math.ceil(", arg, ")"))
                    }

                    # round(x, digits)
                    if (length(expr) == 2) {
                        return(paste0("Math.round(", arg, ")"))
                    }

                    digits <- expr[[3]]
                    digits_js <- expr_to_js(digits)
                    return(paste0("(Math.round(", arg, " * Math.pow(10, ", digits_js, ")) / Math.pow(10, ", digits_js, "))"))
                }

                if (op == "log") {
                    # log(x, base)
                    if (length(expr) < 2 || length(expr) > 3) {
                        stop("buildPlot(): log() in yAxis2.transform must be log(x) or log(x, base)")
                    }
                    x_js <- expr_to_js(expr[[2]])
                    if (length(expr) == 2) {
                        return(paste0("Math.log(", x_js, ")"))
                    }
                    base_js <- expr_to_js(expr[[3]])
                    return(paste0("(Math.log(", x_js, ") / Math.log(", base_js, "))"))
                }

                if (op == "log10") {
                    if (length(expr) != 2) {
                        stop("buildPlot(): log10() in yAxis2.transform must be log10(x)")
                    }
                    x_js <- expr_to_js(expr[[2]])
                    return(paste0("(Math.log(", x_js, ") / Math.LN10)"))
                }

                if (op == "log2") {
                    if (length(expr) != 2) {
                        stop("buildPlot(): log2() in yAxis2.transform must be log2(x)")
                    }
                    x_js <- expr_to_js(expr[[2]])
                    return(paste0("(Math.log(", x_js, ") / Math.LN2)"))
                }

                stop(sprintf("buildPlot(): Unsupported function/operator in yAxis2.transform: %s", op))
            }

            stop("buildPlot(): Unsupported expression type in yAxis2.transform")
        }

        yAxis2_labels <- if (has_axis2_series) {
            list(enabled = yAxis.label)
        } else {
            # linked mode defaults to the same labels (including any y_offset formatter)
            yAxis_labels
        }

        if (!is.null(yAxis2.transform)) {
            rhs <- yAxis2.transform[[2]]
            transform_js <- expr_to_js(rhs)
            y_offset_js <- if (y_offset > 0) sprintf(" - %.17g", y_offset) else ""
            yAxis2_labels$enabled <- TRUE
            yAxis2_labels$formatter <- htmlwidgets::JS(sprintf(
                "function() { var y = this.value%s; var y2 = %s; if (y2 === null || y2 === undefined || !isFinite(y2)) return ''; return Highcharts.numberFormat(y2, %d); }",
                y_offset_js,
                transform_js,
                yAxis2.decimals
            ))
        }

        yAxis2_defaults <- list(
            opposite = TRUE,
            gridLineWidth = 0,
            title = list(
                text = if (!is.null(yAxis2.legend)) yAxis2.legend else NULL,
                style = list(fontSize = yAxis.legend.fontsize)
            ),
            labels = yAxis2_labels,
            reversed = yAxis.reverse
        )

        if (!has_axis2_series) {
            # Linked axis: must match primary type, otherwise Highcharts can fail to render.
            yAxis2_defaults$linkedTo <- 0
            yAxis2_defaults$type <- if (yAxis.log) "logarithmic" else "linear"
            yAxis2_defaults$max <- if (!is.na(yAxis.max)) yAxis.max else NULL
            yAxis2_defaults$min <- if (!is.na(yAxis.min)) yAxis.min else NULL
        } else {
            # Independent axis: default to linear unless caller overrides via yAxis2.
            yAxis2_defaults$type <- "linear"
        }

        yAxis_secondary <- if (!is.null(yAxis2)) {
            utils::modifyList(yAxis2_defaults, yAxis2)
        } else {
            yAxis2_defaults
        }

        plot.object <- highchart() |>
            hc_xAxis(
                labels = xAxis_labels,
                tickPositioner = x_tickPositioner,
                title = list(
                    text = xAxis.legend,
                    style = list(fontSize = xAxis.legend.fontsize)
                ),
                type = if (xAxis.log) "logarithmic" else "linear",
                reversed = xAxis.reverse,
                max = if (!is.na(xAxis.max)) xAxis.max else NULL,
                min = if (!is.na(xAxis.min)) xAxis.min else NULL
            ) |>
            hc_yAxis_multiples(yAxis_primary, yAxis_secondary) |>
            hc_exporting(
                enabled = TRUE,
                filename = if (!is.null(plot.filename)) plot.filename else "highchart-plot",
                buttons = list(
                    contextButton = list(
                        menuItems = c("downloadPNG", "downloadJPEG", "downloadPDF", "downloadSVG", "downloadCSV", "downloadXLS")
                    )
                )
            )
    }

    ## 12. Theme handling
    if (!is.null(plot.theme)) {
        plot.object <- plot.object |> hc_add_theme(plot.theme)
    } else {
        plot.object <- plot.object |> hc_add_theme(hc_theme_flat())
    }

    ## 13. Titles
    if (!is.null(plot.title)) {
        plot.object <- plot.object |>
            hc_title(
                text = plot.title,
                style = list(fontSize = plot.title.fontsize)
            )
    }
    if (!is.null(plot.subtitle)) {
        plot.object <- plot.object |>
            hc_subtitle(
                text = plot.subtitle,
                style = list(fontSize = plot.subtitle.fontsize)
            )
    }

    ## 14. Plot size
    if (!is.null(plot.height) || !is.null(plot.width)) {
        plot.object <- plot.object |>
            hc_size(height = plot.height, width = plot.width)
    }

    ## 15. Legend (add legend title using group.legend)
    plot.object <- plot.object |>
        hc_legend(
            enabled = legend.show,
            align = legend.align,
            verticalAlign = legend.valign,
            layout = legend.layout,
            title = list(
                text = group.legend,
                style = list(fontWeight = "bold") # optional
            ),
            itemStyle = list(fontSize = group.legend.fontsize)
        ) |>
        hc_chart(style = list(fontFamily = "Helvetica"))
    
    ## 15b. (removed — tooltip built once at §16)

    ## ============ LINES =============
    if (!is.null(data.lines)) {

        ## Optional auto-envelope: compute .max/.min in plotting space when no
        ## explicit fill column is provided by the caller. This uses only ID, X, Y.
        if (isTRUE(fill.minmax) &&
            !is.null(fill.max) && !is.null(fill.min) &&
            (!"fill" %in% names(data.lines) || !any(data.lines$fill, na.rm = TRUE))) {

            if (!inherits(data.lines, "data.table")) {
                data.lines <- data.table::as.data.table(data.lines)
            }

            # Remove any existing envelope IDs from local copy
            data.lines <- data.lines[!ID %in% c(fill.max, fill.min)]

            # Ensure required columns are present
            if (!all(c("ID", "X", "Y") %in% names(data.lines))) {
                stop("data.lines must contain columns ID, X and Y when using fill.max/fill.min")
            }

            # Start with a logical fill column set to FALSE
            if (!"fill" %in% names(data.lines)) {
                data.lines[, fill := FALSE]
            } else {
                data.lines[, fill := FALSE]
            }

            COLS <- names(data.lines)

            # Upper envelope: for each X, point with maximum Y among all IDs
            MAX <- data.lines[, .SD[which.max(Y)], by = X]
            MAX[, ID := fill.max]

            # Lower envelope: for each X, point with minimum Y among all IDs
            MIN <- data.lines[, .SD[which.min(Y)], by = X]
            MIN[, ID := fill.min]

            # Make sure MAX and MIN have exactly the same columns as data.lines
            for (N in COLS) {
                if (!N %in% names(MAX)) MAX[, (N) := NA]
                if (!N %in% names(MIN)) MIN[, (N) := NA]
            }
            data.table::setcolorder(MAX, COLS)
            data.table::setcolorder(MIN, COLS)

            # Mark only envelopes for fill shading and set explicit style/size
            MAX[, fill := TRUE]
            MIN[, fill := TRUE]
            
            # Set style for envelopes
            if ("style" %in% COLS) {
                MAX[, style := fill.max.style]
                MIN[, style := fill.min.style]
            }
            
            # Set size for envelopes
            if ("size" %in% COLS) {
                MAX[, size := if (!is.null(fill.max.size)) fill.max.size else line.size]
                MIN[, size := if (!is.null(fill.min.size)) fill.min.size else line.size]
            }

            data.lines <- data.table::rbindlist(list(data.lines, MAX, MIN), use.names = TRUE)

            # Set custom colors for envelope IDs
            if (!fill.max %in% names(ID.COLOR.MAP)) {
                ID.COLOR.MAP[fill.max] <- fill.max.color
            }
            if (!fill.min %in% names(ID.COLOR.MAP)) {
                ID.COLOR.MAP[fill.min] <- fill.min.color
            }
        }

        unique_lines <- unique(data.lines$ID)

        for (gid in unique_lines) {
            sub_data <- data.lines[ID == gid]

            y_axis_idx <- 0
            if ("yAxis" %in% names(sub_data)) {
                y_axis_vals <- unique(sub_data$yAxis[!is.na(sub_data$yAxis)])
                if (length(y_axis_vals) > 1) {
                    warning(sprintf(
                        "Multiple yAxis values found for ID='%s'. Using the first.",
                        gid
                    ))
                }
                if (length(y_axis_vals) >= 1) {
                    y_axis_idx <- as.integer(y_axis_vals[1])
                }
            }

            # Determine line style from data or fallback
            if ("style" %in% names(sub_data)) {
                style_val <- tolower(as.character(sub_data$style[1]))
            } else {
                style_val <- tolower(line.style) # fallback
            }
            ## --- dash style (unchanged) -------------------------------------

            dash_style <- LINE.STYLE[[style_val]]
            if (is.null(dash_style)) {
                warning(sprintf(
                    "Invalid line style '%s' for ID='%s'. Using fallback 'solid'.",
                    style_val, gid
                ))
                dash_style <- LINE.STYLE[["solid"]] # final fallback
            }

            ## --- line size (per-group or global fallback) ------------------
            if ("size" %in% names(sub_data)) {
                size_val <- as.numeric(sub_data$size[1])
                if (is.na(size_val) || size_val <= 0) {
                    warning(sprintf(
                        "Invalid line size for ID='%s'. Using global line.size.",
                        gid
                    ))
                    size_val <- line.size
                }
            } else {
                size_val <- line.size  # global fallback
            }

            ## --- geometry ("line" vs "spline") ------------------------------
            if ("type" %in% names(sub_data)) {
                type_val <- tolower(as.character(sub_data$type[1]))
            } else {
                type_val <- line.type # global fallback
            }
            if (!type_val %in% c("line", "spline")) {
                warning(sprintf(
                    "Invalid line type '%s' for ID='%s'. Using 'line'.",
                    type_val, gid
                ))
                type_val <- "line"
            }

            ## --- add series -------------------------------------------------
            plot.object <- plot.object |>
                hc_add_series(
                    data = sub_data,
                    type = type_val, # <- per-series geometry
                    hcaes(x = X, y = Y),
                    name = as.character(gid),
                    yAxis = y_axis_idx,
                    color = ID.COLOR.MAP[as.character(gid)],
                    dashStyle = dash_style,
                    lineWidth = size_val,  # <- per-group size
                    marker = list(enabled = FALSE)
                )
        }

        ## ============ AREA-FILL =============
        if ("fill" %in% names(data.lines)) {
            ID.FILL <- unique(data.lines[fill == TRUE, ID])

            if (length(ID.FILL) > 2) {
                warning("More than two IDs marked for filling. Only the first two will be used.")
                ID.FILL <- ID.FILL[1:2]
            }
            if (length(ID.FILL) == 2) {
                # Fill area between exactly two sets
                gid1 <- ID.FILL[1]
                gid2 <- ID.FILL[2]
                xvals <- sort(unique(c(
                    data.lines[ID == gid1]$X,
                    data.lines[ID == gid2]$X
                )))
                if (line.type == "spline") {
                    curve1 <- spline(
                        data.lines[ID == gid1]$X,
                        data.lines[ID == gid1]$Y,
                        xout = xvals, method = "natural"
                    )
                    curve2 <- spline(
                        data.lines[ID == gid2]$X,
                        data.lines[ID == gid2]$Y,
                        xout = xvals, method = "natural"
                    )
                } else {
                    curve1 <- approx(
                        data.lines[ID == gid1]$X,
                        data.lines[ID == gid1]$Y,
                        xout = xvals, method = interpolation.method
                    )
                    curve2 <- approx(
                        data.lines[ID == gid2]$X,
                        data.lines[ID == gid2]$Y,
                        xout = xvals, method = interpolation.method
                    )
                }
                fill_data <- data.frame(
                    X    = xvals,
                    LOW  = pmin(curve1$y, curve2$y),
                    HIGH = pmax(curve1$y, curve2$y)
                )

                plot.object <- plot.object |>
                    hc_add_series(
                        data = fill_data,
                        type = if (line.type == "spline") "areasplinerange" else "arearange",
                        hcaes(x = X, low = LOW, high = HIGH),
                        name = if (!is.null(fill.legend) && nzchar(fill.legend)) {
                            fill.legend
                        } else {
                            paste("Area between", gid1, "and", gid2)
                        },
                        yAxis = 0,
                        color = ID.COLOR.MAP[as.character(gid1)],
                        fillOpacity = fill.opacity,
                        marker = list(enabled = FALSE),  # Disable markers on arearange
                        lineWidth = 0  # No border line on arearange
                    )
            }
        }
    }

    ## ============ POINTS =============
    if (!is.null(data.points)) {
        unique_points <- unique(data.points$ID)

        for (gid in unique_points) {
            sub_data <- data.points[ID == gid]

            y_axis_idx <- 0
            if ("yAxis" %in% names(sub_data)) {
                y_axis_vals <- unique(sub_data$yAxis[!is.na(sub_data$yAxis)])
                if (length(y_axis_vals) > 1) {
                    warning(sprintf(
                        "Multiple yAxis values found for point ID='%s'. Using the first.",
                        gid
                    ))
                }
                if (length(y_axis_vals) >= 1) {
                    y_axis_idx <- as.integer(y_axis_vals[1])
                }
            }

            # Determine point style from data or fallback
            if ("style" %in% names(sub_data)) {
                style_val <- tolower(as.character(sub_data$style[1]))
            } else {
                style_val <- tolower(point.style)
            }

            symbol_style <- POINT.STYLE[[style_val]]
            if (is.null(symbol_style)) {
                warning(sprintf(
                    "Invalid point style '%s' for ID='%s'. Using fallback 'circle'.",
                    style_val, gid
                ))
                symbol_style <- POINT.STYLE[["circle"]]
            }

            # Build scatter series
            plot.object <- plot.object |>
                hc_add_series(
                    data = sub_data,
                    type = "scatter",
                    hcaes(x = X, y = Y),
                    name = as.character(gid),
                    yAxis = y_axis_idx,
                    color = ID.COLOR.MAP[as.character(gid)],
                    marker = list(
                        symbol = symbol_style,
                        radius = point.size
                    )
                )
        }
    }

    ## 16. Tooltip
    if (x_offset > 0 || y_offset > 0) {
        tooltip_formatter <- htmlwidgets::JS(sprintf(
            "function() {
                var name  = this.series.name;
                var x_val = this.x - %f;
                var y_axis = (this.series && this.series.userOptions &&
                              this.series.userOptions.yAxis != null)
                             ? this.series.userOptions.yAxis : 0;
                var y_off = (y_axis === 0) ? %f : 0;
                var y_val = this.y - y_off;
                var x_str = Math.abs(x_val) < 1e-10 ? '0' : x_val.toString();
                var y_str = Math.abs(y_val) < 1e-10 ? '0' : y_val.toString();
                return '%s: <b>' + name + '</b><br/>%s: ' + x_str + '<br/>%s: ' + y_str;
            }",
            x_offset, y_offset,
            group.legend, xAxis.legend, yAxis.legend
        ))
        plot.object <- plot.object |>
            hc_tooltip(
                sort       = FALSE,
                split      = FALSE,
                crosshairs = TRUE,
                formatter  = tooltip_formatter
            )
    } else {
        plot.object <- plot.object |>
            hc_tooltip(
                sort        = FALSE,
                split       = FALSE,
                crosshairs  = TRUE,
                headerFormat = "",
                pointFormat  = sprintf(
                    "%s: <b>{point.series.name}</b><br>%s: {point.x}<br>%s: {point.y}",
                    group.legend, xAxis.legend, yAxis.legend
                )
            )
    }
    plot.object <- plot.object |>
        hc_plotOptions(
            series = list(
                dataLabels = list(enabled = point.dataLabels)
            )
        )

    ## 17. Print max absolute value (applied to data.lines only)
    if (print.max.abs && !is.null(data.lines)) {
        # data.lines$Y is already validated numeric above
        data_abs <- data.lines[, .SD[which.max(abs(Y))], by = ID]
        plot.object <- plot.object |>
            hc_annotations(
                list(
                    labels = lapply(seq_len(nrow(data_abs)), function(i) {
                        list(
                            point = list(
                                xAxis = 0, yAxis = 0,
                                x = data_abs$X[i], y = data_abs$Y[i]
                            ),
                            text = paste0("Max Abs: ", round(data_abs$Y[i], 2))
                        )
                    })
                )
            )
    }

    ## 18. Save if requested
    if (plot.save) {
        if (is.null(plot.filename)) {
            plot.filename <- "plot.html"
        }
        saveWidget(widget = plot.object, file = plot.filename)
    }

    return(plot.object)
}
