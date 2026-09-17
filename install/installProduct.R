local({
  Args <- commandArgs(trailingOnly = TRUE)
  System <- length(Args) > 0L && identical(Args[1L], "--system-cli")
  if (System) Args <- Args[-1L]
  if (!length(Args)) stop("Repository root is required", call. = FALSE)
  Root <- normalizePath(Args[1L], mustWork = TRUE)
  source(file.path(Root, "install/package.R"), local = TRUE)
  source(file.path(Root, "install/product.R"), local = TRUE)
  installProduct(root = Root, args = Args[-1L], system = System)
})
