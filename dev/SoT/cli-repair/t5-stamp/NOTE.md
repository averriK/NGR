# T5 — Sello de publicación con fuente sha sin git

Fecha: 2026-09-18. Next: `cli-repair-real-project-tests-20260918`. Dependía de T2 (árboles renderizados).

## Hallazgo (extraído de los HTML renderizados en T2, AR-S2L1W)

Sello en `html/sha/index.html` (comando `grep -o 'Pub:[^<]*'`, valor único en todo el archivo):

- **ngr: `Pub: 18/09/2026 Rev.65795cc / — · DRAFT`**
- **qrt: `Pub: 18/09/2026 Rev.1bb0769 · DRAFT`**

## Lectura

- ngr estampa doble revisión: `Rev.<base CLI> / <rev fuente sha>`. La base es `65795cc` (commit del CLI instalado). La fuente sha (`reports/sha`, `_master/sha.es.qmd`) no está bajo git en este proyecto ⇒ la marca es `—` (em-dash) y el sello lleva `· DRAFT`.
- qrt estampa una sola revisión (`1bb0769`, la registrada en su manifiesto) con `· DRAFT`.
- El mismo patrón dual aparece en los 21 alias (64 líneas de sello en los 40 archivos de texto que difieren, todas de la forma `Rev.65795cc / — · DRAFT` vs `Rev.1bb0769 · DRAFT`; ver `../t2-render/NOTE.md`).

## Estado

Comportamiento conforme al diseño del contrato: fuente sin git ⇒ rev `—` + DRAFT, sin inferir ni inventar hash. T5 queda cerrada. Queda para el propietario la decisión P1 del handoff: si `reports/sha` pasa a git (con lo que el sello mostraría su hash real en vez de `—`).
