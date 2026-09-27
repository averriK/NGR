## Objective
Aplicar en NGR la regla de mantenimiento de dev/ confirmada por el propietario (sesión gmsp, recibida vía gmsp-cb el 2026-09-27) con las decisiones que dio en esta sesión.

## Rulings
- Regla de mantenimiento (cinco puntos): en dev/SoT y dev/plan sólo cadenas vivas con STATE.md ACTIVE o BLOCKED; una carpeta DONE se borra en el commit que la cierra tras pasar a dev/ARCHITECTURE.md las reglas supervivientes y a la cadena sucesora las esperas y defectos abiertos; en dev/ sólo ACTIVE.md, ARCHITECTURE.md, STATE.md vivos, dev/legacy y lo que un estado vivo cite; todo dev/ rastreado y sin bytes de evidencia; el producto no enlaza dev/.
- Propietario (esta sesión, 2026-09-27) aprobó punto por punto: 1 borrar las 16 carpetas de dev/SoT y las 58 de dev/plan salvo esta cadena; 2 cerrar cli-fusion como DONE y quitarlo del árbol junto con cli-repair y quarto-yaml; 3 borrar dev/docs, dev/lib y los sueltos, pero «deja dev/bugs por un rato para que los auditemos a ver si fueron corregidos»; 4 extraer los Rulings de los estados DONE para que elija qué pasa a ARCHITECTURE.md; 5 corregir las referencias a dev/ del producto; 6 aplicar la regla legacy a legacy/ de raíz; 7 la .dotx «lo usamos para diseñar un style que consume la librería lib y el cli. si ya fue usado, lo dejas en legacy»: fue usada (estados srk-template, srk-prototype/implementation, srk-document-demo), va a dev/legacy.
- Propietario: «no hay planes activos en NGR»; el ACTIVE de cli-fusion no cuenta. La resolución de los handoffs de dev/bugs no se conoce; no afirmar abiertos ni cerrados.
- Orden previa «borra lo de crawford» mantenida por el propietario tras el aviso de que lib/inst/docx/README.md documenta ese DOCX como única fuente admitida de reference.docx; los generadores verifican su SHA-256 7ec329ffa48eea32f473cd9efcf1b39c054bdc43b7f1e8de4d1c0884e83d7605. Sin él no se regenera desde el repositorio.
- El rm de rutas sin rastrear fue denegado al agente por el clasificador de permisos de Claude Code; no se reintenta. Lo ejecuta el propietario con DELETE.txt. Push no autorizado.
- dev/bugs se conserva citado por esta cadena hasta la auditoría del propietario.

## Evidence and no-repeat
- Inventario de dev/ del 2026-09-27 enviado a gmsp-cb: 481M, 29 rastreados, 5022 sin rastrear, 27 ignorados, 79 STATE.md (77 DONE, 1 ACTIVE, más esta cadena).
- RULINGS-REVIEW.md en esta carpeta: Objective y Rulings de los 77 estados DONE, 106171 bytes; verificado completo por comm contra la lista DONE. Pendiente de que el propietario marque lo que sobrevive.
- DELETE.txt en esta carpeta: 77 rutas sin rastrear aprobadas (16 dev/SoT, 58 dev/plan, dev/docs, dev/lib, NOTICE-INSTALLER-FAMILY-STANDARD-20260918.md). Excluye ACTIVE.md, ARCHITECTURE.md, dev/bugs, dev/legacy y esta cadena.
- Fuera de alcance, observados y no tocados: bugs/ en la raíz del repositorio con 3 archivos sin rastrear del 2026-09-24 (20260924-buildPlot-library-docx.md, 20260924-docx-metadata-from-params.md, 20260924-docx-srk-render.md); lib/inst/docx/__pycache__/ sin rastrear.
- Modificaciones locales sin commit de cli-fusion/STATE.md, cli-repair/PLAN.md y cli-repair/STATE.md: sus Rulings de árbol de trabajo están en RULINGS-REVIEW.md; el resto de esas deltas no se conserva, conforme a la regla 2.
- NEXT-CLOSED {"id":"dev-cleanup-20260927-delete","evidence":"Superado por la orden de esperar a G1; el rm había sido denegado y nada se borró."}
- NEXT-CLOSED {"id":"dev-cleanup-20260927-await-g1","evidence":"Instrucciones de G1 recibidas vía gmsp-cb el 2026-09-27 y aprobadas punto por punto por el propietario en esta sesión."}

## Effects
- Producto sin referencias a dev/: README.md, cli/scaffold/styles/theme.scss, install/README.md y lib/inst/docx/README.md editados; grep de dev/ en README.md, cli, install, lib y skills vacío.
- dev/legacy creado: buildPlot-hist.zip (legacy/buildPlot.Hist2D.R y Hist3D.R), report-mdz-202608-dotx.zip (dev/lib/Report_MDZ_202608.dotx) y README.md con SHA-256; unzip -t sin errores.
- dev/SoT/ACTIVE.md apunta a esta cadena. Sin commit todavía; sin borrados de rutas sin rastrear.

## Delegations
none

## Blocker
none

## Next
NEXT-ID {"action":"Preparar el índice con alcance exacto (git rm de legacy/, sueltos y quarto-yaml; git rm --cached de cli-fusion y cli-repair; git add de producto, dev/legacy, ACTIVE.md y esta cadena), revisar git diff --cached y crear el commit local sin push; después el propietario ejecuta DELETE.txt y marca RULINGS-REVIEW.md.","id":"dev-cleanup-20260927-commit-1"}

## Status
ACTIVE
