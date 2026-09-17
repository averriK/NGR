Args <- commandArgs(trailingOnly = TRUE)
Requirements <- source(Args[[1L]], local = TRUE)$value
Required <- sub("^requires NGR >= ", "", grep("^requires NGR >= ", readLines(Args[[2L]]), value = TRUE))
if (length(Required) != 1L) stop("The CLI VERSION file does not declare the required NGR version.", call. = FALSE)
if (!requireNamespace("NGR", quietly = TRUE)) {
  stop("NGR is required in the active R library; install it separately.", call. = FALSE)
}
if (utils::packageVersion("NGR") < Required) {
  stop("This CLI requires NGR >= ", Required, "; found ", utils::packageVersion("NGR"), " at ",
       find.package("NGR"), ". Update the R package separately before installing this CLI.", call. = FALSE)
}
Missing <- setdiff(Requirements$exports, getNamespaceExports("NGR"))
if (length(Missing)) stop("NGR lacks exports: ", paste(Missing, collapse = ", "), call. = FALSE)
message("NGR ", utils::packageVersion("NGR"), " at ", find.package("NGR"))
