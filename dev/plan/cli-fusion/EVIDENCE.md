# Contraste de contrato: observaciones del 2026-09-15

Esta lectura sirve a la propuesta de interfaz. **No admite todavía el baseline
SoT ni acredita paridad, renders, instalación o efectos Netlify.**

La propuesta inicial fue retirada tras la corrección del propietario sobre el
contexto de uso. [USAGE.md](USAGE.md) recoge el contraste posterior con proyectos
consumidores. Las observaciones siguientes son evidencia, no decisiones aprobadas.

## Documentos y continuidad

Se leyeron completos, en el orden solicitado: el PLAN de esta carpeta;
QRT `dev/plan/ngr-fusion-20260915/PLAN.md`; `ngr-books-20260915/PLAN.md`;
su `QRT-CAPABILITIES.md`; `ngr-contract-20260915/PLAN.md`; y
`ngr-provenance-20260915/REVIEW.md`. Las rutas históricas son antecedentes.

El selector inicial contenía Markdown y apuntaba a la tarea histórica
`dev/plan/quarto-yaml/active.md`. Se leyó ese antecedente sin reabrirlo.
El encargo actual autorizó reconciliar la tarea: `dev/SoT/ACTIVE.md` contiene
ahora únicamente `dev/plan/cli-fusion/STATE.md`. El propietario confirmó esa
selección y el uso del `dev/` existente en su segundo mensaje.

Se leyeron los skills instalados `code` y sus veinte tarjetas completas,
`sot`, `bash`, `r`, `python`, y `qrt` con las referencias de scaffold/manifest
y render. No se ha usado la interfaz data.table. La lectura de implementación
se rigió por las metodologías y reglas de lenguaje; las consultas a la CLI
pública QRT se rigieron por el skill QRT.

## Identidades reobservadas

NGR checkout: `3b1493d609f90970752851c6fea582189538dac6`, rama `main`.
Estado inicial: únicamente `dev/plan/cli-fusion/` sin seguimiento.
[La arquitectura](../../ARCHITECTURE.md:42) separa instalación CLI y paquete R;
[cli/README.md](../../../cli/README.md:1) reserva la interfaz.
`/usr/local/bin/ngr` no existe en esta observación.

| Objeto instalado | BUILD_INFO | SHA-256 del launcher |
|---|---|---|
| `/usr/local/libexec/qrt` | `aa43a56-dirty`, `2026-09-15T17:33:39Z` | `e87f479d2c6e0c2fba8e6212cb4ce1c056b8d19bccdcc8216d2254701efd1584` |
| `/usr/local/libexec/psha` | `1bb0769f-dirty`, `2026-09-15T17:33:30Z` | `5ba946bc6023cb4f70122851331676eed360d43b341cc2026176a5b616afbc3d` |

Ambos launchers coinciden con sus checkouts. También coinciden:

- QRT `lib/renderStamp.R`: `67534736d44734e46eea6eb1ad70e01d0d6e10de67c31a430cc15a651c855841`.
- PSHA `bin/recordScaffold.R`: `41a86da42329fac2edd01c71e449521224401c92e00e75f513758503d4dbe031`.
- `diff -qr` terminó 0, sin diferencias, para QRT `lib/`, QRT `scaffold/`
  y PSHA `scaffold/`, instalado frente a checkout.

Se leyó todo el dispatcher instalado QRT (1732 líneas), todo el PSHA
(672), ambos módulos de procedencia, los cuatro adaptadores YAML/inspección
y `fix_docx.py`; los cinco perfiles/base YAML; filtros de footer; instalador
QRT completo y sección de identidad del instalador PSHA. Los recibos instalados
señalan los respectivos launchers y manifests bajo `/usr/local`.

### Paquete R de comparación

La consulta ejecutada carga `NGR` **0.3.11** desde
`/Users/averrik/Library/R/arm64/4.6/library/NGR` usando R **4.6.1**.
Están los ocho exports Quarto/YAML requeridos por el instalador QRT y
`knitBlock`; no faltó ninguno. Esto prueba presencia, no paridad funcional.

| Archivo instalado NGR | SHA-256 |
|---|---|
| `DESCRIPTION` | `f6e87c536c6b218290003ce4497704902d1edc3095a2a3472a9703413ba6dabe` |
| `NAMESPACE` | `9b4122c5ad86e28575293824b72bb7bcd6327db5f566cf1fc46d47ffdd404868` |
| `R/NGR` | `570ca456b280cdeb201ef5ebdf22dc8f80092e2c0c68e33c7f73340e420f3759` |
| `R/NGR.rdb` | `53db74ab358e8002e7774705bdbea24e6f4c189aa27898849480074941c46a68` |
| `R/NGR.rdx` | `6b59308df28e9da05c521314d7d2a4c1a0c2c38f99f030721d095155b4fdab0b` |

Dependencias consultadas: Quarto `1.9.35`, yaml `2.3.12`, jsonlite `2.0.0`,
knitr `1.52`, rmarkdown `2.32`. La shell resuelve QRT/PSHA/Rscript/Quarto en
`/usr/local/bin`, jq en `/opt/homebrew/bin`, Python mediante pyenv y Netlify
en `/usr/local/bin`. Falta fijar la clausura por comparación, incluidos
intérprete efectivo de mapas y dependencias científicas cuando se seleccione
el producto. No se certificó el runtime Netlify por encontrar su launcher.

La consulta de `Sys.which(c("Rscript", "quarto"))` desde Rscript con startup
normal devolvió cadenas vacías; con `--vanilla` devolvió los dos ejecutables
en `/usr/local/bin`. Antes de una comparación que ejecute subprocesos desde R,
hay que caracterizar ese entorno y mantenerlo igual en referencia/candidato;
esta revisión no cambió perfiles ni eligió un fallback de producto.

## Diferencias que condicionan la propuesta

| Observación actual | Evidencia leída | Punto que debe resolver el contrato |
|---|---|---|
| QRT init omite archivos existentes; con force puede regenerar los 18 artefactos del manifest incluso al copiar un solo componente. | [QRT:56](/usr/local/libexec/qrt/bin/qrt:56), [seeder:115](/usr/local/libexec/qrt/bin/qrt:115) | Alcance de la copia y preservación de la edición existente. |
| PSHA crea 21 artefactos, conserva manifest existente y protege params, _local y cuatro masters. Pull puede restaurar un master protegido si falta. | [PSHA:28](/usr/local/libexec/psha/bin/psha:28), [seeder:124](/usr/local/libexec/psha/bin/psha:124), [pull:481](/usr/local/libexec/psha/bin/psha:481) | Propiedad de semillas y tratamiento de los dos seeders; no concatenar sus artefactos. |
| PSHA mueve masters o elimina homónimos de raíz antes del preflight. | [migración:58](/usr/local/libexec/psha/bin/psha:58), [pull:435](/usr/local/libexec/psha/bin/psha:435) | Cambio deliberado: ninguna migración editorial lateral. |
| QRT status usa diff bajo pipefail; pull por componente incluye extras en su comparación. PSHA status no excluye todos los componentes locales como pull. | [QRT:1339](/usr/local/libexec/qrt/bin/qrt:1339), [PSHA:358](/usr/local/libexec/psha/bin/psha:358) | Distinguir drift, propiedad y error; verificar el caso de status sin reporte. No se ejecutó ese caso aquí. |
| Render usa CWD; deploy cambia a Git root; doctor mezcla fallback de params a Git root con mapper en CWD. | [QRT render:1168](/usr/local/libexec/qrt/bin/qrt:1168), [deploy:1464](/usr/local/libexec/qrt/bin/qrt:1464), [PSHA doctor:513](/usr/local/libexec/psha/bin/psha:513) | Resolver coherencia de raíz conservando el uso desde el proyecto; no deducir obligatoriedad de un flag. |
| QRT valida V1/V2, claims de todos los outputs, cuatro perfiles, mapas/static y Netlify. Extras de render manifest pueden ignorarse. | [QRT:184](/usr/local/libexec/qrt/bin/qrt:184), [render:1075](/usr/local/libexec/qrt/bin/qrt:1075) | Preservar capacidades; rechazar argumentos sin función. |
| Mapas resuelven Python por texto del shebang y PATH; QRT impone import de Kashima. | [QRT:396](/usr/local/libexec/qrt/bin/qrt:396), [mapper:1](/usr/local/libexec/psha/scaffold/mapper/run.py:1) | Conservar operación; dependencia del productor PSHA declarada en sus recursos. |

## Procedencia y consumidores leídos

[recordScaffold.R](/usr/local/libexec/psha/bin/recordScaffold.R:1) recibe rutas
copiadas y exclusiones; escribe commit, dirty y MD5 por archivo bajo
`scaffolds.psha.files`. `complete` compara cobertura de nombres, no uniformidad
de commit ni limpieza. Sin manifest no registra. La copia y la escritura del
JSON no forman una transacción común.

[renderStamp.R](/usr/local/libexec/qrt/lib/renderStamp.R:8) recorre todas las
fuentes registradas, contrasta digest con el proyecto, agrupa revisiones y
produce `Pub: DD/MM/YYYY Rev.…`, con DRAFT ante edición, ausencia o desconocido.
[El launcher](/usr/local/libexec/qrt/bin/qrt:1169) captura el sello antes del
staging, una vez por render Quarto. No calcula dependencias por artefacto.

Se recorrieron estas cadenas concretas, sin atribuirles un inventario de todos
los capítulos científicos:

- [_master/book.en.qmd](/usr/local/libexec/psha/scaffold/_master/book.en.qmd:1)
  declara capítulos/apéndices y dos bibliografías; `index.qmd` llega a setup y
  cover. Setup carga NGR instalado, parámetros y `oq/data/data.R` opcional.
- [_master/gmdp.en.qmd](/usr/local/libexec/psha/scaffold/_master/gmdp.en.qmd:1)
  y `toc.en.qmd` incluyen `_revealjs/contents.toc.qmd`, que llama
  [toc.R:3](/usr/local/libexec/psha/scaffold/scripts/setup/toc.R:3).
  GMDP exige aliases ts/dn/kmax/kh; el orden y nombres son editoriales PSHA.
- [_master/transmittal.en.qmd](/usr/local/libexec/psha/scaffold/_master/transmittal.en.qmd:1)
  llama [transmittal.R](/usr/local/libexec/psha/scaffold/scripts/setup/transmittal.R:9).
  Éste y TOC leen `qrt.manifest.json`; también lo hace `.deckNote` en
  [utils.R:24](/usr/local/libexec/psha/scaffold/scripts/setup/utils.R:24).
- [cover.R:17](/usr/local/libexec/psha/scaffold/scripts/setup/cover.R:17),
  sus portadas/firma y `transmittal.R:179` consumen QRT_RENDER_STAMP.
  Los perfiles book/html y revealjs incluyen respectivamente
  [page-footer.lua](/usr/local/libexec/qrt/scaffold/lua/page-footer.lua:31) y
  [footer.lua](/usr/local/libexec/qrt/scaffold/lua/footer.lua:4).

El cambio de nombre del manifest debe migrar estos lectores junto con el
productor. El sello de texto no sirve para reconstruir metadatos.

Bibliografía: los dos `apa.csl` tienen SHA-256
`56b2dc053036b6103aaeaf3c772e023e4f3773dca53481d29450fb6131364ca3`.
Los `references.bib` difieren: QRT
`58cebf3f5f84d714986556f3de49605a58958fccf330968a941a794035ae5ad0`,
PSHA `5733029ce7e187dfdcd471a3ea64d0f6babc6aa1416909b15369cd56a4c719c6`.
Se leyeron sus cabeceras y consumidores, no todas las entradas. No se acepta
supresión, equivalencia bibliográfica ni unión automática por estos hashes.

## Verificación ejecutada y trabajo posterior

- Consultas públicas `qrt --help`, `qrt render --help`, `qrt init --help`:
  salida 0. La ayuda instalada confirma destino HTML declarado en manifest.
  La referencia del skill que todavía deriva ese destino sólo del stem está
  superada en esa superficie por el código y la ayuda leídos; se conserva
  el resto de sus procedimientos.
- Consultas de identidades y exports R, comparación de hashes y `diff -qr`
  descritas arriba. No se ejecutaron renders ni operaciones de recursos.
- Leídos los oracles históricos de paths QRT y procedencia PSHA. El primero
  usa stubs y el segundo apunta a un candidato anterior del sello; no deben
  ejecutarse sin adaptar su entrada y condición al baseline instalado.

Tras el cierre del contrato: preservar los runtimes y sus dependencias
necesarias bajo `dev/SoT/cli-fusion-20260915/`, caracterizar el comportamiento
por CLI instalada y admitir el primer candidato. Ningún snapshot ni candidato
de implementación fue creado en esta revisión documental. Los hashes de esta
nota son identidades observadas, no un reemplazo de esa preservación.

## Comprobación posterior del uso en proyecto

Se reabrió el skill QRT instalado; el recibo `.agents/agents-skills.json`
registra release `c9b9daf535aa004eef05bc4f98835370a242da986d8244064316700ae79aa963`,
coincidente con el catálogo aprobado. Se leyeron sus referencias de scaffold,
render, deploy y dominios; también code con las veinte tarjetas y las reglas R.

En `/Users/averrik/Cloud/github/projects/AR-S2L1W`,
`qrt render --manifest qrt.manifest.json --dry-run --only report,toc` terminó 0:
dos trabajos, primero toc → html/toc y después report → html/book. Es un plan
local, sin render ni efectos remotos. Lecturas y límites en [USAGE.md](USAGE.md).

Identidades consultadas después del plan, SHA-256:

| Entrada | Digest |
|---|---|
| QRT instalado, bin/qrt | `e87f479d2c6e0c2fba8e6212cb4ce1c056b8d19bccdcc8216d2254701efd1584` |
| AR-S2L1W, qrt.manifest.json | `1dedc7b3d220e569a505b53f4989e985778e463f071d2e65244d49805692366c` |
| AR-S2L1W, _master/toc.es.qmd | `38079750ebb94315c9bbe12973ac419209a00ac407b6b1f4590cfd90691ac788` |
| AR-S2L1W, _master/book.es.qmd | `843949afcd2becbe77c799cf9115f55957369b5f352a1e348137006908dff1ee` |
| AR-SAD40, AGENTS.md | `20b99a9349d6cdb4f088e68e2fde5b140ba763de4aa7db56055795c653ea9c93` |

Se corrigieron las secciones y valores del STATE para el esquema del hook
instalado. La invocación pública de continuity.py con evento SessionStart y
CWD de NGR devolvió el estado seleccionado sin error de validación.
