#!/usr/bin/env bash
# Family installer for macOS and Linux: detects R (R is never installed by
# this script), installs the checkout R package and installs
# the command and its launchers
# under the prefix through the receipt-keeping writer install/cli/manage.R.
#
# Usage:
#   sudo bash install/install.sh [--yes] [--check] [--prefix DIR]
#                                [--library DIR] [--dependency FILE ...]
#                                [--tarball FILE] [--component all|lib|cli]
#
# The prefix defaults to /usr/local, which needs sudo. The R library is always
# the invoking user's default R library (R_LIBS_USER), unless --library is set.
# R work always runs as the invoking user, never as
# root; only the prefix files are written as root. Without --tarball the
# package is always built from lib/. Nothing is written to a log file.
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
PREFIX=/usr/local
LIBRARY=""
TARBALL=""
DEPENDENCIES=()
COMPONENT=all
YES=0
CHECK=0
STAGES=5

show_usage() {
  sed -n '2,16p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//' >&2
}
info()  { printf '[INFO] %s\n' "$*"; }
ok()    { printf '[OK]   %s\n' "$*"; }
warn()  { printf '[WARN] %s\n' "$*" >&2; }
fail()  { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
stage() { printf '\n== Stage %s/%s: %s ==\n' "$1" "$STAGES" "$2"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) YES=1; shift ;;
    --check) CHECK=1; shift ;;
    --prefix) [[ $# -ge 2 ]] || fail "--prefix needs a directory"; PREFIX="$2"; shift 2 ;;
    --library) [[ $# -ge 2 ]] || fail "--library needs a directory"; LIBRARY="$2"; shift 2 ;;
    --dependency) [[ $# -ge 2 ]] || fail "--dependency needs an archive"; DEPENDENCIES+=("$2"); shift 2 ;;
    --tarball) [[ $# -ge 2 ]] || fail "--tarball needs a file"; TARBALL="$2"; shift 2 ;;
    --component) [[ $# -ge 2 ]] || fail "--component needs all, lib or cli"; COMPONENT="$2"; shift 2 ;;
    -h|--help) show_usage; exit 0 ;;
    *) show_usage; fail "Unknown option: $1" ;;
  esac
done
case "$COMPONENT" in all|lib|cli) ;; *) fail "Unknown component: $COMPONENT" ;; esac
[[ "$PREFIX" == /* ]] || PREFIX="$PWD/$PREFIX"
[[ -z "$TARBALL" || "$TARBALL" == /* ]] || TARBALL="$PWD/$TARBALL"
if [[ "$COMPONENT" == cli && ( -n "$TARBALL" || "${#DEPENDENCIES[@]}" -gt 0 ) ]]; then
  fail "--component cli cannot install R archives"
fi

# ---------------------------------------------------------------- stage 1
stage 1 "Requirements"

if [[ "$(id -u)" == 0 ]]; then
  [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != root ]] \
    || fail "Run this installer with sudo from your own account: R work must not run as root."
  USER_NAME="$SUDO_USER"
  [[ "${SUDO_UID:-}" =~ ^[0-9]+$ && "$SUDO_UID" != 0 && "$(id -u "$USER_NAME")" == "$SUDO_UID" ]] \
    || fail "SUDO_USER does not match the invoking SUDO_UID"
  r_environment=("PATH=$PATH")
  for name in R_LIBS R_LIBS_USER R_LIBS_SITE; do
    if value="$(printenv "$name")"; then r_environment+=("$name=$value"); fi
  done
  as_user() { sudo -n -H -u "$USER_NAME" -- env "${r_environment[@]}" "$@"; }
  ok "Running as root for $PREFIX; R work runs as $USER_NAME"
else
  USER_NAME="$(id -un)"
  as_user() { "$@"; }
  ok "Running as $USER_NAME"
fi

rscript_path="$(as_user bash -c 'command -v Rscript' || true)"
[[ -n "$rscript_path" ]] \
  || fail "R is not installed or Rscript is not on the PATH of $USER_NAME. Install R from https://cran.r-project.org/ and run this installer again."
[[ -x "$(dirname "$rscript_path")/R" ]] \
  || fail "R is not installed next to Rscript: $(dirname "$rscript_path")/R"
r_version="$(as_user "$rscript_path" --vanilla -e 'cat(R.version$major, R.version$minor, sep = ".")')"
r_minimum="$(grep -oE 'R \(>= [0-9.]+\)' "$ROOT_DIR/lib/DESCRIPTION" | head -1 | grep -oE '[0-9.]+' || true)"
if [[ -n "$r_minimum" ]]; then
  r_ok="$(as_user "$rscript_path" --vanilla -e "cat(as.character(utils::compareVersion('$r_version', '$r_minimum') >= 0))")"
  [[ "$r_ok" == TRUE ]] || fail "R $r_version is older than the required $r_minimum: $rscript_path"
fi
ok "R $r_version at $rscript_path"

if as_user bash -c 'command -v git' >/dev/null 2>&1; then
  ok "git found; the receipt records the source commit"
else
  warn "git not found; the receipt records the source as unknown"
fi
if ! as_user bash -c 'command -v pandoc' >/dev/null 2>&1; then
  warn "pandoc not found; documentation builds remain a separate maintenance operation"
fi

PACKAGE=""
COMMAND=""
RUNTIME=""
VERIFY=""
facts="$(as_user "$rscript_path" --vanilla -e '
Args <- commandArgs(TRUE)
Dcf <- read.dcf(file.path(Args[1L], "lib/DESCRIPTION"), fields = c("Package", "Version"))
cat(Dcf[1L, "Package"], Dcf[1L, "Version"], sep = "\n")
File <- file.path(Args[1L], "install/requirements.R")
if (file.exists(File)) {
  Cli <- source(File, local = TRUE)$value
  Field <- function(x) if (length(x)) x else ""
  cat(Field(Cli$command), Field(Cli$runtime),
      paste(Cli$tools, collapse = " "), paste(Cli$optional, collapse = " "),
      Field(Cli$verify), sep = "\n")
}' "$ROOT_DIR")"
PACKAGE="$(sed -n 1p <<<"$facts")"
source_version="$(sed -n 2p <<<"$facts")"
COMMAND="$(sed -n 3p <<<"$facts")"
RUNTIME="$(sed -n 4p <<<"$facts")"
TOOLS="$(sed -n 5p <<<"$facts")"
OPTIONAL="$(sed -n 6p <<<"$facts")"
VERIFY="$(sed -n 7p <<<"$facts")"
[[ -n "$RUNTIME" ]] || RUNTIME="$COMMAND"
[[ -n "$PACKAGE" && -n "$source_version" ]] || fail "lib/DESCRIPTION must identify Package and Version"
if [[ "$COMPONENT" != lib && -z "$COMMAND" ]]; then
  fail "This product has no implemented CLI (install/requirements.R); use --component lib"
fi
# TOOLS and OPTIONAL are space-separated requirement lists; word splitting is
# the declared intent here.
if [[ "$COMPONENT" != lib ]]; then
for tool in $TOOLS; do
  as_user bash -c "command -v \"$tool\"" >/dev/null 2>&1 \
    || fail "Required executable unavailable: $tool"
done
for tool in $OPTIONAL; do
  if ! as_user bash -c "command -v \"$tool\"" >/dev/null 2>&1; then
    warn "Optional tool not found: $tool"
  fi
done
fi

if [[ -z "$LIBRARY" ]]; then
  LIBRARY="$(as_user "$rscript_path" --vanilla -e 'cat(path.expand(Sys.getenv("R_LIBS_USER")))')"
  [[ -n "$LIBRARY" ]] || fail "R reports no user library for $USER_NAME; set R_LIBS_USER and retry"
fi
ok "R library: $LIBRARY"
# The selected library stays first; the user's existing chain stays visible.
r_libs="$LIBRARY${R_LIBS:+:$R_LIBS}"

printf '\n%s installation\n' "$PACKAGE"
printf 'Source:  %s\nPrefix:  %s\nLibrary: %s\nR user:  %s\n\n' \
  "$ROOT_DIR" "$PREFIX" "$LIBRARY" "$USER_NAME"
printf 'Component: %s\n' "$COMPONENT"
if [[ -n "$TARBALL" ]]; then printf 'Archive: %s\n' "$TARBALL"; fi

if [[ "$COMPONENT" != lib && -n "$COMMAND" ]]; then
  previous="$(as_user bash -c "command -v \"$COMMAND\"" || true)"
  if [[ -n "$previous" && "$previous" != "$PREFIX/bin/$COMMAND" ]]; then
    warn "a previous $COMMAND is first on PATH: $previous"
  fi
  for file in lib/DESCRIPTION install/requirements.R install/manifest.json \
              install/cli/manage.R install/installProduct.R install/package.R install/product.R; do
    [[ -f "$ROOT_DIR/$file" ]] || fail "Missing source file: $file"
  done
  ok "Payload complete: manifest, manager and launchers listed in install/manifest.json"
fi

# ---------------------------------------------------------------- stage 2
stage 2 "R package"

# Destination conflicts are checked before building or modifying the R library.
if [[ "$COMPONENT" != lib ]]; then
  check_action=check
  if [[ "$(id -u)" == 0 ]]; then check_action=inspect; fi
  as_user env R_LIBS="$r_libs" "$rscript_path" --vanilla "$ROOT_DIR/install/cli/manage.R" "$check_action" "$PREFIX"
fi
if [[ "$CHECK" == 1 ]]; then
  ok "Check passed; nothing was installed"
  exit 0
fi

installed_version=""
if [[ -n "$LIBRARY" ]]; then
  installed_version="$(as_user "$rscript_path" --vanilla -e '
Args <- commandArgs(TRUE)
if (dir.exists(file.path(Args[2L], Args[1L]))) cat(as.character(utils::packageVersion(Args[1L], lib.loc = Args[2L])))
' "$PACKAGE" "$LIBRARY")"
fi
if [[ -n "$installed_version" ]]; then
  info "Installed: $PACKAGE $installed_version in $LIBRARY"
else
  info "$PACKAGE is not installed in $LIBRARY"
fi
info "Source:    $PACKAGE $source_version"

receipt="$PREFIX/libexec/$RUNTIME/install.json"
replace=false
if [[ "$COMPONENT" != cli && -n "$installed_version" ]]; then replace=true; fi
if [[ "$COMPONENT" != lib && -f "$receipt" ]]; then
  replace=true
  info "Existing $PACKAGE CLI recorded at $receipt; it will be replaced through its receipt"
fi
if [[ "$COMPONENT" == cli && -z "$installed_version" ]]; then
  fail "--component cli needs $PACKAGE installed in $LIBRARY"
fi
if [[ -n "$TARBALL" && ( ! -f "$TARBALL" || ! -f "$TARBALL.rds" ) ]]; then
  fail "Package archive and its .rds record are required: $TARBALL"
fi
if [[ "$COMPONENT" != lib && "$(id -u)" != 0 ]]; then
  parent="$PREFIX"
  while [[ ! -e "$parent" && "$parent" != / ]]; do parent="${parent%/*}"; done
  [[ -w "$parent" ]] || fail "$PREFIX is not writable by $USER_NAME; run: sudo bash install/install.sh"
fi
if [[ "$replace" == true && "$YES" -ne 1 ]]; then
  printf 'Replace %s (component: %s) at the destinations shown above? [y/N] ' "$PACKAGE" "$COMPONENT" >&2
  if ! IFS= read -r confirm; then fail "End of input while confirming replacement; nothing was installed. Use --yes for unattended installation."; fi
  case "$confirm" in [yY]) ;; *) printf 'Aborted by user.\n'; exit 0 ;; esac
fi

# The product installer (install/installProduct.R) owns every R-side check and
# installation: artifact identity, dependencies, CLI tools and packages,
# exports, library shadowing. This script sequences it and, under sudo, does
# the privileged prefix writes itself through install/cli/publish.sh.
kit=("$rscript_path" --vanilla "$ROOT_DIR/install/installProduct.R")
if [[ "$(id -u)" == 0 ]]; then kit+=(--system-cli); fi
kit+=("$ROOT_DIR")
for archive in "${DEPENDENCIES[@]+"${DEPENDENCIES[@]}"}"; do kit+=(--dependency "$archive"); done
if [[ "$COMPONENT" == cli ]]; then
  ok "Library stage skipped (--component cli)"
else
  if [[ -n "$TARBALL" ]]; then
    kit+=(--tarball "$TARBALL")
  else
    build_dir="$(as_user mktemp -d "${TMPDIR:-/tmp}/$PACKAGE-build.XXXXXX")"
    trap 'as_user rm -rf -- "$build_dir"' EXIT
    info "Building $PACKAGE $source_version into $build_dir after dependency checks"
    kit+=(--build "$build_dir")
  fi
fi
kit+=(--component "$COMPONENT" --library "$LIBRARY")
if [[ "$COMPONENT" != lib ]]; then kit+=(--prefix "$PREFIX"); fi

info "Product installer as $USER_NAME: $(printf '%q ' "${kit[@]:3}")"
as_user "${kit[@]}"
if [[ "$COMPONENT" != cli ]]; then
  installed_version="$(as_user "$rscript_path" --vanilla -e 'Args <- commandArgs(TRUE); cat(as.character(utils::packageVersion(Args[1L], lib.loc = Args[2L])))' "$PACKAGE" "$LIBRARY")"
  ok "$PACKAGE $installed_version installed in $LIBRARY"
fi

# ---------------------------------------------------------------- stage 3
stage 3 "Command-line interface"

if [[ "$COMPONENT" == lib ]]; then
  ok "CLI stage skipped (--component lib)"
else
  if [[ "$(id -u)" == 0 ]]; then
    info "Preparing as $USER_NAME; Bash publishes under $PREFIX"
    (
      stage_dir="$(as_user mktemp -d "${TMPDIR:-/tmp}/$PACKAGE-cli.XXXXXX")"
      trap 'as_user rm -rf -- "$stage_dir"' EXIT
      as_user env R_LIBS="$r_libs" "$rscript_path" --vanilla "$ROOT_DIR/install/cli/manage.R" install "$PREFIX" "$stage_dir"
      source "$ROOT_DIR/install/cli/publish.sh"
      publish_cli "$stage_dir" "$PREFIX" "$COMMAND" "$RUNTIME" install "$VERIFY"
    )
  else
    info "The product installer wrote the CLI under $PREFIX as $USER_NAME"
  fi
  as_user env R_LIBS="$r_libs" "$rscript_path" --vanilla -e \
    'R <- jsonlite::read_json(commandArgs(TRUE)[1L], simplifyVector = TRUE)
     cat(file.path(commandArgs(TRUE)[2L], R$file), sep = "\n")' \
    "$receipt" "$PREFIX" | while IFS= read -r file; do
    [[ -f "$file" ]] || fail "Expected installed file is missing: $file"
    printf '  - %s\n' "$file"
  done
  ok "$COMMAND CLI installed under $PREFIX"
fi

# ---------------------------------------------------------------- stage 4
stage 4 "Verification"

if [[ "$COMPONENT" == lib ]]; then
  as_user "$rscript_path" --vanilla -e \
    'Args <- commandArgs(TRUE); invisible(loadNamespace(Args[1L], lib.loc = Args[2L])); message(Args[1L], " loads from ", find.package(Args[1L], lib.loc = Args[2L]))' "$PACKAGE" "$LIBRARY"
  ok "Package loads"
else
  ok "$COMMAND verification passed before committing the CLI transaction"
  case ":$PATH:" in
    *":$PREFIX/bin:"*) ok "$PREFIX/bin is on PATH" ;;
    *) warn "$PREFIX/bin is not on PATH; add: export PATH=\"$PREFIX/bin:\$PATH\"" ;;
  esac
  default_library="$(as_user "$rscript_path" --vanilla -e 'cat(path.expand(Sys.getenv("R_LIBS_USER")))')"
  if [[ "$LIBRARY" != "$default_library" ]]; then
    warn "$LIBRARY is not the default R user library; keep R_LIBS=\"$LIBRARY\" in the shell that runs $COMMAND"
  fi
fi

# ---------------------------------------------------------------- stage 5
stage 5 "Summary"
ok "$PACKAGE $installed_version in $LIBRARY"
if [[ "$COMPONENT" != lib ]]; then
  ok "$PREFIX/bin/$COMMAND, receipt $receipt"
fi
printf '\n'
if [[ "$COMPONENT" != lib ]]; then
  printf 'Usage: %s --help, %s --version\n' "$COMMAND" "$COMMAND"
  printf 'Remove the CLI: bash install/uninstall.sh [--prefix DIR]\n'
fi
printf 'The R package is separate: Rscript -e '"'"'remove.packages("%s")'"'"'\n' "$PACKAGE"
