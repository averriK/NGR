## Objective
Etapa 1 del propietario: que `ngr` reemplace a qrt y psha, reproduciendo sus flujos e hidratando desde una ubicación arbitraria, sin modificar la superficie de producción de la librería fuera de un plan SoT. Plan: dev/plan/cli-repair/PLAN.md. La etapa 2 (gráficos y tablas por CLI para agentes con skills en skill/) se planifica al cerrar la 1.

## Rulings
- Propietario 2026-09-17 (sesión NGR-V2): «vamos a arreglar las cosas graves, vamos a asegurar que el cli ngr puede reproducir los viejos flujos del qrt y del psha, que puede hidratar desde una locacion arbitraria. eso debe funcionar.»
- Propietario: «la libreria NGR es una libreria en produccon. podemos agregar cosas pero no podemo smodificar nada sin un plan SoT.»
- Propietario: «eo otro agente termino de revertir las cagadas que hizo. todo tuyo el repo». La cadena anterior dev/plan/cli-fusion/STATE.md quedó ACTIVE por su autor y no se edita.
- Propietario, manifiesto: «no me gusta ese naming. qrt no existe mas. habiamos rechazdo ese naming y habia un apropuesta de un manifest unico.» Vigente: `manifest.json` único; no operar `qrt.manifest.json`.
- Propietario, parser: «adoptamos el segundo patron, que el parser vive en l main.R.» dbAudit es el otro repo con el patrón anterior.
- Propietario, git: «si, permiso permanente para commit y push. avanza». Cada cambio aceptado se commitea y publica en main con rutas exactas; nada de historia ni otras ramas.
- Propietario, conversión de proyectos: «LA CONVERSION DE PROPYECTOS ES un overkil. es nceario hacerlo ahora?» Sin verbo nuevo; procedimiento manual de tres pasos verificado y documentado.
- Propietario, hoja de ruta: «etapa 1: ngr (CLI) reemplaza a qrt y a psha. etapa 2: ngr (cli) potencia al maximo el uso de los recursos que proporciona el ngr library, para que agentes usando skills guardados en skill/ puedan operar el CLI y generar plots complejos.»
- Propietario, instalador 2026-09-18: «sudo bash install/install.sh. asi se instala en mac os, ASI ES DESDE HACE ANOS» y «ok» al plan de familia: kit canónico único en ~/github/agents/install/, contrato libraries/gmsp/dev/SoT/gmsp-v2-repair-20260917/INSTALLER-CONTRACT-20260918.md (D1–D8). `install/` es superficie del agente del instalador: desde aquí no se toca ni se escribe un instalador propio.
- Rutas aplicables: code, sot, r, git; bash y python según archivo.

## Evidence and no-repeat
- Línea base de la tarea NGR 9d24f37. Contra f192453 los 96 archivos preexistentes del paquete son byte-idénticos; ningún candidato los toca.
- Oráculos instalados: qrt BUILD_INFO aa43a56-dirty, psha 1bb0769f-dirty. cli/tests exige /usr/local/bin delante de /usr/bin en PATH (el oráculo qrt necesita bash >= 4.4) y que exista NGR_TEST_ROOT; comando completo en HANDOFF-SUPERVISOR-20260918.md §5.
- Sondeos sin novedad no se registran ni se commitean (38 commits «Record Nth R7 probe» en origin/main, 02:10–08:26 del 2026-09-18, son ruido reconocido de una automatización ya cerrada; su historia está en git).
NEXT-CLOSED {"evidence":"R1: commit 3f27df4; --from explícito redirige la fuente por id; prueba nueva falla en la línea base.","id":"cli-repair-r1-arbitrary-location-20260917"}
NEXT-CLOSED {"evidence":"R2: commit a5e9788; _master 33 managed y 4 seed como psha. R3 cerrado sin código (procedimiento manual de tres pasos).","id":"cli-repair-r2-master-ownership-20260917"}
NEXT-CLOSED {"evidence":"R8: commits acd0d00 y 4ca8110; NGR_RENDER_STAMP y _ngr-output; cover.R y transmittal.R de reports/sha renombrados fuera de git.","id":"cli-repair-r8-qrt-residue-20260917"}
NEXT-CLOSED {"evidence":"R5: commit 8a08f43; BUILD_INFO junto a scaffold/manifest.json leído por .recordedRevision.","id":"cli-repair-r5-revision-identity-20260917"}
NEXT-CLOSED {"evidence":"R6: commit d8c9159; parser en cli/main.R llamando solo exports; NGR 0.4.0; netlify*Manifest exportadas.","id":"cli-repair-r6-parser-main-20260917"}
NEXT-CLOSED {"evidence":"R4: commits 277ec75 y 4ca8110; plantillas {project_id} en siteSlug/domain resueltas al sembrar; 21 artefactos idénticos a psha init.","id":"cli-repair-r4-artifact-destinations-20260917"}
NEXT-CLOSED {"evidence":"R7 propio rechazado por el propietario («no respeta los otros modelos») y descartado; handoff en HANDOFF-20260918.md.","id":"cli-repair-r7-installer-20260918"}
NEXT-CLOSED {"evidence":"Sucesor no requerido: el propietario cerró el modelo de instalador y aprobó el plan de familia.","id":"cli-repair-handoff-successor-20260918"}
NEXT-CLOSED {"evidence":"L2: tarball exacto NGR_0.4.0.tar.gz (SHA-256 24a3bb9c3614beac182b799a891e0053a2637406aab9245b1a1a2a8659713fd3) con R CMD check --as-cran: 0 errores, 0 advertencias, 1 NOTE (New submission); evidencia en dev/SoT/cli-repair/l2-cran-check/; commit 438a375.","id":"cli-repair-l2-cran-check-20260918"}
NEXT-CLOSED {"evidence":"L3: install/requirements.R coincide con el uso real (12 exports; quarto obligatoria; python3 opcional); commit 438a375.","id":"cli-repair-l3-requirements-review-20260918"}
NEXT-CLOSED {"evidence":"Reverificación verde en 9927eb7: document.R exit 0; testthat 384 PASS, 2 SKIP; cli/tests 36 OK, 5 SKIP.","id":"cli-repair-reverify-green-20260918"}
NEXT-CLOSED {"evidence":"C1/R7: kit canónico de familia adoptado en 5878651 (requirements.R propio, install/manifest.json plano de 395 rutas, MINVERSION en cli/main.R, install.py y sus pruebas retirados); cierre eeabda8.","id":"cli-repair-r7-adopt-family-kit-20260918"}
NEXT-CLOSED {"evidence":"Escritor resincronizado con el canónico endurecido: commit 6c33c1c, registro 5dfb815.","id":"cli-repair-r7-writer-resync-20260918"}
NEXT-CLOSED {"evidence":"C2 verificado 2026-09-18 14:00 -03 tras la corrida sudo del propietario (archivada en dev/SoT/cli-repair/sudo-install-run-20260918.log): /usr/local/bin/ngr --version exit 0 con las líneas D7; recibo esquema 4 con 405 archivos presentes y 405 md5 iguales, kit de 17 archivos igual al canónico; BUILD_INFO en libexec/ngr y en libexec/ngr/scaffold; ngr pull --from ngr en scratch 389 contribuciones, status equal, doctor passed; 0 archivos de root en la librería R del usuario. Hallazgos en NOTICE-C2-VERIFICATION-20260918.md.","id":"cli-repair-c2-verify-usr-local-20260918"}
NEXT-CLOSED {"evidence":"C2 hallazgos 1-3 cerrados por el agente del instalador en 399602a: install/ byte-idéntico (diff -rq, 0 diferencias) al canónico corregido ~/github/agents/install/ (bash 3.2: rollback sin local y arreglo vacío con guardián, install/bugs/20260918-bash32-publisher-rollback-y-arreglo-vacio.md); manage.R limita el sello dirty a cli/install/lib (paridad psha: bin scaffold) y publish.sh da cada archivo publicado a root (0:0) bajo elevación; ambos fixes también aplicados al canónico con doc install/bugs/20260918-dirty-scope-y-ownership-root.md para re-sync de la familia. Oráculo post-fix: test-installers.sh PASS x2, testProduct.R PASS; con solo dev/ ajeno sucio, BUILD_INFO de prefijo scratch sale git_describe=backup-before-typewriter-height-166-g399602a dirty=false (antes: -dirty por el repo entero), y con sonda en cli/ sale -dirty/dirty=true; prefijos /tmp descartados. Línea base congelada en dev/SoT/cli-repair/r7-kit-dirty-ownership/.","id":"cli-repair-c2-kit-dirty-ownership-20260918"}
NEXT-CLOSED {"evidence":"Reinstalación limpia verificada 2026-09-18 15:00 -03: recibo /usr/local/libexec/ngr/install.json esquema 4 del 17:38:03Z, source 65795cc dirty false, 405 archivos con md5 iguales; ngr --version build backup-before-typewriter-height-167-g65795cc sin -dirty; las 529 entradas de /usr/local/libexec/ngr y /usr/local/bin/ngr son de root; proyecto scratch con ngr pull --from ngr y ngr render _master/slides.qmd --profile revealjs sella «Pub: 18/09/2026 Rev.65795cc» sin DRAFT.","id":"cli-repair-c2-reverify-clean-install-20260918"}

## Effects
- origin/main contiene R1–R8, L2, L3, la adopción del kit, la corrección bash 3.2 + alcance dirty + ownership (399602a) y los handoffs (HANDOFF-20260918.md, HANDOFF-SUPERVISOR-20260918.md, HANDOFF-PENDIENTES-20260918.md en esta carpeta). reports/sha modificado fuera de git: manifest.json, scripts/setup/cover.R, scripts/setup/transmittal.R.
- `ngr` instalado en /usr/local por el propietario el 2026-09-18 14:38 -03 desde 65795cc con árbol limpio en las rutas del sello: BUILD_INFO sin -dirty, archivos de root, sello de render sin DRAFT. La instalación sucia de las 13:59 (36e7182) quedó reemplazada.
- Árbol de trabajo: install/ commiteado (399602a) y las rutas del sello (cli/, install/, lib/) limpias. Ajenos, no tocar: dev/plan/cli-fusion/STATE.md (modificado; ya no sella DRAFT: fuera del alcance), dev/docs/, dev/SoT/NOTICE-INSTALLER-FAMILY-STANDARD-20260918.md. El canónico ~/github/agents/install/ quedó por delante de los install/ de los demás repos de la familia (re-sync byte a byte pendiente de sus agentes).
- Librerías R: NGR 0.4.0 en ~/Library/R/arm64/4.6/library; fósil 0.3.10 de root en la librería del sistema (remoción pedida por el propietario, requiere su sudo).

## Blocker
none

## Next
NEXT-ID {"action":"Ejecutar las pruebas con proyectos reales T1–T9 de dev/plan/cli-repair/HANDOFF-PRUEBAS-REALES-20260918.md sobre copias livianas en scratch (proyectos de solo lectura, Netlify solo --dry-run), empezando por T1 y T2 en AR-S2L1W; registrar cada cierre como NEXT-CLOSED compacto y admitir cada defecto como candidato SoT nuevo en PLAN.md antes de tocar código.","id":"cli-repair-real-project-tests-20260918"}

## Status
ACTIVE
