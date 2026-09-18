## Objective
Etapa 1 del propietario: que `ngr` reemplace a qrt y psha, reproduciendo sus flujos e hidratando desde una ubicación arbitraria, sin modificar la superficie de producción de la librería fuera de un plan SoT. Plan: dev/plan/cli-repair/PLAN.md. La etapa 2 (gráficos y tablas por CLI para agentes con skills en skill/) se planifica al cerrar la 1.

## Rulings
- Propietario 2026-09-17 (sesión NGR-V2): «vamos a arreglar las cosas graves, vamos a asegurar que el cli ngr puede reproducir los viejos flujos del qrt y del psha, que puede hidratar desde una locacion arbitraria. eso debe funcionar.»
- Propietario: «la libreria NGR es una libreria en produccon. podemos agregar cosas pero no podemo smodificar nada sin un plan SoT.»
- Propietario: «eo otro agente termino de revertir las cagadas que hizo. todo tuyo el repo». La cadena anterior dev/plan/cli-fusion/STATE.md quedó ACTIVE por su autor y no se edita.
- Propietario, manifiesto: «no me gusta ese naming. qrt no existe mas. habiamos rechazdo ese naming y habia un apropuesta de un manifest unico.» Vigente: `manifest.json` único; no operar `qrt.manifest.json`.
- Propietario, parser: «adoptamos el segundo patron, que el parser vive en l main.R.» dbAudit es el otro repo con el patrón anterior.
- Propietario, git: «si, permiso permanente para commit y push. avanza». Cada candidato aceptado se commitea y publica en main con rutas exactas; nada de historia ni otras ramas.
- Propietario, conversión de proyectos: «LA CONVERSION DE PROPYECTOS ES un overkil. es nceario hacerlo ahora?» Sin verbo nuevo; procedimiento manual de tres pasos verificado y documentado.
- Propietario, hoja de ruta: «etapa 1: ngr (CLI) reemplaza a qrt y a psha. etapa 2: ngr (cli) potencia al maximo el uso de los recursos que proporciona el ngr library, para que agentes usando skills guardados en skill/ puedan operar el CLI y generar plots complejos.»
- Rutas aplicables: code, sot, r, git; bash y python según archivo.

## Evidence and no-repeat
- Línea base de la tarea NGR 9d24f37. Contra f192453 los 96 archivos preexistentes del paquete son byte-idénticos; ningún candidato los toca.
- Oráculos instalados: qrt BUILD_INFO aa43a56-dirty (400 archivos), psha 1bb0769f-dirty (771). cli/tests se corre con NGR_REFERENCE_BIN=/usr/local/bin/qrt y NGR_REFERENCE_LIBRARY = librería personal; 35 OK, 5 omitidas.
NEXT-CLOSED {"evidence":"R1: commit 3f27df4 en origin/main; prueba nueva falla en la línea base con «refusing implicit retarget»; escenario por CLI de ubicación alternativa; workflow pkgdown success.","id":"cli-repair-r1-arbitrary-location-20260917"}
NEXT-CLOSED {"evidence":"R2: commit a5e9788 en origin/main; claims de _master 33 managed y 4 seed como psha; status --check detecta sha.qmd editado y pull --force lo restaura conservando book.en.qmd. R3 cerrado sin código con el procedimiento de tres pasos verificado. Línea base del manifest del scaffold en dev/SoT/cli-repair/r2-master-ownership/.","id":"cli-repair-r2-master-ownership-20260917"}
NEXT-CLOSED {"evidence":"R8: commit acd0d00 en origin/main; NGR_RENDER_STAMP y _ngr-output; con librería base y filtro renombrado el oráculo testPublicStampParityAndFailures falla y con el candidato pasa; cover.R y transmittal.R de reports/sha renombrados con líneas base en dev/SoT/cli-repair/r8-qrt-residue/. La adaptación de test_render.py dejaba la referencia en DRAFT con árbol limpio; corregida en 4ca8110.","id":"cli-repair-r8-qrt-residue-20260917"}
NEXT-CLOSED {"evidence":"R5: commit 8a08f43; BUILD_INFO escrito por el instalador y leído por .recordedRevision; con CLI instalado en prefijo temporal el pie pasa de Rev.— · DRAFT a Rev.d7a7262; reinstalación idempotente y desinstalación completa.","id":"cli-repair-r5-revision-identity-20260917"}
NEXT-CLOSED {"evidence":"R6: commit d8c9159; parser en cli/main.R llamando solo exports; netlifyRegisterManifest/DeployManifest/DomainManifest exportadas con pruebas propias; versión 0.4.0 y cli/VERSION con requisito; con la librería personal 0.3.11 --help y --version funcionan y status dice «NGR >= 0.4.0 is required; found 0.3.11»; suite del paquete 70 pruebas y cli/tests 36 con qrt de referencia, 0 fallos.","id":"cli-repair-r6-parser-main-20260917"}
NEXT-CLOSED {"evidence":"R4: commit 277ec75 en origin/main; prueba nueva falla en la línea base; por CLI el primer pull no siembra y avisa, con el id de marcador tampoco, y con project_id AR-TEST0 los 21 artefactos sembrados son idénticos a los de psha init; deploy init --manifest --dry-run resuelve artest0-toc. Manifest del scaffold con plantillas, sha256 5284807730862778; línea base en dev/SoT/cli-repair/r4-artifact-destinations/.","id":"cli-repair-r4-artifact-destinations-20260917"}
NEXT-CLOSED {"evidence":"R7 superado por orden del propietario 2026-09-18 («detente», «prepara un handoff»): el candidato (install/install.sh con sudo -n -u SUDO_USER para R, install/uninstall.sh, install/cli/ensurePackage.R, prueba en cli/tests/test_install.py:93-114) fue rechazado («no respeta los otros modelos»), quedó sin commitear y su rama root nunca fue ejecutada. Handoff en dev/plan/cli-repair/HANDOFF-20260918.md.","id":"cli-repair-r7-installer-20260918"}

## Effects
- origin/main = c16267e (plan y estado) tras d8c9159 (R6), 8a08f43 (R5), 277ec75/4ca8110 (R4), acd0d00 (R8), a5e9788 (R2), 3f27df4 (R1); workflows pkgdown success. reports/sha modificado fuera de git: manifest.json (masters, plantillas de destinos), cover.R y transmittal.R (NGR_RENDER_STAMP).
- Candidato R7 descartado el 2026-09-18 con el «ok» del propietario al plan («tira mi candidato»): install/install.sh y cli/tests/test_install.py restaurados desde HEAD (install.sh md5 8cb2fcbc…, kit congelado), install/uninstall.sh e install/cli/ensurePackage.R borrados; índice vacío. Ajenos, no tocar: dev/plan/cli-fusion/STATE.md, dev/docs/.
- Librerías: NGR 0.4.0 instalada en la personal el 2026-09-18 (`~/Library/R/arm64/4.6/library`); 0.3.10 de root sigue en la librería del sistema (remoción pedida por el propietario, requiere sudo). ngr no instalado en /usr/local. Scratch con ≈490 MB por borrar (lib7, p7, p7b, r7, stub, testroot10).

- Ruling del propietario 2026-09-18, textual: «sudo bash install/install.sh. asi se instala en mac os, ASI ES DESDE HACE ANOS» y «ok» al plan de instaladores de familia: kit canónico único en ~/github/agents/install/ mantenido por gmsp-V2 (sesión spt-02), contrato libraries/gmsp/dev/SoT/gmsp-v2-repair-20260917/INSTALLER-CONTRACT-20260918.md (D1 sudo /usr/local con todo R como usuario; D2 agents; D3 error si librería vieja; D4 Windows usuario; D5 manifiesto completo; D6 escritor en R; D7 recibo md5 y --version de 4 líneas; D8 libexec). Hasta que el kit exista, install/ de NGR queda congelado en HEAD. Particularidades NGR enviadas a spt-02: BUILD_INFO también junto a scaffold/manifest.json; --version con versión propia del CLI.
NEXT-CLOSED {"evidence":"Sucesor ya no requerido para R7: el propietario cerró el modelo (sudo bash install/install.sh; kit de familia) y aprobó el plan; candidato descartado; handoff §7 con inventario de los clásicos.","id":"cli-repair-handoff-successor-20260918"}

## Blocker
El kit canónico de familia (~/github/agents/install/, gmsp-V2) no existe todavía; NGR no toca install/ hasta que exista y el propietario haya corrido sudo bash install/install.sh en gmsp.

## Next
NEXT-ID {"action":"Cuando exista el kit canónico en ~/github/agents/install/ con sus pruebas y la corrida sudo del propietario archivada: copiarlo byte a byte a NGR/install/, aportar install/requirements.R y el manifest.json plano de cli/ (395 rutas), retirar install/cli/install.py y sus pruebas Python solo cuando el escritor R cubra rollback/archivo ajeno/recibo, asegurar BUILD_INFO también junto a scaffold/manifest.json, correr las pruebas aisladas del kit y cli/tests, y registrar; commit y push autorizados.","id":"cli-repair-r7-adopt-family-kit-20260918"}

## Status
BLOCKED
