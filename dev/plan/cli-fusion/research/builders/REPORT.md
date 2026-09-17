# Builders compartidos y cortes de datos

2026-09-16. Misión `cli-fusion-builders-composition-20260916`.
Investigación estática; no implementación, render, instalación ni certificación de resultados científicos.

## Conclusión

**Sí: varios capítulos o scaffolds pueden compartir el mismo builder cuando comparten su contrato de datos y representación. Un corte distinto no exige otro archivo.** El código observado ya lo hace. La distinción decisiva es entre independencia del capítulo, independencia del esquema científico e independencia del entorno de ejecución: son tres propiedades diferentes.

La recomendación es conservar una implementación común por operación realmente compartida, dejando a los masters y bloques la selección editorial. Los datos, unidades y selecciones científicas deben ser entradas explícitas del builder o de un adaptador científico con propietario claro. No conviene convertir todos los builders en una API universal ni trasladar mecánicamente cada filtro a cada capítulo. El filtrado que exige mantener juntas curvas, escalas y metadatos puede seguir dentro de la función común.

Los escenarios blasting y SSEL proceden del encargo del propietario: no se leyó aquí un scaffold completo de ninguno de ellos. AR-SAD40 es un contraste real ajeno a PSHA, **no evidencia de que sea SSEL**. Por eso esta recomendación permite su convivencia sin afirmar compatibilidad científica aún no comprobada.

## Método y alcance observado

- Validado el locator exacto contra `Delegations` del estado coordinador y abierto el estado hijo antes del análisis.
- Leídos los skills instalados `code`, sus veinte tarjetas completas, `r` y `datatable`; no se operaron datasets ni se ejecutaron sus builders.
- Seguidas las inclusiones desde los masters; los listados se usaron sólo como localizadores.
- Tres cadenas completas: espectros UHS de PSHA, series temporales SRS de PSHA y resultantes estructurales de AR-SAD40. Se leyó además el builder `kh.R` como contraste científico, sin declarar completo el inventario de ese artefacto.
- Leído `NGR/lib/R/knitBlock.R` como evidencia del mecanismo existente, sin editarlo ni asumir que el paquete instalado tenga esa misma identidad.
- Se compararon SHA-256 de **dos builders concretos**, no de la clausura entera: los bytes de fuente PSHA, instalación PSHA y proyecto AR-S2L1W coinciden para `UHS.R` y `TS.R`.

| Builder | SHA-256 común en los tres destinos |
| --- | --- |
| `scripts/fig/UHS.R` | `bd48b726cc7b333cdc346f0a3b4194764148ee059732e70fe9cbffab988c9fa7` |
| `scripts/fig/TS.R` | `db18dff4eca687ede0b3ef7b913abf02f50d218ed05ad8ac76c8fa56a0e7ad69` |

Destinos comprobados: `/Users/averrik/Cloud/github/tools/psha/scaffold`, `/usr/local/libexec/psha/scaffold` y `/Users/averrik/Cloud/github/projects/AR-S2L1W`. La igualdad de esos archivos acredita reutilización literal actual; no acredita iguales setups, datos ni resultados.

## Cadena 1: PSHA, espectros UHS

### Master y bloques

1. [`sha.qmd:19`](/Users/averrik/Cloud/github/tools/psha/scaffold/_master/sha.qmd:19) carga setup y report; desde la línea 67 recorre sitios. En [`sha.qmd:126`](/Users/averrik/Cloud/github/tools/psha/scaffold/_master/sha.qmd:126) llama a `/_revealjs/uhs.qmd` con `siteID.target` y título.
2. [`_revealjs/uhs.qmd:7`](/Users/averrik/Cloud/github/tools/psha/scaffold/_revealjs/uhs.qmd:7) resuelve `ID.target` contra `UHSTable` y en la línea 18 incluye `/_fig/UHS.qmd`.
3. [`_fig/UHS.qmd:3`](/Users/averrik/Cloud/github/tools/psha/scaffold/_fig/UHS.qmd:3) resuelve targets, probabilidades y captions. Sus líneas 29–35 recorren periodos de retorno y una rama MCE, llamando al mismo `UHS.Vs30.qmd` mediante `knitBlock`.
4. [`UHS.Vs30.qmd:10`](/Users/averrik/Cloud/github/tools/psha/scaffold/_fig/UHS.Vs30.qmd:10) recorre `Vs30.gmdp`; [`UHS.one.qmd:6`](/Users/averrik/Cloud/github/tools/psha/scaffold/_fig/UHS.one.qmd:6) hace `source()` de `scripts/fig/UHS.R` y emite `PLOT`.

### Datos, corte y salida

El builder no recibe un nombre de capítulo. En cambio depende de `UHSTable`/`MCETable`, `ID.target`, `Vs30.target`, `p.target`, `TR.target`, `siteID.target`, `Sa.log`, grosores de línea, `.matchP()` y `buildPlot()`. La ausencia local de `TR.target` activa la rama MCE; su presencia selecciona UHS por periodo de retorno. Después aplica el corte de sitio. Estos son contratos científicos y de entorno, aunque el builder sea editorialmente agnóstico. Véase [`UHS.R:2`](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/fig/UHS.R:2), líneas 2–17.

El builder forma series, decide estilos para periodos y probabilidades, ordena datos y rechaza más de una ordenada por serie/Tn antes de crear `PLOT`: [`UHS.R:34`](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/fig/UHS.R:34), líneas 34–90. El resultado explícito del script es la asignación de `PLOT`; elimina sus temporales al final. No contiene una escritura explícita de archivo ni un cache persistente. Las funciones gráficas llamadas no se ejecutaron ni se auditaron aquí íntegramente.

El setup carga bibliotecas, helpers, el `oq/data/data.R` opcional y parámetros; define valores gráficos y ejecuta `global.R`: [`setup.R:14`](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/setup/setup.R:14), líneas 14–71 y 101–102. [`global.R:2`](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/setup/global.R:2) lee `oq/data/<nombre>.Rds`; las tablas se cargan sólo si el binding no existe. Sus líneas 25–78 derivan selecciones y etiquetas de UHS. Por tanto un objeto preexistente puede impedir recargar datos; compartir el archivo no garantiza que dos libros estén usando el conjunto previsto.

**Consecuencia de diseño:** compartir `UHS.R` es viable con ese contrato. Separar el corte del dibujo puede ser útil, pero debe conservar la diferencia MCE/UHS, probabilidades, unidades, estilos, agrupación y rechazo de duplicados. Pasar una tabla cualquiera llamada `DATA` sería insuficiente.

## Cadena 2: PSHA, series temporales SRS

1. [`srs.at.qmd:8`](/Users/averrik/Cloud/github/tools/psha/scaffold/_master/srs.at.qmd:8) carga setup, resuelve selecciones y, para cada run, lee `data/TSW.csv` bajo `PathSRS` antes de llamar a `/_revealjs/srs.at.qmd` (líneas 23–43).
2. [`_revealjs/srs.at.qmd:3`](/Users/averrik/Cloud/github/tools/psha/scaffold/_revealjs/srs.at.qmd:3) incluye el bloque de figura. [`_fig/srs.at.qmd:5`](/Users/averrik/Cloud/github/tools/psha/scaffold/_fig/srs.at.qmd:5) fija `ID = "AT"`; sus líneas 15–16, 32–33 y 49–50 fijan `DIR` a H1/H2/UP y ejecutan **el mismo** `TS.R`.
3. [`TS.R:2`](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/fig/TS.R:2) compone la columna con `ID` y `DIR`, admite AT/VT/DT, valida que la columna exista, determina la etiqueta de unidades y construye las series desde `TSWTable`. Devuelve mediante `PLOT`, cambia opciones del widget y elimina sus temporales (líneas 11–42).

La reutilización no es sólo potencial: [`_fig/srs.vt.qmd:5`](/Users/averrik/Cloud/github/tools/psha/scaffold/_fig/srs.vt.qmd:5) y [`_fig/srs.dt.qmd:5`](/Users/averrik/Cloud/github/tools/psha/scaffold/_fig/srs.dt.qmd:5) fijan otra medida y llaman al mismo archivo. El master de velocidad también lee `TSW.csv` por selección: [`srs.vt.qmd:23`](/Users/averrik/Cloud/github/tools/psha/scaffold/_master/srs.vt.qmd:23).

El resolver existente usa `gmsp/match`, parámetros declarados o runs encontrados, y consulta `metadata/runMatch.json` para el sitio: [`utils.R:469`](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/setup/utils.R:469), líneas 469–592. Una `PathSRS` explícita produce una selección única sin esa comprobación de sitios del report: [`utils.R:595`](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/setup/utils.R:595), líneas 595–620. Es una selección del consumidor, no propiedad del builder gráfico.

**Consecuencia de diseño:** aquí el reparto ya es claro: master elige run, bloque elige medida/componente, builder interpreta el esquema y dibuja. Un scaffold blasting podría reutilizarlo sólo si sus datos cumplieran ese esquema, unidades y convenciones de componentes; no se ha observado tal compatibilidad. No hay razón observada para crear `TS` por capítulo.

## Cadena 3: AR-SAD40, resultantes de acero y shotcrete

1. [`_master/report.qmd:5`](/Users/averrik/Cloud/github/projects/AR-SAD40/_master/report.qmd:5) enumera `_index/liner.ES.qmd` y `_index/rehabilitation.ES.qmd` entre los capítulos.
2. [`_index/liner.ES.qmd:3`](/Users/averrik/Cloud/github/projects/AR-SAD40/_index/liner.ES.qmd:3) carga setup; la línea 82 incluye el capítulo. [`liner.existing.es.qmd:62`](/Users/averrik/Cloud/github/projects/AR-SAD40/_chapters/liner.existing.es.qmd:62) incluye la figura de resultantes.
3. [`Resultants.liner.ES.qmd:3`](/Users/averrik/Cloud/github/projects/AR-SAD40/_fig/Resultants.liner.ES.qmd:3) selecciona caption y envuelve [`Resultants.liner.qmd:4`](/Users/averrik/Cloud/github/projects/AR-SAD40/_fig/Resultants.liner.qmd:4). Este bloque carga `Resultants.R`, pasa rutas, radio y parámetros gráficos a `buildCalculationResultantsInteractive()`, y conserva su resultado en `PLOT`.
4. [`Resultants.shotcrete100.qmd:3`](/Users/averrik/Cloud/github/projects/AR-SAD40/_fig/Resultants.shotcrete100.qmd:3) reutiliza **la misma función** con otras rutas, otro radio y `liningID = "shotcrete"`.

[`Resultants.R:3`](/Users/averrik/Cloud/github/projects/AR-SAD40/scripts/fig/Resultants.R:3) ofrece datos en memoria (`curves`/`scales`) o lectura de CSV, valida esquemas y filtra ambas tablas por revestimiento. [`Resultants.R:185`](/Users/averrik/Cloud/github/projects/AR-SAD40/scripts/fig/Resultants.R:185) recibe también la selección N/M/Q, escala y etiquetas de casos, y retorna el widget desde `highcharter::hc_tooltip()` (líneas 185–272). Sus funciones de preparación geométrica reciben curvas, escalas y radio sin conocer el capítulo: [`ringFigureData.R:21`](/Users/averrik/Cloud/github/projects/AR-SAD40/scripts/R/ringFigureData.R:21) y [`ringFigureData.R:129`](/Users/averrik/Cloud/github/projects/AR-SAD40/scripts/R/ringFigureData.R:129).

El setup de proyecto carga funciones y resultados: [`setup.R:29`](/Users/averrik/Cloud/github/projects/AR-SAD40/scripts/setup/setup.R:29). El lector de resultados define las rutas `data/calculation`, incluidas curvas y escalas, y valida los CSV: [`coverCalculationResults.R:120`](/Users/averrik/Cloud/github/projects/AR-SAD40/scripts/setup/coverCalculationResults.R:120), líneas 120–166 y 231–248. La asignación final `Calculation <- loadCoverCalculationResults(...)` está en [`coverCalculationResults.R:1391`](/Users/averrik/Cloud/github/projects/AR-SAD40/scripts/setup/coverCalculationResults.R:1391).

Este builder sigue acoplado a su dominio: valida modelos e interfaces específicos, usa etiquetas en español y carga `scripts/R/ringFigureData.R` mediante una ruta relativa al directorio de trabajo. Sus bloques eliminan `CAP`, `PLOT` y la función pública al terminar, pero no todos los helpers cargados. No es un módulo aislado sólo por contener funciones. Véase [`Resultants.R:1`](/Users/averrik/Cloud/github/projects/AR-SAD40/scripts/fig/Resultants.R:1), líneas 1–100, y [`Resultants.liner.qmd:24`](/Users/averrik/Cloud/github/projects/AR-SAD40/_fig/Resultants.liner.qmd:24).

Se leyeron pruebas existentes que distinguen resultantes y escalas, y casos de acero/shotcrete/hormigón armado: [`testCalculationFigures.R:80`](/Users/averrik/Cloud/github/projects/AR-SAD40/scripts/R/testCalculationFigures.R:80), líneas 80–127, y [`testCalculationFigures.R:180`](/Users/averrik/Cloud/github/projects/AR-SAD40/scripts/R/testCalculationFigures.R:180), líneas 180–231. **No se ejecutaron**; son evidencia de observables pretendidos, no un resultado de aceptación.

**Consecuencia de diseño:** una función compartida con selectores explícitos ya resuelve diferencias de slicing sin copiar el builder por capítulo. Mantener dentro el corte simultáneo de curvas y escalas protege una relación real; extraerlo a cada capítulo podría duplicar esa obligación.

## Globals, efectos y aislamiento

| Elemento | Hecho observado | Implicación para componer |
| --- | --- | --- |
| `UHS.R` y `TS.R` | Scripts que leen bindings y asignan `PLOT`; no son funciones invocadas con un objeto explícito. | Mismo archivo es reutilizable; ejecución correcta exige preparar exactamente su contexto. |
| `setup.R` PSHA | Adjunta bibliotecas, carga helpers/datos, define defaults y llama un instalador condicional de hook. | Cargar dos setups en la misma sesión puede afectar nombres, valores y hooks; hace falta comprobar compatibilidad, no sólo nombres de archivos. |
| `global.R` PSHA | `if (!exists(...))` decide si cargar tablas y derivados. | Un segundo libro puede heredar datos o derivados previos; sería una hipótesis de fallo a comprobar, no un fallo ejecutado aquí. |
| `knitBlock(vars=...)` | Superpone bindings nombrados y los restaura al salir; usa `knitr::knit_global()`. | Ya existe contexto temporal para targets. No restaura todos los globals ni promete deshacer mutaciones por referencia. |
| Labels | `knitBlock` reescribe/registra labels; PSHA también tiene un hook condicionado por opción. | Evitar colisiones de labels es una responsabilidad distinta de deduplicar archivos y aislar datos. |
| Outputs/caches | Los tres builders inspeccionados producen objetos gráficos; no declaran escritura de archivos ni cache persistente propio. | No se ha auditado la clausura de outputs/caches del renderer. Aislar un entorno R no separaría por sí solo destinos del filesystem. |

Fuentes para los mecanismos de entorno: [`knitBlock.R:23`](/Users/averrik/Cloud/github/libraries/NGR/lib/R/knitBlock.R:23), líneas 23–64; registro de labels en [`knitBlock.R:131`](/Users/averrik/Cloud/github/libraries/NGR/lib/R/knitBlock.R:131); hook en [`utils.R:160`](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/setup/utils.R:160), líneas 160–179. Los `source()` de PSHA y `Resultants.R` no especifican entorno local; el contrato por defecto de R es el workspace global, leído en el skill instalado [`r/SKILL.md`](/Users/averrik/.agents/skills/r/SKILL.md).

El contraste `kh.R` muestra por qué no todo corte es editorial: además de seleccionar sitio/modelos/probabilidades, une alturas de `ShearTable`, convierte Da/H a porcentaje y limita el dominio a 10%; después detecta duplicados. Es lógica científica que comparte un dibujo, no un nombre de capítulo: [`kh.R:11`](/Users/averrik/Cloud/github/tools/psha/scaffold/scripts/fig/kh.R:11), líneas 11–40. Su caller configura el despliegue por modelos: [`_fig/kh.qmd:3`](/Users/averrik/Cloud/github/tools/psha/scaffold/_fig/kh.qmd:3), líneas 3–28.

## Comparación de alternativas

| Alternativa | Ventajas | Costes y límites | Cuándo encaja |
| --- | --- | --- | --- |
| Mismo archivo compartido, contrato actual | Menor cambio; misma corrección llega a consumidores; ya ocurre con TS y Resultants. | Los scripts globales siguen dependiendo del setup y orden; fuentes distintas deben coincidir en contenido y contrato. | Primera composición cuando el archivo y sus dependencias son realmente comunes. |
| API común, selección del consumidor fuera | Entradas visibles; permite probar dos cortes en una sesión; el capítulo conserva la decisión editorial; facilita compartir sin globals. | No elimina adaptación científica, schema, unidades ni etiquetas; mover cada filtro fuera puede duplicar validaciones coordinadas. | Builders compartidos con variantes reales de datos; conservar dentro la selección que protege invariantes del modelo. |
| Copia independiente por scaffold | Cada libro puede evolucionar bajo otra política científica sin sincronización forzada. | Correcciones divergentes, duplicación y conflictos si terminan en la misma ruta. Mismos bytes hoy no garantizan futura convergencia. | Cuando los contratos difieren de verdad; la identidad debe reflejar la operación o dominio, sin renombrar por capítulo por defecto. |
| Entorno separado por ejecución | Contiene bindings temporales si todas las cargas respetan ese entorno; reduce dependencia del orden. | `source()` global, objetos mutables, hooks, opciones, bibliotecas y CWD requieren tratamiento específico; no separa archivos. `knitBlock` actual no lo implementa. | Cuando compartir proceso es necesario y el contrato de ejecución puede delimitarse. |
| Proceso separado por artefacto | Mayor separación de sesión R para artefactos independientes. | Más carga de setup; no resuelve includes de dos libros dentro del mismo artefacto, ni destinos compartidos. No se verificó aquí cómo QRT separa procesos. | Artefactos autónomos, después de revisar el renderer existente. |

## Recomendación acotada para la composición

1. **No crear builders por capítulo.** Mantener identidades por operación. Separar en la propuesta el recurso compartido de las instancias editoriales que lo invocan.
2. **Conservar la reutilización literal demostrada.** Si dos fuentes aportan iguales bytes y compatible clausura, un destino compartido puede servir a ambas. La igualdad de bytes sola no prueba que sus setups suministren las mismas unidades y tablas.
3. **Antes de compartir un builder divergente, comparar su contrato.** Entradas/schema/unidades; selectors; dependencias y entorno; validaciones; objeto retornado; efectos y destinos. Si sólo cambia la selección editorial, compartir implementación y pasar la selección. Si cambia la semántica, no fundirla bajo una selección ambigua.
4. **Usar las capacidades existentes proporcionalmente.** `knitBlock(vars=..., stem=..., labels=...)` ya sirve para targets temporales y labels, aunque no ofrece aislamiento completo. `Resultants.R` demuestra funciones con datos/selectores explícitos. No hace falta inventar ahora otro dispatcher de builders.
5. **Separar conflictos de archivos y conflictos de ejecución.** El manifest/preflight evita dos contenidos incompatibles en una misma ruta. El contrato de ejecución evita tablas o targets equivocados aun cuando el archivo sea idéntico. Ninguno sustituye al otro.
6. **Dejar abiertas las decisiones que no están respaldadas.** No se propone un nuevo flag, esquema de manifest, cache, registro global de builders, ni promover automáticamente estos scripts a `lib/`. La composición puede acordarse antes de seleccionar una API de migración.

## Comprobaciones que admitirían una futura implementación

Estas son necesidades de aceptación propuestas, **no pruebas ejecutadas** ni permiso para cambiar fuentes:

- Dos invocaciones del mismo builder con cortes distintos producen sus respectivas series/casos y no heredan un target anterior; repetir el primero recupera su resultado original.
- UHS conserva MCE frente a TR, sitio, Vs30 y probabilidades, y sigue rechazando series/Tn duplicadas.
- TS conserva medida/componente, unidades y selección de run; incluirlo dos veces conserva labels distintos.
- Resultants conserva el vínculo entre curvas, escalas, revestimiento y radio; los tests existentes ofrecen observables reutilizables.
- El caso de entorno elegido observa bindings, objetos por referencia, hooks y CWD, y verifica por separado las rutas de assets/caches del renderer.
- Los tres scaffolds reales, cuando se aporten sus masters/manifests, se recorren hasta sus datos antes de declarar la compatibilidad conjunta.

No se encontró un requisito que justifique copiar o renombrar automáticamente los builders por capítulo. Sí se observó suficiente heterogeneidad para rechazar la premisa de que «agnóstico al capítulo» signifique «ejecutable con cualquier setup».
