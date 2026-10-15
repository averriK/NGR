local({
  # The script locates itself, under Rscript (--file=) or source() (ofile),
  # and works from the module's lib/ whatever the caller's directory.
  File <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
  if (!length(File)) File <- unlist(lapply(seq_len(sys.nframe()), function(i) sys.frame(i)$ofile))
  if (!length(File)) stop("Run this script with Rscript or source()", call. = FALSE)
  Here <- dirname(normalizePath(gsub("~+~", " ", File[[1L]], fixed = TRUE), winslash = "/", mustWork = TRUE))
  WD <- setwd(file.path(dirname(Here), "lib"))
  on.exit(setwd(WD), add = TRUE)
  source(file.path(Here, "package.R"), local = TRUE)
  Package <- .packageInfo(".")
  Args <- .entryArguments(Package$package, "output")
  buildPackage(path = ".", output = Args[["output"]])
})
