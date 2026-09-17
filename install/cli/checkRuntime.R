Requirements <- source(commandArgs(trailingOnly = TRUE)[[1L]], local = TRUE)$value
if (!requireNamespace("NGR", quietly = TRUE)) {
  stop("NGR is required in the active R library; install it separately.", call. = FALSE)
}
Missing <- setdiff(Requirements$exports, getNamespaceExports("NGR"))
if (length(Missing)) stop("NGR lacks exports: ", paste(Missing, collapse = ", "), call. = FALSE)
if (!is.function(get0(".cliNgr", envir = asNamespace("NGR"), inherits = FALSE))) {
  stop("NGR lacks the CLI entry point.", call. = FALSE)
}
if (!identical(formals(NGR::quartoRender)$manifest, "manifest.json")) {
  stop("NGR uses an incompatible project manifest; update the R package separately before installing this CLI.", call. = FALSE)
}
message("NGR ", utils::packageVersion("NGR"), " at ", find.package("NGR"))
