## Rscript install/build.R OUTPUT_DIR, from the module root: builds lib/ into OUTPUT_DIR with its .rds record.
source("install/package.R")
buildPackage(path = "lib", output = commandArgs(TRUE)[1L], documents = FALSE)
