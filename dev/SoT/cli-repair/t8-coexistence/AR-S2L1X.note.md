# T8 — Convivencia de los oráculos tras instalar `ngr`

2026-09-18. `ngr` instalado 14:38 en `/usr/local` (no escribe fuera de
`bin/ngr` y `libexec/ngr`; los libexec de qrt y psha quedaron intactos desde la
línea base del plan).

| Comprobación | Resultado |
| --- | --- |
| `qrt --help` | exit 0 |
| `psha --help` | exit 0 |
| `psha status` en copia sin convertir de AR-S2L1X | exit 0; reporta deriva por componente: `scripts/ 79 files differ`, `_local/ 4`, `bib/ 1`, `params.yml 1` (proyecto de trabajo con personalizaciones; comportamiento habitual) |
| `qrt status` en la misma copia | `bib/  → clean`; exit 1 |
| `qrt render --manifest qrt.manifest.json` en copia sin convertir de AR-S2L1W | corriendo en paralelo para T2 (progreso por alias en /tmp/ngr-real/qrt-render.log) |

El exit 1 de `qrt status` es diseño propio, no efecto de `ngr`: `cmd_status`
(`/usr/local/libexec/qrt/bin/qrt:1338-1364`) itera los componentes de su
scaffold (`bib lua styles yml`, presentes en CWD solo `bib/` en AR-S2L1X) y no
fija código de salida: la función devuelve el estado del último test
`[[ -d "$dst" ]]` del bucle, que falla para el primer componente ausente.
AR-SAD40 (sin ninguno de los 4 componentes de qrt) produce la misma salida
vacía y exit 1 en una copia idéntica sin convertir.
