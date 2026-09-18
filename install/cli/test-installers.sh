#!/usr/bin/env bash
# Common regressions use a disposable fixture. An optional library enables the
# enclosing product's installed-interface check without replacing that package.
set -euo pipefail
root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
Rscript --vanilla "$root_dir/install/cli/testManager.R" "$root_dir"
Rscript --vanilla "$root_dir/install/cli/testManager.R" "$root_dir" --native
Rscript --vanilla "$root_dir/install/cli/testWrapper.R" "$root_dir/install"
if [[ $# -gt 0 ]]; then Rscript --vanilla "$root_dir/install/cli/testProduct.R" "$root_dir" "$1"; fi
