# Propuesta: cómo el informe encuentra los datos durante la coexistencia

2026-09-19, sesión NGR-V2. Sustituye el borrador `project.data.json` de
`libraries/hazard/dev/PROJECT-DATA.md` §«Borrador concreto». Pendiente de
decisión del propietario. Todo lo afirmado se verificó hoy con lectura directa.

## 1. `params.yml` no es un requisito de Quarto (demostración)

| Comprobación | Resultado |
| --- | --- |
| ¿Algún master declara `params:` en su frontmatter (mecanismo de Quarto)? | No: `grep '^params:' reports/sha/_master/*.qmd` → 0 |
| ¿NGR pasa `--execute-params` o `metadata-files` a Quarto? | No: 0 coincidencias en `lib/R` y `cli/`. El comando es `c("render", "--profile", profile, "--output-dir", "_ngr-output")` (`lib/R/quartoRender.R:86`) o la forma directa (`:124`) |
| ¿El `_quarto.yml` base lo menciona? | No: `cli/scaffold/yml/_quarto.yml` no nombra `params.yml` |

Quarto nunca ve `params.yml`. Lo abren a mano cinco consumidores:
`reports/sha/scripts/setup/setup.R:49-51`, `checkParameters.R:1`,
`transmittal.R:89,130`, `mapper/run.py:33` (Python) y NGR
`lib/R/resources.R:246,257` (`params.project_id`, que siembra los 21 artefactos).

**Conclusión:** `params.yml` es configuración del proyecto leída por R y Python,
no una pieza del ecosistema Quarto. Se conserva tal cual — sigue siendo semilla
(`manifest.json`: `params.yml` → `ownership: seed`) y sigue siendo la única
fuente de `project_id`, consultor, sitios del reporte y sección `mapper`.

## 2. Qué está mal en `project.data.json`

1. **Naming.** La casa nombra los archivos de la raíz con una palabra en
   minúscula más su formato: `manifest.json`, `params.yml`, `hazard.json`,
   `newmark.json`. El propietario ya rechazó el compuesto punteado
   (`qrt.manifest.json` → `manifest.json`). `project.` es además redundante:
   todo lo que está en la raíz pertenece al proyecto.
2. **Es un tercer declarante de la misma ruta.** Los productores ya declaran
   dónde escriben: `hazard process [CONFIG]` lee `hazard.json` con
   `path.data` («Global tables and SSM leaves, default: `data`», ayuda del CLI;
   `lib/R/processContract.R:41-80`), y `newmark.json` ya existe en AR-S2C1R con
   `"path": {"data": "oq/data", "uhs": …, "calc": …}`. Un mapa aparte repite esa
   decisión y puede quedar desincronizado, que es justo lo que PROJECT-DATA.md
   quiere evitar («Una ubicación autorizada por producto»).

## 3. Propuesta: el informe lee el contrato del productor

Sin archivo nuevo y sin vocabulario nuevo.

| Dato | Declarante | Clave |
| --- | --- | --- |
| UHSTable, AEPTable, AEPSTable, MCETable, ScenarioTable, ScenarioGMPETable, GMPETable, ASCETable, DEQTable, RMwTable, SSMTable | `hazard.json` | `path.data` |
| DnTable, kmaxTable, ShearTable | `newmark.json` | `path.data` |
| Parámetros del informe (consultor, sitios, mapper, `project_id`) | `params.yml` | sin cambios |

Reglas:

1. **Resolución.** El informe resuelve cada tabla contra el `path.data` del
   contrato de **su** productor, relativo a la raíz del proyecto. Nada de
   nombres fijos: hoy conviven tres valores reales (`oq/data` en los proyectos,
   `data` por defecto en el CLI hazard, `data/hazard` en la conversación del
   propietario). El contrato es el que manda.
2. **Sin contrato, contrato heredado.** Si `hazard.json`/`newmark.json` no
   existen, el informe usa `oq/data` como hasta hoy. Es la regla 2 de
   PROJECT-DATA.md, no una cadena de búsqueda: con contrato presente nunca se
   mira la otra ubicación.
3. **Selección de generación.** Durante la coexistencia, la generación que se
   publica es la que declara el contrato en ese momento. Para renderizar la
   vieja se apunta el contrato a `oq/data`; para la nueva, a su raíz. Una sola
   decisión, en el archivo que además la produjo.
4. **Fallo explícito.** Hoy `.loadOQ` (`reports/sha/scripts/setup/global.R:3`)
   devuelve `NULL` en silencio si el archivo no está: con datos en dos lugares,
   el informe publicaría números viejos sin avisar. Con contrato declarado, una
   tabla requerida ausente falla nombrando contrato, clave y ruta.
5. **Protección de `pull`.** `lib/R/resources.R:89-92` protege
   `.git .ngr oq gmsp manifest.json qrt.manifest.json`. Se agrega la raíz que
   declaren los contratos —y `hazard.json`/`newmark.json` como propiedad del
   proyecto— para que ningún recurso del scaffold pueda invadirlas ni con
   `--force`.

## 4. Lo que esto no resuelve

`setup.R:45` carga `oq/data/data.R`, que mezcla selección científica con
controles del informe (PROJECT-DATA.md lo señala en su tabla de lecturas). Los
contratos JSON se llevan la parte científica; la parte de reporte no tiene
todavía dueño. **Decisión del propietario:** si esos controles pasan a
`params.yml` (su lugar natural) o si `data.R` sobrevive como archivo del
proyecto. Mientras no se decida, `data.R` se sigue cargando donde esté.

## 5. Trabajo que implica (bajo plan SoT, con línea base congelada)

- `reports/sha/scripts/setup/global.R`: resolver por contrato y fallar nombrando.
- `reports/sha/scripts/setup/setup.R`: leer los contratos antes de `params.yml`.
- `NGR/lib/R/resources.R`: proteger las raíces declaradas y los contratos.
- Oráculo: los mismos datos en el layout viejo y en el nuevo producen tablas y
  productos idénticos; una ruta declarada ausente falla en vez de devolver NULL;
  `pull --force` no invade las raíces declaradas.
