# Handoff: terminar la etapa 1 de `ngr` y probarla con proyectos reales (2026-09-18 15:00 -03)

Autor: sesión NGR-V2, por orden del propietario: «dale un handoff … para que el otro agente termine
de implementar lo que falta y haga las pruebas que faltan con proyectos reales». Solo hechos
observados hoy, con su fuente; lo no observado dice UNKNOWN.

## 0. Leer primero (rutas absolutas)

1. `/Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-repair/HANDOFF-PRUEBAS-REALES-20260918.md` (este archivo)
2. `/Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-repair/STATE.md` (estado operativo; lo inyecta el hook `~/.claude/lifecycle/continuity.py` vía `/Users/averrik/Cloud/github/libraries/NGR/dev/SoT/ACTIVE.md`)
3. `/Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-repair/PLAN.md` (plan SoT: R1–R8, oráculos, aceptación real)
4. `/Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-repair/HANDOFF-20260918.md` (§3 arquitectura de scaffolds; §7 instaladores clásicos)
5. `/Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-repair/NOTICE-C2-VERIFICATION-20260918.md` (verificación de la instalación)
6. `/Users/averrik/Cloud/github/libraries/NGR/cli/README.md` (uso del CLI; conversión de proyectos: sección del manifiesto de proyecto)
7. Router y skills del propietario: `/Users/averrik/.claude/CLAUDE.md`; aplican `code`, `sot`, `git`, `r`, y `qrt` solo para operar el oráculo.

## 1. Punto de partida verificado (14:49–15:00 -03)

- NGR `main` = `origin/main` = `65795cc`. `install/` commiteado en `399602a` (kit de familia corregido:
  bash 3.2, sello `dirty` limitado a `cli/ install/ lib/`, archivos publicados a root).
- **`ngr` instalado y limpio** (reinstalación del propietario 14:38): `/usr/local/bin/ngr --version` →
  `ngr 0.2.0-dev` / `package: NGR 0.4.0` / `cli: /usr/local/libexec/ngr/main.R` /
  `build: backup-before-typewriter-height-167-g65795cc` (sin `-dirty`); recibo
  `/usr/local/libexec/ngr/install.json` esquema 4, `source.dirty false`, 405 archivos con md5 iguales;
  las 529 entradas de `/usr/local/libexec/ngr` son de root.
- **Sello sin DRAFT comprobado:** proyecto scratch, `ngr pull --from ngr`, `ngr render _master/slides.qmd
  --profile revealjs` → pie `Pub: 18/09/2026 Rev.65795cc`.
- Oráculos vivos: `/usr/local/bin/qrt` (BUILD_INFO `aa43a56-dirty`) y `/usr/local/bin/psha`
  (`1bb0769f-dirty`). No desinstalarlos: son la referencia y siguen operando los proyectos sin convertir.
- Scaffold SHA: `/Users/averrik/Cloud/github/reports/sha/manifest.json` (carpeta SIN git; con cambios de
  R2/R4/R8: `manifest.json`, `scripts/setup/cover.R`, `scripts/setup/transmittal.R`).
- Única aceptación real hecha (PLAN.md:112-114): deck `sha` de AR-S2L1W en copia liviana, qrt+psha vs
  `ngr` con la librería del árbol (no la instalada): 578 archivos, 529 widgets, 598 captions, bytes
  idénticos tras normalizar sello e ids de widgets. **Todo lo demás de proyectos reales está sin probar.**

## 2. Proyectos reales (inventario de solo lectura, 14:50)

Raíz: `/Users/averrik/Cloud/github/projects/`. Nueve tienen `qrt.manifest.json` y `_master/`; ninguno
tiene todavía `manifest.json` (ninguno convertido):

| Proyecto | `oq/data` | Rama |
| --- | --- | --- |
| `/Users/averrik/Cloud/github/projects/AR-M2V4D` | sí | main |
| `/Users/averrik/Cloud/github/projects/AR-S2C1R` | sí | main |
| `/Users/averrik/Cloud/github/projects/AR-S2L1W` | sí | dev |
| `/Users/averrik/Cloud/github/projects/AR-S2L1X` | no | main |
| `/Users/averrik/Cloud/github/projects/AR-S2P30` | sí | main |
| `/Users/averrik/Cloud/github/projects/AR-SABP0` | sí | main |
| `/Users/averrik/Cloud/github/projects/AR-SAC00` | sí | main |
| `/Users/averrik/Cloud/github/projects/AR-SACU0` | sí | main |
| `/Users/averrik/Cloud/github/projects/AR-SAD40` | no | main |

## 3. Reglas del propietario para probar con proyectos reales (no negociables)

1. **Los proyectos son de solo lectura.** Nada de editar ni de git dentro de `projects/AR-*`. Toda
   prueba corre sobre una **copia liviana** en scratch (carpetas de scaffold + `oq/data` + manifiesto);
   al terminar se borra («borra los Gb de basura que generas»).
2. **Sin efectos en Netlify:** deploy y dominios solo con `--dry-run`. Un deploy real necesita orden expresa.
3. **Prohibido inferir:** cada resultado cita comando, salida y ruta; lo no observado es UNKNOWN.
   Las citas `archivo:línea` son textuales.
4. **No fabricar datos:** `oq/data` es salida pura del productor; no se mezcla ni se edita.
5. **La librería NGR es de producción:** los 96 archivos preexistentes de `lib/` (byte-idénticos desde
   `f192453`) no se modifican sin plan SoT (línea base, candidato, oráculo que falle en la base).
   Agregar exports sí. `install/` es del kit de familia: no se toca desde aquí.
6. Commit y push por cambio aceptado, rutas exactas, identidad humana, sin atribución a IA (permiso
   permanente del propietario del 2026-09-17).

## 4. Pruebas que faltan con proyectos reales

Método de referencia (el de la aceptación ya hecha): copia liviana del proyecto; producto A con el
oráculo (`qrt`/`psha` instalados, sobre la copia sin convertir); producto B con `ngr` instalado (sobre
otra copia convertida); comparar árboles normalizando solo el sello `Pub:/Rev.` y los ids de widgets.
Entorno: `PATH="/usr/local/bin:$PATH"` (qrt necesita bash ≥ 4.4).

| # | Prueba | Aceptación |
| --- | --- | --- |
| T1 | **Conversión (R3) en copia de cada uno de los 9 proyectos:** renombrar `qrt.manifest.json` → `manifest.json`, borrar su bloque `scaffolds`, `ngr pull --from ngr --from /Users/averrik/Cloud/github/reports/sha/manifest.json --force`. Solo se verificó en un proyecto creado con `qrt init` + `psha init` (PLAN.md:66-73), nunca en uno real. | `ngr status` sin conflictos; los artefactos conservan `siteSlug`/`domain`; `ngr doctor` pasa; las 4 semillas del proyecto (`_master/book.{es,en}.qmd`, `docx.{es,en}.qmd`) quedan intactas byte a byte; registrar por proyecto cuántos `equal`, `project-seed` y cualquier otro estado. |
| T2 | **Render de TODOS los artefactos del manifiesto** de una copia convertida (empezar por AR-S2L1W, que tiene referencia): `ngr render --manifest manifest.json --dry-run` y luego el render real; mismo conjunto con `qrt render --manifest qrt.manifest.json` en la copia sin convertir. Hoy solo está probado el deck `sha`. | Cada alias: salida presente y árbol idéntico al del oráculo tras normalizar sello e ids. Cubrir los cuatro perfiles (`revealjs`, `book`, `html`, `docx`) y los dos idiomas. Listar alias fallidos con su error textual. |
| T3 | **Deriva y restauración (R2)** en copia real: editar un master administrado (`_master/sha.qmd`) y una semilla; `ngr status --check`; `ngr pull --force _master`. | `status --check` sale ≠ 0 con el administrado editado; `pull --force` lo restaura y conserva la semilla (paridad con `psha pull --force _master`: «33 files restored, 4 project-owned kept»). |
| T4 | **Hidratar desde ubicación arbitraria (R1)** en copia real: copiar `reports/sha` a otra ruta, `ngr pull --from <copia>/manifest.json --force scripts`, y volver a la original. | Mensaje `[pull] source sha now at … (was …)`, hidratación completa, y regreso sin pasos extra. Con la ruta guardada borrada: error que nombra la fuente y pide `--from`. |
| T5 | **Sello en documento real:** con `reports/sha` sin git el sello del scaffold sale `Rev.—`/DRAFT por esa fuente. | Registrar el sello exacto obtenido; la corrección depende de la decisión del propietario (§5 P1). |
| T6 | **Publicación en seco** en copia real convertida: `ngr deploy init --manifest manifest.json --dry-run`, `ngr deploy --manifest manifest.json --dry-run`, dominio `--dry-run`. | Resuelve los mismos `siteSlug`/`domain` que el `qrt.manifest.json` original; ninguna llamada real a Netlify. |
| T7 | **Proyectos sin `oq/data`** (AR-S2L1X, AR-SAD40): conversión y `--dry-run`. | El fallo por datos faltantes nombra el dato; no aborta con traza cruda. |
| T8 | **Convivencia:** tras instalar `ngr`, `qrt --help`/`psha --help` y un `qrt status` en una copia sin convertir. | Los oráculos siguen operando igual. |
| T9 | **Suites del repo** con la instalación nueva: `bash install/cli/test-installers.sh`; `Rscript -e 'devtools::test("lib")'`; `cli/tests` (comando en `HANDOFF-SUPERVISOR-20260918.md` §5; ojo: parte de esas pruebas usaban el `install.py` retirado, ya adaptadas en `5878651`). | 0 fallos; registrar conteos. |

Registrar cada prueba en `STATE.md` como evidencia compacta (una línea `NEXT-CLOSED` por prueba
cerrada; sin diario) y la evidencia voluminosa en `dev/SoT/cli-repair/<prueba>/`. Un defecto encontrado
se admite como candidato SoT nuevo (R9, R10…) en `PLAN.md` antes de tocar código.

## 5. Lo que falta implementar o decidir

| # | Pendiente | De quién |
| --- | --- | --- |
| P1 | `reports/sha` sin git → sello `Rev.—`/DRAFT para ese scaffold. Decidir si pasa a repo git (o si se instala con `BUILD_INFO` propio). | Propietario |
| P2 | Remover el fósil NGR 0.3.10 de la librería de root: `sudo Rscript -e 'remove.packages("NGR", lib = "/Library/Frameworks/R.framework/Versions/4.6/Resources/library")'`. | Propietario |
| P3 | Convertir de verdad los 9 proyectos (después de T1–T2 verdes y con orden expresa por proyecto; implica tocar repos de proyecto). | Propietario ordena; agente ejecuta |
| P4 | Defectos que aparezcan en T1–T8: candidato SoT por defecto, oráculo que falle en la base. | Agente de NGR |
| P5 | **Objetivo principal del propietario aún abierto:** que los scaffolds no dupliquen código que la librería o el CLI pueden manejar. `install/README.md:121-123`: «Scaffold builder migration and complete project acceptance remain in progress». Requiere inventario de `reports/sha/scripts/` contra exports de NGR y plan SoT propio. | Agente de NGR, con plan aprobado |
| P6 | **Etapa 2** (palabra del propietario): el CLI expone gráficos y tablas de la librería para agentes con skills en `skill/`. Sin empezar; `skill/`, `app/`, `mcp/` son placeholders. Plan SoT propio al cerrar la etapa 1. | Agente de NGR, con plan aprobado |
| P7 | Kit: huérfano `install/cli/checkRuntime.R`; mensaje sin sudo (`Installation parent is not a writable directory` en vez de `[ERROR] … run: sudo bash install/install.sh`); re-sync del canónico en los demás repos; Windows sin ejecutar. | Agente del instalador / agentes de cada repo |
| P8 | Avisar a dbAudit la decisión R6 (parser en `cli/main.R`). | Propietario |
| P9 | 38 commits «Record Nth R7 probe» en `origin/main`: dejarlos o limpieza de historia con orden expresa. | Propietario |

## 6. Trampas verificadas (no repetir)

1. `cli/tests` y cualquier uso del oráculo qrt: `/usr/local/bin` delante de `/usr/bin` en `PATH`, y
   `mkdir -p /tmp/ngr-tests` antes (`NGR_TEST_ROOT`).
2. No afirmar nada de una rama no ejecutada (sudo, Windows, deploy real).
3. No escribir instaladores ni variantes; `install/` se copia byte a byte del canónico
   `/Users/averrik/github/agents/install/`.
4. `STATE.md` es vista actual, no diario; validar tras cada reescritura:
   `cd /Users/averrik/Cloud/github/libraries/NGR && printf '{"cwd":"%s","hook_event_name":"SessionStart","source":"startup"}' "$PWD" | python3 ~/.claude/lifecycle/continuity.py`
5. Ajenos en el árbol de NGR, no tocar: `dev/plan/cli-fusion/STATE.md`, `dev/docs/`,
   `dev/SoT/NOTICE-INSTALLER-FAMILY-STANDARD-20260918.md`.
