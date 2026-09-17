local({
  source("../install/package.R", local = TRUE)
  Args <- .entryArguments("NGR", "library")
  installRequirements(
    path = ".", library = Args[["library"]], dependencies = TRUE,
    packages = c("roxygen2", "pkgbuild", "rcmdcheck", "spelling", "pkgdown", "rhub", "digest", "testthat")
  )
  message("Maintenance dependencies prepared in ", Args[["library"]],
          ". Make this library visible in subsequent R sessions.")
})
