# Rulings de los estados DONE de dev/ (extracto para revisión del propietario, 2026-09-27)

Regla 2: antes de borrar una cadena, las reglas del propietario que sobreviven pasan a dev/ARCHITECTURE.md. Este archivo reúne Objective y Rulings de cada STATE.md cerrado, tal como estaban en el checkout el 2026-09-27, para que el propietario marque lo que sobrevive. Nada de aquí es regla vigente hasta que se copie a dev/ARCHITECTURE.md.

## dev/plan/agent-memory-incident-20260924/STATE.md

Status: DONE · 1179 bytes · última modificación 2026-09-24

> Registrar el incidente de memoria operativa y continuidad del agente solicitado por el propietario en NGR/dev/bugs.

- Pedido vigente: «reorta el bug masivo de tu memoria en NGR/dev/bugs».
- Alcance documental: declarar hechos observados, responsabilidad y límites de evidencia. No reabrir implementación ni ejecutar renders.
- Estados anteriores DONE se conservan; este registro no certifica aceptación DOCX ni cierra el incidente técnico.

## dev/plan/cli-fusion/research/alternatives/STATE.md

Status: DONE · 2333 bytes · última modificación 2026-09-16

> Comparar alternativas de composición de scaffolds completos, builders comunes y contexto editorial; entregar evidencia, pros/contras y casos adversariales antes de formular contratos CLI.

- Misión literal: cli-fusion-composition-alternatives-20260916. Locator validado contra Delegations del estado seleccionado dev/plan/cli-fusion/STATE.md en /Users/averrik/Cloud/github/libraries/NGR.
- Encargo del propietario del 2026-09-16: investigación de arquitectura con varios agentes, previa a contratos. Sólo documentación dentro de dev/plan/cli-fusion/research/alternatives/; sin implementación, instalaciones, renders, recursos copiados, publicación ni Git mutado.
- REPORT.md es recomendación de investigación, no arquitectura aprobada. El plan del propietario sigue siendo dev/plan/cli-fusion/PLAN.md.

## dev/plan/cli-fusion/research/builders/STATE.md

Status: DONE · 4244 bytes · última modificación 2026-09-16

> Investigar con evidencia del código si builders en scripts/fig pueden compartirse entre scaffolds PSHA, blasting y SSEL cuando cambia el slicing. Recorrer al menos tres cadenas master → bloque _fig → builder → datos/setup, identificar funciones agnósticas al capítulo, selección de datos, globals, side effects, outputs/caches y dependencias. Separar hechos observados y escenarios hipotéticos. Comparar compartir mismo archivo, API común con slicings fuera, copia por scaffold y aislamiento de entornos. No proponer renombrar builders por capítulo por defecto.

- Misión literal: cli-fusion-builders-composition-20260916. Coordinador: dev/plan/cli-fusion/STATE.md en /Users/averrik/Cloud/github/libraries/NGR. Validar el locator exacto contra Delegations antes de actuar.
- Encargo nuevo del propietario del 2026-09-16: análisis profundo con varios agentes sobre coexistencia de scaffolds PSHA/blasting/SSEL, builders agnósticos al capítulo salvo slicings y fusión de carpetas. Este es análisis previo a contratos, no implementación.
- Escribir sólo en dev/plan/cli-fusion/research/builders/; entregar REPORT.md allí, con referencias absolutas y líneas. No editar fuentes, instalaciones, lib/, proyectos consumidores ni estado del coordinador. No instalar, renderizar, copiar recursos, publicar ni mutar Git.
- Leer skills instalados code y veinte tarjetas antes de análisis de diseño; r/bash/python según fuente revisada; datatable si se usa su interfaz. QRT skill sólo si se opera CLI pública instalada, no como ruta para mantener productor. No sustituir instrucciones de skill por conocimiento improvisado.
- Fuentes de evidencia inicial: /Users/averrik/Cloud/github/tools/psha/scaffold, /usr/local/libexec/psha/scaffold, /Users/averrik/Cloud/github/tools/qrt; proyectos /Users/averrik/Cloud/github/projects/AR-S2L1W y AR-SAD40. Leer antes de atribuir contenido; bounded reads por bytes/líneas; no _ref ni archivos privados ajenos. Plan vigente: /Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-fusion/PLAN.md. Leer lo pertinente, no reabrir tareas históricas.
- No tomar CONTRACT.md como contrato: propuesta retirada. No están decididos nuevos flags ni mecanismos. La arquitectura contempla manifests fuente, destinos compartidos y procedencia por archivo; el análisis puede criticar y comparar alternativas sin declararlas aprobadas.
- Comunicar avances y hallazgos al coordinador por collaboration. Si contexto se compacta, revalidar locator y abrir este estado. Al terminar, cerrar el Next con evidencia de REPORT.md, dejar Next none y Status DONE; el coordinador hará join.

## dev/plan/cli-fusion/research/editorial/STATE.md

Status: DONE · 2299 bytes · última modificación 2026-09-16

> Investigar ventajas y riesgos de fusionar carpetas editoriales y scripts de varios scaffolds, contrastando nombres y referencias reales, y entregar análisis al coordinador.

- Misión literal: cli-fusion-editorial-collisions-20260916. Coordinador: dev/plan/cli-fusion/STATE.md en /Users/averrik/Cloud/github/libraries/NGR. El locator se validó contra la entrada exacta de Delegations seleccionada por dev/SoT/ACTIVE.md.
- Encargo del propietario del 2026-09-16: investigación con varios agentes previa a contratos. Sólo documentación en dev/plan/cli-fusion/research/editorial/; sin implementación, Git, renders, instalaciones ni efectos remotos.
- Skills instalados aplicados: code y sus veinte tarjetas completas, r. No se operó QRT ni data.table, ni se editó código.

## dev/plan/cli-install-guide/STATE.md

Status: DONE · 2591 bytes · última modificación 2026-09-20

> Alinear la sección Install de lib/vignettes/cli.Rmd y las dos frases de instalación de README.md con el instalador canónico, a pedido de aom-v0 dentro de la coordinación autorizada por el propietario.

- Tarea directa; cadena nueva dev/plan/cli-install-guide/STATE.md. cli-root permanece DONE.
- AOM recibió esta guía y cerró la instalación canónica y el skill. Esta tarea sólo corrigió documentación; no instaló ni repitió pruebas de raíz.
- Leídos lib/vignettes/cli.Rmd, install/USAGE.md, install/requirements.R y las entradas/argumentos de install/install.sh e install/install.ps1.
- AOM añadió las dos frases de README.md; archivo completo leído. No ampliar a otras secciones.
- Contrato: producto completo biblioteca + CLI; construcción implícita desde lib/; --check/--tarball/--dependency; sin --component o --build públicos. Quarto requerido y Python opcional. Windows por usuario sin elevación predeterminada.

## dev/plan/cli-repair/STATE.md

Status: DONE · 4120 bytes · última modificación 2026-09-20

> Auditoría solicitada por el propietario el 2026-09-20: contrastar NGR con qrt/psha, leer dev/ y el reporte de AOM, y determinar qué falta antes de retirar los predecesores. Auditoría terminada; reparaciones, instalación y retirada no ejecutadas.

- Instrucción de apertura: auditar la librería, el CLI y el skill prototipo; el instalador y contrato CLI canónicos pertenecen a AOM.
- Corrección del propietario: «products/hazard es una alucinación. no existe ese path». Fue una ruta inventada sólo para un fixture temporal. No usar esa sonda como evidencia de afectación de proyectos reales.
- La librería está en producción: cualquier modificación de implementación requiere plan SoT. Esta tarea no modificó implementación.
- Los parámetros y rutas científicos se consumen desde sus contratos de productor. No cambiar esos contratos para acomodarlos a un lector incorrecto.
- Ajeno: dev/plan/cli-fusion/, dev/docs/ y las modificaciones preexistentes en skills/ngr/references/{deploy,long-jobs,resources-manifest}.md y dev/SoT/NOTICE-INSTALLER-FAMILY-STANDARD-20260918.md. Se conservaron.

## dev/plan/cli-root/STATE.md

Status: DONE · 4005 bytes · última modificación 2026-09-20

> Adaptar el CLI NGR a --root DIR según la convención AOM vigente, por «avanza» del propietario después del cierre de protección de raíces.

- Tarea directa Auditar NGR contra QRT y PSHA. Nueva cadena dev/plan/cli-root/STATE.md; ngr-gmsp-closure permanece DONE.
- AOM/docs/workspace-contract-plan.md, sección 5: raíz existente, relativa al CWD del llamador; entradas y salidas relativas al proyecto, absolutas conservadas, modo previo sin opción. Sin nueva política de permisos ni cambios científicos.
- AOM confirmó que sólo modifica Newmark y que no hay cambios concurrentes en NGR CLI. Esta tarea entrega fuente/candidato aceptados; AOM conserva instalación canónica y alineación del skill. Sin autoridad Git o de retiro de herramientas.
- Rutas de mantenimiento: code db006ef77a7e, sot 6a2b5866ae75, r f6fc91995993 y python 693fbb19f670. Skills y referencias aplicables leídos. No operar cambios de fuente mediante el skill consumidor ngr.
- Diagnóstico focalizado del transporte de rutas. No repetir matrices, pruebas científicas, migraciones, renders reales ni publicación Netlify.

## dev/plan/declared-bugs/STATE.md

Status: DONE · 4377 bytes · última modificación 2026-09-20

> Revisión pedida por el propietario tras la auditoría: leer los bugs y pendientes declarados en dev/ por el agente que fue retirado, y distinguir los todavía vigentes de los resueltos o históricos.

- Revisar y contrastar; no se pidió reparar producción, hidratar proyectos ni instalar nada.
- El estado anterior dev/plan/cli-repair/STATE.md está DONE. Esta es una revisión nueva y no reabre sus Next cerrados.
- products/hazard era un fixture ficticio; no atribuirlo a proyectos reales.
- El instalador y el contrato CLI canónicos pertenecen a AOM. Cualquier reparación de producción requiere el plan SoT correspondiente.
- Conservar todos los cambios ajenos. PLAN.md y HANDOFF-20260920.md fueron restaurados/agregados por el agente anterior en 6a55e69 y a18dfec; el nuevo REPORTE-HIDRATACION-TRAS-MUDANZA-20260920.md está sin seguimiento y no es nuestro.

## dev/plan/dev-cleanup-20260921/STATE.md

Status: DONE · 3926 bytes · última modificación 2026-09-21

> Revisar dev/ de ssel, NGR, zot, dbAudit, hazard y newmark para identificar volumen y archivos que pueden limpiarse, por la ampliación explícita del propietario del 2026-09-21.

- Tarea directa nueva después de reports-status-20260921 DONE. No reabrir auditorías anteriores.
- Inventario por bytes y cantidad, lectura de estados, productores y consumidores antes de clasificar. Un nombre, antigüedad o estado DONE no autoriza por sí solo borrar evidencia.
- Coordinar con aom-v0: este agente revisa SSEL/NGR/zot/dbAudit; AOM ya revisa hazard/newmark. Confirmar frontera actual por mensaje. No duplicar inventarios profundos Git/SSEL ya completados; separar dev de .git y datos de proyecto.
- La petición vigente es revisar oportunidades de limpieza. No se han seleccionado ni autorizado por inferencia borrados irreversibles, GC, referencias Git o datos científicos. Preparar lista concreta de candidatos y efectos antes de decidir una acción de limpieza.
- Mantener los estados activos y la evidencia que impide repetir migraciones/renders. Las pruebas científicas anteriores no se ejecutan de nuevo.

## dev/plan/docx-srk-audit-20260924/python-review/STATE.md

Status: DONE · 2266 bytes · última modificación 2026-09-24

> Revisar de forma independiente la robustez de lib/inst/docx/fix_docx.py y las pruebas que lo cubren; entregar hallazgos precisos al coordinador.

- Delegación de la auditoría solicitada por el propietario el 2026-09-24: detectar primero si el código DOCX es robusto antes de adaptar un futuro template SRK.
- Leer código, callers y tests actuales. Evaluar pérdida de formato/contenido, alcance de los parches, idempotencia, fallos y límites de cobertura. No modificar implementación ni plantillas, no ejecutar renders de proyectos, no instalar ni usar Git para mutaciones.
- Sólo escribir dentro de dev/plan/docx-srk-audit-20260924/python-review/. Entregar REVIEW.md con líneas exactas y diferenciar defecto demostrado, riesgo y requisito aún desconocido. El coordinador realiza las sondas de ejecución: evitar duplicarlas.
- Cargar continuity, code y python; leer sus referencias requeridas. El template SRK no fue recibido: no inventar sus reglas.

## dev/plan/docx-srk-audit-20260924/STATE.md

Status: DONE · 5143 bytes · última modificación 2026-09-24

> Evaluar la robustez del recorrido DOCX de NGR y sus herramientas Python; preparar un diagnóstico y un plan verificable para adaptarlo al template SRK que el propietario proporcionará.

- Instrucción nueva del propietario, 2026-09-24: leer bugs, revisar carátula ausente y apéndices ajenos al formato SRK, detectar primero si el código es robusto y después definir qué pedirle. Alcance actual: auditoría de código, diagnóstico local acotado y plan; no implementar todavía el formato SRK.
- El template SRK futuro todavía no está identificado ni recibido; no inventar sus estilos, medidas, metadatos ni apariencia. Las plantillas existentes sirven para caracterizar el código actual, no como aceptación SRK.
- No alterar implementación, plantillas, proyectos científicos ni sus salidas; no instalar, publicar, modificar Git ni contactar otras tareas. Se permiten documentos y sondas locales de esta auditoría.
- Estado nuevo declarado en el chat antes de cambiar el selector. El estado previo session-skill-errors-20260922 era inválido para el parser y declaraba DONE; no se reabre ni se modifica.
- Skills aplicables: code/review, python/review, r/review y continuity. Releases de catálogo/recibo ya leídas en esta sesión: code 20f157d03388, python 7713fa30b469, r 301dd508a2ee, continuity ae9919e0cc7b.

## dev/plan/gmsp-cli-audit/STATE.md

Status: DONE · 3474 bytes · última modificación 2026-09-20

> Auditar el CLI de libraries/gmsp como reemplazo de SPT, su concordancia con la organización de hazard/newmark y el acceso de NGR a sus productos para los masters _master/srs.*.

- Auditoría directa del propietario, posterior a ngr-integration/DONE. AOM conserva instaladores. No autoriza instalar, publicar, retirar herramientas ni recalcular o migrar proyectos. No hay delegaciones.
- Separar CLI, identidad científica de los productos y acceso del scaffold. No presentar exit 0, un HTML o el cierre histórico de otro alcance como aceptación del flujo completo.
- Skills aplicados: code y r para revisión/comprobadores; datatable para lecturas y fixtures; spt para help y sus seis operaciones en raíces temporales propias.

## dev/plan/gmsp-cli-contracts/STATE.md

Status: DONE · 2746 bytes · última modificación 2026-09-20

> Completar la documentación de entradas, resultados, destinos y efectos de las seis operaciones GMSP conforme al contrato AOM, por «continua» del propietario.

- Tarea directa; nueva cadena dev/plan/gmsp-cli-contracts/STATE.md. Los cierres anteriores permanecen DONE.
- AOM confirmó que no edita GMSP y asignó esta corrección documental a esta tarea. AOM conserva instalación, skill y sus dos documentos de conformidad; no editarlos aquí.
- Leer los seis runners y sus resolutores antes de describir sus destinos. Mantener process como escritor de la base declarada. El CLI no ofrece dry-run.
- Corregir también las instrucciones de instalación obsoletas observadas en la misma guía contrastándolas con el instalador vigente. No cambiar código ejecutable, recetas, unidades, targets, cuotas ni productos.
- Rutas aplicadas: code db006ef77a7e y r f6fc91995993 para lectura de fuente; continuity 022a663de9be para estado. No operar GMSP como consumidor.

## dev/plan/gmsp-paths/STATE.md

Status: DONE · 3120 bytes · última modificación 2026-09-20

> Resolver las rutas de gmsp consumidas por SHA y migrar sus productos locales a data/gmsp, coordinando con AOM, por instrucción explícita del propietario del 20 de septiembre de 2026.

- Alcance completado: siete proyectos auditados; seis con productos GMSP y AR-SACU0 sin ellos.
- Las recetas quedan en gmsp/*.json; SHA usa id/path.out de gmsp/match*.json, sin fallback de productos. Ciencia, metadata histórica y bases externas se conservan.
- AOM confirmó por mensaje su frontera: skills/continuity en agents; no escribe reports ni proyectos. Esta tarea no modifica skills ni productor gmsp, ni tiene autoridad de publicación/instalación.
- La procedencia científica histórica de caldera/CN se mantiene separada en gmsp-target-review/RESULTS.md; esta mudanza no autoriza recalcular targets.

## dev/plan/gmsp-target-review/STATE.md

Status: DONE · 3017 bytes · última modificación 2026-09-20

> Revisar la objeción del propietario del 20 de septiembre de 2026: localizar las diferencias de las suites guardadas y discriminar redondeo, banda frente a curva central y cambios de insumos; no presumir que las suites son incorrectas.

- Nueva revisión directa posterior a gmsp-cli-audit/DONE. Sólo lectura de productores/proyectos; comprobadores y evidencia nuevos en esta carpeta. No recalcular suites, modificar contratos científicos ni instalar.
- Aplicar code y r a la revisión del código y datatable a las lecturas/comparaciones. Validación diagnóstica acotada, no certificación ni repetición de renders o fixtures CLI cerrados.
- Separar target de entrada, objetivo del optimizador y espectros logrados. No inferir la procedencia histórica sólo a partir del JSON.

## dev/plan/m2v4d-deploy-audit-20260921/STATE.md

Status: DONE · 2063 bytes · última modificación 2026-09-21

> Verificar si los renders de AR-M2V4D están listos o incompletos y dar comandos NGR para desplegarlos en Netlify, contrastando registros y sitios antiguos.

- Nueva tarea directa tras srs-two-projects-20260921 DONE. El propietario pide revisión y comandos; mantiene «no renderices nada». No ejecutar renders, deploys, creación/borrado de sitios, cambios de dominio ni Git mutations.
- Raíz: /Users/averrik/Cloud/github/projects/AR-M2V4D. Preservar todos sus cambios preexistentes.
- Ruta ngr 46828e0ff9f8: lectura pública de ayuda, planes deploy/init/domain --dry-run, consultas Netlify de sólo lectura si necesarias. continuity 022a663de9be. Recibos instalados cotejados.

## dev/plan/m2v4d-final-scc-20260922/STATE.md

Status: DONE · 3977 bytes · última modificación 2026-09-22

> Incorporar S1′ y S2′5km como escenarios definitivos de AR-M2V4D, ejecutar oficialmente las16celdas nuevas en tms9900, actualizar productos dependientes y avisar al propietario que puede renderizar y republicar.

- Órdenes del propietario: «me quedo con este S2′ como definitivo… S1=S1′»; después «debes calcular ahora oficialmente los16escenarios» y «las corridas son en tms9900».
- S1=SCC/Mw6.5/Repi100km/dep15km, plano324/46/100; S2=SCC/Mw4.5/Repi5km/dep2.5km, plano112.5/80/90. Identidades S1/S2, CFD y ocho Vs30[180,270,360,560,760,800,1250,1500]. Árbol SCC/pesos/configuración conservados. No reutilizar los IDs de prueba como producción.
- Proyecto /Users/averrik/Cloud/github/projects/AR-M2V4D. Rutas públicas usadas: hazard4277df0275e9 pack/run/info/extract/process(mce,mcer), newmark7870fbdb0a1f process(dn,kmax); gmsp0e01cee6162e para resolver independencia del targetMDE. No productores privados ni cambios de servicios.
- Sin render, deploy, reinicio, commit o push; el propietario renderiza/publica. No reabrir las tareas de pruebas, que siguen DONE.

## dev/plan/m2v4d-mce-s1-20260921/STATE.md

Status: DONE · 6760 bytes · última modificación 2026-09-21

> Completar extracción y procesamiento MCE/DSHA, MCER y Newmark DN/kmax de AR-M2V4D. Cumplido; el propietario hará render, publicación y reinicio.

- Autoridad: «termina con la extracción y procesamiento. luego renderizo luego publico luego reinicio». Esta tarea termina con productos locales aceptados; no ejecutar render, deploy, reinicio, commit ni push.
- Tarea directa. Proyecto científico: /Users/averrik/Cloud/github/projects/AR-M2V4D. Cadena seleccionada en checkout NGR: dev/plan/m2v4d-mce-s1-20260921/STATE.md.
- Recetas aprobadas tras la orden de actualizar RATIONALE/JSON y lanzar con hazard: S1 SCC, Mw6.5, Repi225km, dep15km, strike/dip/rake324/46/100; S2 ASC, Mw4.5, Repi1km, dep2.5km, strike/dip/rake112.5/80/90. WC1994 y una variante base. S2 idealiza North G, no un mecanismo medido.
- Dos escenarios científicos × CFD × Vs30{180,270,360,560,760,800,1250,1500}=16 combinaciones. Sin directividad ni variantes adicionales. No reutilizar S1 rechazado Mw6.5/Repi0.
- Producción exclusivamente por CLI públicos hazard y newmark instalados. No cambios de productor, servicios, UHS, ShearTable ni parámetros Newmark. Contrato conserva Mw.gmdp=7, NS=300 y subduction=false; no ts ni semilla nueva. Semilla histórica de ShearTable no registrada; su hash identifica la generación.
- Coordinación autorizada con tarea hazard «fix-bug», thread01a0c599-6c75-76d0-8503-78de915919a1. Sin delegación ni mantenimiento en su repo; no trabajar sobre otros proyectos.

## dev/plan/m2v4d-new-publication-20260921/STATE.md

Status: DONE · 2603 bytes · última modificación 2026-09-21

> Crear y publicar los sitios nuevos de AR-M2V4D con todos los productos del manifest, verificando destinos, dominios y salidas servidas.

- Nueva tarea directa tras auditoría SRS DONE. El propietario pidió sitio nuevo con todos los decks y respondió explícitamente «Crea y publica los sitios nuevos».
- Alcance: 21 productos existentes de AR-M2V4D, cuenta averrik, slugs arm2v4d-* y dominios srk.ar declarados. No borrar/modificar psha-crawford ni reasignar crawford.srk.ar.
- Se mantuvo la restricción de no renderizar ni calcular. La publicación no certifica científicamente SRS; la incertidumbre se informó antes de la autorización.
- Se informó que el sitio viejo tiene contraseña y los nuevos no la heredan. No administrar contraseñas.
- Rutas ngr 46828e0ff9f8 (init/deploy/domain públicos) y continuity 022a663de9be. No mutaciones Git.

## dev/plan/m2v4d-s2-scc-5km-20260922/STATE.md

Status: DONE · 3186 bytes · última modificación 2026-09-22

> Prueba aislada S2 SCC con Repi5km y comparación PGA84 contra Repi1km, AR-M2V4D. Terminada.

- Nueva tarea declarada en dev/plan/m2v4d-s2-scc-5km-20260922/STATE.md por orden «intentar recalcular ese escenario con Repi5km en lugar de1km». Cadena anterior DONE intacta.
- Sólo scenario/S2/CFD/760 en tms9900. Conservar SCC, Mw4.5, dep2.5km, geometría112.5/80/90, WC1994, una variante base, GMM/pesos y azimut. Sólo se cambió distancia/epicentro y descripción.
- Workspace: /Users/averrik/Cloud/github/libraries/NGR/dev/plan/m2v4d-s2-scc-5km-20260922/workspace. Destinos internos de hazard.json. Sin integración al proyecto, otrosVs30, S1, render, deploy, Newmark, GMSP ni Git.
- Ruta hazard4277df0275e9, recibo concordante. CLI0.2.0/buildc709b01-dirty y Engine3.26.2. Operaciones públicas pack/run/info/extract/process --steps mce. Servidor18800 por túnel existente a tms9900:8800, sin modificar servicios.
- Persisten limitaciones científicas de Pezeshk2011 descritas en la comparación anterior. Resultado numérico aceptado no autoriza adoptar la prueba ni sustituir GMM/pesos.

## dev/plan/m2v4d-scc-comparison-20260922/STATE.md

Status: DONE · 5167 bytes · última modificación 2026-09-22

> Comparar S1′/S2′ de AR-M2V4D a Vs30=760 m/s, verificar el resultado alto de S2′ y comunicar a «fix skills» las operaciones efectivamente realizadas. Alcance terminado; pruebas sin integrar.

- Propietario: «S2′ mismas distancias pero SCC en lugar de ASC. S1′ Repi100km en lugar de225km». Luego liberó tms9900 y autorizó exactamente dos cálculos, no todos los Vs30. Aceptación posterior requerida por el propietario antes de incorporar las pruebas.
- S1′ SCC/Mw6.5/Repi100km/dep15km, geometría324/46/100 y azimut original. S2′ SCC/Mw4.5/Repi1km/dep2.5km, geometría112.5/80/90 y epicentro original. Una variante base, WC1994. CFD y760m/s exclusivamente.
- Proyecto original: /Users/averrik/Cloud/github/projects/AR-M2V4D. Todos los productos de prueba en /Users/averrik/Cloud/github/libraries/NGR/dev/plan/m2v4d-scc-comparison-20260922/workspace. No integración, render, deploy, Newmark, GMSP ni Git autorizados en esta tarea.
- Operaciones públicas hazard pack/run/info/extract/process --steps mce. Skill aprobado4277df0275e9 y recibo instalado concordantes; CLI0.2.0/buildc709b01-dirty, Engine3.26.2.
- Servidor tms9900 mediante túnel existente127.0.0.1:18800→127.0.0.1:8800 remoto. Nunca confundir con8800 de la Mac; no se modificó túnel/servicio.
- Última instrucción del propietario: verificar PGA84≈1.2g de S2′ e informar a «fix skills» en github/agents sobre producción oficial, aislamiento, extracción y batches. Comunicación autorizada; no delegación ni más corridas.

## dev/plan/m2v4d-srs-provenance-20260921/STATE.md

Status: DONE · 1918 bytes · última modificación 2026-09-21

> Determinar si AR-M2V4D tiene productos SRS reales, de qué ejecución proceden y si existe evidencia de definición/aprobación del propietario. Corregir la recomendación previa de render/deploy si asumía una selección no autorizada.

- Tarea directa nueva tras m2v4d-deploy-audit DONE. El propietario cuestiona explícitamente haber definido una selección SRS. Su existencia en un manifest o HTML no prueba autorización científica.
- Inspección de sólo lectura del proyecto, contratos, productos, registros e historial Git. No ejecutar cálculos, renders, deploys, borrados ni cambios Git.
- Continuity cargado. Sólo escribir evidencia y estado de esta auditoría en NGR/dev.

## dev/plan/ngr-gmsp-closure/STATE.md

Status: DONE · 4188 bytes · última modificación 2026-09-20

> Cerrar la aceptación instalada del parche NGR después de la entrega AOM. El propietario acotó la continuación al señalar que las pruebas históricas ya se habían hecho y eran excesivas.

- Tarea directa Auditar NGR contra QRT y PSHA; no hay delegación hija. Cadena anterior gmsp-paths DONE: no repetir migración, hidratación ni renders aceptados.
- Esta continuación escribe evidencia bajo dev/plan/ngr-gmsp-closure. Conserva contratos, productos y tablas científicas; no recalcula suites ni inventa selectores.
- AOM confirmó por mensaje la instalación/concordancia fuente-runtime del parche como etapa posterior a skills/continuity. La publicación e instalación permanecen en su ámbito; esta tarea verifica después. No nueva autoridad Git.
- Diagnóstico focalizado, no certificación de una release. Rutas instaladas verificadas contra agents-skills.json: continuity 022a663de9be, code db006ef77a7e, r f6fc91995993 y datatable daf97c193a71.
- Aceptación consumidora siguiente: ngr 4f7f2f1bf1c8, operación pública `ngr pull --from <manifest>` / `ngr pull --force` sólo sobre fixtures propios. Skill y referencia leídos; ayuda instalada comprobada.
- Última instrucción del propietario: «los commits anteriores tienen la carpeta oq/data ... me parece un overkill esas pruebas ... ya las habíamos hecho». Se detiene la ampliación histórica y la repetición de suites. Procedencia caldera/CN queda como límite documental, sin bloquear GMSP ni pedir otro snapshot ahora.

## dev/plan/ngr-integration/STATE.md

Status: DONE · 3133 bytes · última modificación 2026-09-20

> Ejecutar «implementa» sobre los pendientes NGR del plan report-contracts y asumir gmsp conforme a «Asume también la parte de gmsp».

- Esta cadena es posterior a report-contracts/DONE; no reabre sus tres lectores aceptados. El propietario asignó gmsp a esta tarea; no hay delegación ni agentes lanzados.
- AOM conserva instalación, distribución, CLI, ayuda y skill. Hazard y newmark conservan la validación científica de sus productores. No instalar, publicar ni retirar qrt/psha por este cierre.
- Rutas reales de los proyectos: las de sus contratos; products/hazard no es una ruta real observada.

## dev/plan/ngr-output-message-20260921/STATE.md

Status: DONE · 1258 bytes · última modificación 2026-09-21

> Reportar a aom-v0 el mensaje de salida interno de NGR denunciado por el propietario: Output created: _ngr-output/index.html.

- Nueva cadena dev/plan/ngr-output-message-20260921/STATE.md. Estado anterior ngr-render-evidence-20260921 permanece DONE.
- Autoridad explícita del propietario: reportar el bug a aom-v0. No ejecutar renders ni modificar implementación o proyectos.
- No convertir la denuncia en una instrucción para hidratar un directorio interno ni afirmar que el último render terminó su entrega.

## dev/plan/ngr-render-evidence-20260921/STATE.md

Status: DONE · 1765 bytes · última modificación 2026-09-21

> Completar el reporte autorizado a aom-v0 localizando evidencia ya existente de un render NGR real para acreditar las recetas del skill.

- Nueva cadena dev/plan/ngr-render-evidence-20260921/STATE.md; ngr-skill-incident-20260921 sigue DONE.
- Continuación de la coordinación solicitada por el propietario. aom-v0 pide sólo localizadores de evidencia existente: comando, versión/build, CWD, perfil y log/resultado.
- No ejecutar renders/pruebas ni modificar skills, CLI, proyectos o Git. No extrapolar la evidencia de un perfil a otro ni de una instalación a otra.

## dev/plan/ngr-repair-20260924/STATE.md

Status: DONE · 3322 bytes · última modificación 2026-09-24

> Preparar el plan de corrección de NGR (DOCX CAN: apéndices y preliminares; idioma de interfaz; buildPlot; documentación) en dev/plan/ngr-repair-20260924/PLAN.md para que otro agente Opus lo implemente.

- Instrucción vigente del propietario: «prepara el plan para corregir NGR y otro agentge opus lo toma». Autorizó escribir el plan y su continuidad. No autorizó modificar implementación, instalar, renderizar proyectos, hidratar ni commit/push; nada de eso se hizo.
- Nuevo estado declarado en el chat para este objetivo: dev/plan/ngr-repair-20260924/STATE.md. El estado anterior dev/plan/agent-memory-incident-20260924/STATE.md permanece DONE y no se reabre.
- Rutas cargadas: continuity ae9919e0cc7b, code 20f157d03388 (veinte cartas leídas completas), sot e6d9504c32ae; recibos coinciden con el catálogo. El implementador declara su propio estado dev/plan/ngr-repair-build-20260924/STATE.md y su raíz SoT dev/SoT/ngr-repair-build-20260924/; este estado DONE no se reabre para implementar.
- Las decisiones de producto pendientes están en PLAN.md §3 como preguntas cerradas Q1–Q9 con recomendación; ningún valor fue inventado ni validado por este estado.
- Trabajo ajeno sin commitear (cli-fusion, cli-repair, bandeja bugs/, artefactos dev/) conservado; sólo se escribió en esta carpeta y en el selector.

## dev/plan/ngr-repair-audit-20260924/docx/STATE.md

Status: DONE · 1853 bytes · última modificación 2026-09-24

> Auditar C4, Q2/Q3 y aceptación DOCX del plan dev/plan/ngr-repair-20260924/PLAN.md.

- Subtarea de la auditoría solicitada por el propietario: «lee el plan para repararlo . auditalo. dev/plan/ngr-repair-20260924/PLAN.md».
- Leer el plan, compositor, generación de referencia, pruebas y fuentes citadas necesarias. Buscar fallos concretos de ejecutabilidad, contratos, preservación y cobertura. Entregar sólo hallazgos accionables, con líneas exactas y límites.
- Sólo lectura salvo este estado. No editar implementación, plan o proyectos; no instalar, renderizar ni ejecutar pruebas. No reabrir decisiones de producto ni asumir respuestas a Q1–Q9.
- Coordinador exacto: dev/plan/ngr-repair-audit-20260924/STATE.md, seleccionado en dev/SoT/ACTIVE.md; el estado anterior de redacción está DONE.

## dev/plan/ngr-repair-audit-20260924/oracles/STATE.md

Status: DONE · 2851 bytes · última modificación 2026-09-24

> Auditar C1, C2, C5 y los comandos de pruebas e instalación propuestos en dev/plan/ngr-repair-20260924/PLAN.md.

- Subtarea de la auditoría solicitada por el propietario: «lee el plan para repararlo . auditalo. dev/plan/ngr-repair-20260924/PLAN.md».
- Leer plan, código y pruebas necesarias para detectar errores concretos en oráculos, rutas, carga del candidato y diagnóstico de figuras. Entregar hallazgos accionables con líneas exactas y límites.
- Sólo lectura salvo este estado. No editar implementación, plan o proyectos; no instalar, renderizar ni ejecutar pruebas. No reabrir decisiones de producto ni asumir respuestas a Q1–Q9.
- Coordinador exacto: dev/plan/ngr-repair-audit-20260924/STATE.md, seleccionado en dev/SoT/ACTIVE.md; el estado anterior de redacción está DONE.

## dev/plan/ngr-repair-audit-20260924/STATE.md

Status: DONE · 4105 bytes · última modificación 2026-09-24

> Auditar dev/plan/ngr-repair-20260924/PLAN.md contra código, pruebas y contratos actuales.

- Instrucción vigente del propietario: «lee el plan para repararlo . auditalo. dev/plan/ngr-repair-20260924/PLAN.md».
- Alcance: revisión y continuidad de la auditoría. No implementar el plan, instalar, hidratar, renderizar proyectos ni mutar Git.
- Estado nuevo declarado en el chat. El estado del plan permanece DONE.
- Rutas cargadas y recibos verificados: continuity ae9919e0cc7b, code 20f157d03388 (veinte cartas completas), r 301dd508a2ee, python 7713fa30b469. La lectura de sot sirve sólo para contrastar el procedimiento propuesto; no hay reemplazo autorizado.
- Preservar cambios ajenos observados en dev/ y bugs/.

## dev/plan/ngr-repair-build-20260924/STATE.md

Status: DONE · 7921 bytes · última modificación 2026-09-24

> Entregar un handoff que reconstruya el prototipo CAN aprobado y distinga la integración histórica de los defectos Word actuales sin resolver.

- Última instrucción: «olvida el commit push. decime como resolviste el problema antes. decile al proximo agente que hiciste antes que funciono y que pasa ahora que no funciona».
- Staging, commit y push cancelados antes de ejecutarse. Implementación y render detenidos en este cierre. No reinstalar ni convertir a PDF.
- Propietario confirma cuerpo/tablas correctos en Word y objeta portada incompleta/adicional y formato de apéndices. Abrió la versión posterior a las 18:34 de ~/github/projects/AR-SABP0/docx; no atribuirlo a vista anterior.
- Fuente CAN validada; no Mendoza. Metadata params.yml y fecha automática. Preliminares acordados: carátula, portadilla, índice y firmas. Portada provisional cover.R sólo HTML, firmas conservadas en DOCX.
- Handoff solicitado para el siguiente agente. Su entrega no certifica ni resuelve el formato real de SABP0; nuevas acciones requieren la siguiente instrucción del propietario.

## dev/plan/ngr-skill-incident-20260921/STATE.md

Status: DONE · 1355 bytes · última modificación 2026-09-21

> Reportar a aom-v0 el bug grave del skill NGR solicitado por el propietario: recetas y parámetros deben proceder de pruebas, no de inferir comportamiento del help.

- Nueva tarea directa, declarada en dev/plan/ngr-skill-incident-20260921/STATE.md; estado anterior two-projects-status-20260921 permanece DONE.
- Autoridad: solicitud explícita del propietario de documentar y comunicar a aom-v0. Es comunicación a una tarea existente, no delegación ni nueva tarea.
- No ejecutar renders/deploys ni modificar skills, CLI, proyectos o Git. Distinguir el fallo de recomendación observado de un fallo de ejecución no reproducido.

## dev/plan/ngr-skill-review-20260922/STATE.md

Status: DONE · 2511 bytes · última modificación 2026-09-22

> Determinar si el skill NGR indujo o autorizó los errores de esta conversación; informar sólo a la tarea «fix skills» de ~/github/agents si se acredita una falla causal del skill.

- Solicitud directa del propietario 2026-09-22: revisar esa causalidad y, sólo si el skill fue la falla, reportar al agente indicado; no comunicar a todos los agentes del repositorio agents.
- Revisión documental de la extracción rechazada y de la atribución de mapas. No reabrir implementación, render, instalación ni publicación. La tarea previamente seleccionada m2v4d-final-scc-20260922 está DONE y permanece intacta.

## dev/plan/pending-implementation-20260921/STATE.md

Status: DONE · 3519 bytes · última modificación 2026-09-21

> Implementar los pendientes reales de ZOT/AOM y AR-S2J2J/NGR, y cumplir la instrucción posterior del propietario: «no. regenera los 36 escenarios y actualiza el informe».

- Tarea directa, seleccionada por dev/SoT/ACTIVE.md. La orden de regenerar los 36 reemplazó la elección anterior de recuperar cuatro casos.
- Se conservaron las predicciones SSEL y el contrato actual: F125.Qo.Do.vmd, D/MIC 150..400 cada 50, p90, 86 registros, D50=false, D100=false, nTheta=36, xi=.05. No se reentrenó SSEL ni se cambiaron targets por inferencia.
- Frontera de aom-v0: otros tres proyectos, reports/sha y activación de Hazard. Cierre informado en esa tarea.
- Efectos locales; no staging, commit, push ni despliegue. Los entrypoints TS/SRS independientes no son parte de esta regeneración.

## dev/plan/project-pending-20260921/STATE.md

Status: DONE · 5164 bytes · última modificación 2026-09-21

> Auditar cuáles afirmaciones de los dos diagnósticos AOM del 2026-09-21 son reales, incorrectas, desactualizadas o no comprobadas, por la corrección explícita del propietario. Esta tarea contrasta GMSP y SSEL y consolida con aom-v0.

- Tarea directa; nueva cadena dev/plan/project-pending-20260921/STATE.md. No reabrir estados DONE anteriores.
- Reparto acordado por intercambio con aom-v0: aquí GMSP y SSEL (proyectos, contratos/lectores, README y arnés SSEL); AOM toma Hazard/Newmark, identidad efectiva de instalaciones y consolidación AOM. El reparto sustituye las dos propuestas simultáneas.
- Leer código y consumidores antes de adoptar conclusiones de los diagnósticos; no inferir instalación obsoleta sólo por BUILD_INFO de un commit anterior.
- No repetir cálculos, matrices, migraciones, hidrataciones ni renders ya aceptados. No ejecutar pipelines científicos de AR-SABE0.
- Edición, staging, commit, push, borrado de referencias y GC son autoridades separadas. Preparar efectos Git concretos sin ejecutarlos por inferencia. No cambiar niveles TR, tope de tamaño ni valores científicos.
- Aplicar continuidad y metodología code/r para lecturas/correcciones de fuente; cargar sot/bash antes de sus acciones si se seleccionan. No activar consumidores por el nombre del producto.
- Nueva instrucción del propietario: revisar veracidad, no ejecutar recomendaciones del autor por presunción. Pausadas correcciones de producto y migraciones hasta contraste. AOM notificado: revisar Hazard/Newmark, identidad instalada y P4–P8; aquí GMSP y SSEL. No llamar falsedad a lo meramente no comprobado.

## dev/plan/publish-report-20260921/STATE.md

Status: DONE · 2785 bytes · última modificación 2026-09-21

> Commit y push de los cambios aceptados de AR-S2J2J; consultar el skill NGR y verificar el contrato actual para un nuevo deploy del informe.

- Tarea directa por orden «commit push. consulta al skill de ngr como hacer un deploy nuevo del reporte».
- Destino confirmado por el propietario: «si, dev a origin/dev». Publicación limitada a AR-S2J2J.
- Consulta de deploy: planes nativos y documentación. No se pidió explícitamente subir a producción ni crear sitios; no hubo efecto Netlify.
- Rutas aprobadas usadas: git c92fde5476da (stage/commit/push), ngr 46828e0ff9f8 (deploy --manifest --dry-run y deploy init --manifest --dry-run), continuity 022a663de9be.

## dev/plan/report-contracts/STATE.md

Status: DONE · 3825 bytes · última modificación 2026-09-20

> Implementar la petición del propietario de corregir y probar los lectores con los contratos actuales, dejar un plan compartible dividido entre NGR, hazard, newmark y gmsp, y retirar handoffs obsoletos absorbidos por él.

- Nueva tarea posterior a declared-bugs/DONE; no reabre sus acciones cerradas. El propietario autoriza ahora la reparación y la limpieza documental.
- Fuente de lectores: libraries/reports/sha. NGR hidrata y renderiza scaffolds; no contiene un catálogo cerrado de productos científicos. AOM conserva instaladores y CLI canónicos.
- Baseline inmutable: reports commit 6672b0d, scripts/setup/contracts.R, scripts/setup/hazardContext.R y scripts/tbl/Scenarios.R bajo sha/. Candidato concurrente observado: c1483f36ac5ea09e0c75f283172e1b6b89f5fe32, esos tres archivos. No atribuirnos su autoría ni sobrescribir cambios concurrentes.
- Diferencia solicitada: leer hazard.path.calcs y newmark.path.products. Mantener valores, selecciones, unidades, formato y política de tablas individuales ausentes. No recalcular productos científicos.
- Oráculo: baseline falla frente a contratos reales; candidato carga productos Newmark, metadatos clásicos y escenarios reales, y diagnostica contratos incompletos. Verificar identidad de los lectores efectivamente usados por proyectos.
- Rutas aplicables: code/review; r/review y script diagnóstico; sot/patch para aceptación e integración del candidato. Skills instalados leídos. No commit, push, instalación ni mensajes externos autorizados por inferencia.
- Preservar cambios ajenos. Eliminar sólo handoffs de NGR expresamente absorbidos por PLAN.md tras trasladar los pendientes todavía útiles.

## dev/plan/reports-status-20260921/STATE.md

Status: DONE · 1568 bytes · última modificación 2026-09-21

> Verificar el estado local y de publicación de libraries/reports/sha, incluidos commits y push, por la ampliación directa del propietario del 2026-09-21.

- Tarea directa; nueva cadena después de project-pending-20260921 DONE. La auditoría anterior queda cerrada y no se reabre.
- Interpretar «verifica el status ... commit push etc» como comprobación del estado Git y remoto; no inventar autoridad para staging/commit/push. No pedir confirmación para lecturas.
- No repetir renders ni pruebas GMSP aceptadas. Comparar archivos con identidades aceptadas sólo si explica qué falta publicar.
- Las ampliaciones propuestas por otros agentes no desplazan esta instrucción directa del propietario.

## dev/plan/s2j2j-close-20260921/STATE.md

Status: DONE · 4567 bytes · última modificación 2026-09-21

> Implementar los pendientes de AR-S2J2J y comprobar sus productos con NGR, GMSP y SSEL actuales, siguiendo «avanza por favor» del propietario tras la lista de pendientes.

- El propietario amplió el alcance: auditar .gitignore y faltantes tras clonar. Contrastar dependencias efectivas del render con índice y exclusiones locales/globales; conservar en Git los insumos necesarios y distinguir exclusión de eliminación histórica.
- Nueva tarea directa después de s2j2j-render-20260921 DONE; estado declarado dev/plan/s2j2j-close-20260921/STATE.md.
- Resolver los snapshots SSEL correspondientes, la configuración de plots y los productos NGR; preservar productos anteriores y no inventar Fmax, unidades o generación. Se autorizan las correcciones locales y su validación. No publicación remota inferida.
- Usar ngr público para manifest/render; code/r/sot para scripts consumidores, git para recuperación si resulta necesaria. No mantenimiento de productores ni nuevas corridas científicas sin demostrar su necesidad.

## dev/plan/s2j2j-render-20260921/STATE.md

Status: DONE · 3011 bytes · última modificación 2026-09-21

> Responder con evidencia al propietario si AR-S2J2J funciona y renderiza con NGR, GMSP y SSEL actuales.

- Tarea directa nueva después de s2j2j-ssel-20260921 DONE. Nuevo estado declarado dev/plan/s2j2j-render-20260921/STATE.md.
- Revisar masters reales y sus lectores; comprobación mínima aislada para render. No regenerar señales/escenarios ni alterar productos actuales para responder status. No commit/push nuevo autorizado por inferencia.
- Rutas vigentes: ngr render público; code/r para revisión de scripts consumidores. GMSP fuente no es objetivo de mantenimiento. Leer contratos públicos instalados de funciones realmente usadas antes de probar.
- AOM mantiene Hazard y README/arneses SSEL; AR-S2J2J permanece aquí.

## dev/plan/s2j2j-ssel-20260921/STATE.md

Status: DONE · 6002 bytes · última modificación 2026-09-21

> Atender el fallo nuevo de AR-S2P30 al renderizar docx (Mw.gmdp ausente) y completar la petición vigente de compatibilidad AR-S2J2J con SSEL actual, con commit nuevo en dev que preserve lo anterior, coordinando con aom-v0.

- Tarea directa del propietario, nueva después de dev-cleanup-20260921 DONE. Estado declarado: dev/plan/s2j2j-ssel-20260921/STATE.md.
- El reporte nuevo de Mw.gmdp tiene prioridad; no cancela AR-S2J2J. Leer consumidor, configuración y productor antes de elegir corrección; no inventar valores científicos.
- AR-S2J2J: autorizado ajustar y crear commit en dev; no inferir push. Preservar main y outputs antiguos; revisar efectos de scripts antes de ejecutarlos.
- Coordinar con tarea aom-v0 01a0a5b0-d006-7ee3-b2d5-e2748ef82519. No nueva delegación lanzada.
- Rutas aprobadas: code para revisión/edición, sot para transición de fuente existente, r para R, ngr para render público, git para futuro commit. Recibos coinciden con catálogo vigente.

## dev/plan/sabp0-docx-format-audit-20260924/STATE.md

Status: DONE · 2191 bytes · última modificación 2026-09-24

> Auditar por pedido nuevo del propietario la diferencia de portada y apéndices entre los DOCX actuales de AR-SABP0 y el prototipo SRK CAN; explicar responsabilidad y migración faltante.

- Pedido: «vos preparaste el codigo python ... revisa ~/github/projects/AR-SABP0/docx/ ... acaso debimos hidratar SABP0 con un nuevo master/_docx? ... o mentiste?». Autoriza inspección y diagnóstico, no nuevos parches ni renders científicos.
- Handoff anterior cerrado en dev/bugs/20260924-handoff-docx-ar-sabp0.md; se preserva la detención de implementación. Nueva revisión separada, sin reabrir renders fallidos ni el estado DONE anterior.
- No intervenir Word ni modificar los DOCX abiertos, los masters, los builders o la instalación.

## dev/plan/sabp0-docx-render-20260924/STATE.md

Status: DONE · 7187 bytes · última modificación 2026-09-24

> Entregar el handoff solicitado en dev/bugs y detener la implementación. La reparación/aceptación DOCX permanece sin resolver para la auditoría del siguiente agente.

- Instrucción final del propietario: «ya esta. fallaste ... prepara un handoff, otro agente va a revisar el dano ... declara lo qeu hiciste y lo que rompiste», ubicación «en dev/bugs». No continuar parches ni renders; documentar efectos y límites de atribución.
- Instrucción nueva: «reinstalado... ahora pueds intentar renderizar AR-SABP0?». Retomar primero ambos idiomas de AR-SABP0 con el CLI instalado; no reinstalar ni modificar el proyecto.
- Mandato actual: «revisa la carpeta NGR/dev/bugs ... hay qye hacer ajustes a NGR porque este problema es un problena del codigo. 20260924-docx-metadata-from-params.md». Archivo localizado en bugs/, leído completo: cliente/consultora/código desde params.yml; título/lang del master; fecha automática dd/mm/yyyy idéntica al sello Printed; rótulos es/en. Sin srk ni cambios a proyectos ni campos nuevos. Reinstalación de la librería a cargo del propietario, como declara el bug.
- Aceptación indicada en ese contrato: AR-SABP0 y AR-S2L1W, masters _master/docx.es.qmd y _master/docx.en.qmd, perfil docx, destinos docx/docx.es.docx y docx/docx.en.docx. AR-SABP0 conserva confirmación directa de cliente Anglo American / Stracon, consultora SRK Consulting (Argentina) S.A., código AR-SABP0 y títulos actuales. No preguntar fecha fija otra vez.
- Reparación y pruebas de fuente autorizadas. No nuevo commit/push por extender publicación CAN ya completada; no instalar, intervenir Word ni regenerar productos científicos.
- Rutas leídas/recibos comprobados: continuity ae9919e0cc7b; code20f157d03388 y20cards; r301dd508a2ee conpackages; python7713fa30b469; sot e6d9504c32ae; writing7fc3bebbd027 y ledger para documentación. Cambios ajenos de quartoRenderStamp/tests/manual, test-resources y dev preservados; se consume el sello Printed actual sin editarlo.

## dev/plan/sabp0-docx-rerender-20260924/STATE.md

Status: DONE · 3824 bytes · última modificación 2026-09-24

> Renderizar los masters DOCX español e inglés de AR-SABP0 con apéndices explícitos mediante NGR, perfil docx.

- Instrucción nueva del propietario: «entonces edita el master de docx, agrega los apendices y renderizalo e profile docx con ngr... qu emas necesitas?».
- Proyecto validado: /Users/averrik/Cloud/github/projects/AR-SABP0. Masters _master/docx.es.qmd y _master/docx.en.qmd; perfil docx; destinos existentes docx/docx.es.docx y docx/docx.en.docx. Conservar copia previa antes de reemplazarlos.
- Continuación de la instalación aislada de prueba autorizada por el propietario: dev/SoT/ngr-repair-build-20260924/installed/{library,prefix}. No reinstalar. No PDF. Commit y push siguen cancelados.
- Metadata desde params.yml, fecha automática, fuente CAN, cover.R provisional sólo HTML y firmas conservadas. No modificar cuerpo, tablas ni resultados científicos.
- Route: ngr (03b35b69a704), operación pública render. Ejecución secuencial mediante CLI instalado, con R_LIBS y R_LIBS_USER apuntando a la biblioteca aislada.

## dev/plan/sabp0-hydration-correction-20260924/STATE.md

Status: DONE · 2285 bytes · última modificación 2026-09-24

> Corregir la instrucción de hidratación de AR-SABP0 conforme al skill instalado y dar los comandos para que el propietario genere ambos Word.

- Nuevo mandato del propietario: «no. así no se hidrata. lee bien el skill». Rechaza la reducción anterior a dos archivos. Se retira esa recomendación como procedimiento de hidratación del proyecto.
- Se conserva su elección «tenemos que generar ambos. lo hago yo»: Word español e inglés; el propietario ejecuta. No instalar, hidratar ni renderizar por él.
- Ruta ngr 03b35b69a704, operaciones pull y render; continuity ae9919e0cc7b. Skills y recibo releídos; no recurrir al help como acreditación de procedimiento.
- Reinstalación ya verificada en la cadena srk-can-install-20260924, que permanece DONE. No repetir instalación ni reporte a fix skills.

## dev/plan/session-skill-errors-20260922/STATE.md

Status: DONE · 2744 bytes · última modificación 2026-09-22

> Revisar los otros errores documentados de esta sesión, contrastar su causa con la versión aplicable de los skills NGR/hazard y reportar sólo a «fix skills» si se acredita una falla del skill.

- El propietario aclaró que no se refiere al error de recomendar 21 productos y exige revisar los demás errores de esta sesión. No limitar esta revisión a arquitectura ni a esa recomendación.
- Sólo auditoría documental y eventual reporte autorizado; no modificar productores, skills, cálculos, renders, sitios ni Git.
- Tarea actual: «Auditar NGR contra QRT y PSHA», ID01a0bf93-b6a8-7910-ba8f-6eb0c1a60917, NGR. Único destinatario autorizado: «fix skills», ID01a0c60d-8f94-7023-ba9d-f1e1e89a9055, /Users/averrik/Cloud/github/agents. Identificados por list_threads; título y ubicación coinciden. No contactar aom-v0 ni otras tareas.
- La cadena previa ngr-skill-review-20260922 está DONE, con veredicto acotado a extracción/arquitectura; no prueba causalidad de los otros incidentes.

## dev/plan/sha-docx-contract-bug-20260924/STATE.md

Status: DONE · 2826 bytes · última modificación 2026-09-24

> Explicar los campos que exige NGR para Word, comprobar compatibilidad del scaffold SHA y reportar el defecto en reports/dev/bugs según la petición del propietario.

- Propietario: «que campos necesitan mis proyectos ... es un bug de mi scaffold ... reportalo ... sino explicame». Autoriza auditoría y reporte local; no reparación, render, hidratación ni nuevas mutaciones Git.
- Ruta indicada abreviada ~/github/reports no existe. Repositorio SHA observado y ya usado en esta tarea: /Users/averrik/Cloud/github/libraries/reports; su dev/bugs existe. Reportar allí, sin crear repositorio paralelo.
- continuity ae9919e0cc7b y writing 7fc3bebbd027; ngr03b35b69a704 leído como contrato de hidratación, sin operación CLI. Skills/recibo leídos; writing/casos/ledgers ya leídos íntegros en esta sesión. No repetir pruebas de la implementación CAN aceptada.

## dev/plan/srk-can-build-20260924/audit/STATE.md

Status: DONE · 3928 bytes · última modificación 2026-09-24

> Auditar la candidata CAN de NGR y comunicar defectos accionables antes de su integración local.

- Propietario pidió «prepara un prototipo, un plan y audito con otro agente antes de promocionarlo a NGR»; el plan autorizado dev/plan/srk-can-implementation-20260924/IMPLEMENTATION.md requiere auditoría independiente. Nueva instrucción «ahora se ve bie. implementamos lo spasos siguients?» autoriza código local y pruebas. Sin commit/push ni instalación habitual.
- Metadata aprobada por propietario: title y srk.client/company/project/date explícitos en master; fecha de emisión y código de proyecto. Una pasada Quarto resuelve semántica; Python compone visuales; referencia CAN sustituye hoja anterior.
- Sólo lectura de implementación, baseline, tests y callers. Escribir informe y estado únicamente bajo dev/plan/srk-can-build-20260924/audit/. No modificar código ni manejar Word.
- Código metodología/python/r/sot según rutas aplicables; continuity para estado. Usar Python de /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3. Para cualquier conversión PDF usar sólo LibreOffice bundled: /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/override/soffice; no LibreOffice desktop.

## dev/plan/srk-can-build-20260924/STATE.md

Status: DONE · 8532 bytes · última modificación 2026-09-24

> Implementar los pasos siguientes del plan SRK CAN: referencia CAN y composición Python propiedad de la librería NGR, consumida por API y CLI; verificar un reporte completo y dejar evidencia revisable.

- Propietario: «ahora se ve bie. implementamos lo spasos siguients?». Cierra la objeción de portada en Microsoft Word y autoriza implementar el plan documentado dev/plan/srk-can-implementation-20260924/IMPLEMENTATION.md. La aprobación visual proviene del propietario; no atribuirla a una nueva observación propia.
- Mantener referencia CAN obligatoria, librería dueña del motor y CLI consumidor; preservar fuentes Crawford, candidato5 y trabajo ajeno. No promover por copia directa el prototipo ni usar Mendoza.
- Implementación local y pruebas, sin commit/push ni instalación en el entorno habitual. Una instalación aislada de prueba corresponde a la validación API/CLI del plan. Printed queda fuera de esta implementación.
- Rutas de metodología: code (diseño/implementación y cierre estructural), python, r (incluidas mecánicas de paquete), sot (preservar baseline/candidata y verificar superficie integrada). Las decisiones de metadata no resueltas se consultan antes de su implementación dependiente.
- Propietario aprobó por respuesta async «Sí, metadata explícita en el master»: title + srk.client/company/project/date obligatorios; project es código y date emisión; encabezado/pie usan título/código/fecha. No inferir empresa, cliente ni fecha de generación como defaults.
- Propietario aprobó la entrega corregida con «Perfeccto. aprobado» después de recibir word-review/report.docx y las instrucciones para revisar apertura y cuerpo en Word. Esta aceptación cierra el aviso y la revisión visual; procede del propietario, no de una observación propia de Word. No amplía la autoridad a instalación habitual ni Git.

## dev/plan/srk-can-implementation-20260924/STATE.md

Status: DONE · 3334 bytes · última modificación 2026-09-24

> Documentar el plan de código SRK CAN para que otro agente lo implemente; verificar arquitectura librería/CLI y explicar alcance observado del prototipo.

- Instrucción nueva del propietario: «perfecto. avanza ... deja el plan documentado para que otro agente lo implemente ... el código ... trabaja desde la librería y el CLI lo usa? ... el prototipo funciona? ya renderizó reportes con este formato?». Autoriza especificación técnica y lectura de fuentes/evidencias, no solicita implementar producción en esta entrega ni lanzar otro agente ahora.
- Estado anterior dev/plan/srk-prototype-20260924/STATE.md DONE se preserva. Fuente CAN/NA elegida expresamente; reemplazo de reference.docx obligatorio en el plan. Se conserva una resolución común de citas y tres zonas visuales. Word y LibreOffice son criterios de aceptación.
- Leer callers, recursos, distribución y tests antes de fijar plan. Diferenciar lo probado por la muestra de lo no integrado. No repetir pruebas verdes ni renderes idénticos. No Git, instalación, publicación o edición de producción.

## dev/plan/srk-can-install-20260924/STATE.md

Status: DONE · 8406 bytes · última modificación 2026-09-24

> Dar al propietario los comandos de hidratación/render Word de AR-SABP0 después de la reinstalación de NGR ya verificada, respetando las elecciones que valide.

- Propietario 24/09: «NGR reinstalado». Se verificó el producto instalado; no repetir instalación. Skill install d84b25445ba6 leído para esta comprobación posterior, sin invocar instalador.
- Propietario, nuevo pedido 24/09: «ahora instalo NGR? quiero hidratar el proyecto AR-SABP0 y renderizarlo en word. como hago?». Se interpreta como solicitud de instrucciones: no ejecutar instalación, pull ni render para producirlas.
- Rutas actuales: continuity ae9919e0cc7b; ngr 03b35b69a704, operaciones públicas pull y render. Recibo instalado coincide con ambos prefijos. Leídos SKILL.md y referencias resources-manifest, render y recipe-evidence.
- Propietario respondió «tenemos que generar ambos. lo hago yo. ya puedo renderizar?»: quedan seleccionados los masters Word español e inglés ofrecidos, conservando configuración y actualizando recursos registrados. Dar comandos; no ejecutar pull ni render.
- Propietario: «aprobado» en respuesta al siguiente paso declarado de instalar en el entorno habitual; luego «instala». Autoriza la instalación local del código aprobado mediante el instalador oficial, manteniendo destinos existentes.
- La aceptación del cuerpo Word y la corrección del aviso está cerrada en dev/plan/srk-can-build-20260924/STATE.md (DONE). No reabrir implementación ni repetir su validación sin defecto nuevo.
- No hay autorización de commit/push, publicación remota, cambio de versión de release ni migración de proyectos existentes. No intervenir en Word.
- Ruta de instalación actual: install; verificación posterior solamente. Mantener la operación normal, sin alternativas ni llamadas a helpers de instalación.
- Propietario rechazó el comando con --tarball: «no entendiste cómo se instala ni cómo funciona el instalador. rechazado». Retirar esa selección y la consulta async que pedía ejecutarla. Mantener la instalación normal desde checkout; no consumir el archivo preparado ni volver a proponer ese flujo.
- Propietario reafirmó «sudo bash install/install.sh» y pidió reportar al agente de ~/github/agents/ que el skill está corrupto porque no debió ocurrir el desvío. Reporte autorizado; distinguir denuncia del propietario de una causa aún no demostrada.

## dev/plan/srk-can-publish-20260924/STATE.md

Status: DONE · 4929 bytes · última modificación 2026-09-24

> Commit y push de los cambios propios SRK CAN de NGR; dejar el reporte solicitado de fallas de skills en ~/github/agents/bugs.

- Propietario: «commit push de tus cambios». Confirma destino por respuesta async: «Sí, dev → origin/dev», github.com/averriK/NGR. Autorizadas preparación del índice, commit y publicación en ese destino, sin reescribir historia.
- Pedido adicional: «reporta a github/agents/bugs los errores que cometiste por culpa de un mal skill ... reporta qué skill usaste ... si ... alguno». Autoriza reporte local en agents/bugs; no confundir con autorización de publicar Git de agents ni enviar mensajes adicionales.
- Rutas: git 831f68b86775, continuity ae9919e0cc7b, writing 7fc3bebbd027 para el reporte. Leídos git, continuity, writing, sus casos/ledgers y agents/AGENTS.md. User solicita escribir el reporte; no condicionar esa escritura a nueva aprobación editorial.
- Alcance Git propio comprobado en srk-can-build/owned.json (20 archivos) y deletions.json (2 retiros). Preservar los cambios expresamente ajenos en quartoRenderStamp y tests/docs, test-resources y los otros pendientes no incluidos en ese alcance; no publicar carpetas de pruebas/render temporales.
- NGR/AR-SABP0: se detectó que la recomendación anterior de render listo omitió srk.client/company/project/date requeridos por el contrato CAN. Los masters leídos carecían de srk. Se informó al propietario. No escribir valores ni ejecutar render; incorporar este error al reporte.

## dev/plan/srk-cover-comparison-20260924/STATE.md

Status: DONE · 3363 bytes · última modificación 2026-09-24

> Revisar nuevamente la fidelidad visual de la portada del prototipo NA frente al reporte CAN aportado, identificar diferencias reales y corregir la conclusión/documentación según evidencia.

- El propietario cierra su objeción en Word con «ahora se ve bie. implementamos lo spasos siguients?». La portada queda conforme por esa observación del propietario, no por una nueva prueba automática. La implementación es una nueva tarea.
- Comparar candidato5 enlazado en entrega con DOCX/PDF Crawford elegidos por el propietario. Revisar tipografía efectiva, posición y diferencias Word/LibreOffice. Preservar fuentes y entregables anteriores. No cambiar arbitrariamente diseño ni metadata; diagnosticar primero.
- El propietario confirmó «En Microsoft Word» como visor donde observa la diferencia. La comprobación en LibreOffice no demuestra fidelidad en Word. No controlar Word mientras el propietario lo usa; inspección de ventanas sin editar ni cerrar documentos.
- La hoja CAN del cuerpo sigue pendiente del plan. Esta revisión no modificó producción. La instrucción nueva autoriza avanzar con la implementación desde un nuevo estado.

## dev/plan/srk-document-demo-20260924/content/STATE.md

Status: DONE · 4288 bytes · última modificación 2026-09-24

> Generar un único DOCX de contenido de demostración con cuerpo y tres apéndices para que el coordinador incorpore carátula y portadas SRK.

- Misión srk-demo-content-20260924. El propietario solicita un documento completo renderizado para evaluar el plan. Sólo escribir bajo dev/plan/srk-document-demo-20260924/content/.
- Leer AUDIT.md y object-map/REVIEW.md de dev/plan/srk-template-20260924, perfil NGR y el fixture objects.qmd antes de diseñar. Usar referencia cli/scaffold/styles/reference.docx actual para cuerpo. No cambiar producción, ejecutar ciencia, instalar ni Git.
- Crear espécimen en español con contenido verificable de la auditoría: propósito, mecanismo de composición, objetos presentes y resultados A/B/C; no inventar datos de cliente, autores, firmas o resultados científicos. No copiar la auditoría completa como informe: redactar contenido conciso que permita evaluar diseño, unas3–4 páginas de cuerpo más contenido de3 apéndices.
- Un render Quarto común de cuerpo+apéndices, sin filtro appendix-style defectuoso. Mantener bibliografía global para no inventar política por parte. Puede usar bibliografía real ya existente y una cita contextual a Newmark1965 en una sección sobre objetos de informes; leer la entrada antes. Alternativamente usar fuentes documentales primarias verificadas.
- Estructura: H1 cuerpo, H2–H4 en cadena; tabla Markdown y tabla flextable con celdas combinadas y nota si factible sin cambiar datos; una tabla que cruce página de catálogo de estilos real; figura esquemática de composición (SVG/PNG dibujado por código, sin imagegen); fórmula OMML descriptiva de suma de anchos, nota al pie real, listas y referencias internas. No inventar resultados cuantitativos.
- Tres H1 de apéndice con IDs exactamente sec-demo-apx-a, sec-demo-apx-b, sec-demo-apx-c. Títulos: Catálogo de objetos; Tablas y notas; Trazabilidad del documento. El coordinador usará esos bookmarks para insertar portadas y reestilar. Sus contenidos deben usar H2/H3, no otro H1 accidental. Bibliografía global H1 Referencias al final del cuerpo, antes de apéndices, con todas las fuentes del conjunto.
- Entregar content.docx, fuentes QMD/BIB/imagen y una nota de instrucciones breves. Renderizar Quarto para verificar XML; la QA visual final la hará el coordinador después de componer. No añadir carátula propia ni página de título Quarto. No generar texto de informe con explicaciones de implementación innecesarias.
- Runtime Python /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3; si necesitas LO sólo bundled /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/override/soffice. No Word UI. El coordinador ejecutará marker de creación; no repetir. Cargar skills code/python/r según operaciones. Nuevo código local permitido; nombres de casa.

## dev/plan/srk-document-demo-20260924/review/STATE.md

Status: DONE · 2715 bytes · última modificación 2026-09-24

> Revisar estáticamente el compositor del espécimen SRK y detectar riesgos concretos del DOCX para entrega, sin editarlo ni modificar producción.

- Delegación de la petición del propietario de ver un documento completo renderizado antes de aprobar el plan. Revisión acotada de dev/plan/srk-document-demo-20260924/compose_demo.py y sus inputs dev/lib/Report_MDZ_202608.dotx y content/content.docx. El coordinador está corrigiendo layout; las observaciones se refieren al hash leído, no afirmar verificar bytes posteriores.
- Es un prototipo local con bibliografía/crossrefs resueltas en una pasada, no tres renders independientes. Auditar conservación de partes, relaciones, estilos/numIds, bookmarks, notas, sección y propiedades OOXML que puedan producir reparación en Word. Leer sólo artefactos relevantes. No modificar archivos del coordinador, no volver a renderizar, no operar Word. Reporte y estado sólo en write_root.
- Runtime Python /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3. Si surgiera necesidad futura de LibreOffice, sólo /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/override/soffice. No instalar dependencias ni escribir fuera de write_root.

## dev/plan/srk-document-demo-20260924/STATE.md

Status: DONE · 4769 bytes · última modificación 2026-09-24

> Entregar un documento completo de demostración SRK en DOCX y PDF para que el propietario pueda evaluar visualmente el resultado antes de aprobar el plan.

- Nueva instrucción del propietario: «necesito ver un documento completo renderizado para aprobar el plan; si no no sé qué logras». Autoriza preparar un prototipo local completo y renderizarlo, no integrar todavía producción.
- Se conserva la fuente de diseño validada dev/lib/Report_MDZ_202608.dotx y la referencia actual del cuerpo cli/scaffold/styles/reference.docx, conforme a sus instrucciones anteriores. Tres apéndices y objetos NGR forman parte del espécimen de aceptación solicitado; usar contenido documental de la auditoría y fuentes leídas, sin inventar resultados de un proyecto ni calcular ciencia.
- Prototipo con carátula hidratada, cuerpo y tres apéndices; objetos: H1–4, captions, tablas, imagen, matemática, nota al pie, citas/bibliografía. Mantener bibliografía común en esta demostración como en el master actual: el propietario no eligió todavía bibliografía por parte. No presentar el prototipo como prueba de tres renders independientes.
- Trabajar sólo en esta carpeta. No modificar NGR, referencia actual, DOTX original, proyectos científicos, instalaciones ni Git. Recursos de auditoría anterior son fuentes verificables, no repetir sus diagnósticos cerrados.
- Runtime Python /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3; Node /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node. Sólo LibreOffice bundled /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/override/soffice. No operar Word mientras está en uso del propietario; entregar DOCX para revisión y PDF inspeccionado, sin afirmar validación Word no observada.
- Skills documents, code, python y continuity aplican; sot antes de modificar código existente. Instalar dependencias requiere autorización independiente; no necesario para comenzar.

## dev/plan/srk-docx-commit-20260924/STATE.md

Status: DONE · 3004 bytes · última modificación 2026-09-24

> Crear commits locales de los cambios DOCX de NGR y del scaffold compartido reports/sha para que el propietario reinstale.

- Instrucción nueva: «estoy viendo una de tus pruebas y parece funcionar... por favor, commit los cambios del scaffold y del NGR y reinstalo».
- Autoriza staging y commit de los cambios de esta tarea en NGR y reports/sha; no push ni instalación. No nuevos renders ni PDF.
- Repositorios: /Users/averrik/Cloud/github/libraries/NGR y /Users/averrik/Cloud/github/libraries/reports; ramas actuales dev. Conservar identidad humana configurada y cambios ajenos.
- Route: git (831f68b86775), operaciones staging y commit. Inspeccionar diff de trabajo, luego snapshot completo staged y commit resultante.

## dev/plan/srk-docx-push-20260924/STATE.md

Status: DONE · 2859 bytes · última modificación 2026-09-24

> Publicar los commits locales de NGR y reports/sha solicitados después de la reinstalación informada por el propietario.

- Nueva instrucción: «reinstalado commmit push?». Commit y push solicitados para la continuación de los dos repositorios; los commits propios ya existen y no deben duplicarse.
- El usuario informa reinstalación; no se verificó instalación en esta operación Git.
- Route: git (831f68b86775), operación push. No instalación, cambios de implementación, renders, PDF ni historia reescrita.
- El propietario responde «push, y cerramos» a la confirmación de los destinos NGR→averriK/NGR:dev y reports→kanameishi/reports:dev y del alcance de 3 y 36 commits respectivamente. Ambos destinos y sus commits anteriores quedan autorizados.

## dev/plan/srk-prototype-20260924/audit/STATE.md

Status: DONE · 4837 bytes · última modificación 2026-09-24

> Auditar independientemente el prototipo Python SRK, su plan y preservación antes de considerar promoción.

- Autoridad del propietario: «prepara un prototipo, un plan y audítalo con otro agente antes de promocionarlo a NGR». Esta misión sólo revisa; escribe pruebas/evidencia/informe en dev/plan/srk-prototype-20260924/audit/. No editar implementación, producción ni entregables previos. Enviar hallazgos a root y al constructor /root/srk_prototype_build.
- Candidato está siendo terminado por constructor en implementation/srk_prototype.py, prepare_fixture.py, sample-spec.json, sample-content.docx, srk-template.zip y prototipo-srk.docx (ver nombres exactos en su README cuando exista). Leer archivos reales; no tratar ausencia temporal como defecto. Root entregará aviso de identidad final antes de cerrar. Puedes adelantar revisión de PLAN.md, artifact.md, integration/INTEGRATION.md y mecanismos existentes; no certificar bytes que cambien durante revisión.
- Baseline preservado dev/plan/srk-document-demo-20260924/compose_demo.py. Fuente explícita dev/lib/Report_MDZ_202608.dotx SHA256 a59d255d3ea3c91491ddb468b003b096a9df996cd8de90c997921f7eb89d5a74. Contenido original dev/plan/srk-document-demo-20260924/content/content.docx SHA25662732c96e7cc3639e57df14556683b4f3320812a7d0495cbd7ec6579f4f27958. No auditar entrega vieja como si fuera nueva.
- Portada anterior rechazada: esquema inventado no debe aparecer. Comparar estructura de portada, estilos/num y dependencias con fuente. Cuadrados naranjas sí existen en fuente y deben conservarse. Pie fuente10pt frente a demo11pt es desviación real. No existe gran desplazamiento superior: medición PDF descartó esa primera hipótesis de root. Propietario ofreció documento humano, aún pendiente; no afirmar aprobación visual ni Word.
- Revisión focal: selectores, límites de entrada, mapeos y colisiones, preservación texto ordenado/citas/notas/bookmarks/relaciones/matemática/tabla, conflictos pPr, atomicidad y errores, contratos no basados en assert, alcance proporcionado. Cuerpo una sección y apéndices por bookmarks explícitos es límite intencional; no exigir generalidad arbitraria. Probar variación de cantidad, errores y preservación con fixtures derivados de input autorizado en write_root. No repetir tests verdes mismos bytes sin observable nuevo; revisar evidencia del constructor y añadir sólo pruebas independientes competentes.
- Aplicar continuity, code, python y sot según corresponda. Runtime Python /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3; sin instalar dependencias. No operar Word. Si render fuera necesario, coordinar con root; sólo LibreOffice /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/override/soffice. Root renderiza/QA; puedes inspeccionar PNG/PDF generados para contraste, no afirmar cobertura Word.
- Cerrar con candidato final y hallazgos atendidos o límites explícitos. No confundir aceptación técnica acotada con aprobación visual del propietario. Referencia humana recién recibida dev/lib/CAPR003324_Crawford_SeismicHazard_20260831.docx: coordinador atiende análisis, fuera del candidato auditado. Printed está fuera de auditoría.

## dev/plan/srk-prototype-20260924/implementation/STATE.md

Status: DONE · 6662 bytes · última modificación 2026-09-24

> Construir un prototipo reutilizable de composición SRK desde el ensayo existente, sin editar producción ni entregables previos.

- Corrección posterior del propietario: «la portada no se parece al template SRK» y cuestiona la imagen inventada. La carátula anterior está RECHAZADA como oráculo visual. NO copiar dibujo del cuerpo a portada. Sólo logo original y elementos reales de fuente; slot de fotografía queda vacío (no placeholder inventado) hasta imagen real del propietario. Preservar geometría fuente y limitar modificaciones a hidratación/bugs. Avisar cualquier desvío necesario; no declarar fidelidad final sin QA comparativa del coordinador.
- Delegación de la petición del propietario «prepara un prototipo, un plan y audítalo con otro agente antes de promocionarlo a NGR». Esta misión implementa, otra misión independiente auditará el candidato final. Root prepara plan y QA visual; no generar PDF aquí.
- Escrituras sólo dev/plan/srk-prototype-20260924/implementation/. Leer baseline dev/plan/srk-document-demo-20260924/compose_demo.py (SHA256 2d8f890913e18d9930ab196b2345dfeedf655344a62302a4c079deb0f5fafee6), su artifact.md, README.md y contenido. Conservar baseline intacto, candidato nuevo en write_root.
- Implementar CLI Python local con prepare-template y compose. prepare-template deriva versión propia del DOTX validado (dev/lib/Report_MDZ_202608.dotx SHA256 a59d255d3ea3c91491ddb468b003b096a9df996cd8de90c997921f7eb89d5a74), sin formularios legacy usados en cover/apéndice y con componentes/slots identificables. Puede ser paquete de componentes ZIP con manifiesto explícito si simplifica sin fingir que es un DOTX abrible; documentar formato. compose toma template preparado, content.docx y JSON explícito con metadata de portada/header/footer y lista ordenada de bookmarks de apéndices/resúmenes, produce DOCX. No generalizar merge arbitrario de DOCX.
- Inputs de muestra autorizados: content/content.docx de la fase anterior, misma metadata y tres apéndices de su compositor. No inventar resultados/proyectos. Citas comunes resueltas por Quarto; preservar bookmarks y bibliografía. Geometría SRK A4 y cuerpo Letter como fuentes. No colocar título/fecha, nombres sec-demo ni índices body[78] en lógica general: ubicarlos por estilos/estructura validada en la preparación específica del DOTX y en spec de muestra. Metadata todos campos explícitos.
- Conservar todas las partes originales no afectadas, grid/cell widths, merges, notas, matemática, imágenes, links; importar estilos/nums con cierre de dependencias y sin colisiones; preservar los estilos del cuerpo. La operación prepare depende del hash exacto SRK; compose soporta lista variable de apéndices del contenido, comprueba existencia, unicidad y orden. No inferir por palabra References. Sólo normalizar conflictos pPr conocidos (caption/jc) y fallar ante conflicto desconocido en vez de borrar datos silenciosamente.
- Validación de errores con excepciones (no assert de contratos que desaparezcan con python -O), escritura temporal+reemplazo sólo tras validar, rechazar output que pise inputs y detectar documento ya compuesto. Errores deben conservar output previo. Sin normalizador regex global ni autofit sobre cover. Mantener cuerpos con una sección simple en v0 y rechazar explícitamente sección interna no soportada; plan cubrirá paisaje/múltiples secciones después.
- Reutilizar mecanismos probados, pero no importar script de dev externo como dependencia runtime. Código acotado en uno o pocos módulos. Añadir tests unittest focales que prueben salida y fallos relevantes; evitar marco de pruebas nuevo. No replicar datos de ciencia. No instalar dependencias. lxml y python-docx bundled disponibles, declarar dependencia si se usa. Mantener convención code/python/sot. La ecuación especial de la demo puede pasar por preparación de fixture separada; no fijar eq-ancho en composer general.
- Python /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3. Si fuera necesario renderizar tras coordinación con root, sólo LibreOffice /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/override/soffice. No usar Word ni renderer aquí. Entregar CLI, spec de muestra, template normalizado, DOCX compuesto y README con comandos y límites. Avisar pronto de interfaz al coordinador.

## dev/plan/srk-prototype-20260924/integration/STATE.md

Status: DONE · 3470 bytes · última modificación 2026-09-24

> Mapear puntos reales de integración futura del prototipo SRK en NGR y producir recomendaciones verificadas para el plan.

- Aclaración del propietario comunicada por el coordinador al cerrar: tamaño Printed está bien; reclamo es hora de generación y zona horaria. Diagnóstico tipográfico cerrado, pregunta de salida retirada. No editar producción; prioridad portada SRK. Incorporar sólo el diagnóstico del diff/caller/pruebas y el pendiente acotado.
- Delegación de instrucción «prepara un prototipo, un plan y audítalo con otro agente antes de promocionarlo a NGR». Sólo lectura de NGR y escritura de INTEGRATION.md y estado dentro de esta carpeta. No editar producción, no Git, no renders científicos ni instalaciones.
- Leer callers reales de render desde cli hacia lib/R/quartoRender.R, perfil cli/scaffold/yml/_quarto-docx.yml, filtros appendix-style/cover-title/list-style, lib/inst/docx/fix_docx.py, tests pertinentes y mecanismos manifest/master que usan cuerpo y apéndices. Un listing o grep sólo es locator, abrir archivos para afirmaciones. Citar paths y líneas actuales.
- Plan deseado: mantener referencia actual del cuerpo, preparar componentes SRK normalizados de DOTX, reparar contenido antes de componer carátula y portadas de apéndice, validar antes de publicar salida. El prototipo actual usará contenido con citas comunes resueltas en una pasada; tres renders independientes aún son alternativa. No inventar nuevo campo público si existing manifest ofrece el dato; separar decisiones pendientes de mecanismos implementables.
- Analizar despliegue Python/dependencias, ruta del fixer, pruebas actuales y forma de entregar output sin pisar salida válida ante error. Identificar mínimo diff futuro y gates, especialmente Word/LibreOffice y crossrefs/bibliografía. No producir esquema final de configuración ni ejecutarlo, sólo propuesta ligada a código leído.
- Leer skills code/python/r conforme revisión; no usar ngr consumer para fuente. Runtime Python bundled /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3. Sólo LibreOffice bundled /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/override/soffice si surgiera necesidad; esta misión no renderiza.

## dev/plan/srk-prototype-20260924/na-audit/STATE.md

Status: DONE · 3557 bytes · última modificación 2026-09-24

> Auditar de forma independiente el cambio del compositor local MDZ a la fuente NA elegida por el propietario, antes de promoción.

- Usuario: «el dotx mendoz esta corrupto. usa lo de NA». Candidato auditado final dev/plan/srk-prototype-20260924/na-candidate-5/srk_prototype.py. Baseline intacto implementation/srk_prototype.py2bfe9775; fuentes NA DOCX/PDF en dev/lib/CAPR003324_Crawford_SeismicHazard_20260831.*.
- Root trabaja en render/fixture/pruebas. Auditar implementación y preservación, relaciones/imágenes, cierre de estilos y numeración, bindings viejos de Crawford, entrada inválida, identidad de cuerpo. Enviar hallazgos temprano, no editar candidato; escribir sólo na-audit/. No promover ni modificar fuente/producción.
- Defecto _replaceText detectado por root, reproducido por auditor sobre4 y corregido en5: se toma el primer run y su rPr opcional, sin propagar VerbatimChar posterior.
- El separador usa celda de altura disponible y centrado vertical; resúmenes en primera página de contenido. Root comunicó ampliación del plan por instrucción del propietario: generar y reemplazar reference.docx desde CAN. PLAN.md leído lo exige y declara el cuerpo actual transitorio. Esta auditoría no acredita migración aún no implementada.
- Python /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3. LibreOffice sólo /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/override/soffice; no instalar, no Word. Carga skills code/python/sot/continuity para auditoría, documentos si necesario. No repetir suite verde idéntica; diseñar comprobación independiente focal donde haga falta.
- Verificación visual completa la hace root; puedes inspeccionar cover/separadores cuando render final esté disponible, sin volver a renderizar el mismo archivo. Audita contrato/reportes además de código; estado DONE sólo con identidad observada y límites.

## dev/plan/srk-prototype-20260924/na-review/STATE.md

Status: DONE · 2837 bytes · última modificación 2026-09-24

> Inspeccionar la estructura reutilizable de portada y apéndices del reporte NA/Crawford elegido por el propietario; documentar selectores, dependencias y riesgos para el candidato nuevo.

- Propietario: «el dotx mendoz esta corrupto. usa lo de NA». Prioridad portada; la fuente es dev/lib/CAPR003324_Crawford_SeismicHazard_20260831.docx y su PDF homónimo. Lectura y análisis; no modificar estas fuentes, código, candidato ni producción.
- Misma tarea de prototipo, plan y auditoría antes de promoción. Este análisis nuevo responde al cambio explícito de fuente; no reabre misiones antiguas.
- Fuente PDF 160 páginas; sólo primeras dos ya revisadas en pdf-review/COMPARISON.md. Elegir páginas de apéndices por lectura acotada de texto/estructura, no revisar ciencia. Leer OOXML pertinente y rasterizar páginas seleccionadas si necesario.
- Escribir únicamente dev/plan/srk-prototype-20260924/na-review/. Coordinar root que implementa mientras este agente inspecciona.
- Python /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3; LibreOffice exclusivamente /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/override/soffice. No instalar ni operar Word. Poppler bundled en dependencies/bin/override.
- Leer skills aplicables; emitir hallazgos verificables, no inventar metadata ni interpretar presencia de rectángulo celeste/acento grave como aprobación editorial.

## dev/plan/srk-prototype-20260924/pdf-review/STATE.md

Status: DONE · 2993 bytes · última modificación 2026-09-24

> Comparar independientemente portada y portadilla del PDF Crawford aportado frente al render LibreOffice del DOCX correspondiente.

- Delegación de la revisión de formatos/cover solicitada por propietario, que acaba de agregar el PDF. Leer fuentes; sólo escribir evidencia/informe en dev/plan/srk-prototype-20260924/pdf-review/. No editar documentos, código, template, estado padre ni producción. No operar Word.
- Fuentes: dev/lib/CAPR003324_Crawford_SeismicHazard_20260831.pdf SHA2561531a5eca65729cef42f303395cd8a4aa244b8a1e415ed317f0bbcfd0b7f8a0a (160páginas); DOCX mismo stem SHA2567ec329ffa48eea32f473cd9efcf1b39c054bdc43b7f1e8de4d1c0884e83d7605; render LO existente dev/plan/srk-prototype-20260924/human-reference/CAPR003324_Crawford_SeismicHazard_20260831.pdf con PNG1–2. Root inspecciona visualmente PDF aportado y compara diseño MDZ en paralelo.
- Alcance: páginas1–2. Medir fuentes/tamaños y posiciones relevantes (título, cliente, logo/datos) entre motores; revisar si el rectángulo celeste y dos marcas visibles en renderLO también aparecen en PDF aportado, y corroborar en OOXML sólo si necesario. No declarar corrupción sólo por avisos pypdf de offsets. No revisar contenido científico ni160páginas. Registrar límites: PDF aporta referencia de render, no valida prototipo en Word.
- Python bundled /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3. Poppler bundled en /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/override/. PDF/document skills según lectura. No instalar. Si render DOCX imprescindible, sólo LO /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/override/soffice; existente basta.
- Entregar COMPARISON.md conciso con observaciones medidas, conclusiones acotadas y hashes. Terminar estado DONE al cerrar revisión. Elección de portada Crawford vsMDZ aún pendiente del propietario; no elegir ni proponer cambio ejecutable.

## dev/plan/srk-prototype-20260924/STATE.md

Status: DONE · 7399 bytes · última modificación 2026-09-24

> Preparar un prototipo Python reproducible, plan de promoción a NGR y auditoría independiente antes de promoverlo.

- Propietario: «prepara un prototipo, un plan y audítalo con otro agente antes de promocionarlo a NGR». Esta entrega cumple la fase local de muestra, plan y auditoría; no incluye promoción, instalación, publicación ni Git.
- Fuente elegida expresamente: «el dotx mendoz esta corrupto. usa lo de NA». Crawford DOCX/PDF gobierna portada y separadores; Mendoza queda preservado como baseline rechazado. No importar datos científicos ni contactos del reporte.
- Propietario: «apruebo» y «en el plan, debemos reemplazar la hoja de estilos actual por la que se genere del template de CAN». PLAN.md exige generar reference.docx CAN, mapear objetos NGR, reemplazar referencia actual y revisar consumidores/proyectos. La aprobación del rumbo no acredita observación de Word. El cuerpo de esta muestra conserva la hoja actual sólo como paso transitorio.
- Metadata, contenido y tres apéndices reutilizan el espécimen autorizado. Resolver semántica común de Quarto antes de componer zonas visuales; no presentar tres renders independientes ni asumir bibliografías separadas.
- Propietario exige Word y PDF LibreOffice. Se inspeccionó el PDF de este candidato; Word permanece sin observación. No operar el Word del propietario mientras lo usa. Portada con logo real SRK, sin imagen inventada.
- Propietario confirmó tamaño de Printed correcto; falta únicamente hora y timezone. Pidió prioridad al cover. Printed queda como cambio separado del plan y no fue aplicado aquí.

## dev/plan/srk-template-20260924/object-map/STATE.md

Status: DONE · 4012 bytes · última modificación 2026-09-24

> Auditar los objetos documentales que NGR renderiza a DOCX y cómo se conectan master, bloques y estilos Word, para evaluar una composición separada de carátula/cuerpo/apéndices.

- Misión srk-template-objects-20260924; usuario amplió explícitamente auditoría a headings1–4, captions, notas al pie, referencias y demás objetos realmente usados por NGR, y consulta si separar _master/docx suma.
- Lectura autorizada de NGR y masters/bloques directamente pertinentes en workspaces /Users/averrik/Cloud/github/tools/psha y /Users/averrik/Cloud/github/tools/qrt. No describir inventario por listado: resolver masters a los bloques que incluyen. Distinguir capacidad NGR de uso observado; no inventar identidad de proyecto del usuario.
- Leer skills continuity, code y r/python si corresponde. Es auditoría de código autorizada, no operar consumidor NGR ni cálculos científicos. No modificar producción, instalar, ejecutar ciencia o Git.
- Escrituras sólo bajo dev/plan/srk-template-20260924/object-map/. Entregar REVIEW.md con citas locales verificadas y matriz objeto→sintaxis/producer→estilo Word→limitación. Identificar dónde se separan capítulos/apéndices y riesgos reales al renderizar tres DOCX y unirlos.
- Puede ejecutar una sonda pequeña no científica de Pandoc/Quarto si hace falta verificar mapping, usando versiones observadas. Python para artefactos: /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3. Marker de documentos ya ejecutado por coordinador, no repetir. Si necesitara render, sólo helper empaquetado con /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/override/soffice; nunca LibreOffice desktop. No entregar nuevos artefactos DOCX como final; son evidencia intermedia.
- Fuente template validada por usuario: dev/lib/Report_MDZ_202608.dotx. XML legible ya extraído bajo ../structure/xml para orientarse, pero leer partes pertinentes antes de afirmar. No repetir auditoría de ZIP o ensayo de tres apéndices que ya hace coordinador.

## dev/plan/srk-template-20260924/STATE.md

Status: DONE · 9021 bytes · última modificación 2026-09-24

> Auditar las debilidades del template SRK dev/lib/Report_MDZ_202608.dotx, ensayar tres apéndices y definir una propuesta de composición para carátula/cuerpo/apéndices que cubra los objetos reales de NGR.

- Instrucción nueva del propietario del 2026-09-24: usar el .dotx de dev/lib como base; desarrollar herramientas Python postrender para reparar tablas, hidratar carátula y formatear apéndices; primero analizar el template reportado como corrupto y tratar de agregar dos o tres apéndices.
- Propietario confirmó fidelidad requerida en Word Y PDF con LibreOffice. Amplió auditoría a objetos NGR: headings 1–4, captions de tablas/figuras, notas al pie, referencias y otros objetos encontrados leyendo el master/callers reales. Pregunta si conviene separar _master/docx y render de carátula/cuerpo/apéndices. Esta fase define propuesta; no autoriza fragmentar producción sin contrastar contratos.
- Aclaración del propietario: conservar el template actual del cuerpo (tablas funcionan) y evaluar renders separados para el resto; preocupa comunicación de citas/bibliografía y crossrefs como @sec-APX1. Dice que quizá perder crossrefs sea precio aceptable: evaluar como alternativa, no eliminar todavía enlaces ni citas. Distinguir referencias internas de bibliografía.
- Bibliografía global o por parte consultada mediante pregunta asíncrona; sin respuesta al cerrar esta auditoría. COMPOSITION.md expone ambas y condiciona su recomendación. Es decisión pendiente para implementación, no trabajo abierto de esta auditoría.
- El archivo suministrado queda explícitamente validado como fuente de diseño para esta tarea. Analizar primero sus reglas; no reemplazarlas con defaults estéticos. Tres apéndices de prueba forman parte del ensayo autorizado, no de un informe científico.
- Preservar el .dotx original y el archivo temporal ~$ de Word. Trabajar en copias bajo esta carpeta; no modificar todavía implementación NGR, recursos instalados, proyectos científicos o Git.
- Nuevo estado declarado en el chat. La auditoría docx-srk-audit-20260924 está DONE; no reabrir sus sondas sin un cambio relevante. La nueva fuente y el ensayo de apéndices constituyen un objetivo distinto.
- Skills cargados: continuity, code, python, documents. Para artefactos usar Python /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3. Render con el helper empaquetado y sólo LibreOffice bundled /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/override/soffice, nunca el LibreOffice de escritorio del usuario.

## dev/plan/srk-template-20260924/structure/STATE.md

Status: DONE · 2898 bytes · última modificación 2026-09-24

> Auditar de forma independiente la coherencia OOXML de Report_MDZ_202608.dotx, especialmente estilos, numeración de apéndices, secciones y Quick Parts.

- Encargo del propietario del 2026-09-24: analizar el .dotx entregado como base y entender la rotura al agregar apéndices. El coordinador prepara el ensayo y los renders; evitar duplicarlos.
- Leer únicamente el original y código/documentación necesarios; no modificar template, implementación NGR o selector. Escribir sólo dentro de dev/plan/srk-template-20260924/structure/.
- Buscar defectos demostrables: referencias ausentes/duplicadas, herencias cíclicas, discordancias styles/numbering/glossary, reinicios e overrides, encabezados/pies y restricciones de edición. Diferenciar integridad ZIP/XML, semántica y apariencia. Entregar REVIEW.md con evidencia precisa, sin declarar corrupción por suposiciones.
- Usar el Python bundled /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3. Si fuese necesario renderizar, sólo LibreOffice bundled /Users/averrik/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/override/soffice; el coordinador hace esos renders.
- Cargar continuity, code, python. Original autorizado: /Users/averrik/Cloud/github/libraries/NGR/dev/lib/Report_MDZ_202608.dotx. No tratar el lock ~$ como fuente.

## dev/plan/srs-two-projects-20260921/STATE.md

Status: DONE · 2401 bytes · última modificación 2026-09-21

> Entregar únicamente los comandos para renderizar los decks SRS de AR-S2L1W y AR-S2P30; no ejecutar renders.

- La instrucción más reciente del propietario en esta tarea es «no renderices nada. solo quiero los comandos que debo ejecutar». Revoca la ejecución solicitada mediante aom-v0. Ningún render había sido iniciado.
- Nueva misión directa de esta tarea existente, tras publish-report-20260921 DONE. Fuente de la orden: /Users/averrik/Cloud/github/agents/dev/SoT/three-projects-update-20260921/STATE.md, Rulings, leído el 21/09. Cita del propietario: «si esta atarea el coresponde al agente nGR , neceisto renderizar AR-S2L1W AR-S2P30 todos los decks de SRS y no se como se hace».
- aom-v0 reservó los renders para esta tarea y no los ejecutará; conserva el frente CLI Hazard. No hay subagentes ni delegación propia.
- Alcance: 12 aliases por proyecto (hub srs y 11 decks): srs,at,vt,dt,ai,cav,cav5,psa,psv,sd,its,ipsa. Sin deploy, commit/push ni cambios/recálculos científicos. Preservar cambios ajenos.
- Ruta aprobada: ngr 46828e0ff9f8, operación pública ngr render --manifest manifest.json --only srs,at,vt,dt,ai,cav,cav5,psa,psv,sd,its,ipsa desde cada raíz. CLI ayuda actual admite la ruta HTML del manifest; no imponer a srs.es el basename contra el contrato instalado.

## dev/plan/ssel-cli-contracts/STATE.md

Status: DONE · 2429 bytes · última modificación 2026-09-20

> Precisar destinos efectivos, reemplazos y efectos de las operaciones SSEL en su documentación, por «continua» del propietario y reparto confirmado con AOM.

- Tarea directa; nueva cadena dev/plan/ssel-cli-contracts/STATE.md. Las cadenas anteriores permanecen DONE.
- AOM confirmó por mensaje que esta tarea toma sólo la corrección documental SSEL; conserva dbAudit, skills, instalación y documentos AOM. No hay solapamiento.
- Mantener código, modelos, registro de operaciones y aceptación instalada de --root. No entrenar, repetir pruebas de dominio, renderizar, instalar ni publicar.
- Leer los destinos en las funciones reales y distinguir serialización --output de efectos internos; fileOrientedOperations no enumera todos los escritores.
- Rutas: continuity 022a663de9be para estado; code db006ef77a7e y r f6fc91995993 para revisión de fuente. No operar SSEL como consumidor.

## dev/plan/two-projects-status-20260921/STATE.md

Status: DONE · 1355 bytes · última modificación 2026-09-21

> Informar estado actual de renders/publicación de AR-M2V4D y AR-S2L1W con lecturas locales y del proveedor.

- Nueva tarea directa de estado tras publicación M2V4D DONE. Sólo lectura; no renders, cálculos, deploys ni Git.
- Usar manifests como inventario y distinguir presencia, generación y publicación. No recomendar repetir por fecha solamente.
- Rutas continuity y ngr instaladas leídas.

## dev/plan/zot-aom-routing-20260921/STATE.md

Status: DONE · 2533 bytes · última modificación 2026-09-21

> Revisar AOM/dev/ESTADO-ZOT-PARA-AOM-20260921.md y acordar con el agente AOM quién toma sus pendientes, por petición expresa del propietario.

- Nueva tarea directa tras s2j2j-close-20260921 DONE; estado declarado dev/plan/zot-aom-routing-20260921/STATE.md.
- Alcance: revisión y cierre documental de los hechos contrastados; no implantar una política nueva de workflows ni reinstalar ZOT.
- No abrir un subagente ni duplicar la tarea AOM existente 01a0a5b0-d006-7ee3-b2d5-e2748ef82519.

## dev/plan/zot-cli-contracts/STATE.md

Status: DONE · 2759 bytes · última modificación 2026-09-20

> Completar concordancia documental de ZOT: cobertura del registro, base de rutas locales, destinos y efectos, por «avanza» del propietario y reparto confirmado con AOM.

- Tarea directa; nueva cadena dev/plan/zot-cli-contracts/STATE.md. Cierres anteriores permanecen DONE.
- AOM reservó ZOT cli/README.md y lib/vignettes/cli.Rmd para esta tarea. Conserva skills GMSP/SSEL, Hazard e informes AOM. No modificar código, registros, skills ni instaladores ZOT.
- No operar Zotero, red, bases reales, credenciales, instalaciones ni renders. Sólo revisión de fuente y comprobación documental focalizada sin dominio.
- El CLI no ofrece --root; documentar CWD y rutas por operación sin crear una raíz de proyecto ficticia.
- Rutas cargadas: continuity 022a663de9be; code db006ef77a7e y r f6fc91995993 para lectura de fuente; python 693fbb19f670 para recibos locales. No activar consumidor zot.

## dev/SoT/ngr-repair-build-20260924/preliminaries/STATE.md

Status: DONE · 5861 bytes · última modificación 2026-09-24

> Implementar candidato Python de portadilla CAN y sección preliminar para DOCX, conservando la carátula aprobada y los objetos del cuerpo.

- Propietario ordenó implementar el plan y confirmó «Sí: carátula, portadilla, índice y firmas». NGR compone carátula/portadilla; Quarto genera TOC y reports conserva firmas.
- Leer plan dev/plan/ngr-repair-20260924/PLAN.md C4, código y tests completos, fuente CAN DOCX y PDF visualmente. No usar pdf2md. Fuente CAN exacta admitida está en dev/lib/CAPR003324_Crawford_SeismicHazard_20260831.docx y .pdf.
- Escribir sólo bajo dev/SoT/ngr-repair-build-20260924/preliminaries/: baseline, candidato y este estado. El coordinador integrará. No cambiar selectores ni producción.
- Archivos candidatos permitidos: lib/inst/docx/compose_docx.py, srk-template.zip, lib/tests/test_docx.py y fixtures/docx/spec.json. build_reference.py/reference.docx sólo si una necesidad observada de esta portadilla lo exige. No editar R/Lua/scaffold/README: coordinador los posee.
- R enviará bloque spec titlePage con clientAddress y companyAddress (listas de líneas desde params.client.address y params.consultant.address), clientWeb y companyWeb (strings desde params.*.web), fileName (nombre DOCX final). Todos opcionales de metadata quedan vacíos si params no los declara; title/fecha/project/organizaciones se reutilizan de cover/headerFooter. Sin campos públicos obligatorios nuevos ni copiar Crawford/legal/copyright científico.
- Mantener fecha dd/mm/yyyy del render, no month/year derivado. Rótulos CAN de cover ya localizados; las etiquetas nuevas equivalentes de portadilla deben seguir lang en/es.
- Numeración: portada sin número, portadilla romana desde ii, TOC preliminar romano, cuerpo desde 1. Investigar cómo separar firmas/cuerpo con los objetos emitidos; comunicar al coordinador antes de inventar un nuevo contrato para esa frontera.
- Congelar baseline; candidato incluye prueba que baseline no cumple (portadilla ausente). Correr tests Python normales y -O del candidato. Validar preservación de cuerpo/objetos sin aflojar errores. Render visual focal de páginas preliminares por LibreOffice en copia y comparar PDF humano; no operar Word.
- No instalar, hidratar, hacer Git ni renderizar proyectos. Resultado: candidato, diff, pruebas, vistas y límites.

## dev/SoT/ngr-repair-build-20260924/reports/STATE.md

Status: DONE · 3866 bytes · última modificación 2026-09-24

> Implementar en reports/sha el contrato de apéndices DOCX CAN explícitos aprobado para reparar AR-SABP0.

- El propietario ordenó al coordinador: «IMPLEMENTA los cambios. instruye al otro agente aqui cuales son los planes» tras pedir reparar el DOCX real y explicar la responsabilidad de masters frente a NGR.
- Leer dev/plan/ngr-repair-20260924/PLAN.md §5, reports/README.md, instrucciones y fuentes antes de editar. NGR y su compositor son del coordinador.
- Fuentes de reports/sha sólo lectura para este agente. Producir candidato con rutas relativas sha/ bajo dev/SoT/ngr-repair-build-20260924/reports/candidate/ y baseline bajo su raíz hermana baseline/. El coordinador integrará el candidato aceptado. Estado propio dev/SoT/ngr-repair-build-20260924/reports/STATE.md. No cambiar selectores.
- Dividir los cinco apéndices actuales de ambos idiomas en archivos explícitos de un H1 numerado con identificador, conservar ids y contenido/inclusiones actuales, declararlos en appendices de cada master. index.qmd sigue primero. No modificar prosa científica ni cálculos.
- Propietario acaba de confirmar «Sí: carátula, portadilla, índice y firmas». Incluir en candidato la rama DOCX de portada para retirar bloques antiguos duplicados conservando la página de firmas; HTML sin cambio. NGR crea carátula/portadilla/índice. No hidratar proyectos, instalar ni mutar Git.
- Aplicar continuity, code, sot y r si corresponde. Congelar baseline antes de la primera edición, comparar contra él y comprobar estructura/ids/referencias sin renderizar proyectos.

## dev/SoT/ngr-repair-build-20260924/review/STATE.md

Status: DONE · 2807 bytes · última modificación 2026-09-24

> Auditar el código integrado de preliminares CAN y el contrato de apéndices antes de promover la reparación.

- Propietario pidió implementación y auditoría con otro agente antes de promocionar; el coordinador implementa y renderiza. Esta misión revisa y sólo escribe bajo dev/SoT/ngr-repair-build-20260924/review/.
- Contrato aprobado: carátula, portadilla, índice y firmas; fuente CAN humana; metadatos de params.yml; fecha automática; sin datos Crawford inventados; apéndices explícitos y referencias compartidas. Lang diferido por el propietario.
- Se revisaron NGR contra HEAD 24c99a5750f667f521a59fb10b1ddfa14f1eb565 y reports candidato-2. No se modificó fuente, instaló software, renderizó proyectos ni operó Word desde esta auditoría.

## dev/SoT/ngr-repair-build-20260924/visual-en/STATE.md

Status: DONE · 3717 bytes · última modificación 2026-09-24

> Auditar visualmente todas las páginas del PDF inglés de AR-SABP0 corregido para la revisión de formato CAN solicitada.

- Propietario pidió reparar preliminares/apéndices y auditar con otro agente; priorizó estructura antes que lang. Revisar sólo salida real, no muestras demo.
- PDF: dev/SoT/ngr-repair-build-20260924/sabp0-en-visual-2/docx.en.pdf. DOCX origen: /Users/averrik/Cloud/github/projects/AR-SABP0/docx/docx.en.docx SHA 8162d5231cc45d98bcbb6774ab131fa72ab95acd92639c4498fca1237c056b09. Verificar existencia/identidad antes de describir.
- Fuente visual CAN: dev/lib/CAPR003324_Crawford_SeismicHazard_20260831.pdf. Páginas 1–2 preliminares; cinco separadores de apéndices al final de reporte. Primeros seis CAN ya vistos por coordinador; hacer comparación focal propia si necesaria.
- Usar rasterización PDF/PNG y view_image; no pdf2md ni extracción textual como validación visual. Puede usar texto sólo como locator. Inspeccionar todas las páginas, con hojas de contacto legibles de hasta cuatro páginas y ampliar defectos. Escribir sólo bajo esta raíz visual-en/; no tocar documentos, código ni selector.
- Contrato: cover/portadilla CAN, firmas página propia, cuerpo desde 1, cinco apéndices separados A–E, notación A.1–A.9. Buscar recortes, superposiciones, tablas/ecuaciones ilegibles, páginas vacías inesperadas, continuidad y encabezados/pies. No revisar ciencia ni cambiar prosa.
- Limitación conocida: campo TOC nativo aún sin actualización en Word; conversión headless de LibreOffice no lo calculó. Página de índice vacía conocida, no reabrirla como hallazgo nuevo. Su paginación final no está certificada. Word sólo lo opera propietario.
- No instalar ni renderizar proyectos. Esta misión rasteriza el PDF ya generado por LibreOffice, no reproduce el render NGR.

---
Estados DONE extraídos: 77
