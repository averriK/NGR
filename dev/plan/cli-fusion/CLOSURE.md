# NGR: entrega local y pendientes

2026-09-17. Resume la implementación y las comprobaciones locales; la sustitución
completa de QRT/PSHA aún no está aceptada. El commit
`b7e09a1da81ee1689c65357e2cf90dba81a46433` fue publicado en `origin/main`;
pkgdown terminó correctamente (run 35276897162). Las guías CLI y scaffolds
responden HTTP 200 con el contenido nuevo. La instalación personal de sistema
no se ha ejecutado; su entrada es `sudo bash install/install.sh`.

## Entrega utilizable

- Biblioteca en `lib/`; CLI en `cli/`, con launchers Bash/CMD/PowerShell y
  una única entrada R, `main.R`. Carga el paquete instalado.
- Verbos: `pull`, `status`, `doctor`, `render`, `deploy`; identificación por
  `--version`. Las operaciones reutilizables pertenecen a la biblioteca.
- Instalación y mantenimiento concentrados en `install/`, según la política
  común coordinada. Entradas `install.sh` y `install.ps1`; herramientas R de
  documentación, build, check e instalación. El componente CLI no instala R.
- Motor de recursos genérico con manifests y procedencia por archivo, destinos
  compartidos y preflight de colisiones. Conserva semillas y datos del proyecto.
- `fix_docx.py` distribuido privadamente por el paquete. NGR no ejecuta
  OpenQuake ni produce mapas; consume los resultados externos existentes.
- Scaffold candidato en `/Users/averrik/Cloud/github/reports/sha`.
  UHS y MCE usan `NGR::buildSpectrumPlot()`; selección y preparación permanecen
  en el scaffold. El antiguo `scripts/fig/UHS.R` se retiró sólo del candidato.

## Actualización: manifiestos y pruebas

Naming aprobado el 2026-09-17: `manifest.json` en cada scaffold y en cada
proyecto, con responsabilidades distintas. Se migraron el motor, la distribución
CLI y los lectores SHA de TOC, transmittal y notas de enlaces. Los proyectos
antiguos requieren migración explícita; no se crea otro estado ni se lee el
nombre anterior silenciosamente. Procedimiento en [cli/README.md](../../../cli/README.md#migrating-an-existing-project).

La biblioteca candidata instalada está en
`dev/SoT/cli-fusion/manifest-20260917/library/NGR`; tar SHA-256
`8f1eb5a67e69b6bf246c0f2dcff0a6d9e4645a05f0acfefb77d2d36c207d5286`.
Identidad y diff en [candidate.json](../../SoT/cli-fusion/manifest-20260917/candidate.json).
Esta tanda probó las entradas del checkout `cli/bin/ngr` y `ngr.cmd`, que
cargan esa biblioteca instalada. No se hizo una nueva instalación de CLI.
El guard de instalación rechaza la biblioteca anterior por su contrato de
manifiesto incompatible, aunque comparta el número de versión de desarrollo.

Pruebas de esta actualización, bajo `dev/SoT/cli-fusion/manifest-20260917/`:

- `resources.log`: 24 pruebas de recursos, interfaz, comparación y Netlify
  simulado. `parity-final.log`: cuatro, incluida migración de una asociación
  antigua seguida de status/pull, conservando todos los recibos.
- `render.log`: cuatro pruebas; comparación con QRT de cinco casos HTML,
  RevealJS y DOCX, procedencia y preservación de productos externos.
- `windows.log`: 15 pruebas de recursos/interfaz, biblioteca instalada desde
  el mismo tar. `focused-final.log` y `windows-final.log`: aserción final de
  protección frente a destinos symlink en ambas plataformas.
- `pilot-result.json`: TOC real RevealJS y transmittal DOCX de AR-M2V4D contra
  QRT; texto y 21 partes OOXML iguales, salvo fechas de generación declaradas.
  `consumers-result.json`: 29 resultados iguales de los tres lectores SHA.
- `native-render.log`: 29 aserciones aprobadas; un caso de render R directo
  omitido porque ese proceso no veía Quarto en PATH. Los renders por la CLI
  sí se ejecutaron. `native-manifest.log`: encoding y selección por manifest.
- `guard-baseline.log`, `guard-reject.log`, `guard-accept.log`: el guard anterior
  admitía la biblioteca incompatible; el nuevo la rechaza y admite la candidata.
  `distribution.log`: preflight de assets sin instalar una CLI.

El baseline falla las tres condiciones nuevas de naming (`baseline.log`).
Las referencias QRT/PSHA instaladas y el scaffold PSHA original permanecen
idénticos. AR-M2V4D original no fue migrado; las pruebas usan copias.
La aceptación completa de los 37 masters y un segundo scaffold real sigue
pendiente. Las entradas de dinámica y la segunda fuente ya se localizaron;
no constituyen una consulta pendiente al propietario. Esta tanda de naming
no ejecutó efectos remotos ni un nuevo check CRAN.

Para ejecutar el candidato local desde un proyecto preparado:

```sh
R_LIBS=/Users/averrik/Cloud/github/libraries/NGR/dev/SoT/cli-fusion/manifest-20260917/library /Users/averrik/Cloud/github/libraries/NGR/cli/bin/ngr --help
```

## Actualización SRS: once masters con datos reales CFD

[Revisión y límites](../../SoT/cli-fusion/srs-20260917/REVIEW.md) y
[resultado](../../SoT/cli-fusion/srs-20260917/result.json): 22 renders terminaron
con código 0; coinciden los 77 widgets completos, sus 77 captions, textos,
IDs y enlaces. Se usaron QRT instalado y la entrada NGR del checkout con la
biblioteca candidata instalada, sobre copias de la misma generación CFD.

Diez masters coinciden también en recursos auxiliares por bytes. IPSA empaquetó
una variable de fuente en otro CSS; el fallo inicial se conserva. La comparación
nativa del navegador confirmó las mismas 36 reglas, orden de reglas no raíz y
30 variables con valores efectivos idénticos. La equivalencia funcional se
aceptó con esa evidencia adicional, sin afirmar igualdad por bytes de IPSA.
Se revisaron visualmente AT, AI, PSA, ITS e IPSA; en los modales, S01 y S24.

Los datos originales, ambos paquetes R, los 400 archivos QRT, 771 PSHA y
766 del scaffold original permanecieron idénticos. Se retiraron 1.55 GB de
temporales; esta fase conserva unos 35 MB con entradas comprimidas y resultados.
Los servidores locales y las ejecuciones terminaron. Estas pruebas nuevas son
de macOS y no extraen todavía los builders SRS ni instalan otra CLI.

## Prototipo anterior preservado

Identidad anterior en
[candidate.json](../../SoT/cli-fusion/completion-20260917/candidate.json):

- Paquete `NGR_0.3.11.tar.gz`, SHA-256
  `386a8e9ecf41f634dbc866138e356ecd74bb0cb8927a4e26ea4a1565a3340531`.
- Biblioteca instalada:
  `dev/SoT/cli-fusion/completion-20260917/library/NGR`.
- CLI instalada:
  `dev/SoT/cli-fusion/completion-20260917/prefix/bin/ngr`.
- 396 archivos CLI cotejados contra fuente y recibo. El número incluye recursos
  distribuidos; no representa 396 instalaciones.

Este prototipo conserva los nombres anteriores; se mantiene para comparación:

```sh
R_LIBS=/Users/averrik/Cloud/github/libraries/NGR/dev/SoT/cli-fusion/completion-20260917/library /Users/averrik/Cloud/github/libraries/NGR/dev/SoT/cli-fusion/completion-20260917/prefix/bin/ngr --help
```

## Comprobaciones de la tanda anterior

Las rutas de evidencia siguientes están bajo
`dev/SoT/cli-fusion/completion-20260917/`, salvo indicación contraria.

| Objeto | Resultado y evidencia |
| --- | --- |
| Paquete final | `check-2.log` y `check-2-00check.log`: 0 errores, 0 warnings, 1 NOTE, «New submission». Se ejecutó el checker mantenido; no se envió a CRAN |
| Documentación | `document-3.log`: roxygen y ortografía aprobados. `pkgdown-2.log`: sitio construido. `docs-result.json`: existencia/enlaces de 11 APIs y presencia textual de instrucciones macOS/Windows; no ejecución de los ejemplos de instalación |
| Instalación macOS | `install-mac-2.log`: entrada común instala paquete y CLI en destinos aislados. `mac-render.log` y `mac-consumer-result.json`: render real con título y widget |
| Instalación Windows real | `install-windows.log`, `windows-diagnose.log`, `windows-accept.log`: entrada común, paquete instalado, pull/status/render y salida verificada. Temporal retirado con recibo |
| UHS/MCE | `mce-builder-20260917/compare.log`, `accept-2.log`, `integrated-2.log`: datos, widgets, captions e IDs conservados; cero consumidores restantes del builder retirado |
| SHA EN | `sha-result.json`: 172 widgets, 195 captions, 390 IDs, 8 títulos, 23 tablas y un iframe iguales. Portada, navegación, UHS y MCE inspeccionados visualmente |
| SHA ES, SDC EN/ES | `additional-2-html-result.json`: widgets, texto de slides, captions, IDs, títulos, tablas, enlaces e iframes iguales |
| Hubs EN/ES | `masters-2-html-result.json`: toc, gmdp y srs, mismo contenido y enlaces |
| Cuatro DOCX | `masters-2-docx-result.json`, `proposals-3-docx-result.json`: todas las partes OOXML, relaciones, estilos y recursos iguales. Sólo se excluyen las fechas created/modified y metadatos temporales ZIP |
| Referencias personales | `references-result.json`: los 400 archivos QRT y 771 PSHA coinciden con la referencia preservada |

Las pruebas anteriores de recursos, cinco perfiles de render, procedencia,
instaladores y Netlify simulado en macOS/Windows permanecen delimitadas en
[LOCAL-VALIDATION.md](LOCAL-VALIDATION.md). No se repitieron casos sin cambios.

**Límite del cierre documental:** los comandos con `/path/to/...` o
`C:/R/library` de la viñeta son plantillas, no transcripciones de ensayos.
Esta tanda no demuestra ejecutar la variante común `--build`, el flujo con
`sudo`, ni toda la secuencia de ejemplos sobre un proyecto completo.
`docs-result.json` sólo comprueba páginas, enlaces y presencia de texto.
La evidencia Windows de instalación usa `--tarball`: argv exacto en
`windows-install.ps1:12`, destinos en líneas 2–4 y resultado en
`install-windows.log:33–46`. El script no fija ni registra el CWD inicial de
instalación; sí fija el CWD del consumidor en `windows-install.ps1:16`.
En macOS, `install-mac-2.log:24–37` acredita artefacto/destinos/resultado,
pero ese log no contiene el argv completo ni el CWD de invocación. No se
reconstruyen esos datos como si fueran evidencia registrada.
`ngr render _master/book.en.qmd --profile book` permanece sin aceptación
en AR-M2V4D por las entradas ausentes; los ensayos genéricos de libros no
convierten ese ejemplo concreto en ejecutado.

## Cobertura acumulada de masters: 25 de 37

| Estado | Masters |
| --- | --- |
| Comparados, RevealJS (10) | `sha`, `sha.es`, `sdc`, `sdc.es`, `toc.en`, `toc.es`, `gmdp.en`, `gmdp.es`, `srs`, `srs.es` |
| Comparados, DOCX (4) | `transmittal.en`, `transmittal.es`, `proposal`, `proposal.es` |
| Comparados, SRS RevealJS (11) | `srs.ai`, `srs.at`, `srs.cav`, `srs.cav5`, `srs.dt`, `srs.ipsa`, `srs.its`, `srs.psa`, `srs.psv`, `srs.sd`, `srs.vt` |
| Pendientes con entradas localizadas en AR-S2L1W (8) | `gmdp.dn.en/es`, `gmdp.kh.en/es`, `gmdp.kmax.en/es`, `gmdp.ts.en/es` |
| Informes completos pendientes de comparación (4) | `book.en`, `book.es`, `docx.en`, `docx.es` |

La cobertura se resolvió desde masters y sus bloques efectivos. Un hub SRS
con enlaces no acredita las once presentaciones científicas. Los DOCX probados
no sustituyen la aceptación de los informes completos con `_chapters/`.
El perfil DOCX de las propuestas se eligió para comparación local; no fija
una política de publicación.

### Fallos y límites conservados

- El primer tar de esta tanda falló por un carácter Unicode literal en código
  R y el import de `utils::file_test`. Se corrigieron con escape equivalente e
  import explícito. `portability.log` conserva igualdad de cuerpos, firmas y
  ayuda; el check corresponde al tar final, no al rechazado.
- En Windows, el primer render terminó con estado 1 sin causa visible. La
  ejecución con log diagnóstico produjo el resultado; otra aserción buscaba
  `proof.html` cuando la configuración producía `index.html`. Se verificó la
  salida correcta. No se atribuye una causa inventada ni se declara resuelta
  una intermitencia a partir de un único éxito.
- Fallos del ensayo: masters ausentes de la copia inicial, PATH alterado por
  el perfil personal de R, `_scope` omitido y comprobaciones con rutas o
  selectores incorrectos. Logs originales conservados; se corrigió el ensayo
  y se repitieron únicamente los casos no aceptados.
- `sha-inputs.json` serializaba los hashes como arrays. Antes de retirar
  entradas, se reconstruyó su asociación a rutas usando el mismo orden R y
  se verificó igualdad exacta con todos los hashes registrados. La asociación
  explícita está en `sha-input-files.json`; no se reemplazó la evidencia original.
- La comparación HTML no certifica disponibilidad de sitios embebidos remotos.
  Netlify está probado con simulación; no se han creado ni publicado sitios.

## Corrección de pendientes por instrucción del propietario

El propietario retiró estas falsas dependencias el 2026-09-17. Corresponde a
esta tarea elegir un proyecto completo y un destino existente para pruebas,
usar la instalación con `sudo bash install/install.sh`, entregar el comando y
realizar commit/push ahora. No hay que volver a pedir esos permisos/selectores.

- Se eligió AR-S2L1W: contiene ShearTable, DnTable y kmaxTable. Su manifest tiene
  21 artefactos y sitios existentes, entre ellos `ars2l1w-toc`.
- El scaffold monitoring existe en
  `/Users/averrik/Cloud/github/libraries/reports/library/monitoring`; ya estaba
  identificado en COMPOSITION.md. Pedir otra fuente fue un error de continuidad.
- La incorporación conjunta base+SHA y la migración de la asociación legacy
  `psha` a `sha` se probaron sobre copias. Se corrigió la base para que no
  distribuya la bibliografía científica que corresponde al scaffold.
  Evidencia: `composition-20260917/REVIEW.md` y `result.json`.
- La instalación de sistema sigue pendiente de que el propietario ejecute la
  instrucción entregada al terminar. Las bibliotecas y prefijos SoT son objetos
  de comparación; no una instalación personal alternativa.
- Commit/push realizado: `b7e09a1`, HEAD y origin/main iguales. El run
  pkgdown 35276897162 terminó success; Pages sirve las nuevas guías CLI y
  scaffolds con HTTP 200. Evidencia en actions-result.json y pages-result.json
  de composition-20260917.
- La prueba Netlify usará un draft de un sitio existente verificado, sin
  reemplazar producción ni cambiar dominios.

No hace falta otra decisión sobre verbos, carpetas `cli/`/`lib/`, `main.R`,
el motor de recursos R, fix_docx o retirada de QRT/PSHA. Sus contratos ya están
cerrados; QRT/PSHA permanecen instalados sin mantenimiento.

### CLI actual instalada y composición

`composition-20260917/install.log` registra instalación por la entrada común
de la CLI actual, con 395 archivos distribuidos, en su `prefix/`; carga la
biblioteca aceptada de manifest-20260917. `installed-result.json` registra
incorporación real de base+SHA, segundo pull por asociación y status --check,
todos con salida 0 desde un proyecto temporal fuera del checkout. La fuente
base se resolvió desde el runtime instalado. El proyecto temporal se retiró.
Esto acepta ese recorrido instalado en macOS; no todos los builders ni una
instalación personal con privilegios elevados.

## Trabajo que sigue siendo responsabilidad de esta tarea

Con el oráculo real SRS ya disponible, migrar sus builders por familia,
revisar las familias restantes con sus productores y aceptar los
12 masters pendientes sobre otro proyecto completo. Reutilizar APIs existentes no equivale a dar por
migrado un consumidor; cada extracción necesita evidencia propia.
También corresponden a esta tarea la publicación autorizada y la instrucción
de instalación. No se trasladan esas obligaciones al propietario como
decisiones técnicas nuevas.

La revisión estructural de esta tanda conserva una sola preparación UHS/MCE
y una API de representación, sin nueva función ni dispatcher para MCE. Los
dos cambios de portabilidad no alteran la interfaz; documentación y vocabulario
corresponden a APIs efectivamente distribuidas. No se modificó la suite común
del coordinador ni el productor PSHA.

## Retención y continuidad

`inputs-archives.json` identifica la referencia completa y el pequeño delta
candidato; se conservan paquete final, biblioteca/CLI instaladas, sitio local,
referencias acotadas y resultados. Se retiraron 800.312.868 bytes de temporales
macOS, copias de informes y el archivo Quarto descargado. El temporal Windows
de 561.056.298 bytes también fue retirado, con recibo propio.

La fase ocupa 35 MB; todo `dev/SoT/cli-fusion/`, 150 MB medidos por `du -sh`.
Los renders se pueden reconstruir desde las entradas congeladas; no se dejaron
las parejas de árboles HTML. Única continuidad:
[STATE.md](STATE.md), seleccionada por `dev/SoT/ACTIVE.md`.
