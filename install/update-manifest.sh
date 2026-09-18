#!/usr/bin/env bash
# Regenerate install/manifest.json from the cli/ tree: every file under cli/
# is payload except README.md and tests/. Run after adding or removing a CLI
# file. Usage: bash install/update-manifest.sh
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
Rscript --vanilla - "$ROOT_DIR" <<'EOF'
Args <- commandArgs(TRUE)
if (!requireNamespace("jsonlite", quietly = TRUE)) stop("jsonlite is required")
Files <- list.files(file.path(Args[1L], "cli"), recursive = TRUE,
                    include.dirs = FALSE, no.. = TRUE, all.files = FALSE)
Files <- Files[Files != "README.md" & !startsWith(Files, "tests/")]
Requirements <- source(file.path(Args[1L], "install/requirements.R"), local = TRUE)$value
if (isTRUE(Requirements$launchers)) {
  Launchers <- paste0(Requirements$command, c("", ".cmd", ".ps1"))
  Files <- c(Files[!startsWith(Files, "bin/") & !Files %in% Launchers],
             file.path("bin", list.files(file.path(Args[1L], "install/launchers"))))
}
Files <- sort(Files, method = "radix")
jsonlite::write_json(list(manifest_version = 1L, files = Files),
                     file.path(Args[1L], "install", "manifest.json"),
                     auto_unbox = TRUE, pretty = TRUE)
message("install/manifest.json: ", length(Files), " files")
EOF
