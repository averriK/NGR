# Handoff del supervisor: estado al 2026-09-18 13:20 -03 → agente revisor del instalador

Autor: conversación supervisora de NGR (Kimi Work). Relevos anteriores:
`HANDOFF-20260918.md` (NGR-V2). Todo lo que sigue cita su fuente observable;
lo no observado se marca UNKNOWN. Canal de respuesta: `STATE.md` (misma carpeta)
o un `NOTICE-*.md` propio; el propietario lee ambos.

## 0. Lo único urgente: tu oráculo falla y el propietario espera

El propietario está listo para `sudo bash install/install.sh` (C2) pero NO
debe correrlo todavía: tu sincronización del canónico nuevo (árbol sin
commitear, quieta desde las 11:40) falla su propio oráculo:

```
bash install/cli/test-installers.sh
# escenario 1: PASS (check, receipt confinement, retirement, rollback, symlinks…)
# escenario 2: Error in runChecks(...): identical(Hash, tools::md5sum(names(Hash))) is not TRUE
#              → install/cli/testManager.R:86 — bytes instalados ≠ md5 del recibo
```

Sospecha sin verificar: orden entre la preparación del recibo (R) y la
escritura de archivos (`cli/publish.sh`), o sync a medias (`publish.sh` de
10:44 vs `manage.R` de 11:40 del canónico). Detalle completo en
`NOTICE-SUPERVISOR-INSTALLER-20260918.md` (misma carpeta, commit 7c87930).

**Compuerta para C2 (observable, corta):** 1) `test-installers.sh` → 0 fallos;
2) `install/` commiteado y publicado. Cuando ambas se cumplan, el propietario
corre el sudo y YO verifico (ver §3). Si en cambio necesitas la corrida sudo
real como evidencia antes de cerrar (precedente gmsp), dilo en `STATE.md`.

## 1. Hecho y cerrado hoy (no repetir)

| Trabajo | Commit en `origin/main` |
| --- | --- |
| L2: tarball 0.4.0 construido + `R CMD check --as-cran` del artefacto exacto: 0 errores, 0 advertencias, 1 NOTE («New submission»). Evidencia en `dev/SoT/cli-repair/l2-cran-check/` | `438a375` |
| L3: `install/requirements.R` coincide con el uso real (12 exports exactos; quarto obligatoria; python3 solo DOCX/Windows) | `438a375` |
| Reverificación verde: `document.R` exit 0; testthat 384 PASS / 2 SKIP; `cli/tests` 36 OK / 5 SKIP | `9927eb7` |
| C1/R7: kit canónico adoptado (39.ª corrida de la automatización): 13 archivos byte-idénticos, `requirements.R` propio, `install/manifest.json` plano de 395 rutas, `MINVERSION` en `cli/main.R`, lanzadores libexec, `install.py` y sus pruebas retirados | `5878651`, cierre en STATE `eeabda8` |
| Resincronización del escritor: el canónico se endureció a las 10:04–10:05 (`manage.R` + `testManager.R`) DESPUÉS de la copia de las 09:56; re-copiado byte a byte, oráculo 0 fallos | `6c33c1c`, registro `5dfb815` |
| Aviso de coordinación al revisor (este bloqueo) | `7c87930` |

Automatización `automation_ff907d6c-e8ee-4937-bfa5-b476373ba697`
(**deshabilitada** por mí al cerrarse R7): sus corridas 1–38 fueron sondeos sin
adopción (commits «Record Nth R7 probe…» — ruido reconocido, diseño mío, no
repetir: registrar cada sondeo en STATE.md generó un commit por corrida); la
39.ª hizo la adopción. Si necesitas reactivar un sondeo, pídelo al propietario.

## 2. Estado del árbol y de la máquina (observado 13:10 -03)

- `main` = `origin/main` = `7c87930`; nada mío sin publicar.
- `install/`: 12 archivos modificados + 4 nuevos (`USAGE.md`, `cli/publish.sh`,
  `cli/testProduct.R`, `cli/testWrapper.R`) — trabajo TUYO sin commitear,
  byte-idéntico al canónico en lo verificado (`install.sh`, `cli/manage.R`).
- Ajenos, no tocar (vigente desde NGR-V2): `dev/plan/cli-fusion/STATE.md`,
  `dev/docs/`, `dev/SoT/NOTICE-INSTALLER-FAMILY-STANDARD-20260918.md`.
- Máquina: `ngr` NO instalado en `/usr/local`; NGR 0.4.0 en la librería
  personal; fósil 0.3.10 en la librería de root (remoción = sudo del
  propietario, C3). gmsp instalado con recibo esquema 4 (su C2 ya hecho).

## 3. División de trabajo y pendientes

- **Tuyo:** cerrar la revisión del instalador (§0). Todo `install/` es tu
  superficie; no la toco.
- **Mío (tras tu cierre y el sudo del propietario):** verificación C2, ya
  registrada como Next `cli-repair-c2-verify-usr-local-20260918` en STATE.md:
  `ngr --version` con líneas D7, recibo esquema 4 en
  `/usr/local/libexec/ngr/install.json`, `BUILD_INFO` junto a
  `libexec/ngr/scaffold/manifest.json`, `ngr pull --from ngr` en scratch.
- **Del propietario (no de agentes):** C2 (sudo en NGR), C3 (fósil 0.3.10),
  C6 (git para `reports/sha`), C8 (avisar decisión R6 a dbAudit).
- **Etapa 2 (C4/L4):** sin empezar; requiere plan SoT propio y se planifica
  al cerrar la etapa 1.
- **Huérfano conocido:** `install/cli/checkRuntime.R` (su rol lo cubre
  `installProduct.R`); limpieza futura, decidida por ti o el mantenedor.

## 4. No repetir (trampas verificadas hoy)

1. `cli/tests` exige `/usr/local/bin` delante de `/usr/bin` en el PATH: el
   oráculo `/usr/local/bin/qrt` usa `env bash` con `set -u` y necesita
   bash ≥ 4.4; con el PATH de sandbox (bash 3.2.57 primero) el oráculo mismo
   falla con «extra[@]: unbound variable» y arrastra fallos espurios.
   Comando completo en STATE.md, entrada `cli-repair-reverify-green-20260918`.
2. `NGR_TEST_ROOT` (`/tmp/ngr-tests`) debe existir antes de correr
   `cli/tests`; si no, 29 errores espurios de `tempfile`.
3. El kit canónico `~/github/agents/install/` es un blanco móvil: se retocó
   09:20, 10:04–10:05 y 10:50–11:40. Antes de copiar o de afirmar
   byte-identidad, compara mtimes/md5 en ese momento.
4. Nunca escribir un instalador propio ni variantes (rechazo del propietario
   al R7 anterior); el escritor es `install/cli/manage.R` del canónico.
5. Los 96 archivos preexistentes de `lib/` (byte-idénticos desde `f192453`)
   no se tocan sin plan SoT propio.

## 5. Cómo correr las pruebas (verificado hoy)

```bash
# oráculo del kit (aislado, scratch en /tmp, ~1 min)
cd /Users/averrik/Cloud/github/libraries/NGR && bash install/cli/test-installers.sh

# paquete
cd /Users/averrik/Cloud/github/libraries/NGR/lib && Rscript ../install/document.R
cd /Users/averrik/Cloud/github/libraries/NGR && Rscript -e 'devtools::test("lib")'

# cli/tests (condición de entorno de la trampa 1)
cd /Users/averrik/Cloud/github/libraries/NGR && mkdir -p /tmp/ngr-tests && \
PATH="/usr/local/bin:$PATH" NGR_TEST_BIN=$PWD/cli/bin/ngr NGR_TEST_ROOT=/tmp/ngr-tests \
NGR_REFERENCE_BIN=/usr/local/bin/qrt NGR_REFERENCE_LIBRARY=$HOME/Library/R/arm64/4.6/library \
python3 -B -m unittest discover -s cli/tests
```

Commit y push por cambio aceptado: autorización permanente del propietario
(2026-09-17), rutas exactas en cada commit, sin otras ramas.
