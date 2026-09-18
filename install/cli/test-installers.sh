#!/usr/bin/env bash
# Isolated tests of the family installer for the enclosing product. Everything
# runs in a scratch prefix and a scratch R library whose paths contain spaces
# and Unicode; user credentials and profiles are emptied. No sudo is used:
# the elevated path is exercised only by the owner. Run from anywhere:
#   bash install/cli/test-installers.sh
set -uo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
failures=0

report() {
  local STATUS="$1"
  local LABEL="$2"
  printf '  %s: %s\n' "$STATUS" "$LABEL"
  if [[ "$STATUS" == FAIL ]]; then failures=$((failures + 1)); fi
}
check() {
  local LABEL="$1"
  shift
  if "$@" >>"$LOG" 2>&1; then report PASS "$LABEL"; else report FAIL "$LABEL"; fi
}

RSCRIPT="$(command -v Rscript || true)"
[[ -n "$RSCRIPT" ]] || { printf '[ERROR] Rscript is required to test the installer\n' >&2; exit 1; }

work="$(mktemp -d "${TMPDIR:-/tmp}/install-test.XXXXXX")"
trap 'rm -rf "$work"' EXIT
LOG="$work/test.log"
: >"$LOG"

# Isolation: scratch library and prefix with spaces and Unicode; the selected
# library chains ahead of the user's real one; profiles and environ are empty.
REAL_LIB="$("$RSCRIPT" --vanilla -e 'cat(path.expand(Sys.getenv("R_LIBS_USER")))')"
LIBRARY="$work/library á with spaces"
PREFIX="$work/prefix á with spaces"
mkdir -p "$LIBRARY"
export R_LIBS_USER="$LIBRARY"
export R_LIBS="$LIBRARY${REAL_LIB:+:$REAL_LIB}"
export R_ENVIRON_USER="$work/Renviron" R_PROFILE_USER="$work/Rprofile"
: >"$R_ENVIRON_USER"; : >"$R_PROFILE_USER"

facts="$("$RSCRIPT" --vanilla -e '
Args <- commandArgs(TRUE)
Dcf <- read.dcf(file.path(Args[1L], "lib/DESCRIPTION"), fields = c("Package", "Version"))
cat(Dcf[1L, "Package"], Dcf[1L, "Version"], sep = "\n")
Cli <- source(file.path(Args[1L], "install/requirements.R"), local = TRUE)$value
Field <- function(x) if (length(x)) x else ""
cat(Field(Cli$command), Field(Cli$runtime), Field(Cli$minimum),
    Field(Cli$verify), sep = "\n")' "$ROOT_DIR")"
PACKAGE="$(sed -n 1p <<<"$facts")"
SOURCE_VERSION="$(sed -n 2p <<<"$facts")"
COMMAND="$(sed -n 3p <<<"$facts")"
RUNTIME="$(sed -n 4p <<<"$facts")"
MINIMUM="$(sed -n 5p <<<"$facts")"
VERIFY="$(sed -n 6p <<<"$facts")"
[[ -n "$RUNTIME" ]] || RUNTIME="$COMMAND"
[[ -n "$PACKAGE" && -n "$COMMAND" ]] || { printf '[ERROR] %s\n' "lib/DESCRIPTION and install/requirements.R must name package and command" >&2; exit 1; }
printf 'Testing %s %s (%s) against %s\n' "$PACKAGE" "$SOURCE_VERSION" "$COMMAND" "$PREFIX"

receipt="$PREFIX/libexec/$RUNTIME/install.json"
MANAGER="$ROOT_DIR/install/cli/manage.R"

# requirements.R minimum equals the CLI's own MINVERSION
minversion="$(grep -oE 'MINVERSION <- "[0-9.]+"' "$ROOT_DIR/cli/main.R" | grep -oE '[0-9.]+' || true)"
if [[ -n "$MINIMUM" || -n "$minversion" ]]; then
  check "requirements.R minimum equals cli/main.R MINVERSION" test "$MINIMUM" == "$minversion"
fi

# --check validates without writing
check "install.sh --check validates and writes nothing" bash "$ROOT_DIR/install/install.sh" --check --prefix "$PREFIX"
check "--check left no prefix behind" test ! -e "$PREFIX"

# full installation: library plus CLI, built from lib/
check "install.sh --component all --build installs" bash "$ROOT_DIR/install/install.sh" --yes --prefix "$PREFIX" --component all --build
check "launcher is executable" test -x "$PREFIX/bin/$COMMAND"
check "receipt exists" test -f "$receipt"
check "receipt is schema 4 with package, source, kit and created" \
  "$RSCRIPT" --vanilla -e '
R <- jsonlite::read_json(commandArgs(TRUE)[1L], simplifyVector = FALSE)
stopifnot(identical(R$schema, 4L), length(R$package$name) == 1L,
          length(R$source$commit) == 1L, length(R$kit) > 0L, length(R$created) > 0L,
          length(R$file) == length(R$md5))' "$receipt"
check "BUILD_INFO recorded in the same transaction" grep -q '^git_describe=' "$PREFIX/libexec/$RUNTIME/BUILD_INFO"
check "receipt md5s match the installed files" \
  "$RSCRIPT" --vanilla -e '
Args <- commandArgs(TRUE)
R <- jsonlite::read_json(Args[1L], simplifyVector = TRUE)
stopifnot(identical(unname(tools::md5sum(file.path(Args[2L], R$file))), unname(R$md5)))' \
  "$receipt" "$PREFIX"

# --version is the four contract lines
version_text="$("$PREFIX/bin/$COMMAND" --version 2>>"$LOG")"
check "--version line 1 is command and version" grep -q "^$COMMAND " <<<"$version_text"
check "--version names the library" grep -q '^library: ' <<<"$version_text"
check "--version names the payload" grep -q "^cli: .*/libexec/$RUNTIME/main.R\$" <<<"$version_text"
check "--version names the build" grep -q '^build: ' <<<"$version_text"

if [[ -n "$VERIFY" ]]; then
  check "verification verb $VERIFY passes" "$PREFIX/bin/$COMMAND" "$VERIFY"
fi

# second run is a no-op
check "second run reports the library unchanged" \
  bash -c "bash '$ROOT_DIR/install/install.sh' --yes --prefix '$PREFIX' 2>&1 | grep -q 'already installed at the source version'"

# explicit replacement with --yes --build
check "forced replacement with --yes --build" bash "$ROOT_DIR/install/install.sh" --yes --prefix "$PREFIX" --build

# kit copies stay byte-identical to the canonical kit
if [[ -d "$HOME/github/agents/install" ]]; then
  kit_drift=0
  for kit_file in installProduct.R product.R package.R build.R install.sh install.ps1 \
                  uninstall.sh uninstall.ps1 update-manifest.sh \
                  cli/manage.R cli/checkPaths.ps1 cli/test-installers.sh cli/test-installers.ps1; do
    if ! cmp -s "$ROOT_DIR/install/$kit_file" "$HOME/github/agents/install/$kit_file"; then
      printf '  drift: %s\n' "$kit_file" >>"$LOG"; kit_drift=1
    fi
  done
  check "install/ is byte-identical to the canonical kit" test "$kit_drift" == 0
else
  report SKIP "canonical kit not found at ~/github/agents/install"
fi

# uninstall preserves the package and foreign files
printf 'keep\n' >"$PREFIX/libexec/$RUNTIME/keep.txt"
check "uninstall.sh removes the CLI" bash "$ROOT_DIR/install/uninstall.sh" --yes --prefix "$PREFIX"
check "launcher and receipt are gone" bash -c "test ! -e '$PREFIX/bin/$COMMAND' && test ! -e '$receipt'"
check "foreign file in libexec is preserved" bash -c "grep -q keep '$PREFIX/libexec/$RUNTIME/keep.txt'"
check "the R package remains installed" \
  "$RSCRIPT" --vanilla -e "invisible(loadNamespace('$PACKAGE', lib.loc = commandArgs(TRUE)[1L]))" "$LIBRARY"
check "uninstall without a receipt is refused" \
  bash -c "'$RSCRIPT' --vanilla '$MANAGER' uninstall '$PREFIX' 2>&1 | grep -q 'No installation receipt'"

# no R on PATH names the cause
check "without R on PATH the cause is named" \
  bash -c "env -i PATH=/usr/bin:/bin HOME='$HOME' bash '$ROOT_DIR/install/install.sh' 2>&1 | grep -q 'R is not installed'"
check "the R error names CRAN" \
  bash -c "env -i PATH=/usr/bin:/bin HOME='$HOME' bash '$ROOT_DIR/install/install.sh' 2>&1 | grep -q 'cran.r-project.org'"

# a foreign destination without a receipt is rejected and untouched
mkdir -p "$work/foreign/bin"
printf 'foreign\n' >"$work/foreign/bin/$COMMAND"
check "foreign destination without receipt is rejected" \
  bash -c "'$RSCRIPT' --vanilla '$MANAGER' install '$work/foreign' 2>&1 | grep -q 'No installation receipt'; test \$? == 0"
check "foreign file is untouched" bash -c "grep -q foreign '$work/foreign/bin/$COMMAND'"

# an outdated manifest stops the installation
printf '# helper\n' >"$ROOT_DIR/cli/bin/unlisted-helper"
check "outdated manifest is rejected" \
  bash -c "'$RSCRIPT' --vanilla '$MANAGER' check '$work/anywhere' 2>&1 | grep -q 'out of date'"
rm -f "$ROOT_DIR/cli/bin/unlisted-helper"

printf 'test-installers: %s failure(s)\n' "$failures"
exit "$(( failures > 0 ? 1 : 0 ))"
