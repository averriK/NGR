local({
  source("../install/package.R", local = TRUE)
  Package <- .packageInfo(".")
  Args <- .entryArguments(Package$package, c("tarball", "output"))
  checkPackage(file = Args[["tarball"]], output = Args[["output"]])
})
