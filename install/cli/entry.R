local({
  File <- grep("^--file=", commandArgs(), value = TRUE)
  if (length(File) != 1L) stop("Run the installed command through its launcher")
  File <- gsub("~+~", " ", sub("^--file=", "", File), fixed = TRUE)
  CLI_RESOURCES <- normalizePath(file.path(dirname(File), "../.."), winslash = "/", mustWork = TRUE)
  Record <- jsonlite::read_json(file.path(CLI_RESOURCES, "install.json"))
  if (!is.null(Record$binding)) {
    Helper <- Filter(function(x) identical(x$installed, "install/cli/manifest.R"), Record$resources)
    if (length(Helper) != 1L || !identical(digest::digest(file = file.path(CLI_RESOURCES, "install/cli/manifest.R"), algo = "sha256"), Helper[[1L]]$sha256)) stop("Installed manifest reader hash mismatch")
    source(file.path(CLI_RESOURCES, "install/cli/manifest.R"), local = TRUE)
    Record <- .verifyResources(CLI_RESOURCES)
    .libPaths(c(Record$package$library, .libPaths()))
    loadNamespace(Record$package$name, lib.loc = Record$package$library)
  }
  source(file.path(CLI_RESOURCES, "main.R"), local = TRUE)
})
