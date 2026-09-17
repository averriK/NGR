local({
  source("../install/package.R", local = TRUE)
  .entryArguments("NGR", character())
  documentPackage(path = ".", roxygen = TRUE)
})
