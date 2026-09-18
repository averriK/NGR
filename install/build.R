local({
  source("../install/package.R", local = TRUE)
  Package <- .packageInfo(".")
  Args <- .entryArguments(Package$package, "output")
  buildPackage(path = ".", output = Args[["output"]])
})
