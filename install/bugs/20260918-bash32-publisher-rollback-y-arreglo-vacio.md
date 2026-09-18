# Bugs bash 3.2 del instalador familiar (2026-09-18) — RESUELTOS

Detectados por el oráculo del kit en `libraries/gmsp` sobre la reescritura del
instalador del 2026-09-18. Ambos son trampas de bash 3.2.57 (el `/usr/bin/env bash`
del sistema macOS) bajo `set -euo pipefail`. Corregidos en este kit canónico el
2026-09-18 (~13:44) y verificados en gmsp (commit `6850dd9`, rama `main`).

## Bug 1 (grave): rollback del publicador inoperante — `install/cli/publish.sh`

`publish_cli` declaraba su estado con `local`, pero en bash 3.2 un trap EXIT
disparado por un fallo de `set -e` **no ve las variables `local` de la función**.
Síntoma: `finish_publish` moría con `complete: unbound variable` y la reversión
nunca corría: un CLI que fallaba su verificación (`--version`) quedaba instalado
a medias en el prefijo, con el recibo nuevo y los archivos rotos.

Reproducción: `Rscript --vanilla install/cli/testManager.R <root> --native`
fallaba con `identical(Hash, tools::md5sum(names(Hash))) is not TRUE` tras una
instalación con lanzador roto; caso mínimo bash en el anexo.

Corrección: el estado que consume `finish_publish` se declara sin `local` (el
cuerpo de `publish_cli` ya es un subshell, nada se fuga al que lo invoca).

## Bug 2 (bloqueante): arreglo vacío bajo `set -u` — `install/install.sh`

`for archive in "${DEPENDENCIES[@]}"` aborta con `DEPENDENCIES[@]: unbound
variable` cuando el arreglo está vacío: **toda** instalación real sin
`--dependency` moría en la etapa 2. Corrección: el idioma
`"${DEPENDENCIES[@]+"${DEPENDENCIES[@]}"}"` (ya usado en `publish.sh`).

## Regla para el kit (bash 3.2, `set -euo pipefail`)

1. Ningún dato consumido por un trap EXIT puede ser `local` de función.
2. Toda expansión `"${arr[@]}"` de un arreglo posiblemente vacío lleva el
   guardián `"${arr[@]+"${arr[@]}"}"`.

## Acción para los repos de la familia

Cualquier `install/` copiado de este canónico entre el 2026-09-18 ~10:44 y ~13:44
arrastra uno o ambos bugs: re-sincronizar byte a byte desde este directorio.

## Anexo: caso mínimo del bug 1

```sh
bash -c '
finish() { local s="$?"; printf "complete=<%s>\n" "${complete-UNSET}"; exit "$s"; }
f() (
  set -euo pipefail
  local complete=false changed=3
  trap finish EXIT
  false
)
f'   # imprime complete=<UNSET> en bash 3.2.57 (macOS): el trap no ve las local
```
