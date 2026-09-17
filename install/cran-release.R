## CRAN release runbook. This file has no executable actions.
## See MAINTENANCE.md in this directory for commands, arguments and effects.
##
## 1. Prepare development requirements with setup.R in an explicit R library.
## 2. Generate documentation with document.R, review source changes and tests.
## 3. Identify and commit the intended source candidate through normal Git work.
## 4. Build once with build.R, then check that tarball with cran-check.R.
##    Retain its adjacent RDS record and complete check logs. Review every NOTE.
## 5. Review the package contextually against current CRAN guidance; the approved
##    cran skill can consume these artifacts. A green local check is not that audit.
## 6. Publish the accepted branch explicitly. Verify CI and public Pages for that
##    commit. In interactive R, source rhub-check.R to dispatch remote checks;
##    verify their results separately and retain the run identities.
## 7. Submit the exact accepted tarball only after its upload interface is agreed.
##    The legacy cran-submit.R rebuilds and is outside this exact-artifact flow.
##    Submission migration is pending; this revision adds no upload operation.
## 8. Retain the submission receipt. An uncertain upload is not permission to retry.
##
## Do not reuse evidence after changing the source candidate or tarball. Installation
## is separate: install.R receives the tarball and an explicit destination library.
