## Guarded interactive CRAN submission of the package under lib/.
## Run only after main, CI, R-hub and the public pkgdown site are verified.

local({
  if (!interactive()) {
    stop("CRAN submission must run in an interactive R session", call. = FALSE)
  }
  if (!file.exists("DESCRIPTION")) {
    stop("Run ../install/cran-submit.R from the package root (lib/)", call. = FALSE)
  }
  Package <- unname(read.dcf("DESCRIPTION", fields = "Package")[1L, "Package"])

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
    stop("CRAN submission of ", Package, " must run from main", call. = FALSE)
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

  message("Submitting ", Package, " from main ", substr(Head, 1L, 7L))
  devtools::submit_cran(pkg = ".")
})

## Follow the link in the CRAN email and confirm the submission.
