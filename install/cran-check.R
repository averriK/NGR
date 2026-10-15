local({
  source("../install/package.R", local = TRUE)
  Args <- .entryArguments("NGR", c("tarball", "output"))
  checkPackage(file = Args[["tarball"]], output = Args[["output"]])
})
