## Guarded interactive CRAN submission of the package under lib/. Run from any
## directory: source("install/cran-submit.R") after main, CI, R-hub and the
## public pkgdown site are verified.

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
  if (!interactive()) {
    stop("CRAN submission must run in an interactive R session", call. = FALSE)
  }
  Package <- .packageInfo(".")

  .gitOutput <- function(args) {
    OUT <- system2("git", args = args, stdout = TRUE, stderr = TRUE)
    Status <- attr(OUT, "status")
    if (!is.null(Status) && Status != 0L) {
      stop("Git command failed: git ", paste(args, collapse = " "), "\n",
           paste(OUT, collapse = "\n"), call. = FALSE)
    }
    OUT
  }

  Branch <- .gitOutput(c("branch", "--show-current"))
  if (!identical(Branch, "main")) {
    stop("CRAN submission of ", Package$package, " must run from main", call. = FALSE)
  }

  Status <- .gitOutput(c("status", "--porcelain"))
  if (length(Status) > 0L) {
    stop("CRAN submission requires a clean working tree", call. = FALSE)
  }

  Head <- .gitOutput(c("rev-parse", "HEAD"))
  Upstream <- .gitOutput(c("rev-parse", "@{u}"))
  if (!identical(Head, Upstream)) {
    stop("main must match its configured upstream before submission",
         call. = FALSE)
  }

  message("Submitting ", Package$package, " ", Package$version, " from main ", substr(Head, 1L, 7L))
  devtools::submit_cran(pkg = ".")
})

## Follow the link in the CRAN email and confirm the submission.
