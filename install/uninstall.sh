#!/usr/bin/env bash
# Remove the command installed under a prefix through its ownership receipt.
# The R package, its dependencies and R itself are left in place.
#
# Usage: [sudo] bash install/uninstall.sh [--yes] [--prefix DIR] [--library DIR]
#
# The receipt is read with the jsonlite of the invoking user's default R
# library (R_LIBS_USER), unless --library is supplied.
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
PREFIX=/usr/local
LIBRARY=""
YES=0

info()  { printf '[INFO] %s\n' "$*"; }
ok()    { printf '[OK]   %s\n' "$*"; }
warn()  { printf '[WARN] %s\n' "$*" >&2; }
fail()  { printf '[ERROR] %s\n' "$*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) YES=1; shift ;;
    --prefix) [[ $# -ge 2 ]] || fail "--prefix needs a directory"; PREFIX="$2"; shift 2 ;;
    --library) [[ $# -ge 2 ]] || fail "--library needs a directory"; LIBRARY="$2"; shift 2 ;;
    -h|--help) sed -n '2,8p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//' >&2; exit 0 ;;
    *) fail "Unknown option: $1" ;;
  esac
done
[[ "$PREFIX" == /* ]] || PREFIX="$PWD/$PREFIX"

if [[ "$(id -u)" == 0 ]]; then
  [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != root ]] \
    || fail "Run this uninstaller with sudo from your own account."
  USER_NAME="$SUDO_USER"
  [[ "${SUDO_UID:-}" =~ ^[0-9]+$ && "$SUDO_UID" != 0 && "$(id -u "$USER_NAME")" == "$SUDO_UID" ]] \
    || fail "SUDO_USER does not match the invoking SUDO_UID"
  r_environment=("PATH=$PATH")
  for name in R_LIBS R_LIBS_USER R_LIBS_SITE; do
    if value="$(printenv "$name")"; then r_environment+=("$name=$value"); fi
  done
  as_user() { sudo -n -H -u "$USER_NAME" -- env "${r_environment[@]}" "$@"; }
else
  USER_NAME="$(id -un)"
  as_user() { "$@"; }
fi
source "$ROOT_DIR/install/cli/r.sh"
rscript_path="$(resolve_rscript)"
if [[ -z "$LIBRARY" ]]; then
  LIBRARY="$(as_user "$rscript_path" --vanilla -e 'cat(path.expand(Sys.getenv("R_LIBS_USER")))')"
  [[ -n "$LIBRARY" ]] || fail "R reports no user library (R_LIBS_USER) for $USER_NAME"
fi
# The selected library stays first; the user's existing chain stays visible.
r_libs="$LIBRARY${R_LIBS:+:$R_LIBS}"
facts="$(as_user "$rscript_path" --vanilla -e '
Args <- commandArgs(TRUE)
Dcf <- read.dcf(file.path(Args[1L], "lib/DESCRIPTION"), fields = "Package")
Cli <- source(file.path(Args[1L], "install/requirements.R"), local = TRUE)$value
cat(Dcf[1L, "Package"], Cli$command, sep = "\n")
Field <- if (length(Cli$runtime)) Cli$runtime else Cli$command
cat(Field, "\n", sep = "")' "$ROOT_DIR")"
PACKAGE="$(sed -n 1p <<<"$facts")"
COMMAND="$(sed -n 2p <<<"$facts")"
RUNTIME="$(sed -n 3p <<<"$facts")"
[[ -n "$RUNTIME" ]] || RUNTIME="$COMMAND"

receipt="$PREFIX/libexec/$RUNTIME/install.json"
[[ -f "$receipt" ]] \
  || fail "No installation receipt at $receipt; existing paths cannot be attributed to $PACKAGE."
info "$PACKAGE CLI recorded at $receipt"
if [[ "$YES" -ne 1 ]]; then
  read -r -p "Remove the $COMMAND CLI under $PREFIX? [y/N] " confirm
  case "$confirm" in [yY]) ;; *) printf 'Aborted by user.\n'; exit 0 ;; esac
fi
if [[ "$(id -u)" != 0 ]]; then
  parent="$PREFIX"
  while [[ ! -e "$parent" && "$parent" != / ]]; do parent="${parent%/*}"; done
  [[ -w "$parent" ]] || fail "$PREFIX is not writable by $USER_NAME; run: sudo bash install/uninstall.sh"
fi
if [[ "$(id -u)" == 0 ]]; then
  stage_dir="$(as_user mktemp -d "${TMPDIR:-/tmp}/$PACKAGE-cli.XXXXXX")"
  trap 'as_user rm -rf -- "$stage_dir"' EXIT
  as_user env R_LIBS="$r_libs" "$rscript_path" --vanilla "$ROOT_DIR/install/cli/manage.R" uninstall "$PREFIX" "$stage_dir"
  source "$ROOT_DIR/install/cli/publish.sh"
  publish_cli "$stage_dir" "$PREFIX" "$COMMAND" "$RUNTIME" uninstall "$rscript_path"
else
  as_user env R_LIBS="$r_libs" "$rscript_path" --vanilla "$ROOT_DIR/install/cli/manage.R" uninstall "$PREFIX"
fi
ok "$COMMAND CLI removed from $PREFIX"
remaining="$(as_user bash -c "command -v \"$COMMAND\"" || true)"
if [[ -n "$remaining" ]]; then
  warn "$COMMAND is still first on PATH: $remaining"
fi
