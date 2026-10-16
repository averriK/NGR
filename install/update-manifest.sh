#!/usr/bin/env bash
# Refresh CLI entries; preserve the manifest's explicit non-CLI resources.
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "$ROOT_DIR/install/cli/r.sh"
rscript_path="$(resolve_rscript)"
"$rscript_path" --vanilla - "$ROOT_DIR" <<'EOF'
Args <- commandArgs(TRUE)
if (!requireNamespace("jsonlite", quietly = TRUE)) stop("jsonlite is required")
Files <- list.files(file.path(Args[1L], "cli"), recursive = TRUE,
                    include.dirs = FALSE, no.. = TRUE, all.files = FALSE)
Files <- Files[Files != "README.md" & !startsWith(Files, "tests/")]
Requirements <- source(file.path(Args[1L], "install/requirements.R"), local = TRUE)$value
Launchers <- paste0(Requirements$command, c("", ".cmd", ".ps1"))
Files <- c(Files[!startsWith(Files, "bin/") & !Files %in% Launchers], file.path("bin", Launchers))
Files <- sort(Files, method = "radix")
source(file.path(Args[1L], "install/cli/manifest.R"), local = TRUE)
Manifest <- .readManifest(file.path(Args[1L], "install/manifest.json"), Requirements$command)
if (Manifest$manifest_version == 1L) Manifest$files <- list()
Manifest$files <- Filter(function(x) !startsWith(x$source, "cli/") &&
                          !any(x$installed %in% file.path("bin", Launchers)), Manifest$files)
if (Manifest$manifest_version == 2L) {
  Manifest$files <- c(lapply(Files, function(path) {
    Source <- paste0("cli/", path)
    if (path %in% file.path("bin", Launchers)) Source <- paste0("install/cli/command", c(".sh", ".cmd", ".ps1")[match(basename(path), Launchers)])
    list(origin = "product", source = Source, installed = path, kind = "runtime",
         mode = if (identical(path, file.path("bin", Requirements$command))) "0755" else "0644")
  }), Manifest$files)
}
if (Manifest$manifest_version == 1L) Manifest$files <- as.list(Files)
jsonlite::write_json(Manifest,
                     file.path(Args[1L], "install", "manifest.json"),
                     auto_unbox = TRUE, pretty = TRUE)
message("install/manifest.json: ", length(Files), " files")
EOF
