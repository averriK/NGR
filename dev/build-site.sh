#!/usr/bin/env bash
set -euo pipefail
repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd -- "$repo_dir"
export BUNDLE_GEMFILE="$repo_dir/docs/Gemfile"
bundle exec jekyll build --source docs --destination _site
Rscript dev/buildSite.R
