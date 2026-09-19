# Propuesta v3: cómo el informe SHA encuentra datos y parámetros

2026-09-19, sesión NGR-V2. Revisión de la v1 con las respuestas de oqt-V2
(`libraries/hazard/dev/migration/RESPUESTA-NGR-INTEGRACION-DATOS-20260919.md`,
commit 651af80 en hazard) y con su segundo intercambio del mismo día, que
retira el modo legado. Sustituye el borrador `project.data.json` de
`libraries/hazard/dev/PROJECT-DATA.md`. Pendiente de decisión del propietario.

## 0. Corrección de la v1

**`IDm` sí está en `newmark.json`.** Lo afirmé ausente leyendo solo las primeras
líneas del archivo; verificado hoy: `AR-S2C1R/newmark.json` trae
`IDm = ["U1"…"U8"]`. oqt-V2 tenía razón. De los 10 parámetros que usa el
informe, los únicos que ningún productor consume son `DaH.gmdp` y
`siteID.gmdp`.

Se mantiene de la v1, ahora con acuerdo explícito de oqt-V2 (P8): la ruta la
declara el contrato del productor, no un archivo nuevo, y no se busca en otra
ubicación. El nombre `project.data.json` queda descartado: viola el naming de la
casa (una palabra en minúscula más su formato: `manifest.json`, `params.yml`,
`hazard.json`, `newmark.json`) y sería un tercer declarante de una ruta que los
productores ya declaran.

Sigue en pie la demostración de la v1: **`params.yml` no es un requisito de
Quarto** —ningún master declara `params:`, NGR nunca pasa `--execute-params` ni
`metadata-files` (`lib/R/quartoRender.R:86,124`), el `_quarto.yml` base no lo
nombra— sino configuración del proyecto que abren a mano `setup.R:49-51`,
`checkParameters.R:1`, `transmittal.R:89,130`, `mapper/run.py:33` y NGR
`resources.R:246,257`. Se conserva, y ahora recibe lo que no tiene otro dueño.

## 1. Dónde está hoy clavado el legado (5 lugares, no 2)

| Archivo | Qué fija |
| --- | --- |
| `reports/sha/scripts/setup/global.R:3` | `.loadOQ()` → `root/oq/data/<Tabla>.Rds`, 13 tablas, y `NULL` en silencio si falta |
| `reports/sha/scripts/setup/setup.R:45` | `source(root/oq/data/data.R)` |
| `reports/sha/_tbl/SSM.ARB.qmd:5` | `SSM_FILE <- file.path(root, "oq", "data", "SSMTable.Rds")` |
| `reports/sha/_tbl/SSM.AUS.qmd:5` | ídem |
| `reports/sha/_tbl/SSM.SAM.qmd:5` | ídem |

## 2. Tablas: quién las escribe y cuáles consume el informe

oqt-V2 confirma el reparto y agrega productos que yo no había listado. Verifiqué
cuáles llegan al informe:

| Productor | Consumidas por el informe | Escritas pero no consumidas |
| --- | --- | --- |
| hazard | `UHSTable`, `AEPTable`, `AEPSTable`, `MCETable`, `ScenarioTable`, `ScenarioGMPETable`, `GMPETable`, `ASCETable`, `DEQTable`, `RMwTable`, `SSMTable` | `SRMwTable` (solo aparece en un mensaje de `scripts/tbl/SSM.*.R:50`), `MCEBranchTable` (0 archivos) |
| newmark | `DnTable`, `kmaxTable`, `ShearTable` | `DnPlotTable` (0 archivos) |

Nombres de archivo y esquemas **no cambian**: los dos CLI reproducen byte a byte
los productos anteriores, y la consolidación de etapa 2 no está implementada ni
decidida. Ningún trabajo de esquema para mí.

**Hojas por sitio.** `DnTable`, `DnDraws`, `PGATable.csv` y `kmaxTable` por sitio
se escriben en `<path.uhs>/<ID.gmdp>/<siteID>/`, junto al `UHSRock.Rds` de
hazard: el árbol `uhs` es compartido por los dos productores. El informe no lo
lee, pero `pull` tiene que protegerlo.

## 3. Resolución de rutas

1. **Por contrato del productor.** Las 11 tablas de hazard contra
   `hazard.json` → `path.data`; las 3 de newmark contra `newmark.json` →
   `path.data`; `SSMTable` con hazard, como el resto de sus tablas.
2. **Sin default propio.** oqt-V2 propone que cada proyecto declare `path.*`
   explícito en los dos contratos (el paso 1 de su migración ya lo hace). El
   informe no copia el default `data` de hazard ni inventa otro: si la clave no
   está, falla nombrando contrato y clave.
3. **Sin modo legado.** Contrato ausente = error explícito que lo nombra; nunca
   se vuelve a `oq/data` por omisión. Acordado con oqt-V2 el 2026-09-19 y
   consistente con el propietario («no queremos hardcode que maneje legacy»): el
   layout de hoy se declara, no se infiere, con un `hazard.json` que diga
   `"path": {"data": "oq/data", "uhs": "oq/uhs", …}`. El paso 1 de
   `libraries/hazard/dev/migration/PLAN.md` escribe los dos contratos por
   proyecto.
   **Condición de secuencia:** hoy ninguno de los 7 proyectos tiene
   `hazard.json` y solo AR-S2C1R tiene `newmark.json`. Este cambio no puede
   entrar antes de que existan los dos contratos en cada proyecto, o los 7
   renders se detienen. Es coordinación con oqt-V2, no un obstáculo de diseño.
4. **Procedencia registrada por familia.** Generaciones distintas entre
   productores no son un error —son productores distintos, cada uno declara su
   raíz—; el riesgo real es que las tablas de newmark se hayan calculado sobre
   un `UHSRock`/`MCETable` de otra generación que la publicada. El informe
   registra, por familia, el contrato, la raíz resuelta y el md5 y la fecha de
   cada archivo leído, y deja eso en el transmittal.
   **Los metadatos no alcanzan solos.** El atributo se llama siempre `oqt`
   (`libraries/hazard/lib/R/tableIO.R:19-23`: `.writeTable` hace
   `attr(DT, "oqt") <- meta`); lo que cambió es un campo interno, donde la
   herramienta anterior guardaba su versión en `oqt`, hazard la guarda en
   `hazard`. Verificado en AR-S2L1W y en las tablas del CLI nuevo:
   `UHSTable`, `MCETable`, `DnTable`, `kmaxTable` y `ShearTable` no traen el
   atributo; `SSMTable` sí (`producer, oqt, written, units, keyRule, selection,
   engine, inputs`) y `AEPSTable` también (`producer, hazard, written, …`).
   oqt-V2 precisa que solo 7 de las 16 escrituras de productos de `runProcess`
   lo llevan, que newmark no escribe ninguno, y que escribirlo en todas cambiaría
   los bytes de productos hoy idénticos a la referencia congelada: es un cambio
   de formato que decide el propietario. El informe lo lee cuando está, como dato
   adicional, y nunca depende de él.
5. **Fallo explícito.** Una tabla requerida que no está en la raíz declarada
   falla nombrando contrato, clave y ruta, en lugar del `NULL` de hoy.

## 4. Parámetros

**Decisión del propietario 2026-09-19:** «si, no debería haber otro lugar. ni
data.R ni nada por el estilo». Los parámetros científicos salen del contrato del
productor que los consume, y no hay un segundo declarante.

| Origen | Claves que usa el informe |
| --- | --- |
| `newmark.json` | `ID.gmdp`, `IDm`, `TR.gmdp` (tablas de newmark), `Vref.gmdp`, `Da.gmdp`, `Hs`, `uscs`, `subduction`, y **`DaH.gmdp`** (ver abajo) |
| `hazard.json` | `TR.gmdp` (tablas de hazard), `uhsOQWeight`, `path.*` |
| `params.yml` | sin cambios: identidad y forma del documento |

`TR.gmdp` existe en los dos contratos con significados distintos —en hazard son
los períodos de retorno que construye; en newmark, la familia de demandas, y su
CLI se detiene si no coincide con la del `UHSRock`—. El informe toma cada uno del
contrato de su producto; nunca uno para todo.

**`DaH.gmdp` va a `newmark.json`.** Decisión del propietario: «es algo más duro
que rara vez el cliente quiera cambiar; no debería ir a params.yml». Es
coherente con lo que es: desplazamientos admisibles relativos en % de `Hs`, cuyo
producto `DaH.gmdp × Hs` determina los niveles `Da` que newmark tiene que haber
calculado —el propio mensaje del informe lo dice: «Declare it in DaH.gmdp and
re-run … --steps dn,kmax» (`scripts/tbl/kh.R:47`, `kmax.R:47`)—. Hoy newmark no
lo lee; queda pedido a oqt-V2 que lo acepte y lo preserve en el contrato, y que
diga si además debería derivar `Da.gmdp` de `DaH.gmdp × Hs` en vez de recibir
las dos listas.

**`siteID.gmdp` no necesita declararse.** `scripts/setup/global.R:43-44` ya lo
deriva de los datos cuando no existe, y la selección explícita del informe vive
en `params$report$sites`, que hoy declara `siteID`, `label`, `siteID.storage` y
`SRS` por sitio. No se agrega a ningún lado.

**`data.R` deja de cargarse.** Ninguna librería lo lee y el propietario lo
declaró legado. Sin modo legado (§3.3) no queda ningún camino que lo cargue.

### Qué es `params.yml` y por qué no cambia

Contiene el documento, no la ciencia (verificado en `AR-S2L1W/params.yml`):
identidad y portada (`title`, `site`, `location`, `project_id`, `year`, `client`,
`consultant`, `roles`, `signature`, `footer`, `URL`), selecciones de publicación
(`report.sites` con sus etiquetas y SRS, `ext`, `ssm`) y la sección `mapper`
(`radius_km`, `mw_min`, `mw_max`) que lee `mapper/run.py:33` en Python.
Nada de eso lo consume un productor, y nada de la ciencia entra aquí.

Su otro papel es estructural y ya existe: NGR lee `params.project_id`
(`lib/R/resources.R:246,257`) para sembrar los 21 artefactos de publicación.

## 5. Protección en `pull`

Hoy `lib/R/resources.R:89-92` protege `.git .ngr oq gmsp manifest.json
qrt.manifest.json`. Se agrega, sin default inventado:

- `hazard.json` y `newmark.json`.
- Cada raíz que esos contratos declaren, en particular `path.output` —las
  salidas de OpenQuake, irrecuperables— y el `path.uhs` compartido.
- `oq/sites`, `oq/calcs` y `run/` (incluido `run/_remote`, que identifica
  cálculos en el servidor).

Ningún recurso del scaffold puede escribir ahí, tampoco con `--force`.

## 6. Prueba: ya no depende de la etapa 2

No hay fecha para `data/hazard` y `data/newmark`, pero los dos CLI aceptan
cualquier ruta del contrato, así que el layout nuevo se arma sobre una copia:
copiar un proyecto, mover las tablas globales a `data/hazard` y `data/newmark`,
ajustar el bloque `path` de los dos contratos y confirmar con
`hazard process --dry-run` y `newmark process --steps dn,kmax --dry-run`.
oqt-V2 ofrece generar esa copia con los CLI reales cuando cierre lo que tiene en
curso; con una copia de un proyecto me alcanza.

Oráculo: la misma información en el layout legado y en el nuevo produce tablas y
productos idénticos; una ruta declarada ausente falla nombrando contrato, clave y
ruta; `pull --force` no invade ninguna raíz declarada.

## 7. Lo que decide el propietario

1. ~~Parámetros científicos desde los contratos~~ — **decidido: sí, sin otro
   lugar** (§4).
2. ~~`DaH.gmdp` y `siteID.gmdp` a `params.yml`~~ — **decidido: no**. `DaH.gmdp`
   va a `newmark.json`; `siteID.gmdp` no se declara (§4).
3. Secuencia: este cambio deja de renderizar cualquier proyecto sin sus dos
   contratos (§3.3). El paso 1 de la migración —escribir los 14 contratos de los
   7 proyectos— lo hace usted con su agente de migración; oqt-V2 solo verifica.
   ¿Se escriben primero y recién entonces entra el cambio?

Una regla dura que prohíba mezclar generaciones necesitaría un criterio de
compatibilidad entre generaciones que hoy nadie definió; queda fuera de esta
propuesta y es decisión suya si alguna vez hace falta.
