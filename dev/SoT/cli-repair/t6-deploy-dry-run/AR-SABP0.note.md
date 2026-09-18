# T6 — Publicación en seco en copia convertida de AR-SABP0

2026-09-18, `/tmp/ngr-real/T1-AR-SABP0` (copia liviana, borrada al terminar).
`ngr` = `/usr/local/bin/ngr`. Ninguna llamada real a Netlify.

| Comando | exit | Observado |
| --- | --- | --- |
| `ngr deploy init --manifest manifest.json --dry-run` | 0 | 21 líneas `INIT <alias> siteSlug=arsabp0-<alias> create=FALSE` (T6.init.tsv) |
| `ngr deploy --manifest manifest.json --dry-run` | 0 | 21 líneas `DEPLOY <alias> path=html/<…> prod=FALSE` |
| `ngr deploy domain --manifest manifest.json --dry-run` | 0 | 21 líneas `DOMAIN <alias> domain=arsabp0-<alias>.srk.ar https=FALSE rebind=FALSE` (T6.domain.log) |

Conciliación contra el `qrt.manifest.json` original
(`t1-conversion/AR-SABP0.artifacts-before.tsv`): T6.join.tsv une por alias los
21 dominios originales con los resueltos; `awk '$2 != $3'` → **0 discrepancias**
(los `siteSlug` del init también coinciden con los originales).
