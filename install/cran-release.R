## CRAN release runbook. This file has no executable actions. Run the scripts
## below from the lib/ directory of the module; they load install/package.R.
##
## 1. Document with documentPackage(path = ".", roxygen = TRUE) from
##    install/package.R and review the source changes and tests.
## 2. Commit the intended source candidate through normal Git work on dev and
##    publish main with it; CI runs there.
## 3. Build once: Rscript ../install/build.R OUTPUT_DIR. Keep the tarball and
##    its adjacent .rds record.
## 4. Check that exact tarball: Rscript ../install/cran-check.R TARBALL CHECK_DIR
##    (--as-cran, donttest, CRAN incoming checks). Review every NOTE.
## 5. Review the package against current CRAN guidance; the approved cran
##    skill consumes these artifacts. A green local check is not that review.
## 6. In interactive R from lib/, source("../install/rhub-check.R") to dispatch
##    R-hub on the published main; it refuses a branch that differs from its
##    remote. Verify the run results separately and keep their identities.
## 7. Submit from main, clean and equal to its upstream, in interactive R from
##    lib/: source("../install/cran-submit.R"), which calls
##    devtools::submit_cran(pkg = ".") and asks you to confirm CRAN's email.
## 8. Keep the submission receipt (lib/CRAN-SUBMISSION). An uncertain upload is
##    not permission to retry.
##
## Do not reuse evidence after changing the source candidate or the tarball.
## Installation is separate: sudo bash install/install.sh from the module root.
