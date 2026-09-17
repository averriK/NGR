# NGR: validación local del paquete y la CLI

Actualizado el 2026-09-17. El estado vigente está en [CLOSURE.md](CLOSURE.md):
tar final SHA-256 `386a8e9ecf41f634dbc866138e356ecd74bb0cb8927a4e26ea4a1565a3340531`,
documentación/check aprobados, instalación común macOS/Windows, UHS/MCE migrados
y 14 de 37 masters comparados con QRT. Faltan entradas científicas para los 23
restantes. Instalación personal y publicación siguen aplazadas.

Las secciones siguientes son evidencia histórica de cada candidato, no el
estado actual. Sus menciones a MCE ausente, ortografía pendiente, `dev/lib/`,
adaptadores antiguos o APIs aún no extraídas describen la etapa fechada; fueron
superadas según CLOSURE.md. Los resultados se atribuyen sólo a su artefacto.

## Antecedente: primer candidato del 2026-09-16

Las extracciones posteriores de procedencia y recursos añaden APIs y tarballs
distintos, descritos al final. El check CRAN siguiente corresponde al tarball
`caec0214…`, no a los sucesores `bcd47dc0…` ni `a3f2a8c9…`.

- CLI propia corregida e instalada en `dev/SoT/cli-fusion/candidate-install/bin/ngr`.
  Conserva `pull`, `status`, `doctor`, `render`, `deploy` y `--version`.
- NGR 0.3.11 construido desde `lib/`, comprobado e instalado mediante los scripts
  reales `dev/lib/build.R`, `cran-check.R` e `install.R`.
- Check del tarball: **0 errores, 0 warnings, 1 NOTE: New submission**. No se
  efectuó envío CRAN ni certificación en otras plataformas.
- Quarto cargó el paquete de la biblioteca aislada durante un render real.
  La instalación CLI también funcionó desde un consumidor fuera del checkout.
- Instalaciones personales, QRT/PSHA originales y mantenimiento ajeno preservados.
  No hubo commit, push, publicación ni operación Netlify remota.

## Interfaz: referencia, corrección y aceptación

La referencia de los dos módulos está en
`dev/SoT/cli-fusion/interface-20260916/reference/lib/`; la identidad anterior del
árbol está en `source-baseline.json`. El candidato reutilizó mediante enlaces los
recursos inalterados: no se duplicó todo el runtime para probar dos módulos.

| Defecto observado | Cambio integrado | Comprobación |
|---|---|---|
| `pull --help` decía resources.py y mezclaba opciones | Cada comando muestra su nombre público y únicamente sus opciones | Ayuda de pull/status/doctor; rechazo de combinaciones inválidas |
| render manifest ignoraba argumentos adicionales | Rechazo antes de iniciar productores, también con dry-run | Opción desconocida falla en ambas formas; el render directo conserva passthrough |
| deploy init interpretaba --help como argumentos incompletos | Ayuda de init/domain/unbind con salida 0 | -h/--help funcionan sin Netlify, jq ni proyecto; ningún efecto |

`cli/tests/test_cli.py`: baseline falla en 11 subcasos, candidato pasa sus cuatro
pruebas. Después de integrar e instalar, las cuatro vuelven a pasar. Las doce
pruebas existentes de recursos y publicación simulada pasan sobre el candidato.
Logs: `interface-20260916/{baseline,candidate,stable,installed,install}.log`.

Revisión estructural del diff: opciones declaradas en su comando mediante
argparse; validación de argumentos en la frontera del manifest; ayuda antes de
dependencias y efectos. Sin nuevos verbos, capas de despacho o reglas científicas.
Los 402 archivos instalados coinciden con el manifest de distribución y su recibo.
`candidate-SHA256.json` identifica el árbol actual; no equivale a prueba funcional.

## Paquete real y mantenimiento

Se verificó el trabajo de la tarea coordinada antes de repetir operaciones:
tarball de referencia `tools/qrt/dev/SoT/family-repair-20260916/NGR/release/`,
SHA-256 `740c74163c6627946d8108e9d8f3530a96dd0a3d32033b9034caae7b4b87da3b`.
Su recibo y check confirmaron dos NOTEs. Se corrigieron dos líneas en `lib/`:

1. `.Rbuildignore` excluía `build/`, donde R genera `vignette.rds`. El tarball
   conservaba seis viñetas HTML pero perdía su índice preconstruido.
2. `DESCRIPTION` repetía `Author` sin el ORCID de `Authors@R`. Se retiró el campo
   redundante; R ahora lo genera conservando autor, roles y ORCID.

La referencia exacta de ambos archivos está en `package-20260916/reference/`.
No se modificaron funciones R, exports, man ni viñetas. El tarball corregido es:

`dev/SoT/cli-fusion/package-20260916/release/NGR_0.3.11.tar.gz`

SHA-256: `caec0214ea064aec9fcfd5a6a060599bdc702a1af1a13a020d860601db05cac9`.
Su `.rds` identifica fuente, commit, árbol sucio, R/plataforma, opciones y resultado.
El check ejecutó tests, ejemplos y reconstrucción de viñetas; desaparecieron ambos
diagnósticos corregibles. El índice instalado contiene seis entradas.

Instalación: `dev/SoT/cli-fusion/package-20260916/library/NGR`.
`install.log` acredita la instalación de ese artefacto y conservación de 103
dependencias. La biblioteca personal no fue el destino.

El diseño de `dev/lib/` es apropiado para mantenimiento del productor: sus
entradas operan desde `lib/`, reciben tarball/destinos explícitos y no son runtime
de la CLI. `setup.R` prepara herramientas y dependencias de desarrollo; no instala
la CLI ni R mismo. `document.R` regenera roxygen y revisa ortografía; no se ejecutó
porque estas dos correcciones no cambian documentación generada. Build, check e
install son operaciones separadas. No se instalaron herramientas nuevas.

El núcleo `package.R` conserva SHA-256
`65dc92e5327db356f611c0e27ef78ce1b8a64c0e282ad5d39da305f6ed66fcf4`.
No se modificó `dev/lib/` ni `dev/ARCHITECTURE.md`, propiedad de la tarea coordinada.

Fuentes primarias consultadas el 2026-09-16:
[DESCRIPTION](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#The-DESCRIPTION-file),
[build y exclusiones](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Building-package-tarballs).
También se observó la implementación instalada de R 4.6.1 que crea el índice antes
de aplicar exclusiones. La NOTE restante corresponde a incoming, no a un envío.

## Integración instalada y límites

`package-20260916/cli-integration.log`: cuatro pruebas adicionales aprobadas:
cinco renders reales — HTML, libro HTML, RevealJS, DOCX simple y compuesto —,
mapas/estáticos, ciclo instalación/actualización/desinstalación y uso desde un
directorio ajeno al checkout. Los temporales se eliminaron al terminar.

El test de render seleccionó `R_LIBS` y `NGR_TEST_LIBRARY` con la biblioteca
aislada. El chunk ejecutado por Quarto comprobó `find.package("NGR")` y el HTML
resultante incluyó esa misma ruta. No se usó source() del checkout para sustituir
el paquete. Estas pruebas se justifican por el cambio de instalación R; no se
repitió el antiguo render de referencia QRT con el mismo entorno.

Los helpers CLI leídos usan NGR, yaml y jsonlite. Quarto con código R necesita su
entorno knitr/rmarkdown. La CLI sigue sin instalar paquetes R. El scaffold SHA
añade requisitos propios: su setup declara, entre otros, dsra, newmark y ggplot2,
y sus masters usan here. Esa lista pertenece al scaffold; DESCRIPTION de NGR no
es un instalador de todas las dependencias científicas de todos los temas.

Netlify se comprobó mediante proveedor simulado: no acredita creación, TLS/DNS
o publicación reales. Los renders de aceptación anteriores y actuales son
fixtures, todavía no un informe científico AR-M2V4D.

## GitHub Pages y siguiente fase

Reobservado Pages run `35020941520`: build y deploy success para
`3b1493d609f90970752851c6fea582189538dac6`. El workflow construye Jekyll y luego
pkgdown desde `lib/`. main remoto continúa en ese commit; dev en
`fbcb9e5753e0ef565202955d4a9e3b3395b34339`. El candidato local no está publicado.

Enlaces públicos:
[portal](https://averrik.github.io/NGR/),
[R](https://averrik.github.io/NGR/lib/),
[referencia R](https://averrik.github.io/NGR/lib/reference/index.html),
[CLI](https://averrik.github.io/NGR/cli/).
La página CLI publicada sigue siendo un placeholder; el manual implementado
permanece local. No se publicó contenido de repositorios privados.

El propietario seleccionó **AR-M2V4D**, artefacto **sha**, master
`_master/sha.qmd`. Su manifest y master ya se leyeron. La siguiente fase sigue
la cadena efectiva de bloques y builders, conserva entradas/semillas y prepara
la comparación en SoT antes de extraer una familia hacia la API instalada NGR.
Los destinos Netlify declarados en el proyecto no autorizan efectos remotos.

El propietario precisó que sha es una prueba inicial limitada: la aceptación
debe cubrir todos los masters y sus cadenas reales, especialmente _chapters,
libros y DOCX. Esa cobertura permanece pendiente.

## Primer piloto real: resultado observado

Se preparó `dev/SoT/cli-fusion/AR-M2V4D/project` con 848 archivos de entrada
(20,545,109 bytes). `inputs.tar.gz` conserva sus bytes; `inputs-SHA256.json`
identifica cada archivo. Se excluyeron cálculos crudos y otras salidas. El master,
parámetros y datos proceden del proyecto seleccionado; no se completaron valores.

`ngr render --manifest qrt.manifest.json --only sha --dry-run` resolvió un job.
El render real falló con `object 'siteID' not found`. La lectura y reproducción
acotada identificaron una tabla ausente, no una columna perdida en UHSTable:
`oq/data/MCETable.Rds` no existe y global.R devuelve NULL; el master llama sin
condición al bloque de comparación y `scripts/fig/UHS.compare.R` indexa ese NULL.
La comparación exige MCE y MDE explícitamente. Evidencia: `render.log` y
`comparison-diagnostic.log`. No se aceptó el deck ni se omitió esa sección.

Mientras se consulta la entrada faltante o su alcance editorial, se caracterizó
el builder probabilístico UHS con la selección efectiva de UHS.TR.qmd: CFD,
Vs30=760, media y TR de 100 a 10.000 años. Produjo ocho series de 32 puntos,
con orden/estilos registrados en `uhs-characterization.log` y el objeto de
presentación en `uhs-reference.rds`. Se comprobó que UHSTable permaneció idéntica.
Esto prepara un oráculo para la extracción; todavía no se cambió el builder.

## Helper de procedencia trasladado a la API

La instrucción transversal del propietario se verificó en gmsp01, mensajes
`01a0ab14-53dd-7f13-8e4c-abb7036565ab` y
`01a0ab23-98e6-7343-a6fe-eec283fe4a43`: la librería proporciona helpers y la CLI
los invoca. Se extrajo `NGR::quartoRenderStamp(manifest, root)`. Recibe el manifest
ya leído, compara los archivos con sus MD5 y devuelve Pub/Rev/DRAFT conservando
el mensaje temporal. El adaptador CLI sólo lee argumentos/JSON e imprime ese
resultado (seis líneas). Los cuatro adaptadores YAML ya usaban la API pública.

Referencia exacta y candidato: `dev/SoT/cli-fusion/provenance-api-20260916/`,
`reference.json` y `candidate.json`. El helper original coincide con QRT instalado
(SHA-256 `67534736d44734e46eea6eb1ad70e01d0d6e10de67c31a430cc15a651c855841`).
Tarball nuevo: `release/NGR_0.3.11.tar.gz`, SHA-256
`bcd47dc0ff1d2ff1d4d240c0a0ba3c7262760de4d22922d038b744164d322f30`.
Instalado en la biblioteca aislada `provenance-api-20260916/library/NGR`.
`jsonlite` permanece en el adaptador; no se añadió dependencia al paquete.

Comprobación enfocada, no certificación de release:

- `baseline.log`: la instalación anterior falla al invocar la API nueva mediante
  `ngr render`, porque el export aún no existe.
- `candidate.log`: dos tests PASS. Un render ejecuta las tres pruebas R de la
  API; seis renders comparan firmas completas, parciales y desconocidas entre
  NGR candidato y `/usr/local/bin/qrt` con la biblioteca baseline. Cuatro intentos
  inválidos comprueban rechazos y conservación de la salida anterior.
- `incompatible.log`: instalar la CLI con el paquete antiguo falla antes de
  crear el destino. Se exige el export nuevo, sin instalar R automáticamente.
- Los 402 archivos del runtime común `candidate-install` coinciden con fuente y
  recibo después de integrar. Se retiró la instalación CLI temporal del ensayo
  mediante su propio instalador; se conservan biblioteca, tarball y evidencia.

`document.R` generó el export y el manual nuevos, pero terminó con error por
términos ortográficos pendientes en documentación existente (`document.log`).
El manual nuevo no aparece en esos hallazgos. No se declara aprobado ese gate ni
se trasladan al nuevo tarball los resultados de CRAN del anterior.

Revisión estructural: una API dueña de la agregación/validación y un adaptador de
entrada/salida; sin segundo algoritmo, nuevas opciones ni cambio de motores
Python/Bash. Los builders científicos siguen pendientes. Esta extracción no
acepta el deck SHA, todos los masters ni la sustitución completa de QRT/PSHA.

## Recursos proporcionados por la biblioteca instalada

La instrucción «observa cómo está hecho dbAudit… no postergues» se ejecutó
leyendo su driver `cli/DBAudit`, `lib/R/cli.R`, `domainRunners.R` y tests.
Se adoptó la separación driver → paquete instalado → operaciones públicas;
no su bootstrap de instalación. dbAudit no fue modificado.

NGR exporta ahora `pullResources`, `compareResources` y `checkResources`.
`lib/R/resources.R` posee composición, validación de claims, copia/recuperación,
comparación y checks declarados. `lib/R/cliResources.R` posee argumentos y salida
de terminal. `cli/lib/resources.R` carga la biblioteca instalada y ejecuta su
entrada; doctor conserva el guard común de exports. El adaptador conserva el
PATH recibido por Bash porque el arranque R observado lo modificaba y perdía
comandos declarados por nombre. La API R directa conserva el entorno de su caller.

La referencia exacta de siete archivos está en
`dev/SoT/cli-fusion/resources-api-20260916/reference/`; `reference.json`
identifica sus bytes. La condición arquitectónica falla con el paquete anterior
(`baseline.log`: tres exports ausentes). El Python preservado permanece callable
como oráculo; se retiró `cli/lib/resources.py` de la implementación activa.

Identidad aceptada:

- Tarball: `resources-api-20260916/release-3/NGR_0.3.11.tar.gz`, SHA-256
  `a3f2a8c9884923cd2649dfc5a3790b5ee29c8d1901d20a6c727f9ea1ba132899`.
- Biblioteca instalada: `resources-api-20260916/library-3/NGR`.
- CLI integrada: `dev/SoT/cli-fusion/candidate-install/bin/ngr`.
  Los 402 archivos coinciden con fuente, recibo y runtime aceptado.
- `candidate.json` identifica los catorce archivos del cambio, paquete y
  recibo CLI; `environment.json` fija R y rutas/versiones de dependencias.
  digest 0.6.39, jsonlite 2.0.0 y stringi 1.8.9 están declaradas en Imports;
  ya estaban instaladas. El mantenimiento conservó las 103 dependencias visibles.

Comprobación focalizada, no certificación de release:

| Oráculo | Resultado y alcance |
| --- | --- |
| `candidate-4.log` | 15 pruebas PASS: siete casos de recursos, API instalada independiente, paridad pull/status, paridad doctor, cuatro casos de interfaz y ejecución instalada fuera del checkout |
| API instalada | Ejecuta 25 aserciones R: metadatos/JSON, hashes, rollback de actualización e incorporación, argv con espacios/metacaracteres, cwd restaurado y casefold Unicode |
| Referencia Python vs candidato | Igualdad de estados de salida/stdout, JSON semántico y hashes de archivos; semillas, drift, actualización parcial, recursos retirados y rechazo de artifacts mal formado; doctor aprobado/fallido sin alterar proyecto |
| `incompatible.log` | El instalador rechaza el paquete anterior por exports ausentes antes de crear el destino; no instala R automáticamente |
| Instalación integrada | `integrated-install.log` más comparación de todos los hashes contra el candidato aceptado; no repetición de renders ajenos al cambio |

Intentos rechazados conservados para no repetirlos: Sys.readlink devolvía NA
interpretado erróneamente como enlace; un objeto artifacts se aceptaba como
lista de semillas; el arranque R perdía PATH de la CLI. Los logs de fallo y
referencias acotadas permanecen en el mismo SoT. La primera comparación también
tuvo un error del propio test por sombrear pathlib.Path; no se contó como PASS.

Revisión estructural del cambio: tres operaciones completas y helpers internos
para invariantes/fallos; sin planes públicos aplicables después de quedar
obsoletos, sin reglas duplicadas R/Python, sin nueva base de datos ni selectores
científicos. El parser queda en el paquete siguiendo el patrón leído en dbAudit;
el driver sólo adapta el proceso. El guard de compatibilidad sigue teniendo un
único propietario, compartido por instalación y doctor.

Se retiró la instalación CLI temporal mediante su instalador y se eliminaron
dos bibliotecas aisladas reemplazadas; se conserva la biblioteca aceptada y los
tarballs identificados. No se tocaron instalaciones personales ni QRT/PSHA.
`document.R` generó exports/Rd pero falló su revisión ortográfica existente
(`document.log`); no se declara aprobado ese gate ni se atribuye a este tarball
el check CRAN anterior. Render/DOCX, publicación, builders y todos los masters
siguen pendientes en el alcance documentado. QRT/PSHA permanecen instalados sin
mantenimiento; su desinstalación futura corresponde al propietario.

## Render individual proporcionado por NGR

Se sustituyó el núcleo de render individual de `cli/lib/render.sh` por un
driver que llama a `NGR::quartoRender()`. La API posee la copia temporal,
composición YAML, procedencia, Quarto, reparación DOCX y entrega. Reutiliza las
APIs existentes; no llama `ngr`, `qrt`, `psha` ni fuentes del checkout.
`fix_docx.py` está sólo en `lib/inst/docx/`, resuelto con `system.file()`.
Su SHA-256 permanece `80a84b59fbb46553877fc6296e4e7dc46534510d2ad7e567e71ecede88262b87`.
Se retiraron de la CLI cinco adaptadores YAML/procedencia y la copia de Python.

Referencia: `dev/SoT/cli-fusion/render-api-20260916/reference/` conserva doce
archivos exactos; `reference.json` identifica sus bytes. El paquete anterior
falla la condición arquitectónica porque no exporta quartoRender (`baseline.log`).
Los 400 archivos de QRT instalado coinciden con su referencia preservada antes
y después del trabajo. QRT/PSHA y la biblioteca personal no se reinstalaron.

Identidad integrada:

- Tarball: `render-api-20260916/release-4/NGR_0.3.11.tar.gz`.
- SHA-256: `e6568688a81f140734c8ac15f84647d64f2ca734944ef44338c381579dabae7d`.
- Biblioteca: `render-api-20260916/library-4/NGR` (seleccionada mediante R_LIBS en las pruebas).
- CLI común: `candidate-install/bin/ngr`, 397 archivos verificados contra
  fuente y recibo (`integrated-identity.log`).
- `candidate.json` fija archivos activos/retirados, tarball, biblioteca y recibo;
  `environment.json` fija R 4.6.1, Quarto 1.9.35, Pandoc 3.8.3, Python 3.12.11,
  ejecutables y dependencias. No se añadieron dependencias R en este tramo.

Comprobaciones focalizadas:

| Evidencia en render-api-20260916 | Resultado observado |
| --- | --- |
| `parity-1.log` | PASS: cinco casos por ngr instalado y QRT público; HTML individual, libro, RevealJS, DOCX individual y libro DOCX. Igualdad de texto HTML y document.xml/styles.xml/numbering.xml, con fuentes intactas |
| `provenance.log` | PASS: firmas completas, parciales y desconocidas iguales; cuatro rechazos conservan la salida anterior |
| `api-4.log` | PASS: API instalada sin CLI; enlaces, fechas, modos (incluido 0666), archivos ocultos, carpetas vacías/ilegibles, hoist, limpieza, cwd/entorno y conservación de salida ante fallo |
| `relocated-3.log` | PASS: runtime final fuera del checkout, ruta temporal con espacios/acentos, pull del scaffold y DOCX con reparación desde el paquete; fuentes y documentos hermanos preservados, error con exit 1 |
| `identity-4.log` | Los cuerpos de la API render/helpers y lector de recursos instalados coinciden con las fuentes finales |

La comparación de cinco formatos se hizo sobre el primer tarball. El segundo
añadió únicamente rechazo explícito de carpetas ilegibles, comprobado mediante
API instalada. El tercero corrigió la codificación de rutas en recursos; los
cuerpos de render quedaron idénticos. El cuarto preserva explícitamente los
permisos de archivos frente a umask, con baseline fallido en modes-baseline.log
y comprobación instalada de API y runtime reubicado.
No se repitieron los renders iguales para atribuirles otra identidad.

Dos fallos de pruebas quedan identificados: `api-1.log` falló por comparar una
ruta temporal con doble separador con el retorno canónico; se corrigió el test,
sin cambiar la API. `relocated.log` descubrió un defecto real de recursos:
radix sort rechazaba rutas nativas con acentos. La admisión adicional está en
`resources-encoding-20260916/`: baseline falla, candidato normaliza sólo esas
rutas con enc2utf8 antes de ordenar, y `candidate.log`/`parity.log` pasan.
La ruta acentuada fue una prueba sintética creada por esta tarea según la
política de instalación, no una ruta del proyecto AR-M2V4D.

Revisión estructural: una operación pública completa; copia interna que conserva
enlaces (file.copy por sí sola los sigue) y frontera de procesos con errores
explícitos. Se retiraron adaptadores y lógica duplicada de producción. No se
creó framework de render, parser YAML alternativo ni nuevos verbos/opciones.
La publicación de salida conserva su límite: reemplazo HTML no atómico y
conservación de hermanos DOCX; limpieza temporal no equivale a rollback.

La instalación CLI temporal y tres bibliotecas de ensayo sustituidas se retiraron;
el SoT de render ocupa aproximadamente 3,5 MB, incluidos los tarballs y la
biblioteca aceptada. No se conservan árboles de documentos regenerables.
La generación de Rd/export terminó y el gate ortográfico falló: incluye términos
de la documentación nueva y existente (`document.log`). No hay aceptación CRAN
del nuevo tarball, comprobación Windows ni aceptación científica de todos los
masters. Permanecen lote/preflight, publicación, builders y la entrada común
cli/main.R; MCE del piloto sigue sin resolverse. Sin commit, push ni efectos remotos.

## Lote render en biblioteca — 2026-09-16

`render-batch-20260916/candidate.json` identifica `quartoRenderManifest`, su
lector/selector privado y el guard de salida compartido con `quartoRender`.
Tarball: `73c754463a4814d5c678cba38908cd1c841ce6cfe2cc0f848516b9251eb3f4ff`.
El baseline instalado no exporta la operación (`baseline.log`).

- `api.log`: 16 comprobaciones de selección en orden, alias desconocidos,
  colisiones también fuera de la selección, preflight sin efectos, esquema 1,
  productos externos y salidas requeridas/opcionales.
- `parity-2.log`: CLI candidata instalada frente a QRT instalado; cinco perfiles
  (HTML, RevealJS, libro, DOCX y DOCX libro), texto HTML y XML DOCX iguales,
  fuentes intactas; además el productor externo nunca se ejecuta.
- `windows-batch.log`: el mismo tarball instalado en
  `C:/Users/averri/AppData/Local/Temp/ngr-batch-20260916/library`; R 4.6.1,
  mismas 16 comprobaciones, cero fallos/warnings/skips. No prueba aún renders
  Quarto ni CLI Windows completa. `pak` se preparó en esa biblioteca temporal.
- `deploy-unchanged.log`: cuatro casos de proveedor simulado pasan después de
  conservar los cuerpos Bash de publicación byte a byte. Sin Netlify remoto.

La corrección explícita del propietario delimita la diferencia: las entradas
legadas `map` representan productos externos que se comprueban; no ejecutan
pipelines Python. `static` mantiene el mismo carácter externo. Se conservan
manifests legados sin inventar una herramienta productora.

La revisión rechazó una eliminación que incluía funciones de deploy no afectadas
(`rejected-removal.json`); fueron restauradas desde la referencia exacta antes
de aceptación. `parity.log` conserva un fallo por comilla en el adaptador, ya
corregido y cubierto por `parity-2.log`. Se retiró el helper de listas Bash sin
consumidores que sólo usaba el antiguo lote. La documentación generó Rd/export;
el gate ortográfico sigue fallando. No hay nuevo check CRAN ni aceptación de
todos los masters científicos. La entrada común y la publicación R siguen.

## main.R, Netlify y plataformas — 2026-09-16

Candidato de cierre: `main-runtime-20260916/release-6/NGR_0.3.11.tar.gz`,
SHA-256 `597d88e1eb6d5dca8ee2792316bc23211985ccaabd1b7c7736b6ef0f60d9a191`.
Instalado en macOS mediante `install/install.R` en `library-6/NGR`.
`identity-6.log` coteja 45 funciones instaladas con las fuentes; `baselines-6.log`
verifica referencias exactas y 71 archivos de producción iguales entre releases
5 y 6 (el último cambio corrige el orden de limpieza del test, no el runtime).

La distribución CLI contiene 396 archivos, de los cuales sólo main.R es R.
Launchers Bash/Windows entran allí y cargan NGR instalado. Se retiraron render.sh,
render.R y resources.R. El guard checkRuntime.R pasó a install/cli y lee el
contrato único install/requirements.R; el backend nunca instala paquetes R.
Los componentes comunes install.sh/install.ps1 y mantenimiento R fueron
integrados por el coordinador; su aceptación integral es independiente de estas
pruebas focales del backend y del runtime.

NGR proporciona nueve operaciones públicas: tres de recursos, dos de render y
cuatro Netlify. El despacho/argv es privado del paquete. No hay llamada de vuelta
a QRT/PSHA ni carga del código R desde el checkout.

| Evidencia bajo main-runtime-20260916 | Resultado y objeto ejercitado |
|---|---|
| mac-1.log | Primer main/Netlify: 22 pruebas PASS, 2 comparaciones Python omitidas por no seleccionar referencia; incluye cinco perfiles frente a QRT |
| mac-deploy-2.log y baseline-deploy.log | Los mismos seis casos Netlify PASS en candidato R y Bash preservado: upload sin build, selección, conflictos antes de efectos, registros/comentarios, dominios y reconciliación TLS |
| mac-resources-2.log | Ocho casos de recursos PASS tras corregir detección de enlaces |
| mac-provenance-3.log | Dos casos PASS, incluida comparación pública QRT, con filtros Lua corregidos |
| mac-install-5.log | Siete casos CLI/instalador PASS con guard reubicado: actualización, retirada, propiedad y ejecución fuera del checkout; prefijo sintético con espacio y ñ |
| mac-cleanup-6.log | 42 aserciones R, cero fallos/warnings/skips: enlaces de archivos/directorios, incluidos colgantes, metadatos, render con enlace, salida preservada al fallar, cwd/entorno y limpieza |
| windows-main-3.log | Windows real: siete recursos, seis Netlify simulados y dos instalación/relocación PASS; el render reveló error de separadores que se corrigió después |
| windows-main-4.log | Cinco perfiles reales y producto externo PASS: HTML, libro, RevealJS, DOCX simple y libro DOCX; tar release-3. Dos casos de firma Unicode fallaron, corregidos después |
| windows-close.log | Cinco casos Python PASS: recursos/enlaces, guardas instalador y procedencia Unicode. Copia R falló en fixture fs::link_create; no se declaró aceptación global |
| windows-final.log | Siete CLI/instalador PASS y 35 aserciones R sin fallos; cuatro warnings de limpieza revelaron otro defecto Windows, corregido en el último candidato |
| windows-cleanup.log | Tar final release-6: 39 aserciones R PASS, cero fallos/warnings/skips, y 45 funciones instaladas iguales a las fuentes. Cierra el fallo de limpieza de enlaces |
| windows-powershell.log | Cinco casos PASS: argumento literal source&one.json invocado como ngr desde PATH/PowerShell, propiedad y retirada de ambos launchers, actualización, relocación y rollback al fallar el segundo launcher |
| mac-powershell-installer.log | Tres casos de instalación PASS con backend final; dos casos específicos Windows omitidos explícitamente |

Windows se ejecutó en W11 real por Parallels, R 4.6.1 ucrt, Python 3.13.14,
fs 2.1.0 y Quarto portable 1.9.35. Se usaron biblioteca/prefijo TEMP propios y
PATH del proceso. No se cambiaron bibliotecas personales ni PATH persistente.
Los logs y capturas de bytes conservan también los intentos fallidos.

### Diferencias de plataforma corregidas

- Sys.readlink no funciona en Windows; fs identifica enlaces fuente/destino,
  incluidos colgantes. Se conserva el rechazo antes de copiar recursos.
- Procedencia normaliza separadores con winslash="/".
- Windows resuelve Python como python; DOCX conserva el recurso fix_docx del paquete.
- Los dos filtros Lua leen la firma con pandoc.system.environment(): os.getenv
  devolvía bytes que dañaban Unicode en Windows.
- fs::link_create crea junctions en Windows y R base file.symlink falló por
  privilegios. La copia de enlaces usa os.symlink estándar de Python, con el
  atributo de directorio leído sin seguir el enlace; no otro motor de recursos.
- Base unlink dio warnings y dejó enlaces de directorio. La limpieza pasó a
  fs::dir_delete/file_delete, que conserva las fuentes y señala errores.

No se ocultaron fallos del harness: mac-install-4.log apuntó a un directorio
temporal inexistente; mac-install-5.log corrige esa invocación. mac-cleanup-5.log
comparó un modo después de borrar el fixture; mac-cleanup-6.log corrige el orden.
Las referencias y el tar de cada intento permanecen identificables.

La revisión estructural retiró motores/adaptadores sustituidos, reutilizó el
lector de artefactos para render/deploy y eliminó la duplicación del contrato
de instalación. Se mantuvieron operaciones con efectos propios y launchers
mínimos; no se añadieron verbos, flags ni un framework de proveedores.

`references.log` verifica 400 archivos QRT, 771 PSHA y 39 del NGR personal sin
diferencias. Esta aceptación de comandos no acredita todos los masters
científicos, la entrada MCE ausente ni un despliegue Netlify real. No hubo
commit, push, publicación Pages o reinstalación personal. No hay nuevo check
CRAN de este tarball; el gate ortográfico anterior sigue registrado.

### Integración y retirada de temporales

El candidato común quedó actualizado en `candidate-install/bin/ngr`, emparejado
con `main-runtime-20260916/library-6` mediante R_LIBS. `candidate.json` fija fuentes,
tarball y recibo; `candidate-2.log` compara los 396 archivos distribuidos contra
fuente/recibo y las seis referencias exactas. Sólo main.R es R en la distribución.
`integrated-version.log` prueba esa entrada definitiva desde /tmp. El primer
cotejo candidate.log intentó tratar los HTML de viñetas generados por R CMD build
como archivos fuente; candidate-2 distingue esos productos documentales.

La sonda windows-arguments-2.log demostró que PowerShell dividía un argumento con
& al pasar por .cmd. `ngr.ps1` entra directamente por Rscript/main.R y evita esa
segunda interpretación; `ngr.cmd` sigue siendo la entrada CMD. La prueba usa
ExecutionPolicy Bypass sólo en su proceso, sin cambiar la política del equipo.
El instalador conserva recibos independientes de ambas entradas y revierte la
primera si falla reemplazar la segunda. No se añadió lógica de dominio al launcher.

Se retiraron dos runtimes CLI redundantes y seis bibliotecas de ensayo macOS.
Los dos directorios SoT de esta etapa bajaron de unos 45 MB a unos 4,8 MB, incluidos
tarballs, referencias, logs y la única biblioteca candidata actual. En Windows
se retiraron Quarto portable (504 MB), el baseline temporal (22 MB), el runtime
CLI y la biblioteca NGR final después de que gmsp liberó su préstamo. Logs
`retire-*.log`, `windows-retire.log` y `windows-retire-library.log`. Las referencias
QRT/PSHA y las instalaciones personales siguen intactas.

Con esto se acepta la frontera de comandos main.R/biblioteca y los casos de
plataforma ejercitados. Quedan builders/scaffolds, todos los masters científicos,
la entrada MCE y cualquier aceptación remota con destinos autorizados.

## UHS probabilístico como API instalada — 2026-09-16

Registro histórico: el propietario rechazó esta extracción el 2026-09-17.
Su paridad funcional no acredita aceptación de arquitectura. API y consumidores
extraídos se retiraron/restauraron en rejected-spectrum-20260917.

`buildSpectrumPlot` integrado en lib recibe series preparadas y aplica la
representación común mediante buildPlot, sin selección científica ni archivos.
En reports/sha, `.prepareUHS` conserva la preparación y los tres consumidores
probabilísticos llaman a NGR. UHS.R y MCE.UHS permanecen porque la rama MCE no
tiene entrada científica disponible para aceptarla.

Tar aislado: `uhs-builder-20260916/release/NGR_0.3.11.tar.gz`, SHA-256
`a11ee5e9aa26f4fe43af90beb7fe8ac94e83b2d4589f400eda6c94419a13cbcd`.
`candidate.json` identifica paquete instalado y nueve archivos integrados.

| Evidencia en uhs-builder-20260916 | Resultado |
|---|---|
| installed.log | Diez comparaciones PASS frente a UHS.R preservado, con datos reales AR-M2V4D; preparación, widget completo, sizing, no mutación y rechazo de duplicados |
| api-2.log | 14 aserciones PASS macOS: PGA, ejes, banda, estilos y no mutación |
| windows-3.log | Las mismas 14 aserciones PASS en W11/R4.6.1 nativo, identidad API y limpieza del fixture |
| consumer.log | Tres bloques QMD reales, renderizados por ngr instalado en referencia/candidato; widgets, captions e IDs idénticos |
| integrated.log | API y nueve archivos coinciden; setup real carga la preparación; MCE/utils intactos; ejecución desde /tmp |

`REVIEW.md` documenta frontera, revisión estructural y fallos de preparación de
tests: setup accidental de testthat, pak no preparado y error de transporte
Parallels. Windows instaló el tar como fixture R base con deps existentes, sin
certificar de nuevo el instalador de producto. La generación roxygen produjo
manual/export pero el gate ortográfico falló; no se declara check CRAN.

No hubo cambio a main.R ni a launchers. No se repitió su matriz ya aceptada.
Esta etapa no acepta todos los masters, MCE, Netlify remoto ni instalación
personal. Referencia y candidato se conservan en SoT; los renders y la copia
desplegada del paquete usados como fixtures son regenerables.
