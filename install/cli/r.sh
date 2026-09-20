#!/usr/bin/env bash
# Resolve the system's current R, never an executable saved by an older install.
resolve_rscript() {
  local system_name candidate
  system_name="$(/usr/bin/uname -s)"
  case "$system_name" in
    Darwin)
      for candidate in /Library/Frameworks/R.framework/Resources/bin/Rscript /opt/homebrew/opt/r/bin/Rscript /usr/local/opt/r/bin/Rscript; do
        if [[ -x "$candidate" ]]; then printf '%s\n' "$candidate"; return 0; fi
      done
      ;;
    Linux)
      for candidate in /usr/local/bin/Rscript /usr/bin/Rscript; do
        if [[ -x "$candidate" ]]; then printf '%s\n' "$candidate"; return 0; fi
      done
      ;;
    *) printf '[ERROR] Unsupported R discovery platform: %s\n' "$system_name" >&2; return 1 ;;
  esac
  printf '[ERROR] Current system Rscript not found. Install or repair the system R installation.\n' >&2
  return 1
}
