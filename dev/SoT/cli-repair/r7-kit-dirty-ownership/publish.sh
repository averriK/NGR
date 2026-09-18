#!/usr/bin/env bash
# Sourced by the Unix wrappers. R prepares the receipt as the caller; this
# transaction owns only prefix files. It also runs without elevation in tests.
publish_cli() (
  set -euo pipefail
  # The subshell isolates this state. Bash 3.2 drops function locals before
  # running EXIT on an errexit failure, so the rollback state cannot be local.
  STAGE="$1" PREFIX="$2" COMMAND="$3" RUNTIME="$4" ACTION="$5" VERIFY="$6"
  recovery="" complete=false restored=true changed=0
  paths=() existed=() slots=() created=()
  [[ "$COMMAND" =~ ^[A-Za-z0-9_-]+$ && "$RUNTIME" =~ ^[A-Za-z0-9_-]+$ ]]
  [[ "$ACTION" == install || "$ACTION" == uninstall ]]
  [[ "$PREFIX" == /* && "$PREFIX" != / && "$PREFIX" != *$'\n'* && ! -L "$PREFIX" ]]
  read_hash() {
    if command -v md5sum >/dev/null 2>&1; then
      md5sum "$1" | cut -d ' ' -f 1
    else
      md5 -q "$1"
    fi
  }
  check_target() {
    local REL="$1" path
    case "/$REL/" in *'/../'*|*'/./'*|*'//'*|*$'\n'*|*$'\r'*|*$'\t'*|*'\'*) return 1 ;; esac
    case "$REL" in
      "bin/$COMMAND"|"bin/$COMMAND.cmd"|"bin/$COMMAND.ps1"|"libexec/$RUNTIME/"*) ;;
      *) printf '[ERROR] Unowned publication path: %s\n' "$REL" >&2; return 1 ;;
    esac
    path="$PREFIX/$REL"
    [[ ! -d "$path" ]]
    while [[ "$path" == "$PREFIX/"* || "$path" == "$PREFIX" ]]; do
      [[ ! -L "$path" ]] || { printf '[ERROR] Symlink in destination: %s\n' "$path" >&2; return 1; }
      path="$(dirname -- "$path")"
    done
  }
  finish_publish() {
    local STATUS="$?"
    trap - EXIT
    if [[ "$complete" == false && "$changed" -gt 0 ]]; then
      for ((i=changed-1; i>=0; i--)); do
        target="$PREFIX/${paths[$i]}"
        if [[ "${existed[$i]}" == true ]]; then
          cp -p "$recovery/$i.before" "$target" || restored=false
        else
          rm -f -- "$target" || restored=false
        fi
      done
    fi
    if [[ "$restored" == true ]]; then
      [[ -z "$recovery" ]] || rm -rf -- "$recovery"
      if [[ "$complete" == false || "$ACTION" == uninstall ]]; then
        for rel in "${created[@]+"${created[@]}"}"; do
          target="$PREFIX/$rel"
          [[ "$rel" != . ]] || target="$PREFIX"
          rmdir -- "$target" 2>/dev/null || true
        done
      fi
    else
      printf '[ERROR] Restore UNKNOWN; recovery retained at %s\n' "$recovery" >&2
    fi
    exit "$STATUS"
  }
  trap finish_publish EXIT
  # Snapshot only prepared regular files; no shell or R code is evaluated from
  # this plan. Revalidate current hashes immediately before the first change.
  [[ -f "$STAGE/files.tsv" && ! -L "$STAGE/files.tsv" ]]
  while IFS=$'\t' read -r rel hash slot; do
    check_target "$rel"
    [[ "$hash" == - || "$hash" =~ ^[a-f0-9]{32}$ ]]
    [[ "$slot" == - || "$slot" =~ ^[0-9]+\.next$ ]]
    for target in "${paths[@]+"${paths[@]}"}"; do [[ "$target" != "$rel" ]]; done
    paths+=("$rel")
    slots+=("$slot")
    target="$PREFIX/$rel"
    if [[ "$hash" == - ]]; then
      [[ ! -e "$target" ]]
      existed+=(false)
    else
      [[ -f "$target" && "$(read_hash "$target")" == "$hash" ]]
      existed+=(true)
    fi
  done < "$STAGE/files.tsv"
  [[ "${#paths[@]}" -gt 0 ]]
  while IFS= read -r rel; do
    case "$rel" in .|bin|libexec|"libexec/$RUNTIME"|"libexec/$RUNTIME/"*) ;; *) return 1 ;; esac
    case "/$rel/" in *'/../'*|*'//'*|*$'\r'*|*$'\t'*|*'\'*) return 1 ;; esac
    created+=("$rel")
  done < "$STAGE/created.txt"
  mkdir -p -- "$PREFIX"
  recovery="$(mktemp -d "$PREFIX/.install-XXXXXXXX")"
  for ((i=0; i<${#paths[@]}; i++)); do
    target="$PREFIX/${paths[$i]}"
    [[ "${existed[$i]}" == false ]] || cp -p "$target" "$recovery/$i.before"
    slot="${slots[$i]}"
    if [[ "$slot" != - ]]; then
      [[ -f "$STAGE/payload/$slot" && ! -L "$STAGE/payload/$slot" ]]
      cp -pP "$STAGE/payload/$slot" "$recovery/$i.next"
      [[ -f "$recovery/$i.next" && ! -L "$recovery/$i.next" ]]
    fi
  done
  for ((i=0; i<${#paths[@]}; i++)); do
    check_target "${paths[$i]}"
    target="$PREFIX/${paths[$i]}"
    if [[ "${existed[$i]}" == true ]]; then
      [[ "$(read_hash "$target")" == "$(read_hash "$recovery/$i.before")" ]]
    else
      [[ ! -e "$target" ]]
    fi
  done
  for ((i=0; i<${#paths[@]}; i++)); do
    target="$PREFIX/${paths[$i]}"
    mkdir -p -- "$(dirname -- "$target")"
    changed=$((i + 1))
    if [[ "${slots[$i]}" == - ]]; then rm -f -- "$target"; else mv -f -- "$recovery/$i.next" "$target"; fi
  done
  if [[ "$ACTION" == install ]]; then
    as_user env R_LIBS="$r_libs" "$PREFIX/bin/$COMMAND" --version
    if [[ -n "$VERIFY" ]]; then as_user env R_LIBS="$r_libs" "$PREFIX/bin/$COMMAND" "$VERIFY"; fi
  fi
  complete=true
)
