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
NEXT-CLOSED {"evidence":"R4: commit 277ec75 en origin/main; prueba nueva falla en la línea base; por CLI el primer pull no siembra y avisa, con el id de marcador tampoco, y con project_id AR-TEST0 los 21 artefactos sembrados son idénticos a los de psha init; deploy init --manifest --dry-run resuelve artest0-toc. Manifest del scaffold con plantillas, sha256 5284807730862778; línea base en dev/SoT/cli-repair/r4-artifact-destinations/.","id":"cli-repair-r4-artifact-destinations-20260917"}

## Effects
- origin/main = 4ca8110. reports/sha modificado fuera de git: manifest.json (masters y plantillas de destinos), scripts/setup/cover.R y transmittal.R (nombre de la variable del sello).
- Sin instalación personal ni efectos en Netlify.

## Blocker
none

## Next
NEXT-ID {"action":"R5 del plan: admitir bajo SoT la identidad de revisión para fuentes sin git: el instalador del CLI registra commit y estado del checkout junto al scaffold base y .resourceRevision la lee antes de recurrir a git; oráculo: desde un CLI instalado en un prefijo temporal el render de prueba muestra Rev.<7 hex> sin DRAFT cuando el checkout está limpio, donde la línea base muestra Rev.— · DRAFT; suites completas con qrt de referencia.","id":"cli-repair-r5-revision-identity-20260917"}

## Status
ACTIVE
