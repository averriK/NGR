local({
  source("../install/package.R", local = TRUE)
  Args <- .entryArguments("NGR", c("tarball", "library"))
  installPackage(file = Args[["tarball"]], library = Args[["library"]])
})
