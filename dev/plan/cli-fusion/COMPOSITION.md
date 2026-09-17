# Composición de scaffolds: carpetas, builders y propiedad

2026-09-16. Propuesta de arquitectura para discusión con el propietario. No es un contrato aprobado de CLI ni una aceptación SoT.

Lectura vigente: [PLAN.md](PLAN.md) y [CONTRACT.md](CONTRACT.md) sustituyen las
decisiones pendientes de verbos de esta investigación. Para operaciones de
biblioteca y builders, consultar [FUNCTION-MIGRATION.md](FUNCTION-MIGRATION.md).
La corrección posterior del propietario excluye generación de mapas del requisito.

## Conclusión

**Compartir `_chapters/`, `_fig/`, `_tbl/` y `scripts/fig/` es viable y útil. Los builders deben identificarse por su cometido, no por el capítulo que los llama.** Si dos usos sólo cambian la selección de datos y mantienen significado, unidades y representación, la primera opción es un mismo builder con contexto de invocación explícito.

La dificultad no está en la carpeta compartida por sí misma. Está en distinguir recursos diferentes, recursos comunes y recursos que parecen comunes pero responden a contratos incompatibles. Recomiendo carpetas compartidas, un responsable de mantenimiento para cada recurso verdaderamente común y calificación selectiva de piezas distintas. La materialización y procedencia se declaran en manifests; no se deducen del orden de copia.

Esto separa cuatro decisiones que la propuesta anterior confundía:

1. **Ubicación:** dónde queda cada archivo en el proyecto.
2. **Ejecución:** qué variables, funciones, configuración y efectos comparte con otros bloques.
3. **Propiedad y revisión:** quién mantiene el recurso y qué consumidores admiten esa revisión.
4. **Composición editorial:** qué master reúne qué bloques en un documento concreto.

Una carpeta por scaffold sólo actúa directamente sobre la primera. Un manifest describe relaciones, pero no vuelve compatibles scripts incompatibles.

## Evidencia y alcance

Se realizaron tres análisis independientes, integrados con lecturas locales del coordinador:

- [Builders y selección de datos](/Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-fusion/research/builders/REPORT.md): cadenas UHS, TS/SRS y Resultants, dependencias y alternativas.
- [Nombres y composición editorial](/Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-fusion/research/editorial/REPORT.md): PSHA frente a monitoring, rutas, setup, parámetros y referencias.
- [Alternativas y actualizaciones](/Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-fusion/research/alternatives/REPORT.md): propiedad compartida, revisiones y casos adversariales.

Se aplicaron los skills instalados code y sus veinte tarjetas, r, y datatable para la lectura de selecciones. La evidencia es estática más comparaciones locales de rutas/hashes. No se ejecutó un render combinado ni se certificó la equivalencia de productos. No se modificó implementación, lib/, instalaciones ni consumidores.

Blasting y SSEL son los escenarios planteados por el propietario. No se verificó una cadena editorial completa de esos scaffolds. Monitoring es un segundo tema real observado, no un sustituto que se declare equivalente a ellos. AR-SAD40 aporta un consumidor real no PSHA; tampoco se lo identifica con SSEL.

### La hipótesis de nombres diferenciados tiene sustento

La comparación exacta de rutas relativas entre los subárboles de PSHA y monitoring produjo:

| Subárbol | Rutas de archivo coincidentes |
|---|---:|
| `_chapters/` | 0 |
| `_fig/` | 0 |
| `_master/` | 0 |
| `scripts/` | 4 |

Las cuatro son `scripts/setup/global.R`, `report.R`, `setup.R` y `utils.R`, todas con hashes distintos. La comparación está documentada en el informe editorial y los ocho MD5 fueron reobservados por el coordinador. Los masters y bloques leídos requieren esos setups: no son archivos sin consumidores encontrados en un listado.

La conclusión está acotada a esos subárboles y a igualdad exacta de ruta. No demuestra ausencia de conflictos en scaffolds completos: `params.yml`, índices de raíz, recursos estáticos y otros destinos quedan fuera de esa tabla; el preflight futuro debe considerar también la equivalencia de rutas del filesystem de destino.

## Qué significa compartir un builder

### Mismo gráfico, distinta selección

PSHA ya lo hace. [_fig/DEQ.operation.qmd](/Users/averrik/Cloud/github/tools/psha/scaffold/_fig/DEQ.operation.qmd:43) y [_fig/DEQ.closure.qmd](/Users/averrik/Cloud/github/tools/psha/scaffold/_fig/DEQ.closure.qmd:42) invocan el mismo [scripts/fig/DEQ.R](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/fig/DEQ.R:18). Cambian el contexto de etapa; el builder no necesita conocer el capítulo llamante.

Pero ese builder también contiene una regla científica: selecciona `p = 0.84` para ANCOLD, Closure y Extreme, y `mean` en los demás casos observados (líneas 22–27). Extraer mecánicamente todo el slicing hacia cada capítulo duplicaría esa regla. Hay que separar la elección del caso —qué etapa mostrar— de la política científica que determina cómo se interpreta.

Monitoring muestra otra organización ya existente: [PZ.levels.one.qmd](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/_fig/PZ.levels.one.qmd:7) selecciona instrumentos y prepara series; [PZ.levels.R](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/scripts/fig/PZ.levels.R:6) representa `DATA`. El [setup global](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/scripts/setup/global.R:32) aplica el corte por fecha/sitio. Son decisiones distintas distribuidas en lugares distintos, no una regla universal de que todo filtro deba estar fuera del builder.

Para blasting, PSHA y SSEL, si se confirma el supuesto «misma representación, distinto subconjunto», mantendría un builder común. El bloque prepara o declara su selección; el builder conserva el algoritmo de representación y las invariantes que todos sus consumidores deben respetar. No crearía un builder por capítulo.

### Parecido visual con significado diferente

UHS representa aceleración espectral frente a período; PZ.levels representa niveles de agua frente a tiempo. Ambos pueden terminar en columnas `ID/X/Y` y llamar al motor genérico [buildPlot](/Users/averrik/Cloud/github/libraries/NGR/lib/R/buildPlot.R:150). Eso permite compartir el motor, pero no demuestra que deban fundirse sus builders de dominio: cambian unidades, escalas, selección, leyenda y significado científico.

La frontera práctica es:

| Diferencia entre usos | Primera opción a evaluar | Coste que evita o conserva |
|---|---|---|
| Sólo targets/subconjunto; mismo significado y resultado | Mismo builder y contexto por invocación | Evita copias que divergen por capítulo. |
| Preparación distinta, contrato de representación realmente igual | Preparación de cada dominio y representación común | Conserva las diferencias donde se conocen sus datos. |
| Reglas científicas, unidades o efectos incompatibles | Builders de dominio distintos, reutilizando motor si corresponde | Evita un builder universal lleno de condiciones por tema. |
| Versiones incompatibles de un recurso requerido | Revisiones compatibles comprobadas o separación deliberada | No oculta una incompatibilidad mediante un nombre nuevo. |

Los selectores deben representar casos reales. No propongo añadir un parámetro que identifique el capítulo ni trasladar todos los scripts a lib/. Cualquier extracción de API de paquete requerirá necesidad demostrada, identidad estable y coordinación con el agente de librerías.

## Lo que nombres diferentes no aíslan

### Funciones, variables y configuración

Los dos `utils.R` definen `readCaption`, pero [PSHA](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/setup/utils.R:7) colapsa las líneas a una cadena y [monitoring](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/scripts/setup/utils.R:7) devuelve el vector de líneas. También difieren sus `.cleanTarget`: PSHA elimina duplicados sin recortar espacios; monitoring recorta espacios sin eliminar duplicados. Renombrar sólo los archivos no cambia los nombres definidos al ejecutarlos.

Existe además una dependencia de orden inferible del código: [PSHA setup](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/setup/setup.R:59) crea `PALETTE = "Set1"` si no existe; [monitoring setup](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/scripts/setup/setup.R:51) hace lo mismo con `"Dark 3"`. En una misma sesión, el primero que cree ese binding condiciona al siguiente. Es una inferencia estática, no un fallo observado en un render conjunto.

El [knitBlock actual](/Users/averrik/Cloud/github/libraries/NGR/lib/R/knitBlock.R:23) ejecuta el child en `knitr::knit_global()` y restaura los bindings declarados en `vars`. Es útil para targets por llamada, pero no garantiza restaurar todas las funciones, opciones o mutaciones por referencia que un script efectúe. No hay motivo para prohibir nombres temporales como `DATA` o `PLOT`; sí hay que comprobar su ámbito y vida útil.

Esto concuerda con las interfaces documentadas: [R source](https://stat.ethz.ch/R-manual/R-devel/library/base/html/source.html) permite elegir el entorno y usa el global por omisión; una carpeta no determina ese entorno. Un error durante la ejecución tampoco revierte automáticamente las asignaciones anteriores.

### Parámetros

Ambos setups leen el `params.yml` raíz. Campos distintos de PSHA y monitoring podrían coexistir. Sin embargo, las semillas de [PSHA](/Users/averrik/Cloud/github/tools/psha/scaffold/params.yml:43) presentan `client` y `consultant` como mappings y las de [monitoring](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/params.yml:21) como cadenas. Esa diferencia de forma está comprobada; todavía no se certificó qué variantes admite cada consumidor.

Es un caso concreto para comprobar consumidores y decidir si la representación existente basta o hace falta adaptación. El proyecto conserva la propiedad de sus valores y semillas; incorporar otro scaffold no autoriza reemplazarlos por los valores de ejemplo de esa fuente.

### Identificadores editoriales

Nombres de archivo diferentes no califican automáticamente labels, ecuaciones, anchors, captions ni referencias bibliográficas. Quarto trata los [includes](https://quarto.org/docs/authoring/includes.html) como contenido integrado en el documento; sus [cross-references](https://quarto.org/docs/authoring/cross-references.html) usan identificadores propios.

NGR ya tiene una capacidad aprovechable: [knitBlock](/Users/averrik/Cloud/github/libraries/NGR/lib/R/knitBlock.R:85) reescribe opciones `label`, `fig-label` y `tbl-label`, y registra duplicados. No reescribe todos los anchors Markdown ni las referencias `@...`. Repetir un bloque exige comprobar las definiciones y sus consumidores, no sólo cambiar el nombre del archivo.

La comprobación debe seguir la composición alcanzable desde el master. El mismo label en dos documentos independientes no equivale a duplicarlo en un único documento. Tampoco un mismo alias `report` en dos proyectos constituye un conflicto; dos artefactos seleccionables en un mismo manifest sí necesitan identidad inequívoca y outputs no solapados. QRT ya comprueba destinos del manifest completo en [el ejecutable instalado](/usr/local/libexec/qrt/bin/qrt:326).

## Alternativas comparadas

| Alternativa | Ventajas | Desventajas | Cuándo tiene sentido |
|---|---|---|---|
| Fusionar árboles, conservando copias independientes de lo común | Migración pequeña; cada fuente puede distribuirse sola; rutas cortas. | Dos mantenedores pueden actualizar el mismo destino; deduplicar bytes no establece compatibilidad futura; setup y parámetros pueden competir. | Punto de partida acotado, con preflight estricto y sin arbitraje por orden. |
| Subcarpetas por scaffold para todo | Procedencia visible; versiones físicas distintas; menos colisiones de entrada. | Reescritura de rutas; duplicación; no aísla R ni IDs; impone estructura incluso donde no hay conflicto. | Recursos realmente incompatibles o distribución independiente que lo requiera, no regla global. |
| Carpetas compartidas, dueño común para recursos comunes y nombres distintos para contratos distintos | Reutilización real; correcciones únicas; selección independiente del capítulo; mantiene rutas editoriales útiles. | Hay que acordar contrato y compatibilidad del recurso común; su actualización afecta a varios consumidores. | Opción recomendada para la composición descrita. |
| Materialización o ejecución separada por artefacto | Puede conservar revisiones incompatibles entre entregables; limita estado de sesión compartido cuando el proceso está aislado. | Duplica materialización; añade coordinación de salidas; no entrega por sí misma un documento mixto; puede exigir reescribir rutas. | Excepción para entregables independientes que no pueden converger en una revisión. |

**El manifest es transversal a estas alternativas.** Puede mapear fuentes arbitrarias a un árbol compartido o separado y registrar procedencia. No conviene presentarlo como alternativa a las carpetas: responde a otra pregunta.

Un scaffold puede ser completo como composición reproducible de recursos propios y comunes declarados. Si debe distribuirse autónomamente sin acceso a otras fuentes, se pueden empaquetar también sus dependencias. Esa autonomía de distribución no exige mantener varias implementaciones independientes del mismo builder. El coste de la opción común es coordinar y fijar esas dependencias; el de las copias independientes es asumir su divergencia y detectar el conflicto al componer.

## El caso decisivo: actualización parcial de algo compartido

Supongamos que dos scaffolds aportan a `scripts/fig/` el mismo recurso H, inicialmente idéntico. Hoy cabe una sola copia física. Mañana una fuente propone H2 mientras la otra mantiene H.

- Si H2 preserva el contrato que necesita la otra fuente, ambas pueden converger después de la comprobación pertinente.
- Si H2 cambia ese contrato, una única ruta no puede representar simultáneamente H y H2. Hay que adaptar consumidores, distinguir recursos o separar entregables según la necesidad real.
- La selección de una sola fuente para actualizar no hace desaparecer al consumidor de la otra.
- Una autorización para reemplazar la copia local sólo resuelve la propiedad del archivo editado; no demuestra compatibilidad entre fuentes.

Por eso recomiendo mantener cada recurso común en una fuente canónica, con consumidores y revisión identificados. Puede distribuirse con varios scaffolds sin convertirse en varias implementaciones mantenidas independientemente. No presupone un repositorio nuevo, un servidor de paquetes, un solver de versiones ni una jerarquía obligatoria de carpetas. El esquema concreto queda por cerrar. El mínimo funcional es poder explicar quién reclama cada destino y por qué una actualización es compatible, conflictiva o aún no verificada. Igualdad de bytes sólo prueba que cabe una misma copia física; la asociación a un contrato común debe ser declarada y comprobada.

La procedencia por archivo ya existe y debe conservarse. [PSHA instalado](/usr/local/libexec/psha/bin/recordScaffold.R:29) registra revisión, dirty y MD5 de los archivos copiados. [QRT instalado](/usr/local/libexec/qrt/lib/renderStamp.R:9) recorre los archivos registrados, contrasta hashes locales y construye la marca de revisión/DRAFT. Es evidencia de materialización y cambios, no una prueba de compatibilidad semántica ni una resolución de recursos compartidos. Actualmente ese lector recorre las fuentes registradas, no una dependencia exacta por artefacto.

La reproducción científica exige además datos, parámetros, master y runtime identificados en la evidencia de aceptación. Un hash común del builder, o un sello de revisión válido, no sustituye esas identidades. Las asociaciones y la procedencia de los recursos pueden mantenerse en el manifest de proyecto previsto, sin otra base de datos de colisiones en `.ngr/`.

## Recomendación concreta por responsabilidad

- **`_chapters/`, `_fig/`, `_tbl/`, captions:** compartir carpetas. Mantener nombres temáticos para piezas distintas y reutilizar la misma pieza cuando su contrato coincida. Comprobar IDs dentro de cada composición efectiva.
- **`scripts/fig/` y `scripts/tbl/`:** compartir por cometido. Resolver selección por invocación y conservar reglas científicas comunes en un solo lugar. Evitar tanto una copia por capítulo como un builder universal con condiciones para cada scaffold.
- **Setup y helpers:** armonizar los contratos que de verdad sean comunes; distinguir o aislar los incompatibles. No escoger una versión por orden de copia o de carga.
- **Masters:** pueden convivir físicamente. Elegir un master distinto para cada artefacto o componer expresamente uno mixto es una decisión editorial. Incorporar fuentes no decide automáticamente esa composición ni reemplaza masters editados.
- **Parámetros, semillas y datos:** respetar propiedad del proyecto; admitir el esquema que requieren sus consumidores o una adaptación comprobada. Conservar `oq/`, `gmsp/` y demás datos.
- **Motor NGR:** conocer recursos, mapeos, procedencia y conflictos, sin decisiones temáticas PSHA/blasting/SSEL. La compatibilidad científica se demuestra en los consumidores; el motor no la infiere analizando el significado de R.

## Comprobaciones necesarias antes de aceptar la implementación

Estas son hipótesis de aceptación futuras, no pruebas ejecutadas:

1. Dos fuentes con destinos editoriales distintos se incorporan en carpetas compartidas sin renombrados innecesarios.
2. Un recurso común idéntico conserva todas sus asociaciones; una revisión divergente se detecta antes de copiar, incluso al seleccionar sólo una fuente.
3. El mismo builder produce las series, unidades, escalas y selección correctas para dos casos, incluidos ejecución A→B→A y fallo intermedio cuando la restauración de contexto sea parte del contrato.
4. Dos bloques del mismo gráfico pueden convivir con IDs y referencias correctos; se comprueba un documento mixto y, por separado, artefactos independientes con outputs distintos.
5. Setup y parámetros se validan con los casos concretos observados: funciones homónimas, paleta dependiente de orden y formas distintas de `client`/`consultant` en las semillas; se comprueba qué formas aceptan sus consumidores.
6. La incorporación y actualización conservan masters editados, parámetros, semillas, extras y datos. Retirar una asociación no borra automáticamente un recurso que otro consumidor necesita.
7. Procedencia refleja los bytes realmente materializados y sus fuentes; la marca de render conserva sus consumidores. Referencia exacta y candidato SoT se fijan antes del cambio.

La aceptación general cubre DOCX, presentaciones, estáticos, productos externos consumidos y Netlify. No se incorpora generación de mapas por aparecer en el inventario histórico. Estos casos sólo cubren las incertidumbres de composición discutidas aquí. Los efectos remotos y pilotos siguen requiriendo destinos definidos; no se ejecutaron en esta investigación.

## Decisión propuesta para la conversación

Adoptar **carpetas compartidas con propiedad explícita de recursos comunes y separación selectiva por incompatibilidad real** como dirección de diseño. Para los builders y helpers reutilizables de presentación, concretar esa propiedad en la API del paquete R NGR instalado, según el análisis siguiente. Confirmar después las reglas de actualización y materialización derivadas de esa dirección, y sólo entonces expresar el contrato de verbos y parámetros. No convertir esta recomendación en implementación por el mero hecho de haberla documentado.

## Builders como API del paquete: propuesta precisada con el propietario

El propietario pregunta si los scripts comunes deberían salir de los scaffolds y pasar a NGR, quedando los scaffolds como consumidores mediante `NGR::función()`. **Sí, para la lógica reutilizable de reporting: ésta es una concreción mejor que distribuir copias comunes de scripts.** La colisión identifica dónde revisar; la responsabilidad del código decide qué pertenece al paquete. La consulta no se interpreta como autorización para retirar archivos ahora.

Ya existe un precedente en el checkout: [buildSectionResultantsPlot](/Users/averrik/Cloud/github/libraries/NGR/lib/R/buildSectionResultantsPlot.R:1) recibe curvas y ordenadas preparadas, documenta que devuelve un widget y deja al llamante los cálculos y transformaciones físicas. Su función y argumentos están en líneas 75–88; figura exportada en [NAMESPACE](/Users/averrik/Cloud/github/libraries/NGR/lib/NAMESPACE). La [prueba mantenida](/Users/averrik/Cloud/github/libraries/NGR/lib/tests/testthat/test-buildSectionResultantsPlot.R:56) comprueba geometría, forma del resultado e invariancia de las entradas. Se leyeron contrato y pruebas; no se ejecutaron en esta consulta ni se verificó aquí esa exportación en la instalación personal.

El reparto propuesto es:

| Responsable | Qué conserva |
|---|---|
| Paquete R NGR, `lib/` | Builders reutilizables de figuras/tablas, validación de sus entradas y helpers comunes de presentación/contexto. Funciones con argumentos y retornos explícitos. |
| Scaffold | Narrativa, composición, captions, labels, selección del caso y llamadas a APIs instaladas. Puede contener código consumidor propio. |
| Librería científica responsable | Algoritmos y reglas científicas reutilizables que no son presentación. No se duplican en cada capítulo para poder extraer el builder. |
| Proyecto | Datos, parámetros, valores científicos elegidos, masters editables y personalizaciones. |
| CLI ngr, `cli/` | Incorporación/actualización de recursos y coordinación del render/publicación, cargando el paquete instalado. |

El [setup PSHA](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/setup/setup.R:39) mezcla carga de helpers, valores de proyecto, parámetros y datos OQ; también declara umbrales científicos y opciones visuales. Por eso no conviene trasladarlo entero a una función que siga poblando globales. Hay que separar la implementación reutilizable de la configuración y preparación que poseen el proyecto y el dominio.

Los bloques pasarían a invocar las funciones exportadas pertinentes. El builder común recibiría datos y opciones y devolvería el gráfico, en vez de buscar `DATA`, `PALETTE` o targets en la sesión y dejar `PLOT` como asignación lateral. `NGR::builder()` se entiende aquí como notación conceptual: NGR ya tiene funciones por cometido, como `buildPlot()` y `buildSectionResultantsPlot()`; no se propone un dispatcher universal por nombre de capítulo o scaffold.

Para [PZ.levels.R](/Users/averrik/Cloud/github/libraries/reports/library/monitoring/scripts/fig/PZ.levels.R:10), el motor ya es `buildPlot()`. Si el script sólo aporta la configuración particular del bloque, éste puede llamar directamente a `NGR::buildPlot()` con ella. Una función nueva se justifica si encapsula una representación reutilizable con contrato propio, no para convertir cada nombre de archivo en una exportación.

El operador `::` accede a una función exportada y carga el namespace sin adjuntar el paquete al search path, según la [documentación de R](https://stat.ethz.ch/R-manual/R-devel/library/base/html/ns-dblcolon.html). La mejora de aislamiento proviene también de convertir el script en una función con dependencias explícitas: añadir `::` a un wrapper que siga haciendo `source()` y escribiendo globales no resuelve ese problema.

Esta dirección elimina la distribución y actualización de esos builders comunes como archivos del scaffold. Traslada la obligación a una versión compatible del paquete NGR y de sus dependencias, que deberá quedar identificada para la aceptación. El instalador CLI sigue sin instalar ni actualizar paquetes R. La retirada de copias se hace después de migrar sus consumidores y comparar observables SoT; requiere coordinación de los cambios concretos en lib/ con el agente de librerías.
