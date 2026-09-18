# T2 — Render real AR-S2L1W (21 alias): ngr vs qrt, comparación de árboles

Fecha: 2026-09-18. Next: `cli-repair-real-project-tests-20260918`.
ngr bajo prueba: `/usr/local/bin/ngr` (instalado por el propietario 14:38, build `65795cc`, sin `-dirty`).
Oráculo: `/usr/local/bin/qrt`. Proyecto `projects/AR-S2L1W` intacto; todo en copias `cp -Rc`.

## Disposición

- ngr: `/tmp/ngr-real/T1-AR-S2L1W` (copia convertida en T1, `manifest.json` ngr).
- qrt: `/tmp/ngr-real/T2-AR-S2L1W-qrt` (copia sin convertir, `qrt.manifest.json`).
- `html/` borrado de ambas copias antes de renderizar: los árboles comparados son producto puro del render.
- Lanzados desacoplados 15:11:59 (`nohup`); ngr exit 0 a las 17:15:32, qrt exit 0 a las 17:15:49.
- Logs: `ngr-render.log`, `qrt-render.log` (este directorio). 21/21 alias en ambos, cero líneas `failed|Error|Execution halted`.
- Alias renderizados (21, todos fuentes `.es`, 20 revealjs + 1 book): toc, report(book), gmdp, gmdp.ts, gmdp.dn, gmdp.kmax, gmdp.kh, sdc, sha, srs, srs.at, srs.vt, srs.dt, srs.ai, srs.cav, srs.cav5, srs.psa, srs.psv, srs.sd, srs.its, srs.ipsa. El manifiesto de este proyecto no tiene perfiles ni segundo idioma; esa rama del criterio no aplica aquí.
- Tiempos (log ngr): toc 36 s; report (book) 15:12:35→16:02:51 (~50 min, el cuello de botella); alias revealjs entre 34 s y ~10 min; `srs.its` el más pesado tras el book (16:55:04→17:14:59, ~20 min). Ambos renders avanzaron en paso (misma duración por alias ±1 min).

## Comparación de árboles (`diff -rq`, 11.664 archivos por lado, listas de nombres idénticas)

- **11.561 / 11.664 byte-idénticos.**
- **103 diferentes, en 3 clases, 0 inexplicadas:**

1. **63 source maps `styles/_pdfjs/build/*.map` (3 × 21 alias): lado qrt = puntero Git LFS de 3 líneas (`version https://git-lfs.github.com/spec/v1`, oid sha256:26fab4…), lado ngr = contenido real (`{"version":3…`). Mecanismo verificado: el proyecto original tiene los `.map` como punteros LFS sin resolver en su árbol de trabajo; `ngr pull` (conversión T1) refrescó `styles/_pdfjs/build/*.map` con los bytes reales del scaffold instalado (`cmp` T1.styles == `/usr/local/libexec/ngr/scaffold/styles/...` ✓; la ruta está en `manifest.json`). qrt copia verbatim lo que haya en el proyecto. Efecto: salida ngr estrictamente más completa (los maps solo los usa devtools; el visor pdf funciona igual) y explica el tamaño 1,4 G vs 1,2 G.
2. **40 archivos de texto (39 HTML + `book/search.json`): idénticos tras normalizar ids aleatorios de widget (`htmlwidget-[0-9a-f]+`) y hashes de revisión, EXCEPTO el sello dual — ver clase 3 — y 3 líneas de solo espacios en `book/index.html`.** Clasificación exhaustiva de las 127 líneas residuales tras normalizar: 64 pares = sello dual; 3 pares = whitespace; 0 otras.
3. **Sello dual de revisión (la característica bajo prueba, T5):** ngr estampa `Pub: 18/09/2026 Rev.65795cc / — · DRAFT` (revisión del CLI base / revisión de la fuente sin git = «—»); qrt estampa `Pub: 18/09/2026 Rev.1bb0769 · DRAFT` (rev única registrada por qrt). 64 líneas de sello en los 40 archivos, todas de esta forma.

## Verificación del alias `sha` contra la referencia de aceptación previa

| métrica | referencia | ngr | qrt |
|---|---|---|---|
| archivos en `html/sha` | 578 | 578 ✓ | 578 ✓ |
| widgets highchart | 529 | 529 ✓ (1058 refs `htmlwidget-` = 2×529) | 529 ✓ |
| captions `<figcaption` | 598 | 598 ✓ (529 fig + 69 tbl) | 598 ✓ |

## Conclusión

Render completo de proyecto real equivalente entre ngr y qrt: mismos 21 alias, mismos archivos, contenido idéntico salvo (a) ids aleatorios de widget, (b) el sello de revisión — donde ngr muestra MÁS información (doble revisión base/fuente, T5) — y (c) los source maps pdfjs, donde ngr entrega contenido real reparado por `ngr pull` frente a punteros LFS sin resolver que qrt propaga. Ninguna diferencia residual sin explicar. T2 queda cerrada.
