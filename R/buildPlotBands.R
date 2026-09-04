# Axis bands for buildPlot(): shaded Highcharts plotBands drawn behind the
# series. `spec` is either the semantic form list(cuts = , colors = ), where
# n strictly increasing cuts split the axis into n + 1 coloured regions, or a
# prebuilt list of plotBands entries passed through unchanged.
.buildAxisBands <- function(spec, isLog, name) {
    if (is.null(spec)) {
        return(NULL)
    }
    Usage <- sprintf(
        "buildPlot(): %s must be list(cuts = , colors = ) or a list of list(from = , to = , color = ) entries.",
        name
    )
    if (!is.list(spec) || !length(spec)) {
        stop(Usage, call. = FALSE)
    }

    if (is.null(spec[["cuts"]])) {
        Prebuilt <- is.null(names(spec)) && all(vapply(
            spec,
            function(Band) is.list(Band) && all(c("from", "to") %in% names(Band)),
            logical(1L)
        ))
        if (!Prebuilt) {
            stop(Usage, call. = FALSE)
        }
        for (Band in spec) {
            if (is.numeric(Band$from) && is.numeric(Band$to) && !isTRUE(Band$from < Band$to)) {
                stop(
                    sprintf("buildPlot(): %s entries must satisfy from < to.", name),
                    call. = FALSE
                )
            }
        }
        return(spec)
    }

    Cuts <- spec[["cuts"]]
    Colors <- spec[["colors"]]
    if (!is.numeric(Cuts) || !length(Cuts) || !all(is.finite(Cuts))) {
        stop(sprintf("buildPlot(): %s$cuts must be finite numbers.", name), call. = FALSE)
    }
    if (any(diff(Cuts) <= 0)) {
        stop(sprintf("buildPlot(): %s$cuts must be strictly increasing.", name), call. = FALSE)
    }
    if (!is.character(Colors) || length(Colors) != length(Cuts) + 1L || anyNA(Colors)) {
        stop(
            sprintf("buildPlot(): %s$colors must have length(cuts) + 1 entries.", name),
            call. = FALSE
        )
    }
    if (isLog && any(Cuts <= 0)) {
        stop(
            sprintf("buildPlot(): %s$cuts must be positive on a logarithmic axis.", name),
            call. = FALSE
        )
    }

    # The outer regions are open-ended: Highcharts clamps every band to the
    # axis extremes, so no band can invert (from >= to) whatever the plotted
    # range. The bound is a finite sentinel rather than Inf because jsonlite
    # serialises Inf as null and Highcharts 9.3 drops a vertical-axis band
    # whose bound is Infinity. 1e100 lies beyond any plotted range yet keeps
    # value x pixels-per-unit far from double overflow; a logarithmic axis
    # opens at 1e-100 because log10 of a non-positive bound is NaN.
    OPEN <- 1e100
    From <- c(if (isLog) 1 / OPEN else -OPEN, Cuts)
    To <- c(Cuts, OPEN)
    Map(
        function(from, to, color) list(from = from, to = to, color = color, zIndex = 0),
        From, To, Colors
    )
}
