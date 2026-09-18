# T3 — Deriva y restauración (R2) en copia convertida de AR-S2P30

2026-09-18, `/tmp/ngr-real/T1-AR-S2P30` (copia liviana `cp -Rc`, borrada al terminar).
`ngr` = `/usr/local/bin/ngr` (reinstalación 14:38, build `…-167-g65795cc`).

1. Estado previo: `md5 -q _master/sha.qmd` → `badc0e2737e9d1a444186d429bf7352b`.
2. Deriva inducida: `printf '<!-- drift T3 -->' >> _master/sha.qmd` (administrado) y
   `printf '<!-- seed edit T3 -->' >> _master/book.es.qmd` (semilla).
3. `ngr status --check` → **exit 1**; el administrado sale
   `sha  different  _master/sha.qmd  locally-modified` y la semilla editada sale
   `sha  project-seed  _master/book.es.qmd` (AR-S2P30.status-check.log).
4. `ngr pull --force _master` → `[pull] complete: 37 resource contributions`.
5. Resultado: `md5 -q _master/sha.qmd` → `badc0e2737e9d1a444186d429bf7352b`
   (restaurado byte a byte); `_master/book.es.qmd` conserva la línea
   `<!-- seed edit T3 -->` (semilla protegida).

Paridad con el oráculo (psha: «33 files restored, 4 project-owned kept»): ngr
restaura los administrados y conserva las 4 semillas del proyecto; el reporte
es por contribuciones (37) con líneas `keep`/`preserve` para lo project-owned.
