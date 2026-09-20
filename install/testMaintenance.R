# Focused maintenance tests. Run from lib/; all writes stay in a temporary tree.
local({
  source("../install/package.R", local = TRUE)
  Package <- .packageInfo(".")
  Scripts <- normalizePath("../install", winslash = "/", mustWork = TRUE)
  DIR <- tempfile("maintenance-ü-")
  dir.create(DIR)
  on.exit(unlink(DIR, recursive = TRUE), add = TRUE)
  WD <- getwd()
  on.exit(setwd(WD), add = TRUE, after = FALSE)
  Libraries <- .libPaths()
  Root <- file.path(DIR, "repository with space")
  dir.create(file.path(Root, "lib", "R"), recursive = TRUE)
  dir.create(file.path(Root, "install"), recursive = TRUE)
  FILES <- list.files(Scripts, pattern = "[.]R$", full.names = TRUE)
  stopifnot(all(file.copy(FILES, file.path(Root, "install"))))
  writeLines(c(
    paste0("Package: ", Package$package), "Version: 0.0.1",
    "Title: Exercise Package Maintenance Boundaries",
    "Description: Provides a small local fixture to exercise maintenance boundaries.",
    "Authors@R: person('Fixture', 'Maintainer', email = 'fixture@example.org', role = c('aut', 'cre'))",
    "License: MIT + file LICENSE", "Encoding: UTF-8"
  ), file.path(Root, "lib", "DESCRIPTION"))
  writeLines("", file.path(Root, "lib", "NAMESPACE"))
  writeLines(c("YEAR: 2026", "COPYRIGHT HOLDER: Fixture Maintainer"),
             file.path(Root, "lib", "LICENSE"))
  setwd(file.path(Root, "lib"))

  runEntry <- function(script, args, status, pattern) {
    OUT <- suppressWarnings(system2(
      file.path(R.home("bin"), "Rscript"),
      shQuote(c(file.path("../install", script), args)), stdout = TRUE, stderr = TRUE
    ))
    n <- attr(OUT, "status")
    if (is.null(n)) n <- 0L
    stopifnot(identical(n, status), any(grepl(pattern, OUT, fixed = TRUE)))
    invisible(OUT)
  }
  expectFailure <- function(expr, pattern) {
    OUT <- tryCatch(force(expr), error = identity)
    stopifnot(inherits(OUT, "error"), grepl(pattern, conditionMessage(OUT), fixed = TRUE))
  }

  for (File in c("setup.R", "build.R", "cran-check.R", "install.R")) {
    runEntry(script = File, args = character(), status = 1L, pattern = "Required arguments:")
  }
  runEntry(script = "rhub-check.R", args = character(), status = 1L,
           pattern = "interactive session")
  runEntry(script = "build.R", args = "../build with space", status = 0L, pattern = "SHA-256:")
  Artifact <- normalizePath(file.path("../build with space", paste0(Package$package, "_0.0.1.tar.gz")))
  runEntry(script = "build.R", args = "../build with space", status = 1L, pattern = "already exists")
  message("PASS: actual Rscript entries, required arguments, dispatch guard and build collision")

  local({
    testthat::local_mocked_bindings(
      roxygenise = function(...) stop("fixture roxygen invoked"), .package = "roxygen2"
    )
    testthat::local_mocked_bindings(
      spell_check_package = function(...) data.frame(), .package = "spelling"
    )
    documentPackage(path = ".", roxygen = FALSE)
    expectFailure(documentPackage(path = ".", roxygen = TRUE), "fixture roxygen invoked")
  })
  message("PASS: hand-authored documentation skips roxygen; generated documentation invokes it")

  local({
    Calls <- new.env(parent = emptyenv())
    Calls$results <- list(
      "status --porcelain" = character(), "branch --show-current" = "main",
      "rev-parse HEAD" = "candidate", "config --get branch.main.remote" = "origin",
      "config --get branch.main.merge" = "refs/heads/main",
      "ls-remote --exit-code origin refs/heads/main" = "different\trefs/heads/main"
    )
    Check <- .releaseSource
    environment(Check) <- list2env(list(
      .packageInfo = .packageInfo,
      .gitOutput = function(path, args) {
        x <- paste(args, collapse = " ")
        stopifnot(x %in% names(Calls$results))
        Calls$results[[x]]
      }
    ), parent = baseenv())
    expectFailure(Check("."), "does not match its live remote")
    Calls$results[["ls-remote --exit-code origin refs/heads/main"]] <- "candidate\trefs/heads/main"
    stopifnot(identical(Check(".")$commit, "candidate"))
    Calls$results[["status --porcelain"]] <- " M source"
    expectFailure(Check("."), "clean working tree")
    Calls$results[["status --porcelain"]] <- character()
    Calls$results[["branch --show-current"]] <- ""
    expectFailure(Check("."), "named branch")
  })
  message("PASS: live remote mismatch, dirty tree and detached branch refuse release dispatch")

  # A failed checker must leave a failed record, and an interrupted checker
  # must never inherit a previous successful result.
  local({
    testthat::local_mocked_bindings(
      rcmdcheck = function(...) list(
        stdout = "fixture failure", stderr = "diagnostic", status = 1L,
        errors = "fixture error", warnings = character(), notes = character(),
        rversion = R.version.string, platform = R.version$platform
      ), .package = "rcmdcheck"
    )
    expectFailure(checkPackage(file = Artifact, output = "../failed check"), "Package check failed")
    stopifnot(identical(.readArtifact(Artifact)$check$status, "failed"),
              file.exists("../failed check/stderr.log"))
  })
  local({
    testthat::local_mocked_bindings(
      rcmdcheck = function(...) stop("fixture interruption"), .package = "rcmdcheck"
    )
    expectFailure(checkPackage(file = Artifact, output = "../interrupted check"), "fixture interruption")
    stopifnot(identical(.readArtifact(Artifact)$check$status, "running"))
  })
  message("PASS: failed and interrupted checks cannot retain a passed verdict")

  installRequirements(path = ".", library = "../R library", packages = character(), dependencies = NA)
  stopifnot(identical(.libPaths(), Libraries))
  message("PASS: native dependency preparation restores library resolution; dependency failures are covered by cli/testDependencies.R")

  write("tampered", file = Artifact, append = TRUE)
  runEntry(script = "cran-check.R", args = c(Artifact, "../forbidden check"),
           status = 1L, pattern = "SHA-256")
  runEntry(script = "install.R", args = c(Artifact, "../forbidden library"),
           status = 1L, pattern = "SHA-256")
  stopifnot(!file.exists("../forbidden check"), !file.exists("../forbidden library"))
  message("PASS: altered artifacts fail through both real entries before destination creation")
})
