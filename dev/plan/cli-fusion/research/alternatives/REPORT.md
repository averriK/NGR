# Alternativas de composición: fuentes, recursos comunes y contexto editorial

2026-09-16. Misión `cli-fusion-composition-alternatives-20260916`.
Análisis de diseño; ninguna alternativa está aprobada ni implementada por este informe.

## Conclusión

La recomendación es **materialización declarada en un árbol compartido, con un propietario común para los builders que tengan realmente el mismo contrato, y recursos editoriales distintos cuando cambien la selección, el relato o la identidad de la figura**. Son decisiones complementarias: el manifest resuelve qué se copia y quién lo exige; el propietario común resuelve quién mantiene una operación; el capítulo decide dónde y con qué contexto aparece.

No hace falta imponer una carpeta física por scaffold para conseguirlo. Tampoco basta fusionar carpetas y comparar hashes. Dos copias iguales hoy pueden ser obligaciones incompatibles mañana: si PSHA exige unos bytes y SSEL exige otros incompatibles en el mismo destino, no existe un único archivo que satisfaga ambas. El conflicto permanece aunque sólo se haya seleccionado actualizar uno de los libros.

Esta recomendación sigue la dirección del [plan vigente](/Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-fusion/PLAN.md:64), que permite mappings arbitrarios, destinos compartidos y procedencia por archivo. Propone precisar sus consecuencias; no reemplaza las decisiones pendientes por nuevos flags o un schema inventado.

## Evidencia leída en esta sesión

La cadena seleccionada comienza en el master, no en un listado de recursos. Es una muestra acotada de arquitectura; no un inventario completo de PSHA, blasting o SSEL.

| Lectura | Consecuencia observable para la comparación |
|---|---|
| [PSHA, master ES](/Users/averrik/Cloud/github/tools/psha/scaffold/_master/book.es.qmd:7), líneas 7–33 | Selecciona capítulos y apéndices concretos. `_book/deq.ES.qmd` y `_book/psha.ES.qmd` pertenecen al libro observado. El [master de AR-S2L1W](/Users/averrik/Cloud/github/projects/AR-S2L1W/_master/book.es.qmd:7), leído completo, contiene esas mismas entradas; no se ejecutó el consumidor. |
| [Capítulo DEQ](/Users/averrik/Cloud/github/tools/psha/scaffold/_book/deq.ES.qmd:1), líneas 1–53 y 59–116 | Carga setup/report, incluye narración de `_chapters/`, y selecciona bloques de `_fig/` y `_tbl/`. Proporciona `ID.target`, sitio, stems y, en una tabla específica, estándar y etapa. Es el nivel donde ya se expresa una selección editorial concreta. |
| [Capítulo PSHA](/Users/averrik/Cloud/github/tools/psha/scaffold/_book/psha.ES.qmd:20), líneas 20–58 | Ejecuta un mismo bloque por sitio, con stem y ancla propios. La identidad del archivo no equivale a la identidad de cada aparición en el libro. |
| [Wrapper DEQ operación ES](/Users/averrik/Cloud/github/tools/psha/scaffold/_fig/DEQ.operation.ES.qmd:1), líneas 1–17, y [wrapper cierre ES](/Users/averrik/Cloud/github/tools/psha/scaffold/_fig/DEQ.closure.ES.qmd:1), líneas 1–16 | Seleccionan texto/caption y delegan a los bloques comunes de operación y cierre. La localización editorial ya está separada de parte de la ejecución. |
| [Bloque operación](/Users/averrik/Cloud/github/tools/psha/scaffold/_fig/DEQ.operation.qmd:4), líneas 4–44 y 52–138; [bloque cierre](/Users/averrik/Cloud/github/tools/psha/scaffold/_fig/DEQ.closure.qmd:4), líneas 4–43 y 51–140 | Ambos llaman a `scripts/fig/DEQ.R`; cambian `Stage.target`, captions, labels y condiciones HTML/DOCX. Seleccionan Vs30 de forma distinta según salida. Reutilización del builder y variedad editorial ya coexisten. |
| [Builder DEQ](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/fig/DEQ.R:18), líneas 18–39 y 152–186 | Filtra con objetivos recibidos, contiene una regla científica ANCOLD/Closure/Extreme y construye `PLOT`. No lee el nombre del capítulo en esas operaciones. No es una función pura: consume tablas y variables del entorno y deja un resultado llamado `PLOT`. |
| [Setup](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/setup/setup.R:39), líneas 39–51, 55–71 y 101–102 | Carga helpers, parámetros y tablas y establece defaults compartidos. Tener `scripts/` separados no cambia por sí mismo estas referencias ni el entorno de evaluación. |
| [Contexto del reporte](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/setup/report.R:98), líneas 98–126; [ejecución del bloque](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/setup/utils.R:292), líneas 292–321 | El helper deriva stem/labels del contexto y guarda/restaura las variables declaradas en `vars` dentro de `knitr::knit_global()`. Es una reutilización existente que debe evaluarse antes de diseñar otro motor. La restauración leída cubre esas variables declaradas; no afirma aislamiento general de efectos. |
| [NGR, `knitBlock` en checkout](/Users/averrik/Cloud/github/libraries/NGR/lib/R/knitBlock.R:23), líneas 23–45, 48–63, 118–151 y 154–172 | Expande includes, reescribe/comprueba labels, superpone variables y ejecuta `knit_child` en el entorno de knitr. Restaura CWD. Esta lectura describe el checkout, no acredita que el paquete instalado tenga estos bytes. |
| [QRT, configuración book](/Users/averrik/Cloud/github/tools/qrt/scaffold/yml/_quarto-book.yml:1), líneas 1–5 | Declara `execute-dir: project`. Separar archivos en subcarpetas no basta para cambiar la raíz de ejecución que esta configuración pide. |

El builder DEQ permite una conclusión acotada: **ser agnóstico al capítulo no significa ser agnóstico al dominio ni carecer de política científica**. La selección `Standard/Stage/ID/Vs30` varía; la regla de probabilidad para un criterio concreto sigue dentro del builder. Extraer todo el slicing al capítulo podría duplicar esa regla y no se justifica sólo por querer compartir un script.

## Qué aportan las fuentes primarias

Consultadas el 2026-09-16. Se separan sus hechos de las inferencias de diseño.

- **Includes de Quarto.** Se comportan como inclusión textual: referencias relativas se resuelven respecto del documento principal; los includes con código comparten motor. Quarto recomienda rutas desde la raíz para includes reutilizados. **Inferencia:** mover cada scaffold a una subcarpeta no crea un namespace de ejecución ni arregla sus referencias internas. Un mapping de copia no puede prometer portabilidad del recurso sin leer sus consumidores. [Documentación oficial](https://quarto.org/docs/authoring/includes.html).
- **Crossrefs de Quarto.** Cada entidad necesita un identificador único; en libros las referencias alcanzan otros capítulos. **Inferencia:** los nombres de archivo distintos no resuelven la repetición de `fig-…`, `tbl-…` o `sec-…` al componer un libro. Identidad de aparición y referencias deben validarse sobre la composición seleccionada. [Cross References](https://quarto.org/docs/authoring/cross-references.html), [Book Crossrefs](https://quarto.org/docs/books/book-crossrefs.html).
- **R `source`.** `local = FALSE` evalúa en el entorno global; `TRUE` usa el entorno llamador; puede proporcionarse un entorno explícito. `chdir` controla otro eje: el directorio temporal de ejecución. Un error de ejecución puede dejar asignaciones anteriores. **Inferencia:** una carpeta, un entorno R y un proceso son fronteras distintas; no debe venderse una como sustituto de otra. [Manual oficial de R](https://stat.ethz.ch/R-manual/R-devel/library/base/html/source.html).
- **Entornos R.** La búsqueda puede continuar por entornos envolventes, y el entorno léxico de una función difiere del frame que la llama. **Inferencia:** crear un entorno hijo no demuestra por sí solo ausencia de dependencias implícitas o de efectos fuera del entorno. No se propone un sandbox de ejecución. [Environment Access](https://stat.ethz.ch/R-manual/R-devel/library/base/html/environment.html).
- **Ejecución Quarto.** `execute-dir: project` controla CWD; cache/freeze tienen reglas de invalidación propias y los datos externos requieren atención. **Inferencia:** copia reproducible de recursos, compatibilidad de la composición y reproducción del cálculo son tres afirmaciones diferentes. Un sello de recursos no basta para la última. [Managing Execution](https://quarto.org/docs/projects/code-execution.html).

## Cuatro alternativas y sus límites

### A. Fusionar los árboles completos y reutilizar destinos de contenido igual

**Ventajas:** conserva rutas actuales, reduce migración inicial, deja un proyecto editable y evita cargar scaffolds temáticos dentro del runtime NGR. Comparar bytes y colisiones puede preceder toda escritura, como pide el plan.

**Costes:** convierte el árbol del proyecto en un conjunto de dependencias entre fuentes. Un recurso compartido ya no puede actualizarse sin considerar sus otros consumidores. La igualdad de archivos no prueba igualdad de sus datos, helpers, captions o supuestos de unidades. Los nombres genéricos pueden esconder una diferencia editorial legítima.

**Sirve cuando:** los recursos tienen identidad y contrato realmente comunes, o sus destinos distintos ya están bien nombrados. **No resuelve:** propietario de futuras revisiones, compatibilidad de actualizaciones parciales, labels, entornos o outputs generados. Un sistema de «última copia gana» contradice el plan y descarta evidencia.

### B. Conservar una carpeta física por fuente

**Ventajas:** hace visible el origen y permite mantener dos revisiones incompatibles de un mismo recurso en ubicaciones diferentes. Facilita una evolución independiente cuando esa independencia es real.

**Costes:** duplica helpers si se usa como regla universal, alarga rutas y exige migrar includes/source/lectores de datos. El código observado usa destinos desde la raíz, por lo que mover archivos sin migrar referencias cambia o rompe el consumo. El namespace de archivos no incluye automáticamente las variables R, labels, bibliografía ni destinos de figuras.

**Sirve cuando:** dos recursos parecidos deben coexistir y no tienen un contrato común. **No resuelve:** reutilización común ni composición editorial. Como obligación universal requeriría revisar la decisión explícita del plan de no imponer namespaces físicos. Puede seguir siendo un mapping permitido para un caso concreto, sin cambiar la regla general.

### C. Un propietario de recursos comunes y capas editoriales diferenciadas

**Ventajas:** elimina la ambigüedad de quién cambia un builder; una corrección común no se propaga mediante copias manuales entre libros. Conserva variaciones donde tienen significado: escenario, selección, caption, estructura narrativa, lengua y formato. La cadena DEQ muestra que esta frontera ya tiene una base local.

**Costes:** los libros pasan a depender explícitamente de una revisión común. Una actualización incompatible exige coordinar consumidores o conservar variantes. Hay que demostrar que el supuesto núcleo es común en contrato, y no sólo parecido. Un núcleo excesivo acoplaría libros que evolucionan por razones distintas.

**Sirve cuando:** ambos consumidores necesitan la misma operación científica sobre entradas declaradas y difieren en selección o presentación. **No implica:** trasladar todos los scripts al paquete R, crear otro paquete ni hacer que NGR lleve los recursos de todos los libros. La ubicación se decide por responsabilidad y consumidor; este informe no selecciona una nueva distribución.

Un scaffold puede seguir siendo «completo» como entrada capaz de materializar todos sus recursos necesarios, incluidos los comunes. Si «completo» exige además un archivo distribuible autónomo sin ninguna otra fuente disponible, ese requisito debe expresarse y resolverse en el empaquetado; no obliga a que cada libro mantenga una copia editable del mismo builder.

### D. Materializar la composición declarada por manifests

**Ventajas:** separa el árbol de origen del árbol consumido; permite fusionar recursos o conservar subcarpetas de manera explícita. Puede describir las obligaciones de todas las fuentes, resolver colisiones antes de escribir y registrar qué bytes quedaron realmente asociados a cada una. Es compatible con A, B o C.

**Costes:** el manifest debe describir recursos reales y no convertirse en una segunda implementación del libro. La copia no puede inferir todo `source()` dinámico ni convertir código arbitrario en portable. Una revisión de fuente no describe por sí sola un proyecto actualizado sólo en algunos archivos. Preflight tampoco es una transacción: una interrupción requiere distinguir efectos observados y pendientes.

**Sirve cuando:** la materialización tiene un contrato declarado y el proyecto conserva edición y procedencia. **No resuelve:** compatibilidad científica por digest, extracción automática del núcleo, entorno de cálculo reproducible o edición editorial de los masters. La recomendación es emplearlo para materialización y atribución, sin convertirlo en un planificador general del cálculo.

### Comparación resumida

| Criterio | A: árbol fusionado | B: carpeta por fuente | C: propietario común | D: manifest de materialización |
|---|---|---|---|---|
| Preservar rutas observadas | Alto | Bajo sin migración | Depende de conservar interfaz | Alto con mappings compatibles |
| Dos versiones incompatibles simultáneas | No en el mismo destino | Sí, con consumo separado | No para una sola instancia común | Puede detectarlo y representar destinos distintos |
| Actualizar un libro sin afectar otro | Sólo sin obligaciones compartidas | Mejor a nivel de archivos | Requiere compatibilidad del común | Puede preflightar todas las obligaciones |
| Evitar mantenimiento duplicado | Sólo mientras no diverjan | No por sí sola | Sí para lo realmente compartido | No por sí sola |
| Atribuir revisiones mezcladas | Necesita registro | Sigue necesitando registro | Necesita revisión común + consumidores | Su función propia, si registra por archivo |
| Aislar labels/variables/outputs | No | No por sí sola | Exige contrato de invocación | Puede validar identidades declaradas; no inferir todos los efectos |

## Actualizaciones, propiedad y reproducibilidad

Una ruta fusionada necesita distinguir tres hechos sin confundirlos:

1. **Contenido materializado:** cuáles son sus bytes actuales y si el proyecto los modificó respecto de la copia registrada.
2. **Obligaciones de fuentes:** qué recurso/revisión pide cada fuente asociada a esa ruta; un archivo puede satisfacer a varias.
3. **Compatibilidad de uso:** qué consumidores fueron contrastados con esa revisión y qué entradas/efectos esperan. La igualdad de digest sólo decide el primer hecho.

Ejemplo hipotético: PSHA@A y SSEL@B aportan el mismo `scripts/fig/DEQ.R` con digest H. Puede almacenarse un único archivo H y conservar ambas asociaciones. Si PSHA@C pide H2 y SSEL@B sigue pidiendo H, actualizar sólo PSHA no da autoridad para sustituir el archivo compartido. Las salidas honestas son mantener lo anterior y exponer el conflicto, coordinar una composición compatible o seleccionar destinos/consumidores separados. Elegir automáticamente H2, H o el más reciente inventaría una política.

Un archivo retirado de una fuente puede seguir exigido por otra o editado por el proyecto. Desasociar una obligación y borrar bytes son operaciones diferentes. El [plan](/Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-fusion/PLAN.md:80) ya excluye el borrado lateral.

La mezcla de revisiones no es necesariamente un error: puede ser el resultado legítimo de una actualización selectiva. Lo incorrecto sería etiquetarla como si todo el libro proviniera de un único commit. Tampoco debe confundirse una composición atribuible con una composición compatible: el registro explica de dónde vino; la prueba del consumidor decide si funciona.

Para reproducir un render también importan los masters editables, parámetros y datos, la versión efectiva del código y herramientas de ejecución y, si se reutilizan, los resultados cacheados. Este informe no propone nuevos campos para todos ellos. Establece el límite de la afirmación: un manifest de copia por archivo no certifica reproducción del cálculo ni identidad de un documento renderizado.

## Casos adversariales mínimos para decidir la arquitectura

Son diseños de prueba; no se ejecutaron, no crean fixtures ni requieren ahora un framework.

| Caso | Qué debe distinguir la prueba |
|---|---|
| Dos fuentes exigen los mismos bytes; una cambia sola | La copia inicial puede reutilizarse. La actualización debe detectar la obligación anterior de la fuente no seleccionada antes de tocar el destino. |
| Builder idéntico, helpers o tablas con contrato diferente | El preflight de bytes puede pasar y el consumidor fallar. Evidencia de que el hash no prueba compatibilidad científica ni la clausura de dependencias. |
| Operación y cierre reutilizan DEQ, con sitio y estándar distintos | Selección, datos de la figura, caption y labels deben corresponder a cada aparición; cambiar el orden no debe dejar objetivos de la aparición anterior. Anclar la futura prueba a datos pequeños conocidos. |
| Un bloque falla después de cambiar una variable no declarada en `vars` | Delimitar qué restauran realmente `.knitContextBlock`/`knitBlock`, sin presumir que una carpeta o un entorno hijo proporcionan aislamiento total. |
| Dos includes de fuentes distintas contienen el mismo label | La composición debe detectar o resolver la identidad según un contrato explícito, aunque las rutas de archivo sean diferentes. Comprobar referencias, no sólo ausencia de error. |
| Master situado fuera de la raíz y bloque reubicado | Verificar cada include/source y la raíz de ejecución de la composición final. El mapping no debe prometer que reubicar un recurso reescribe automáticamente sus consumidores. |
| Actualización selectiva de un archivo, conservando otros de la revisión anterior | El registro debe describir esa mezcla y el sello no atribuir todo el libro a la revisión nueva. |
| Archivo compartido retirado de una sola fuente | Conservar bytes y obligación restante; no inferir borrado de su desaparición en un inventario. |
| Recurso administrado editado localmente y master editado localmente | Distinguir modificación local, permiso de reemplazo y semilla editorial. Resolver un reemplazo local no debe resolver por accidente un conflicto entre fuentes. |
| Interrupción después de copiar un archivo y antes de completar el lote | El estado recuperable debe describir lo observado; ningún informe puede afirmar que todo el lote quedó materializado sólo porque el preflight pasó. |

La primera prueba discriminante debería ser la actualización unilateral de un destino compartido: decide propiedad y precedencia antes de invertir en gramática CLI. Para builders, el caso discriminante es reutilizar la misma operación con dos contextos distintos, incluyendo un fallo entre ellos. No se requiere todavía renderizar todos los scaffolds.

## Recomendación acotada y decisiones que siguen abiertas

- Conservar el árbol fusionado donde los contratos actuales lo soportan; mantener origen y revisión fuera del nombre físico cuando no aporten significado al consumidor.
- Compartir un builder sólo cuando tenga una responsabilidad y contrato comunes. Mantener en el capítulo/bloque la selección y narrativa que efectivamente cambian; no repartir entre capítulos reglas científicas que ya tienen un propietario.
- Nombrar recursos distintos por su diferencia real cuando diverjan. El prefijo de fuente puede servir para dos recursos independientes, pero no sustituye un contrato de uso ni una identidad de aparición.
- Usar el manifest para declarar materialización y obligaciones, preservar edición local y detectar incompatibilidades entre todas las fuentes implicadas. No deducir compatibilidad de igualdad de bytes ni del orden de copia.
- Evaluar la fusión física de `_chapters/` y `_fig/` por facilidad de edición y claridad de las unidades, no como solución a propiedad o ejecución. Pueden compartir carpeta manteniendo su rol; cambiar la carpeta no unifica sus contratos. Los consumidores concretos de esa reorganización deben leerse y migrarse juntos antes de aceptarla.

Quedan por resolver con evidencia de los otros trabajos: cuáles son realmente los recursos comunes de blasting/SSEL, cuáles sus diferencias contractuales, y qué pruebas actuales admiten la reutilización. Esta misión no leyó sus clausuras completas y no afirma que sean compatibles. También queda abierta la interpretación operacional de «scaffold completo» si exige distribución autónoma. Ninguna de estas incertidumbres justifica inventar ahora un parser, un registro de plugins ni un sistema de dependencias general.

## Alcance y verificación

Se leyeron los skills instalados `code` y sus veinte tarjetas completas, y `r`. El recibo `/Users/averrik/.agents/agents-skills.json`, leído en esta sesión, declara releases que coinciden con el catálogo: code `db006ef77a7e616f00f88ba10cb6f71b741336a4913ab05c039edfc4db40fa44`, r `15ce51e4ce5d7fa1f5da7e45ab10fec0b4956e9ce48f4469ef4d246ed82b3a06`.

Identidades SHA-256 observadas de cuatro entradas de la cadena:

| Archivo | SHA-256 |
|---|---|
| `/Users/averrik/Cloud/github/tools/psha/scaffold/_master/book.es.qmd` | `843949afcd2becbe77c799cf9115f55957369b5f352a1e348137006908dff1ee` |
| `/Users/averrik/Cloud/github/tools/psha/scaffold/_book/deq.ES.qmd` | `dc9db491e18f14d485003d1df9724d1cc756b3fda8bd4afa751415afae43efd2` |
| `/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/fig/DEQ.R` | `b459968ade00bb3bb277e798d2aad292f5d851d6d351b7c49d5880c4f5e3339d` |
| `/Users/averrik/Cloud/github/libraries/NGR/lib/R/knitBlock.R` | `3de4e7f36078fd66d27f3dcce47979f72f2afefd1dfe73b004c3fbd6e197971c` |

Fase: diagnóstico documental del diseño. No se ejecutaron builders, renders, copias de recursos, instalaciones ni pruebas del producto. Las afirmaciones sobre comportamiento describen código leído y fuentes primarias, con inferencias marcadas; no son pruebas de paridad ni certificación de los runtimes instalados.
