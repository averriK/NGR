# T7 — Proyectos sin `oq/data`: AR-S2L1X y AR-SAD40

2026-09-18. Copias livianas convertidas (T1) y sin convertir (T0), borradas al
terminar. `ngr` = `/usr/local/bin/ngr`; oráculo = `/usr/local/bin/qrt`.

| Comprobación | AR-S2L1X | AR-SAD40 |
| --- | --- | --- |
| Conversión (T1) | pull/status exit 0, artefactos y semillas intactos | idem |
| `ngr render --manifest manifest.json --dry-run` | `dry-run ok` (alias audit, …) | `dry-run ok` (alias model, …) |

Fallo por datos ausentes (render real del alias `audit` en AR-S2L1X):

- `ngr render --manifest manifest.json --only audit` → exit 1:
  `Quitting from audit.qmd:26-33 [unnamed-chunk-1]` —
  `base::stopifnot(exists("root"), exists("ReportDate"))` (la guarda propia del
  qmd nombra los objetos de datos ausentes) — `ngr: quarto failed with status 1.`
  (AR-S2L1X.ngr-render.log)
- Oráculo: `qrt render --manifest qrt.manifest.json --only audit` en la copia
  sin convertir → exit 1 con el mismo `Quitting from audit.qmd:26-33` y
  `[render manifest] quarto render failed: audit` (AR-S2L1X.qrt-render.log).

Paridad: ambos fallan en el mismo chunk por la guarda del proyecto que nombra
el dato; ninguno aborta con una traza cruda del CLI.
