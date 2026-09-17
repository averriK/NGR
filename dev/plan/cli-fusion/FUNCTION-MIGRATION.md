# Migración de operaciones y builders a NGR

2026-09-17. Plan actualizado con recursos, render individual/lotes, Netlify,
main.R y la familia UHS/MCE. Estado actual e identidades en
[CLOSURE.md](CLOSURE.md); evolución de las pruebas en LOCAL-VALIDATION.md.
Responde a la instrucción del propietario verificada en gmsp01, mensaje
`01a0ab3a-bfd2-7000-a588-737e86e18475`, y al contraste con el orquestador
`Planificar fusión psha y qrt`. Se aplicaron `code` y sus veinte tarjetas,
las reglas R/Bash/Python y el criterio de admisión de `sot`.

## Resultado de la revisión

La CLI consume una parte de la API de NGR. No necesita consumir toda la
biblioteca. El objetivo es que las operaciones reutilizables que ofrece la
CLI sean proporcionadas por la biblioteca instalada, conservando en la CLI
argumentos, ayuda, entrada/salida y traducción de errores a códigos de salida.

La frontera de comandos está implementada: YAML, procedencia, recursos, render
individual/lotes y publicación pertenecen a la biblioteca. La migración de
builders está aceptada para UHS/MCE y sigue abierta para las familias restantes.
El mapa de main.R y las operaciones está en
[CLI-LIBRARY.md](CLI-LIBRARY.md). No se interpreta una prueba funcional
satisfactoria como prueba de esta frontera arquitectónica.

La dependencia buscada es:

```text
ngr instalado -> API de NGR instalado -> implementaciones y herramientas externas
scaffold      -> API de representación NGR(datos preparados, opciones explícitas)
proyecto      -> API científica de su productor -> datos que consume el scaffold
```

NGR no llama de vuelta a `ngr`, `qrt` o `psha`. Los ejemplos operativos y las
pruebas de usuario entran por la CLI instalada; las llamadas R directas se
reservan para consumidores R legítimos y comprobaciones de la API.

## Qué existe y qué se reutiliza

Lecturas de código, contratos y consumidores realizadas en esta revisión:

| Superficie leída | Responsabilidad observada | Decisión |
| --- | --- | --- |
| [launcher](../../../cli/bin/ngr) y [Windows](../../../cli/bin/ngr.cmd) | Entran únicamente por cli/main.R | Despacho y operaciones en NGR instalado |
| [main.R](../../../cli/main.R) | Frontera de proceso, namespace y códigos de salida | Único archivo R de runtime; checkRuntime pasó a install/cli |
| [quartoYaml.R](../../../lib/R/quartoYaml.R) | Frontmatter, composición de libros, perfil DOCX y serialización YAML | Reutilizar las APIs existentes, sin una segunda lógica de merge |
| [quartoRenderStamp.R](../../../lib/R/quartoRenderStamp.R) | Procedencia por archivo y marca Pub/Rev/DRAFT | Reutilizar; extracción focalizada ya comprobada, con límites en LOCAL-VALIDATION |
| [resources.R](../../../lib/R/resources.R) | Asociaciones, selección, identidad, claims, copias, comparación y checks | Tres operaciones públicas; helpers de invariantes internos. Python preservado sólo como referencia SoT |
| [quartoRenderManifest.R](../../../lib/R/quartoRenderManifest.R) | Preflight de lote, orden, ejecución y comprobación de salidas | Sustituye Bash; productos externos conservados sin ejecutar sus productores |
| [quartoRender.R](../../../lib/R/quartoRender.R) | Render individual, staging, Quarto, copia de salida y DOCX | API instalada; reutiliza composición YAML y firma existentes |
| [fix_docx.py, líneas 277–339](../../../lib/inst/docx/fix_docx.py#L277) | Reparación de OOXML y sustitución del archivo DOCX | Recurso privado del paquete, byte idéntico al original; sin exports por transformación XML |
| [netlify.R](../../../lib/R/netlify.R) | Sitios, asociaciones, upload, dominio/TLS y diagnóstico DNS | Cuatro operaciones públicas; proveedor simulado comparado con Bash preservado |
| [buildPlot](../../../lib/man/buildPlot.Rd), [buildTable](../../../lib/man/buildTable.Rd), [knitBlock](../../../lib/man/knitBlock.Rd) | Representación de datos y composición de bloques | Reutilizar; no crear builders que sólo reenvían estos argumentos |

Dos sustituciones aparentemente plausibles no son equivalentes:

- [buildYAML.R:21](../../../lib/R/buildYAML.R#L21) descubre archivos por nombres y
  lenguaje; busca recursos de `smartReports` en la línea 328, recrea
  `publish_dir` en la 364 y tiene limpieza de archivos por extensión en su
  ruta de error. No reproduce el render en copia temporal ni su contrato de
  preservación. No se invocó ni modificó como parte de esta revisión.
- [export.R:18](../../../lib/R/export.R#L18) exporta un widget mediante
  HTML/webshot a imagen. No proporciona publicación Netlify.

### Naming y organización

`buildPlot` conserva parámetros públicos históricos con puntos; los helpers
Quarto forman una familia pública existente. No se renombra ninguna de esas
interfaces al migrar otra operación. Los nombres nuevos R siguen lowerCamelCase
y los internos llevan un punto inicial; Python y Bash siguen sus skills.
`fix_docx.py` y los adaptadores heredados tienen nombres distintos de esas
reglas: la migración revisará sus llamadores antes de cualquier cambio, no
aplicará un renombrado global como tarea adicional.

Las funciones nuevas viven en `lib/R/`; recursos ejecutables internos que se
conserven se distribuyen desde `lib/inst/` y se resuelven desde el paquete
instalado. `cli/` conserva launchers, main.R y recursos de distribución.
La política común sitúa toda la instalación y el mantenimiento en `install/`.
Los datos de un libro siguen en su fuente, con manifest propio.
No se necesita una biblioteca adicional ni una carpeta destino por scaffold.

## Primera operación: composición de recursos

Primer tramo implementado: tiene contrato aprobado, un límite de efectos
observable y comprobaciones existentes; no depende de datos MCE, Quarto ni
Netlify. Las tres funciones se exportan desde NGR:

```r
pullResources(from = NULL, source = NULL, paths = character(),
              root = getwd(), force = FALSE, dryRun = FALSE)
compareResources(from = NULL, source = NULL, paths = character(),
                 root = getwd())
checkResources(source = NULL, root = getwd())
```

| Entrada | Contrato que justifica su presencia |
| --- | --- |
| `root` | CWD por omisión, como la CLI aprobada; un consumidor R puede pasar una raíz explícita |
| `from` | Rutas de manifests fuente explícitos; `NULL` utiliza asociaciones existentes |
| `source` | Identidades registradas; `NULL` selecciona las aplicables; incompatible con `from` no vacío |
| `paths` | Rutas destino o prefijos; sin selección nueva se conserva la selección incorporada. Con `from` y selección vacía se incorpora toda esa fuente |
| `force` | Permiso explícito para reemplazar archivos administrados diferentes; nunca semillas ni incompatibilidades entre fuentes |
| `dryRun` | Mismo plan y mismos rechazos, sin escritura; no rebaja el permiso de reemplazo |

La abreviatura CLI `--from ngr` se resuelve a la ruta del manifest base
distribuido y se pasa como `from`. La API recibe una fuente ordinaria; no
necesita la instalación CLI para trabajar con otra fuente. Esto evita trasladar
todos los recursos estáticos al paquete sólo para resolver una abreviatura.

`pullResources` posee la operación completa: carga, selección, preflight de
todas las contribuciones implicadas, copia y actualización del manifest.
Devuelve las acciones por fuente/ruta y el manifest resultante; la CLI imprime
el resultado. La planificación y aplicación son helpers internos, no una API
pública que permita aplicar un plan obsoleto o saltarse validaciones.

`compareResources` devuelve filas de fuente/ruta/estado/modificación local y
un indicador de diferencias. La biblioteca decide qué constituye una
diferencia; la CLI traduce `--check` y ese resultado a exit 1. No cambia
asociaciones, recursos ni recibos.

`checkResources` valida claims y ejecuta los argv declarados por las fuentes
registradas, en la raíz explícita. Es una operación con efectos potenciales
de terceros, no una consulta pura. No interpreta reglas PSHA ni inventa checks.
La compatibilidad entre versión CLI y exports de NGR se verifica al instalar;
no se llama a un script de la CLI desde la biblioteca.

Errores de ruta, esquema, identidad, colisión y escritura conservan su causa.
La API R señaliza condiciones; no oculta fallos mediante un resultado vacío.
El nombre aprobado es `manifest.json`, tanto en la fuente como en el proyecto;
la migración de productores y consumidores se comprobó en manifest-20260917.
Se conservan los hashes, la procedencia parcial, las semillas, los extras y las
raíces protegidas. No hay lectura automática del nombre legado ni doble escritura.
Un campo sin lectura local puede participar en serialización, firmas o consumo
externo: comprobar esas relaciones antes de proponer su retirada. La ausencia
de efecto directo no demuestra ausencia de contrato.
La recuperación actual cubre fallos ordinarios de escritura; no se promete
atomicidad frente a interrupciones del proceso o escritores concurrentes.

### Alternativas de implementación

| Alternativa | Ventaja | Coste o problema | Propuesta |
| --- | --- | --- | --- |
| Dejar el motor en CLI y llamarlo desde R | Cambio pequeño | La biblioteca dependería de su consumidor; las reglas seguirían fuera de ella | Descartada para esta frontera |
| Implementar composición de recursos en R dentro de NGR | Una API y una implementación de sus reglas; evita transporte R/Python para trabajar con archivos y manifests | Comprobar rutas, hashes y recuperación contra el motor preservado | Implementada; comparación acotada en LOCAL-VALIDATION |
| Conservar el motor Python como implementación privada tras una API R | Reduce el cambio inicial de algoritmos caracterizados | Añade transporte y dos lenguajes sin una biblioteca externa Python que esta operación necesite | No adoptarla por conservar la implementación del prototipo |
| Crear otro paquete público de motores | Permitiría consumidores Python independientes | No hay consumidor observado que lo exija; añade distribución y versiones | No introducirlo |

El propietario cuestionó la elección de Python para recursos e instalación.
La lectura confirmó que `resources.py` usa sólo biblioteca estándar y fue añadido
al prototipo; no procede de una integración QRT/OpenQuake. Por ello se retira
la preferencia anterior por un motor Python privado. La recomendación es R para
las reglas de composición y sus efectos sobre el proyecto, con la CLI traduciendo
argumentos y resultados. No dividir una misma copia/recuperación entre CLI Bash
y biblioteca R: quien posee la operación conserva sus invariantes y limpieza.

La API funciona sin runtime CLI ni checkout. JSON, SHA-256 y casefold usan
jsonlite, digest y stringi, ahora declarados en Imports. No se implementaron
parsers ni algoritmos criptográficos propios. La referencia exacta, paquete
instalado y comparaciones están bajo resources-api-20260916. No se reescriben
otras operaciones en el mismo candidato.

### Instalación de la CLI

La política posterior del propietario está en
[install/README.md](../../../install/README.md). `install/` concentra instalación
de componentes, biblioteca/dependencias y herramientas de documentación,
build/check y CRAN. Las entradas son install.sh para macOS/Linux e install.ps1
para Windows, dentro de esa carpeta. El coordinador integró esas herramientas;
el backend CLI único reside en install/cli. El runtime nunca instala
dependencias al operar. El instalador CLI actual sólo comprueba NGR; la entrada
común puede coordinar instalación R y CLI como efectos separados.
Conservar recibos, preflight, propiedad y recuperación durante la migración.
Una prueba macOS no acredita funcionamiento Windows.

## Render, DOCX y publicación

Después de recursos, cada tramo conserva una responsabilidad completa:

1. **Render individual implementado: quartoRender.** Entrada QMD, perfil explícito, raíz y opciones Quarto;
   posee copia temporal, limpieza, configuración, ejecución y entrega de salida.
   Llama directamente a los helpers YAML y de procedencia existentes. Devuelve
   las salidas producidas. La copia actual del destino HTML no es atómica;
   la extracción no debe anunciar rollback inexistente.
2. **Render de manifest implementado: quartoRenderManifest.** Posee selección, preflight global de destinos,
   requisitos declarados y orden. Reutiliza el render individual. Los estáticos
   se conservan como artefactos sin productor. La generación de mapas no forma
   parte del uso QRT declarado por el propietario y no es un requisito de esta
   migración. La presencia de esa rama en el código no acredita su aceptación.
3. **Corrección DOCX integrada en render.** Recibe el archivo y comunica el
   recuento de correcciones; protege las partes OOXML ajenas. Las transformaciones
   conservan su implementación Python por decisión explícita del propietario.
   Ubicación implementada: `lib/inst/docx/fix_docx.py`, resuelta desde NGR instalado
   por la operación R de documentos. La CLI no conserva otra copia del algoritmo.
   La selección por
   `QUARTO_PROJECT_OUTPUT_FILES` pertenece a la entrada de proceso, no al algoritmo.
4. **Publicación implementada: netlifyRegister/Deploy/Domain/Unbind.** Registro/asociación, upload, configuración de dominio y
   retirada de alias son operaciones con efectos diferentes y ya tienen
   consumidores CLI. Cada operación es responsable de preflight de la selección
   antes de sus efectos; reutilizan lectura de manifest e identidad de sitio.
   El transporte sigue usando Netlify CLI. No se crea un cliente HTTP adicional.
   Draft sigue siendo la omisión; crear sitio, producción y rebind conservan
   sus permisos explícitos. Unbind sólo retira la asociación local.

La API individual es `quartoRender(input, profile, root = getwd(), output = NULL,
args = character(), manifest = "manifest.json")`; devuelve invisiblemente
las rutas entregadas. Las firmas de lote/publicación están documentadas en los
manuales del paquete y los llamadores CLI ya migraron. No hace falta exportar cada helper Bash ni un
orquestador universal. El lote sí justifica una frontera por sus reglas
compartidas. Un fallo posterior puede dejar renders o efectos remotos anteriores;
el resultado y el diagnóstico deben conservar esa información.

### Corrección del alcance de mapas

El propietario corrigió explícitamente: «nunca renderizamos mapas desde qrt».
La explicación anterior confundía una rama observada en el código con el flujo
del propietario. Se retira su atribución como uso histórico o contrato aceptado.

La rama leída en `bin/qrt:682–753` y reproducida en el prototipo es un hecho de
implementación; su existencia y una prueba sintética no bastan para admitirla
como referencia SoT del comportamiento requerido. No se migrará como requisito
de la biblioteca NGR. La cobertura de mapas se refiere a los productos externos
que un informe o una publicación consume, no a ejecutar su generador desde NGR.
No se modificaron ni retiraron ejecutables durante esta corrección documental.

## Builders: representación frente a selección científica

Familia UHS/MCE integrada el 2026-09-17:
`NGR::buildSpectrumPlot(data, logScale, fill, fillSize)` proporciona la política
visual y reutiliza `buildPlot` sin modificarlo. `reports/sha` conserva la
selección/preparación en `scripts/setup/prepareUHS.R`; UHS.TR, UHS.sites,
UHS.one y MCE.UHS llaman la API instalada. MCETable real permitió aceptar los
dos consumidores restantes y retirar UHS.R del scaffold candidato. PSHA original
permanece intacto. No se declara migrado el conjunto de builders del scaffold.

Evidencia: [revisión SoT](../../SoT/cli-fusion/uhs-builder-20260916/REVIEW.md),
`candidate.json`, 10 comparaciones de datos/widget y rechazo de duplicados,
14 aserciones en macOS y Windows 11, tres bloques renderizados por ngr con
widgets/captions/IDs iguales y cotejo del setup integrado. El tar aislado es
SHA-256 `a11ee5e9aa26f4fe43af90beb7fe8ac94e83b2d4589f400eda6c94419a13cbcd`.
La rama MCE tiene comparación propia en
[mce-builder-20260917/REVIEW.md](../../SoT/cli-fusion/mce-builder-20260917/REVIEW.md).
La documentación y el check del paquete sucesor están aprobados con la identidad
exacta de CLOSURE.md; esto no acredita todos los masters.

La lectura posterior recorrió los 37 masters y sus dependencias efectivas.
CLOSURE.md distingue las comparaciones aprobadas de los masters pendientes;
la corrida CFD de AR-M2V4D permitió comparar las once presentaciones SRS,
con 77 widgets idénticos y equivalencia CSS de IPSA comprobada en navegador.
Evidencia en srs-20260917/result.json y REVIEW.md. Los builders SRS todavía
permanecen en el scaffold; la comparación prepara su extracción, no la sustituye.
Las tablas de dinámica/Newmark siguen ausentes; los hubs no sustituyen sus productos.

| Cadena leída | Reutilización real | Trabajo pendiente y frontera |
| --- | --- | --- |
| `sha.qmd` → bloques UHS/MCE | Los bloques usan `buildSpectrumPlot`; preparación explícita en scaffold | API y consumidores comparados; conservar tablas OQT y elección de escenario fuera de NGR |
| `srs.at.qmd` → bloque AT → [TS.R](../../../../../reports/sha/scripts/fig/TS.R) | Ya llama a `buildPlot`, con segundos numéricos | Reutilizar el gráfico XY. `buildPlot.Time` requiere Date/POSIXct y representa calendario; no es sustitución válida por compartir la palabra tiempo |
| [kh.R](../../../../../reports/sha/scripts/fig/kh.R) | Ya llama a `buildPlot`, con bandas y estilos | Selecciona kmax, une alturas, calcula Da/H y aplica límite 10 %. Revisar esos contratos con el productor antes de extraerlos; no tratarlos como mero dibujo |
| [buildSectionResultantsPlot](../../../lib/man/buildSectionResultantsPlot.Rd) | Recibe curvas y rayos preparados | Ejemplo existente de frontera: NGR dibuja, el consumidor decide resultantes, signos, ángulos y transformación a coordenadas |

No se propone una función NGR por nombre de script. Primero se reutiliza la
API de dibujo existente. Una nueva función visual sólo se justifica si concentra
una política de representación repetida y coherente, con datos, unidades,
etiquetas y retorno explícitos. Los slices de proyecto y el cálculo científico
conservan sus propietarios; una transformación científica compartida requiere
coordinar la API del productor correspondiente.

El cambio de `source()` a funciones se hace sobre esa separación: una función
devuelve el widget, no busca `ID.target`, `TR.target`, `PLOT` o datos en el
entorno global. Captions, orden de capítulos y selección editorial siguen en
los bloques. Se reutiliza `knitBlock` para composición y etiquetas.

Los folders `_chapters/`, `_fig/` y `_tbl/` pueden seguir compartidos. Los nombres
de contenido diferenciado reducen choques, pero no prueban ausencia de colisiones.
Los manifests y los claims por ruta deciden compatibilidad antes de copiar.
Extraer un builder compartido elimina su doble mantenimiento; no elimina las
colisiones posibles entre figuras, capítulos o recursos restantes.

### Necesidad concreta de gmsp: grilla y visibilidad

El orquestador transmitió este consumidor durante la revisión. Se leyeron
[projectPlot.R:27–67](../../../../gmsp/lib/R/projectPlot.R#L27), sus familias
TS/PS y TSI/PSI, y [runMatch.R:420–475](../../../../gmsp/lib/R/runMatch.R#L420).
Comparten la misma grilla: mayor 0.3 / `#e8e8e8`, menor 0.15 / `#f3f3f3` en ambos
ejes. TS/PS y el QA de match empiezan ocultos; TSI/PSI permanecen visibles.
El consumidor también guarda HTML autocontenido y retira su directorio auxiliar.

La primera hipótesis es configuración pública existente, sin ampliar NGR:
combinar el tema 538 con esos valores y `plotOptions.series.visible`, y pasarlo
por `plot.theme`. [hc_theme_merge](https://jkunst.com/highcharter/reference/hc_theme_merge.html)
combina temas, y [Highcharts documenta la visibilidad inicial](https://api.highcharts.com/highcharts/plotOptions.series.visible).
El código leído de `buildPlot` aplica `hc_add_theme` en 671–675 y no fija
`visible` al crear líneas en 866–881. En el highcharter instalado,
`hc_add_theme` guarda el tema por separado; `htmlwidgets/highchart.js:41–76`
aplica tema, configuración y opciones del chart en ese orden. Por tanto no
basta comparar la posición de una clave en `hc_opts`: hay que observar las
opciones efectivas del gráfico y su comportamiento de leyenda.

Esto es una hipótesis sustentada por código, **no equivalencia ejecutada**.
Antes de retirar escrituras sobre `hc_opts`, gmsp debe fijar la identidad
instalada de NGR/highcharter y comparar su oracle plot/match: grillas,
visibilidad inicial y alternada, leyenda, datos, ejes y productos QA. El guardado
mediante `plot.save/plot.filename` se evaluará aparte por su ciclo de archivos;
la firma equivalente no demuestra la misma limpieza de auxiliares. NGR no
recibe selección RecordID/IMF, unidades, medias o targets científicos.

## Secuencia y aceptación

1. **Recursos admitidos bajo SoT.** Referencia exacta y candidato identificados
   en resources-api-20260916. Baseline: API ausente. Candidato: API instalada
   independiente y CLI delegando; sin recopia global.
2. **Recursos comprobados.** candidate-4.log registra 15 pruebas aprobadas con
   seeds, selección parcial, fuentes no seleccionadas, colisiones/casefold,
   rutas/symlinks, hashes, retirados y recuperación. La inyección de fallo es
   interna R; la comparación con referencia y la operación del candidato pasan
   por ngr instalado. No se añadió un flag de fallo al producto.
3. **Tramo integrado.** API invocable sin CLI ni source del checkout, comparación
   con referencia y ejecución fuera del checkout. Los 402 archivos del runtime
   común coinciden con fuente/recibo/candidato aceptado. Identidad y límites en
   LOCAL-VALIDATION.md; no repetir ese tramo sin cambio material.
4. **Render individual/DOCX, lote, publicación y main.R implementados.** Pruebas
   por operación en macOS/Windows, con identidades en LOCAL-VALIDATION. HTML,
   libros, RevealJS, DOCX simple/compuesto y productos externos; excluir generación de
   mapas de la aceptación requerida. Publicación local simulada y publicación real
   son aceptaciones distintas; la segunda espera destinos autorizados.
5. **Migrar consumidores de builders por familia.** Comparar datos preparados,
   series, orden, etiquetas, unidades, estilos y widget; confirmar que la entrada
   no se modifica. Después renderizar por CLI instalada. No usar la selección
   UHS probabilística como evidencia de la rama MCE.
6. **Aceptar todos los masters y consumidores.**
   Recorrer cada master a sus bloques efectivos y entradas; registrar lo
   ejecutado, lo no disponible y los efectos. El primer deck no cubre los libros.
   QRT/PSHA se conservan instalados sin mantenimiento. El propietario decidirá
   su desinstalación futura; la aceptación no ejecuta una retirada automática.

La comparación completa de AR-M2V4D/sha ya pasó con MCETable real, conservada
con sus entradas. La corrida CFD de gmsp ya está disponible y congelada para
los once masters SRS en `srs-20260917`. Sigue abierta la consulta sobre
Shear/Dn/kmax, que limita dinámica/Newmark y los informes completos.

El tar final, documentación, entrada común de instalación en macOS/Windows y
check están identificados en [CLOSURE.md](CLOSURE.md). La NOTE restante es
«New submission»; no hubo envío CRAN. No se declara la sustitución completa,
publicación remota ni reinstalación personal.

Este plan no modifica la suite común `install/`, instalaciones personales, código científico,
Git o servicios remotos. Las extracciones futuras de `lib/` se coordinan con
el orquestador sobre una identidad de paquete fija por comparación.
