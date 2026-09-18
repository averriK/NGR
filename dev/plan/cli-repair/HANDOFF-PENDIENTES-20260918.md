# Handoff de pendientes: CLI `ngr` y librería NGR (2026-09-18 13:45 -03)

Autor: sesión NGR-V2 (Claude), por orden del propietario: «prepara un handoff
declarando lo que falta hacer. otro agente está corrigiendo el instalador».
Solo hechos observados hoy con su fuente; lo no observado dice UNKNOWN.
**El instalador (`install/`) es superficie de otro agente: no tocarlo desde aquí.**

## 0. Rutas absolutas

Handoffs y documentos rectores (leer en este orden):

1. `/Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-repair/HANDOFF-PENDIENTES-20260918.md` (este archivo)
2. `/Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-repair/HANDOFF-SUPERVISOR-20260918.md` (supervisor, 13:20: compuerta de C2, división de trabajo, trampas)
3. `/Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-repair/HANDOFF-20260918.md` (NGR-V2: plan R1–R8, inventario de instaladores clásicos §7, arquitectura de scaffolds §3)
4. `/Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-repair/NOTICE-SUPERVISOR-INSTALLER-20260918.md` (aviso al revisor del instalador)
5. `/Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-repair/PLAN.md` (plan SoT de la etapa 1)
6. `/Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-repair/STATE.md` (estado operativo; hoy INVÁLIDO para el hook, ver §2.C1)
7. `/Users/averrik/Cloud/github/libraries/NGR/dev/SoT/NOTICE-INSTALLER-FAMILY-STANDARD-20260918.md` (aviso de la sesión newmark; sin seguimiento en git)

Instalador de familia:

8. `/Users/averrik/github/agents/install/` (kit canónico; uso en `/Users/averrik/github/agents/install/USAGE.md`)
9. `/Users/averrik/github/agents/dev/installer/STANDARD.md` (estándar consolidado)
10. `/Users/averrik/Cloud/github/libraries/gmsp/dev/SoT/gmsp-v2-repair-20260917/INSTALLER-CONTRACT-20260918.md` (contrato v2, D1–D8)
11. `/Users/averrik/Cloud/github/libraries/gmsp/dev/SoT/gmsp-v2-repair-20260917/HANDOFF-20260918.md` (especificación del kit, §2)
12. `/Users/averrik/Cloud/github/libraries/gmsp/dev/SoT/gmsp-v2-repair-20260917/sudo-install-run-20260918.log` (única corrida `sudo` real archivada, gmsp, 08:27)

## 1. Estado verificado hoy (13:31–13:45 -03)

- NGR `main` = `origin/main` = `c4f3561`. Adopción del kit en `5878651`, resincronización del
  escritor en `6c33c1c`; L2 (`R CMD check --as-cran` del tarball 0.4.0: 0 errores, 0 advertencias,
  1 NOTE) y L3 (`install/requirements.R`) cerrados en `438a375` según `STATE.md` (no re-ejecutados por mí).
- Árbol de trabajo de NGR: `install/` tiene 12 archivos modificados y 4 nuevos **sin commitear**
  (`USAGE.md`, `cli/publish.sh`, `cli/testProduct.R`, `cli/testWrapper.R`); los 18 archivos del kit
  son byte-idénticos (md5) al canónico de las 13:22; 15 de 18 difieren de HEAD.
- Oráculo del kit sobre ese árbol: `bash install/cli/test-installers.sh` → tres `PASS`, exit 0
  (13:35). El fallo de las 13:10 en `install/cli/testManager.R:86` ya no ocurre.
- `bash install/install.sh --check --prefix <scratch>` → «Check passed; nothing was installed»,
  0 archivos escritos. Sin `--prefix` y sin sudo corta en la etapa 2 con
  `Error: Installation parent is not a writable directory: /usr/local/libexec`.
- `/usr/local/bin/ngr` y `/usr/local/libexec/ngr` **no existen**. gmsp sí está instalado con recibo
  esquema 4 (`/usr/local/libexec/gmsp/install.json`, 2026-09-18T11:27:07Z).
- De los 13 archivos del kit registrados en ese recibo de gmsp, 10 cambiaron después
  (`product.R`, `install.sh`, `install.ps1`, `uninstall.sh`, `uninstall.ps1`, `update-manifest.sh`,
  `cli/manage.R`, `cli/checkPaths.ps1`, `cli/test-installers.sh`, `cli/test-installers.ps1`):
  **la versión actual del kit nunca corrió bajo `sudo`.**
- Librerías R: NGR 0.4.0 en `/Users/averrik/Library/R/arm64/4.6/library`; fósil 0.3.10 (root,
  2026-08-17) en `/Library/Frameworks/R.framework/Versions/4.6/Resources/library`.
- `origin/main` contiene 38 commits «Record Nth R7 probe…» (02:10–08:26) de una automatización de
  sondeo que el supervisor declara deshabilitada (`HANDOFF-SUPERVISOR-20260918.md` §1); su estado
  real es UNKNOWN para mí.

## 2. Lo que falta hacer

### A. Agente del instalador (en curso; nadie más toca `install/` ni el kit canónico)

| # | Pendiente |
| --- | --- |
| A1 | Commitear y publicar el `install/` de NGR ya sincronizado con el canónico (rutas exactas). Es la segunda mitad de la compuerta de C2; la primera (oráculo en 0 fallos) hoy se cumple. |
| A2 | Congelar el canónico antes de C2: se retocó 09:20, 10:04–10:05, 10:50–11:40 y 13:22. Declarar la versión (md5 de los 18 archivos) que el propietario va a correr con `sudo`, y re-copiarla byte a byte a los repos antes de esa corrida. |
| A3 | Sin sudo sobre `/usr/local`, el instalador aborta con un error crudo de R; el contrato §2.2 pide `[ERROR] … run: sudo bash install/install.sh`. |
| A4 | Huérfano: `/Users/averrik/Cloud/github/libraries/NGR/install/cli/checkRuntime.R` (su rol lo cubre `installProduct.R`); decidir retiro. |
| A5 | Windows: `install/install.ps1`, `uninstall.ps1`, `cli/test-installers.ps1` sin ejecutar en Windows (contrato §2.3: solo vale el resultado en Windows). |

### B. Propietario (requieren sudo o decisión suya)

| # | Pendiente |
| --- | --- |
| B1 | **C2:** cuando A1 y A2 estén cerrados: `cd /Users/averrik/Cloud/github/libraries/NGR && sudo bash install/install.sh`; guardar la salida completa (p. ej. en `dev/SoT/cli-repair/sudo-install-run-YYYYMMDD.log`). |
| B2 | **C3:** remover el fósil: `sudo Rscript -e 'remove.packages("NGR", lib = "/Library/Frameworks/R.framework/Versions/4.6/Resources/library")'`. |
| B3 | **C6:** decidir si `/Users/averrik/Cloud/github/reports/sha` pasa a repo git (mientras no, los renders con `ngr` sellan `Rev.—` para ese scaffold; además tiene cambios de R2/R4/R8 fuera de git: `manifest.json`, `scripts/setup/cover.R`, `scripts/setup/transmittal.R`). |
| B4 | **C8:** avisar a dbAudit la decisión R6 (parser en `cli/main.R`, no en la librería). |
| B5 | Decidir qué hacer con los 38 commits de sondeo en `origin/main` (dejarlos o una limpieza de historia con su orden explícita; ningún agente reescribe historia por su cuenta). |

### C. Agente de NGR (sucesor de esta sesión o supervisor)

| # | Pendiente |
| --- | --- |
| C1 | **Reparar `STATE.md`:** el hook lo rechaza («state Status must be ACTIVE, BLOCKED, or DONE») porque la línea de Status es `ACTIVE — C1/R7 hecho…`; además es un diario de 30 KB (38 sondeos) y el contrato exige vista actual reemplazable. Dejar Status en una palabra, podar los sondeos (la historia está en git) y validar: `cd /Users/averrik/Cloud/github/libraries/NGR && printf '{"cwd":"%s","hook_event_name":"SessionStart","source":"startup"}' "$PWD" \| python3 ~/.claude/lifecycle/continuity.py`. Hasta entonces la próxima sesión NO recupera el estado. |
| C2 | **Verificación post-instalación** (Next vigente `cli-repair-c2-verify-usr-local-20260918`), después de B1: `/usr/local/bin/ngr --version` (líneas D7 con versión propia del CLI), recibo esquema 4 en `/usr/local/libexec/ngr/install.json`, `BUILD_INFO` junto a `/usr/local/libexec/ngr/scaffold/manifest.json`, y `ngr pull --from ngr` en un proyecto scratch; registrar en `STATE.md`. |
| C3 | Confirmar con el propietario que la automatización de sondeo (`automation_ff907d6c-e8ee-4937-bfa5-b476373ba697`, según el supervisor) está deshabilitada; no crear otra que commitee por corrida. |
| C4 | **Proyectos reales:** 9 proyectos con `qrt.manifest.json`; `ngr` no lo lee. Conversión manual de tres pasos documentada (`cli/README.md`, `lib/vignettes/scaffolds.Rmd`, `PLAN.md` R3). Solo a pedido del propietario; mientras tanto qrt y psha instalados los operan. |
| C5 | **Etapa 2** (palabra del propietario): el CLI expone gráficos y tablas de la librería para agentes con skills en `skill/`. Sin empezar; requiere plan SoT propio; base: parser en `cli/main.R` (`d8c9159`) que llama solo exports. `skill/`, `app/`, `mcp/` son placeholders. |
| C6 | **Regla de producción de la librería:** los 96 archivos preexistentes de `lib/` (byte-idénticos desde `f192453`) no se modifican sin plan SoT; agregar exports sí. |
| C7 | Ajenos en el árbol, no tocar: `dev/plan/cli-fusion/STATE.md` (modificado), `dev/docs/` y `dev/SoT/NOTICE-INSTALLER-FAMILY-STANDARD-20260918.md` (sin seguimiento). |

## 3. Trampas ya verificadas (no repetir)

1. Nunca escribir un instalador propio ni variantes; el escritor es `install/cli/manage.R` del canónico.
2. No afirmar que la rama `sudo` funciona sin la salida del propietario archivada.
3. `cli/tests` exige `/usr/local/bin` delante de `/usr/bin` en `PATH` (el oráculo qrt necesita bash ≥ 4.4)
   y que exista `NGR_TEST_ROOT` (`/tmp/ngr-tests`); comando completo en `HANDOFF-SUPERVISOR-20260918.md` §5.
4. Antes de afirmar byte-identidad con el canónico, comparar md5 en ese momento: es un blanco móvil.
5. `STATE.md` es vista actual, no diario: un sondeo sin novedad no se registra ni se commitea.
