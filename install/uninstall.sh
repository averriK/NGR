#!/usr/bin/env bash
# Remove the command installed under a prefix through its ownership receipt.
# The R package, its dependencies and R itself are left in place.
#
# Usage: [sudo] bash install/uninstall.sh [--yes] [--prefix DIR]
#
# The receipt is read with the jsonlite of the invoking user's default R
# library (R_LIBS_USER), resolved by R itself; it is never an argument.
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
    -h|--help) sed -n '2,8p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//' >&2; exit 0 ;;
    *) fail "Unknown option: $1" ;;
  esac
done
[[ "$PREFIX" == /* ]] || PREFIX="$PWD/$PREFIX"

if [[ "$(id -u)" == 0 ]]; then
  [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != root ]] \
    || fail "Run this uninstaller with sudo from your own account."
  USER_NAME="$SUDO_USER"
  as_user() { sudo -n -H -u "$USER_NAME" -- env PATH="$PATH" "$@"; }
else
  USER_NAME="$(id -un)"
  as_user() { "$@"; }
fi
rscript_path="$(as_user bash -c 'command -v Rscript' || true)"
[[ -n "$rscript_path" ]] \
  || fail "Rscript is not on the PATH of $USER_NAME; the receipt cannot be read."
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
env R_LIBS="$r_libs" "$rscript_path" --vanilla "$ROOT_DIR/install/cli/manage.R" uninstall "$PREFIX"
ok "$COMMAND CLI removed from $PREFIX"
remaining="$(as_user bash -c "command -v \"$COMMAND\"" || true)"
if [[ -n "$remaining" ]]; then
  warn "$COMMAND is still first on PATH: $remaining"
fi
printf 'The R package in %s is untouched. To remove it: Rscript -e '"'"'remove.packages("%s")'"'"'\n' \
  "$LIBRARY" "$PACKAGE"
