#!/usr/bin/env bash
set -euo pipefail
bin_dir="$(cd -- "${BASH_SOURCE[0]%/*}" && pwd -P)"
runtime_dir="$(cd -- "$bin_dir/../libexec/@RUNTIME@" && pwd -P)"
source "$runtime_dir/install/cli/r.sh"
rscript_path="$(resolve_rscript)"
@PATH_EXPORT@
exec "$rscript_path" "$runtime_dir/main.R" "$@"
