# Composición editorial: carpetas compartidas y espacios de nombres

2026-09-16. Investigación estática, sin modificar ni ejecutar scaffolds.
Misión: `cli-fusion-editorial-collisions-20260916`.

## Conclusión

**Sí: si los nombres de destino son distintos, `_chapters/` y `_fig/` pueden ser carpetas compartidas.** Deben ser distintos también para el filesystem de destino, no sólo por mayúsculas. No hay una razón técnica observada para imponer una carpeta física por libro. Los bloques PSHA y monitoring examinados ya usan nombres de dominio suficientemente distintos. Pero «copiar sin pisar archivos» y «componer un documento que se ejecute correctamente» son dos contratos diferentes.

El contraste real aporta una respuesta precisa: en los subárboles `_chapters/`, `_fig/` y `_master/` de PSHA y monitoring no se observaron rutas relativas iguales; en `scripts/` aparecen cuatro rutas iguales, todas con bytes distintos. Aun cambiando esas cuatro rutas, quedarían funciones R homónimas con comportamiento diferente, semillas de parámetros con formas diferentes y valores de sesión dependientes del orden. Los labels, referencias, aliases y outputs constituyen otros espacios que tampoco quedan aislados por el nombre del archivo.

Recomendación editorial: **conservar las carpetas compartidas, usar nombres temáticos donde representan contenidos distintos y tratar explícitamente las pocas piezas que hoy quieren ser dueñas del mismo contrato**. No hace falta anteponer el nombre del scaffold a cada recurso. Tampoco basta con renombrar sus archivos de arranque.

Esta recomendación no aprueba un nuevo contrato de CLI, una migración ni un esquema de manifest. Es compatible con la organización por mapeos del [plan vigente](/Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-fusion/PLAN.md:66), que deja la composición semántica por cerrar.

## Alcance y cadenas efectivamente leídas

Se aplicaron los skills instalados `code` (incluidas sus veinte tarjetas) y `r`. Se leyó la identidad exacta del delegado en el estado seleccionado antes de actuar. La investigación usa fuentes de trabajo; no acredita igualdad con las instalaciones ni un render integrado.

### PSHA

El [master book.en](/Users/averrik/Cloud/github/tools/psha/scaffold/_master/book.en.qmd:6) declara `index.qmd`, capítulos de `_book/`, partes y apéndices. Dentro de esa lista se siguió la cadena representativa:

`_master/book.en.qmd → _book/psha.qmd → _chapters/psha.*.md + _fig/POE.qmd → scripts/fig/POE.R`.

La lectura de [_book/psha.qmd](/Users/averrik/Cloud/github/tools/psha/scaffold/_book/psha.qmd:1) comprobó el setup y los includes de model, uncertainty, disagg, aep y poe. Esos cinco fragmentos se leyeron completos. La invocación de POE está en líneas 63–80 y su [_fig/POE.qmd](/Users/averrik/Cloud/github/tools/psha/scaffold/_fig/POE.qmd:32) llama al builder y emite `fig-poe`. También se leyó el [master sha](/Users/averrik/Cloud/github/tools/psha/scaffold/_master/sha.qmd:33) y su bloque [_revealjs/hazard.qmd](/Users/averrik/Cloud/github/tools/psha/scaffold/_revealjs/hazard.qmd:20), que combinan invocaciones dinámicas y includes literales.

Esto es una clausura representativa para los problemas de composición, no un inventario íntegro ni una certificación del libro completo.

### Monitoring: segundo tema real localizado

El [master report.es](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/_master/report.es.qmd:3) incluye expresamente `_index/piezometers.ES.qmd`. Se siguió y leyó:

`_master/report.es.qmd → _index/piezometers.ES.qmd → _fig/PZ.levels.ES.qmd → _fig/PZ.levels.qmd → _fig/PZ.levels.one.qmd → scripts/fig/PZ.levels.R`.

El [capítulo de piezómetros](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/_index/piezometers.ES.qmd:1) llama al setup y a sus bloques de resultados, tablas y figuras. Se leyeron también los fragmentos de introducción y alertas, `pz.results.es.qmd`, las variantes ES y bases de `PZ.last` y `PZ.alerts`, y los tres scripts de setup que carga `setup.R`.

Monitoring es un ejemplo adicional observado en `libraries/reports/library/monitoring`. No se lo identifica con SSEL ni blasting, ni se presume aprobado como fuente para NGR.

### SSEL, blasting y consumidor no PSHA

La búsqueda acotada por rutas y nombres bajo `tools/`, `libraries/` y `research/` localizó `libraries/ssel` y `research/blastDB`, pero no un scaffold blasting/SSEL verificable desde un master. El [README de ssel](/Users/averrik/Cloud/github/libraries/ssel/README.md:5) declara un paquete R existente y una CLI planificada. Los candidatos de blastDB quedaron como locators de búsqueda, incluidos paths `metadata/PMC…/manifest.json`; su contenido no se usó como evidencia de una fuente editorial. No se afirma que esos scaffolds no existan en otra ubicación; para ellos los escenarios son hipotéticos.

Como control de vocabulario se leyeron el [manifest AR-SAD40](/Users/averrik/Cloud/github/projects/AR-SAD40/qrt.manifest.json:3), su [master report](/Users/averrik/Cloud/github/projects/AR-SAD40/_master/report.qmd:5) y el [capítulo model](/Users/averrik/Cloud/github/projects/AR-SAD40/_index/model.ES.qmd:1). Es un consumidor no PSHA; no hay evidencia leída que lo convierta en SSEL.

## Colisiones físicas observadas

Comparación literal de rutas relativas de cuatro subárboles definidos antes de comparar, con `list.files(..., recursive=TRUE, all.files=TRUE)` y hashes MD5 de las intersecciones. Es una comparación de archivos candidatos a compartir destino; no un inventario de productos derivados de un listado ni un preflight completo de mayúsculas, enlaces o escapes.

| Subárbol | Rutas relativas comunes PSHA/monitoring | Resultado |
|---|---:|---|
| `_chapters/` | 0 | Los nombres observados pueden coexistir. |
| `_fig/` | 0 | Los nombres observados pueden coexistir. |
| `_master/` | 0 | No se observó colisión en estos dos juegos actuales. |
| `scripts/` | 4 | Las cuatro rutas tienen contenido distinto. |

| Ruta común | MD5 PSHA | MD5 monitoring |
|---|---|---|
| `scripts/setup/global.R` | `8e23630ce75de966898b72383198be04` | `b65c9f92a3f7edb83629e6c5b5838155` |
| `scripts/setup/report.R` | `d260a406614d60e70e0a75a9f99f1087` | `2eab730b21339b9ace99cc8c4033add4` |
| `scripts/setup/setup.R` | `53d0d06a2839f3cda4496281c7767292` | `9282e4633f75bc3ffee629313f5faaf7` |
| `scripts/setup/utils.R` | `dc5d6d885a3a10bfba228028ff8fb8ea` | `346022748db51176667146269250ba11` |

No son sólo hits de búsqueda: las cadenas de ambos masters requieren setup. [PSHA setup](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/setup/setup.R:39) carga utils y global; el capítulo carga report. [Monitoring setup](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/scripts/setup/setup.R:36) carga utils, report y global. Se leyeron los archivos completos salvo el utils PSHA, del cual se leyeron las funciones pertinentes en fragmentos acotados.

`params.yml` queda fuera de esa tabla de cuatro subárboles, pero también es un destino compartido con contenido incompatible. Además, el master de monitoring y el de PSHA incluyen ambos `index.qmd`; esos índices no se compararon aquí. Por tanto, los cuatro conflictos no representan una declaración de que sean todos los conflictos de los scaffolds completos.

## Qué continúa compartido aunque los archivos se llamen distinto

### 1. Funciones y variables de R

`source("scripts/setup/tema.R")` con un nombre temático puede resolver la ruta y seguir definiendo la misma función que otro script. El [utils PSHA](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/setup/utils.R:7) y el [utils monitoring](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/scripts/setup/utils.R:7) definen ambos `readCaption`: PSHA colapsa las líneas a una cadena; monitoring retorna las líneas. También definen ambos `.cleanTarget`: [PSHA](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/setup/utils.R:116) elimina duplicados, mientras [monitoring](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/scripts/setup/utils.R:21) recorta espacios y conserva duplicados. No se puede escoger uno por orden de copia o carga sin cambiar algún comportamiento para ciertos inputs.

La ejecución actual de [NGR::knitBlock](/Users/averrik/Cloud/github/libraries/NGR/lib/R/knitBlock.R:23) usa `knitr::knit_global()`. Su overlay restaura las variables incluidas en `vars`, no todo lo que los scripts puedan definir o modificar (líneas 36–63). Por eso un prefijo físico no crea un entorno R aislado. Los builders examinados usan nombres temporales como `DATA`, `CAP` y `PLOT`; su reutilización secuencial puede ser deliberada, pero no equivale a aislamiento de bloques arbitrarios.

Hay un ejemplo directo de estado dependiente del orden: [PSHA setup, línea 59](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/setup/setup.R:59) establece `PALETTE = "Set1"` sólo si no existe; [monitoring setup, línea 51](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/scripts/setup/setup.R:51) hace lo mismo con `"Dark 3"`. Si se ejecutan en una misma sesión, el primero que cree ese binding condiciona al otro. Es una inferencia estática de los guards observados, no un render de ambos ejecutado.

### 2. Parámetros y propiedad de las decisiones

Los dos setups leen el `params.yml` de raíz y asignan `params`. Parte del espacio puede compartirse de forma coherente: PSHA requiere `report.sites`, monitoring requiere fecha e instrumentos. Son campos distintos, no por sí mismos una colisión.

En cambio, [PSHA params](/Users/averrik/Cloud/github/tools/psha/scaffold/params.yml:43) declara `client` y `consultant` como mappings, y [monitoring params](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/params.yml:21) los declara como cadenas. El mismo nodo no conserva ambas formas mediante una unión ciega. Las semillas prueban esa diferencia; no prueban por sí solas qué variantes acepta cada consumidor. La política del proyecto debe definir una representación común o una adaptación explícita después de leer esos consumidores, conservando la propiedad de las semillas. El nombre del archivo fuente no decide esa política.

Los selectores tampoco son todos intercambiables: [PSHA report](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/setup/report.R:87) reserva `siteID.target`, `siteID.storage` y `ReportContext`; [monitoring report](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/scripts/setup/report.R:61) reserva `holeID.target`. Mantener sus identidades evita tratar un sitio y un instrumento como la misma selección porque ambos ocupen una columna `ID` en un plot.

### 3. Labels, anchors, crossrefs y captions

La ruta `_fig/POE.qmd` contiene el label `fig-poe`; `_fig/PZ.levels.one.qmd` contiene `fig-pz-levels`. **No hay colisión entre esos dos labels observados.** La colisión aparece si se repite el mismo bloque o dos bloques declaran el mismo identificador dentro de un mismo documento, aunque los archivos tengan nombres distintos.

Existe ya un mecanismo pertinente: [knitBlock](/Users/averrik/Cloud/github/libraries/NGR/lib/R/knitBlock.R:85) reconoce y reescribe opciones de chunk `label`, `fig-label` y `tbl-label`. Rechaza duplicados reescritos y mantiene un registro de labels emitidos para el input (líneas 118–151). [PSHA sha](/Users/averrik/Cloud/github/tools/psha/scaffold/_master/sha.qmd:43) construye stems por sitio; [monitoring PZ.levels](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/_fig/PZ.levels.qmd:13) distingue todos los instrumentos de cada instrumento individual. Conviene reutilizar y caracterizar esta capacidad, no inventar otra desde cero.

Su alcance es limitado: el código no reescribe los anchors Markdown `{#...}` ni el texto de referencias `@...`. El fragmento [psha.model.md](/Users/averrik/Cloud/github/tools/psha/scaffold/_chapters/psha.model.md:21) define `eq-hazard-integral` y otras ecuaciones, y las referencia más abajo; [psha.disagg.md](/Users/averrik/Cloud/github/tools/psha/scaffold/_chapters/psha.disagg.md:4) referencia ecuaciones ajenas al fragmento. Copiar esos textos a dos rutas distintas no vuelve únicos sus IDs ni conserva automáticamente sus enlaces. Un renombrado editorial debe cubrir definición y consumidores juntos.

Los captions tienen otro lookup independiente de la carpeta del bloque: ambos `readCaption` resuelven `root/_captions/<key>.md`. POE usa `fig.POE`, y la variante ES de [PZ.levels](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/_fig/PZ.levels.ES.qmd:3) usa `fig.PZ.levels.ES`. Son nombres compatibles hoy; seguirán necesitando unicidad o un propietario común si dos temas reclaman la misma clave. Lo mismo vale para claves bibliográficas en un documento compuesto: el nombre de los archivos `.bib` no califica automáticamente sus claves. Esta auditoría no comparó las bibliografías.

### 4. Alias y destinos de artefactos

El [manifest AR-S2L1W, líneas 14–22](/Users/averrik/Cloud/github/projects/AR-S2L1W/qrt.manifest.json:14) separa `alias = report`, master `_master/book.es.qmd`, output `html/book` y destino de publicación. [AR-SAD40](/Users/averrik/Cloud/github/projects/AR-SAD40/qrt.manifest.json:4) usa también alias `report`, con master y output diferentes. Esta repetición está en proyectos distintos y no constituye por sí misma una colisión; las declaraciones muestran que alias, recurso y output son identidades diferentes.

Si se quieren **dos informes en un mismo proyecto**, compartir el nombre `report` sería una decisión ambigua de composición; si se quiere **un informe que combine dos temas**, un único alias `report` puede ser correcto, pero debe apuntar al master editorial que efectivamente los compone. Hidratar recursos no determina ese master ni autoriza concatenar entregables. Mover un master tampoco ajusta por sí solo includes, links y referencias de manifests.

## Qué aporta separar selección y builder

No es preciso que un builder conozca el capítulo que lo utiliza. El ejemplo monitoring ya lo muestra: [global.R](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/scripts/setup/global.R:32) aplica el corte de fecha y sitio; [_fig/PZ.levels.one.qmd](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/_fig/PZ.levels.one.qmd:4) selecciona instrumentos y prepara series/umbrales; el [builder PZ.levels.R](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/scripts/fig/PZ.levels.R:6) consume `DATA` y produce `PLOT`. Sus etiquetas de ejes siguen perteneciendo al dominio piezométrico: agnóstico al capítulo no significa agnóstico a significado y unidades.

En contraste, el [builder PSHA POE.R](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/fig/POE.R:2) filtra directamente `AEPTable` por targets, prepara `DATA` y construye el plot. Separar esos roles permitiría variar el slicing conservando el gráfico, pero trasladar ese filtrado sería una modificación concreta que requiere comparar observables, no una consecuencia automática de compartir `scripts/fig/`.

Para la pregunta editorial basta esta regla: un mismo bloque o builder se comparte cuando significado, inputs y resultado coinciden; dos piezas distintas pueden convivir en la misma carpeta con nombres distintos. La equivalencia no se prueba porque tengan un nombre igual, porque llamen ambas a `buildPlot` o porque ambas sean figuras.

## Alternativas y compromisos

| Alternativa | Ventaja | Coste o límite observado |
|---|---|---|
| Carpetas compartidas y nombres de dominio | Includes legibles; composición directa; permite reutilizar una pieza real. PSHA/monitoring ya no chocan en los tres subárboles editoriales comparados. | Requiere resolver las piezas de setup que compiten por una ruta, más los espacios semánticos anteriores. |
| Namespace físico obligatorio por scaffold | Resuelve gran parte de las colisiones de ruta de entrada; procedencia visual inmediata. | No resuelve funciones, globals, IDs del documento ni outputs. Cambiar rutas exige cambiar consumidores; puede duplicar helpers realmente comunes. El plan vigente no lo impone. |
| Calificación selectiva de piezas incompatibles, con un dueño para lo verdaderamente común | Conserva nombres útiles existentes y concentra el trabajo donde hay conflictos demostrados. | Exige definir qué es común por contrato. No se pueden fusionar hoy las dos `utils.R` por nombre o hash, ni elegir un `params.yml` por orden. |
| Documentos separados que comparten recursos | Evita mezclar la narrativa y los IDs de documentos distintos; cada master declara su producto. | No crea un libro combinado. El aislamiento de sesión del runner debe comprobarse; también necesita alias/output distintos dentro del manifest del proyecto. |

Recomiendo la tercera como forma de concretar la primera, usando PSHA y monitoring como caso de contraste. Para futuros blasting/SSEL, exigir la misma lectura desde sus masters cuando se seleccionen sus fuentes; no asignarles conflictos ficticios ni declarar compatibilidad por sus nombres.

Antes de afirmar que un proyecto compuesto funciona, las comprobaciones competentes serían: preflight de destinos de todas las fuentes implicadas; lectura de la clausura de los masters seleccionados; validación de formas de parámetros y contratos de setup; unicidad de IDs/referencias en el documento compuesto; y render de esos artefactos en un destino de prueba seleccionado. Esta lista identifica lo que falta demostrar, no constituye una implementación ni autorización de efectos.

## Identidad y límites de la evidencia

HEAD observados: PSHA `1bb0769ff59804802bfb6ec05cad570b7684f731`; reports `54dd9ffec899fb46412745f174fdabbad74c563c`; NGR `3b1493d609f90970752851c6fea582189538dac6`. Los hashes siguientes identifican los archivos de trabajo leídos y no implican que el árbol esté limpio.

| Archivo | SHA-256 |
|---|---|
| PSHA `_master/book.en.qmd` | `a435d3157d4d52655c3511a09ad94589994f5f6187b3a20a08039431bb2debe1` |
| PSHA `_book/psha.qmd` | `005c5229de2572a8936a8b04ce00517f0ff52b9ce56df0f10acc3bc9b9dc0ca2` |
| PSHA `scripts/setup/setup.R` | `c16878e3c5b7c55dd7bb138e58a13e82ebc8e432f0b490880176ddb7818acd8d` |
| Monitoring `_master/report.es.qmd` | `c5a542b0c9fde27b0579d115f86b64d6402bc902fd8b52fb87180ec3768bd13a` |
| Monitoring `_index/piezometers.ES.qmd` | `d12367230d1ca352917f21423d6e03229d2e656288ea887eebec49e07a3d6cbd` |
| Monitoring `scripts/setup/setup.R` | `5f3860ab80309c5d69e8e884faef360fea380fe148a179bc3c7e0de3dfdd51a4` |
| NGR `lib/R/knitBlock.R` | `3de4e7f36078fd66d27f3dcce47979f72f2afefd1dfe73b004c3fbd6e197971c` |

No se ejecutaron builders, librerías fuente, renders, copias, instalaciones ni publicaciones. La comparación de rutas/hashes fue una observación local de lectura; el análisis de R fue estático. No se certifica el resultado de combinar ambos scaffolds ni la ausencia de otras colisiones fuera de los subárboles y cadenas explicitados.
