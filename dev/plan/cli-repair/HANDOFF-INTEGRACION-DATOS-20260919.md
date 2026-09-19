# Handoff a oqt-V2 (hazard + newmark): cómo se integra el informe SHA

2026-09-19, sesión NGR-V2. Pedido del propietario: «es momento de integrarnos
entre los tres». Respondé en este archivo, en `dev/plan/cli-repair/STATE.md` de
NGR, o por mensaje a la sesión `NGR-V2`. Reviso mi propuesta con tus respuestas.

Mi propuesta actual, que puede cambiar entera con lo que contestes:
`dev/plan/cli-repair/PROPUESTA-DATOS-20260919.md`.

## 1. Qué hace NGR y qué no

El CLI `ngr` **no lee datos científicos**: 0 coincidencias de
`oq/data|data/hazard|data/newmark` en `lib/R` y `cli/`. Hidrata recursos,
renderiza Quarto y publica. Quien lee las tablas es el **scaffold sha**
(`libraries/reports/sha`, repo git desde ayer), que NGR distribuye con `pull`.

Hoy ese scaffold está clavado en el legado, en dos lugares:

- `scripts/setup/global.R:3` — `.loadOQ()` arma `file.path(root, "oq", "data",
  "<Tabla>.Rds")` para 13 tablas, y **devuelve `NULL` en silencio** si el archivo
  no existe. Con datos en dos ubicaciones, el informe publicaría la generación
  vieja sin avisar.
- `scripts/setup/setup.R:45` — `source(file.path(root, "oq", "data", "data.R"))`.

El propietario ya dijo que ese `setup.R` es obsoleto y que `oq/data` es legacy.

## 2. Reparto de tablas que necesito confirmar

Las 13 que carga el informe, más `SSMTable` que leen `scripts/tbl/SSM.*.R`:

| Productor (mi suposición) | Tablas |
| --- | --- |
| hazard | `UHSTable`, `AEPTable`, `AEPSTable`, `MCETable`, `ScenarioTable`, `ScenarioGMPETable`, `GMPETable`, `ASCETable`, `DEQTable`, `RMwTable`, `SSMTable` |
| newmark | `DnTable`, `kmaxTable`, `ShearTable` |

**P1.** ¿Es correcto ese reparto?
**P2.** ¿Conservan nombre de archivo y esquema, o la consolidación de
`HAZARD-NEWMARK-INTEGRATION.md` los cambia (p. ej. `UHSRock` como tabla de
intercambio)? El informe las lee por nombre; un cambio de esquema es trabajo
mío y necesita saberse antes, no después.

## 3. Rutas

`hazard process --help` documenta `path.data` con **default `data`**, no
`data/hazard`. El propietario habla de `data/hazard` y `data/newmark`.
`newmark.json` de AR-S2C1R declara hoy `"path": {"data": "oq/data", …}`.
Tres valores distintos ya en circulación.

**P3.** ¿La ruta definitiva la declara siempre el contrato del proyecto
(`hazard.json` → `path.data`, `newmark.json` → `path.data`), o hay un default
que los proyectos no van a escribir? Mi propuesta es leer el contrato y no
codificar ningún nombre; necesito que eso sea cierto de los dos lados.
**P4.** ¿Los productos por sitio (`DnDraws`, `PGATable`) van bajo la misma raíz
o tienen la suya? El informe hoy no los lee, pero quiero saberlo antes de
proteger raíces en `pull`.

## 4. Parámetros: el reemplazo de `data.R`

`oq/data/data.R` de AR-S2C1R define 19 identificadores. El informe usa 10 de
ellos, contando los archivos que los nombran:

`ID.gmdp` (20), `IDm` (32), `TR.gmdp` (19), `Hs` (9), `Da.gmdp` (7),
`Vref.gmdp` (4), `DaH.gmdp` (2), `subduction` (2), `siteID.gmdp` (1),
`uscs` (1).

`newmark.json` ya trae `ID.gmdp`, `TR.gmdp`, `Vref.gmdp`, `Da.gmdp`, `Hs`,
`uscs`, `subduction`, `Mw.gmdp`, `NS`, `Dn_weights`, `lo.*`, `s.*`.

**P5.** ¿El informe debe leer esos parámetros de `newmark.json`/`hazard.json`
—es decir, los contratos son también la configuración del proyecto— o los
contratos son solo del productor y el informe necesita su propia declaración?
**P6.** `IDm` (32 archivos del informe) y `DaH.gmdp` no están en `newmark.json`.
¿Quedan en el informe (`params.yml`) o los suma algún contrato?
**P7.** Cuando un proyecto tiene contratos, ¿`data.R` deja de cargarse? Si dos
lugares declaran `TR.gmdp`, quiero un solo dueño, no una precedencia silenciosa.

## 5. Coexistencia y pruebas

**P8.** Durante la transición, ¿qué decide qué generación publica el informe?
Mi propuesta: el contrato del proyecto, y nada de buscar en la otra ubicación.
**P9.** Voy a proteger en `ngr pull` las raíces declaradas y los propios
contratos, como ya protejo `oq/` y `gmsp/` (`lib/R/resources.R:89-92`), para que
ningún recurso del scaffold pueda escribir ahí ni con `--force`. ¿Alguna ruta
que NO deba proteger?
**P10.** ¿Cuándo va a existir el primer proyecto con `data/hazard` y
`data/newmark` poblados? Mis pruebas T1–T9 corrieron sobre copias con `oq/data`
antes de la migración; la prueba que falta —misma información en los dos
layouts produce productos idénticos— no puede correr hasta que exista uno.
Con una copia de un solo proyecto me alcanza; trabajo siempre sobre copias y no
toco los proyectos.

## 6. Lo que yo pongo

- Resolución por contrato en `global.R` y `setup.R`, con fallo explícito que
  nombre contrato, clave y ruta en vez del `NULL` silencioso de hoy.
- Protección de raíces y contratos en `pull`.
- Todo bajo plan SoT con línea base congelada del scaffold, y el oráculo de
  siempre: los mismos datos en los dos layouts producen tablas y productos
  idénticos.
