# Plan SoT de reparación: `ngr` reproduce los flujos de qrt y psha

2026-09-17. Sesión NGR-V2. Continuidad operativa: [STATE.md](STATE.md), seleccionada por
`dev/SoT/ACTIVE.md`. Este plan fija alcance, candidatos y oráculos; no tiene un
`Next` propio.

## Palabra del propietario (textual, 2026-09-17, en esta sesión)

- «vamos a arreglar las cosas graves, vamos a asegurar que el cli ngr puede reproducir los viejos flujos del qrt y del psha, que puede hidratar desde una locacion arbitraria. eso debe funcionar.»
- «la libreria NGR es una libreria en produccon. podemos agregar cosas pero no podemo smodificar nada sin un plan SoT.»
- «eo otro agente termino de revertir las cagadas que hizo. todo tuyo el repo»
- Sobre el nombre del manifiesto de proyecto: «no me gusta ese naming. qrt no existe mas. habiamos rechazdo ese naming y habia un apropuesta de un manifest unico.»
- Sobre dónde vive el intérprete de argumentos: «adoptamos el segundo patron, que el parser vive en l main.R.»
- Concepto: «la libreria proporciona todas las funciones que usa el nuevo CLI. el CLI no deberia tener funiones propias en R a menos que sean de interfacing.»
- Hoja de ruta: «etapa 1: ngr (CLI) reemplaza a qrt y a psha. etapa 2: ngr (cli) potencia al maximo el uso de los recursos que proporciona el ngr library, para que agentes usando skills guardados en skill/ puedan operar el CLI y generar plots complejos.»
- Sobre convertir proyectos existentes: «LA CONVERSION DE PROPYECTOS ES un overkil. es nceario hacerlo ahora?» Sin verbo nuevo (ver R3).

## Línea base

| Objeto | Identidad |
| --- | --- |
| NGR | `9d24f3705021acf340bea004b3a8f2b4abcfe384` (`main` = `origin/main`, 2026-09-17 18:54) |
| Superficie de producción anterior | `f192453`: sus 96 archivos de paquete son byte-idénticos en `lib/` de la línea base |
| Scaffold SHA | `/Users/averrik/Cloud/github/reports/sha` (sin git); `manifest.json` sha256 `6640a7f22a9450af…` |
| Oráculo qrt | `/usr/local/libexec/qrt`, BUILD_INFO `aa43a56-dirty`, 400 archivos |
| Oráculo psha | `/usr/local/libexec/psha`, BUILD_INFO `1bb0769f…-dirty`, 771 archivos |

Regla de alcance: ningún candidato modifica los 96 archivos preexistentes del
paquete. Los candidatos tocan archivos agregados por la fusión (`b7e09a1`), el
scaffold SHA, `cli/` e `install/`. Cada candidato es una hipótesis; su oráculo
debe fallar en la línea base y pasar en el candidato; las suites existentes
(testthat del paquete y `cli/tests`) deben seguir pasando.

## Oráculo común

Flujos viejos ejecutados con qrt/psha **instalados** en una carpeta temporal y
comparados con `ngr` sobre una librería construida desde el commit bajo prueba.
Observados el 2026-09-17 contra `707089b`: coinciden arranque, `doctor`,
deriva local, rechazo sin `--force`, restauración con `--force` y un render de
prueba. Fallan R1–R5.

## Candidatos

### R1 — Hidratar desde una ubicación arbitraria
- Defecto observado: tras un primer `pull`, `ngr pull --from <otra copia>/manifest.json --force scripts`
  termina `Source sha already associated; refusing implicit retarget`
  (`lib/R/resources.R:228`); no existe forma de redirigir. Con la ruta guardada
  inexistente, `status` muere con el error crudo de `normalizePath`.
- Oráculo viejo: `PATH_PSHA=<copia> psha pull --force scripts` hidrata desde la copia y
  volver a la instalación no requiere nada.
- Diferencia pedida: la identidad de una fuente es su `id`. Un `--from` explícito cuyo
  `id` ya está asociado redirige la asociación e hidrata desde allí, informándolo.
  Una ruta guardada inexistente produce un error que nombra la fuente y pide `--from`.
- Estable: conflictos entre fuentes, semillas, recibos, selección parcial, `--dry-run`,
  `--force`, recuperación.
- Archivos: `lib/R/resources.R`, prueba nueva en `lib/tests/testthat/test-resources.R`.

### R2 — Masters hidratables
- Defecto observado: `_master` completo es `seed`; `ngr pull --force _master` deja
  `_master/sha.qmd` en `preserve` y `status --check` sale 0.
- Oráculo viejo: `psha pull --force _master` → «33 files restored, 4 project-owned kept»
  (`bin/psha:37-40` protege solo `book.{es,en}.qmd` y `docx.{es,en}.qmd`).
- Diferencia pedida: mismos 33 administrados y 4 semillas. Archivo: `reports/sha/manifest.json`
  (y el motor solo si la declaración por archivo lo exige).

### R3 — Proyectos existentes (resuelto sin código)
- Hecho: los 9 proyectos reales tienen `qrt.manifest.json`; `ngr` no lee ese nombre (decisión del propietario: manifiesto único `manifest.json`).
- El propietario consideró excesivo un comando de conversión. Verificado el 2026-09-17 en una copia de un proyecto creado con `qrt init` + `psha init`:
  renombrar a `manifest.json`, borrar su bloque `scaffolds` (recibos escritos por psha bajo el nombre `psha`) y correr
  `ngr pull --from ngr --from <sha>/manifest.json --force` deja 1154 `equal` y 2 `project-seed`, conserva los 21 artefactos con
  `siteSlug`/`domain` y pasa `doctor`. Solo renombrar no alcanza: «Unresolved legacy claim from psha at …».
- Efecto: procedimiento de tres pasos documentado en `cli/README.md`, `lib/vignettes/scaffolds.Rmd` y `cli.Rmd`. Mientras un
  proyecto no se pase, qrt y psha instalados lo siguen operando.

### R4 — Destinos de publicación sembrados
- Defecto observado: los 21 artefactos sembrados no traen `siteSlug` ni `domain`;
  `toc.R:95` aborta sin dominio y el transmittal queda vacío.
- Oráculo viejo: `psha init` siembra `<base>-<slug>` y `<base>-<slug>.srk.ar` desde `params.project_id`.
- Diferencia pedida: el scaffold declara plantillas y el motor las resuelve al sembrar;
  el dominio corporativo vive en el scaffold, no en NGR.

### R5 — Identidad de revisión sin git
- Defecto observado: fuente sin git ⇒ `commit: unknown` ⇒ todo documento sale
  `Rev.— · DRAFT` (`lib/R/resources.R:147-159`, `lib/R/quartoRenderStamp.R:48`).
  Afecta a `ngr` instalado y a `reports/` (no es repo git).
- Oráculo viejo: el instalador escribe `BUILD_INFO` con commit y estado sucio; `recordScaffold.R` lo lee.
- Diferencia pedida: el instalador registra la identidad junto al scaffold base y el motor
  la lee antes de recurrir a git.

### R6 — El parser vive en `cli/main.R`
- Decisión del propietario. Hoy `cli/main.R` llama a `.cliNgr` privado con `getFromNamespace`;
  con una librería instalada anterior falla hasta `--help` (`object '.cliNgr' not found`).
- Diferencia pedida: `cli/main.R` interpreta argumentos y llama solo funciones exportadas;
  `--help` y `--version` funcionan sin librería; versión mínima exigida en runtime;
  la librería exporta las operaciones de manifiesto que hoy viven dentro de `.cliDeploy`
  (selección, validación de `siteSlug`/`domain`, comprobación de salidas).
- Acoplado: subir la versión del paquete (0.3.11 identifica hoy builds con APIs distintas).
- Oráculo: `cli/tests` completo más un caso nuevo con librería antigua.

### R7 — Instalador
- Defecto observado: sin `Rscript` sale 1 sin mensaje (`install/install.sh:4` bajo `set -e`);
  exige `--library`, `--prefix` y `--tarball|--build`; no escribe identidad de build.
- Pedido del propietario: asegurar R, instalar la librería si falta, dejar `.sh` y `.ps1`.
- La suite `install/` está copiada en 7 repos (derivó en ssel y zot): cambio de familia, decisión del propietario.

### R8 — Rastros del nombre qrt dentro de NGR
- Aprobado por el propietario («qrt no existe mas»; «ok a … 4»). Alcance: archivos agregados por la fusión, no los 96 preexistentes:
  variable `QRT_RENDER_STAMP` y carpeta temporal `_qrt-output` en `lib/R/quartoRender.R`, los dos filtros lua que leen esa variable,
  sus pruebas y la documentación escrita por la fusión. Ningún proyecto real usa todavía `ngr`, así que el cambio de nombre no deja filtros viejos huérfanos.
- Oráculo: el sello sigue llegando al pie de página del render de prueba; suites completas.

## Etapas (palabra del propietario)

1. `ngr` reemplaza a qrt y a psha: R1–R8 de este plan.
2. `ngr` expone los recursos de la librería (gráficos y tablas) para que agentes con skills guardados en `skill/` operen el CLI y generen plots complejos. Se planifica al cerrar la etapa 1; R6 (parser en `cli/main.R`) es su base.

## Orden

R1 (hecho, `3f27df4`) → R2 (integrado) → R8 → R4 → R5 → R6 → R7. Uno por vez; commit y push solo con autorización explícita.

## Familia

Briefing común: `tools/spt/dev/handoff/model/MODEL-LIBRARY-CLI-SKILL-APP-20260917.md`
(sesión gmsp-V2; sin commitear; ubicación definitiva pendiente del propietario).
dbAudit es el otro repo con parser privado en la librería y debe recibir la decisión R6.
