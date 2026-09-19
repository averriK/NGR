# Propuesta v2: cómo el informe SHA encuentra datos y parámetros

2026-09-19, sesión NGR-V2. Revisión de la v1 con las respuestas de oqt-V2
(`libraries/hazard/dev/migration/RESPUESTA-NGR-INTEGRACION-DATOS-20260919.md`,
commit 651af80 en hazard). Sustituye el borrador `project.data.json` de
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
3. **Proyecto sin contratos: modo legado.** Se resuelve como hoy (`oq/data`) y
   se carga `data.R`. Es la regla 2 de PROJECT-DATA.md, no una cadena de
   búsqueda: con contrato presente no se mira la otra ubicación nunca.
4. **Resolución por productor, con procedencia visible.** Durante la transición
   un proyecto puede tener `newmark.json` y todavía no `hazard.json` —es el caso
   de AR-S2C1R hoy—. Cada familia de tablas se resuelve con su propio contrato o,
   si no existe, en modo legado. Para que esa mezcla nunca sea silenciosa, el
   informe registra de dónde salió cada familia (contrato, clave y raíz) y lo
   deja en el transmittal.
5. **Fallo explícito.** Una tabla requerida que no está en la raíz declarada
   falla nombrando contrato, clave y ruta, en lugar del `NULL` de hoy.

## 4. Parámetros

Un dueño por clave, el contrato del productor que la consume (P5 de oqt-V2):

| Origen | Claves que usa el informe |
| --- | --- |
| `newmark.json` | `ID.gmdp`, `IDm`, `TR.gmdp` (para las tablas de newmark), `Vref.gmdp`, `Da.gmdp`, `Hs`, `uscs`, `subduction` |
| `hazard.json` | `TR.gmdp` (para las tablas de hazard), `uhsOQWeight`, `path.*` |
| `params.yml` | `DaH.gmdp`, `siteID.gmdp`, y lo que ya tenía: `project_id`, consultor, sitios del reporte, sección `mapper` |

`TR.gmdp` existe en los dos contratos con significados distintos —en hazard son
los períodos de retorno que construye; en newmark, la familia de demandas, y el
propio CLI se detiene si no coincide con la del `UHSRock`—. El informe toma cada
uno del contrato de su producto; nunca uno para todo.

**`data.R` deja de cargarse cuando el proyecto tiene contratos.** Ninguna
librería lo lee (0 `source()` en hazard y newmark) y el propietario lo declaró
legado. En modo legado se sigue cargando, sin cambios.

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

1. ¿El informe lee sus parámetros científicos de los contratos de los
   productores (§4), o quiere una declaración propia del informe?
2. ¿`DaH.gmdp` y `siteID.gmdp` a `params.yml`, que es donde caen por descarte?
3. ¿Mezclar generaciones entre productores (§3.4) es un estado aceptable
   mientras dure la transición, con procedencia visible, o debe ser un error?
