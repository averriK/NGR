local({
  source("../install/package.R", local = TRUE)
  Args <- .entryArguments("NGR", "output")
  buildPackage(path = ".", output = Args[["output"]])
})
