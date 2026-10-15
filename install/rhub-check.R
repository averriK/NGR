local({
  source("../install/package.R", local = TRUE)
  Package <- .packageInfo(".")
  .entryArguments(Package$package, character())
  dispatchRhub(path = ".")
})
