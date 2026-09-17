#!/usr/bin/env bash
set -euo pipefail
source_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
rscript_path="$(command -v Rscript)"
user_id="$(id -u)"
if [[ "${user_id}" == 0 ]]; then
  if [[ -z "${SUDO_USER:-}" || -z "${SUDO_UID:-}" || "${SUDO_UID}" == 0 ]]; then
    printf '%s\n' 'Invoke this installer from the intended user account; direct root installation has no R user.' >&2
    exit 1
  fi
  [[ "$(id -u "${SUDO_USER}")" == "${SUDO_UID}" ]] || {
    printf '%s\n' 'The sudo user does not match SUDO_UID.' >&2
    exit 1
  }
  r_environment=("PATH=${PATH}")
  for name in R_LIBS R_LIBS_USER R_LIBS_SITE; do
    if value="$(printenv "${name}")"; then
      r_environment+=("${name}=${value}")
    fi
  done
  exec sudo -n -H -u "${SUDO_USER}" -- env "${r_environment[@]}" \
    "${rscript_path}" --vanilla "${source_dir}/install/installProduct.R" \
    --system-cli "${source_dir}" "$@"
fi
exec "${rscript_path}" --vanilla "${source_dir}/install/installProduct.R" "${source_dir}" "$@"
