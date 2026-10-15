local({
  source("../install/package.R", local = TRUE)
  .entryArguments("NGR", character())
  dispatchRhub(path = ".")
})
