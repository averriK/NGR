# Piloto SHA y extracción de builders a NGR

Secuencia corregida el 2026-09-16 por instrucción del propietario: antes de cualquier prueba del piloto debe estar preparada una versión mínima de ngr que reúna QRT y la incorporación/actualización de recursos PSHA. Los ejecutables anteriores se conservan como referencias SoT, no como runner del candidato.

Actualización 2026-09-17: el primer intento AR-M2V4D/sha falló por MCE ausente;
posteriormente se obtuvo esa entrada real y se completó su comparación.
[CLOSURE.md](CLOSURE.md) identifica el paquete, la CLI y las 14 comparaciones de
masters registradas, junto con los 23 pendientes. UHS/MCE usa la API instalada;
las demás familias no se declaran migradas. Los pasos de preparación siguientes
son antecedentes, no instrucciones para repetir copias o volver a seleccionar
verbos. La composición real con otros scaffolds aún requiere su revisión.

## Organización

| Objeto | Ubicación y finalidad |
|---|---|
| PSHA original | `/Users/averrik/Cloud/github/tools/psha`, junto con su instalación actual, permanece como referencia del producto existente. |
| Scaffold candidato | `/Users/averrik/Cloud/github/reports/sha`: recursos editoriales y consumidores en desarrollo. No es el directorio de datos/salidas de un informe concreto. |
| Recursos de referencia | `/Users/averrik/Cloud/github/libraries/NGR/dev/SoT/cli-fusion/scaffold-20260916/reference`: copia preservada, identificada por `SHA256SUMS` y su recibo. |
| Pilotos y candidatos SoT | Bajo `/Users/averrik/Cloud/github/libraries/NGR/dev/SoT/cli-fusion/`, con entradas/salidas distintas para referencia y candidato cuando la comparación lo requiera. Rutas concretas se fijan antes de cada efecto. |
| Paquete NGR | Cambios aceptados llegan a `NGR/lib/`, coordinados con el agente que verifica librerías. Las pruebas cargan un paquete instalado e identificado. |
| Continuidad | Sólo `NGR/dev/plan/cli-fusion/STATE.md`; no se crea otra cadena en reports/sha. |

## Preparación observada

Se copiaron los 766 archivos de tools/psha/scaffold al destino solicitado. Se verificó identidad inicial por diferencias de árbol y SHA-256 por archivo. El [recibo](/Users/averrik/Cloud/github/libraries/NGR/dev/SoT/cli-fusion/scaffold-20260916/RECEIPT.md) identifica la operación y sus límites. La referencia tiene permisos de sólo lectura. No se ejecutó render ni se modificó implementación.

Esta copia es completa del subárbol solicitado: incluye todavía los scripts originales. Su retirada es el resultado de migraciones aceptadas, no una condición para preparar el candidato. No se reejecuta una copia global sobre el candidato después de empezar a editarlo.

## Secuencia propuesta

### 1. Preparar primero la CLI mínima ngr

El propietario aprobó un único pull para incorporación y actualización. El contrato implementado está en CONTRACT.md. Existe una primera instalación candidata propia en dev/SoT/cli-fusion/candidate-install; IMPLEMENTATION.md registra sus comprobaciones locales. REVIEW.md identifica los defectos de interfaz y la integración todavía pendiente. No es aceptación de producción.

Preparar la implementación en NGR/cli/ y una instalación candidata aislada bajo dev/SoT/cli-fusion/, identificando el destino exacto antes de escribirlo. Debe funcionar fuera del checkout, poseer su runtime y recursos necesarios y cargar el paquete NGR instalado. No basta un alias o wrapper que delegue el trabajo en los ejecutables qrt/psha personales. Puede reutilizar su implementación preservada como parte del nuevo runtime, con procedencia y dependencias identificadas.

El instalador de esa CLI no instala, actualiza ni elimina paquetes R. Las instalaciones personales siguen intactas. Preparado el candidato, sus primeras comprobaciones cubren incorporación, actualización, procedencia, conflictos previos a copia, preservación de recursos del proyecto y render. Todas las operaciones del lado candidato pasan por ngr.

### 2. Fijar la referencia y el paquete del piloto

Preservar e identificar los ejecutables QRT/PSHA, helpers, recursos y dependencias del producto anterior para la comparación SoT. Cualquier ejecución comparativa de esas referencias queda después de preparar el mínimo ngr y se distingue de la ejecución del candidato. La referencia no sustituye a ngr si éste no tiene lista una operación.

Identificar el NGR instalado que usará cada lado y caracterizar la diferencia Rscript normal/--vanilla registrada en EVIDENCE.md. Un snapshot del scaffold por sí solo no cierra la referencia de render.

Coordinar con el agente de librerías el punto de partida y los archivos que se van a cambiar. Conservar el objeto de referencia y preparar el candidato SoT pertinente; no copiar el repositorio entero por comodidad.

Instalar el paquete candidato en una librería R exclusiva de la prueba, bajo dev/SoT/cli-fusion/, mediante la operación de mantenimiento del paquete. No reemplazar la instalación personal. Comprobar desde el contexto efectivo del render qué paquete se cargó: ruta y contenido/revisión, además de la versión. No usar `source()` del checkout como sustituto de la instalación.

Esta instalación de prueba está comprobada en LOCAL-VALIDATION.md: paquete 0.3.11 del tarball caec0214ea064aec9fcfd5a6a060599bdc702a1af1a13a020d860601db05cac9, instalado en dev/SoT/cli-fusion/package-20260916/library. Quarto comprobó esa ruta durante el render. Sigue separada del instalador CLI, que no instala, actualiza ni elimina paquetes R.

### 3. Incorporar el scaffold y renderizar mediante ngr

El propietario seleccionó AR-M2V4D y el artefacto sha el 2026-09-16. Su manifest apunta a _master/sha.qmd, perfil revealjs y salida html/sha. La consulta histórica sobre AR-S2L1W queda sustituida. Leer las dependencias efectivas antes de copiar entradas; la selección del piloto no autoriza publicar en sus sitios Netlify.

Elegido el piloto, leer su manifest, master y dependencias efectivas; copiar únicamente las entradas necesarias a un destino SoT explícito. Preservar parámetros y datos científicos existentes, sin recalcularlos ni completar valores faltantes. Comparar también recursos propios del proyecto con el scaffold: una personalización del consumidor no se sustituye automáticamente por la semilla fuente.

Incorporar desde reports/sha al proyecto piloto y comprobar la actualización mediante la CLI ngr y el contrato pull ya aprobado. Renderizar desde ngr con el master/perfil o artefacto seleccionado y salida local de prueba. Comprobar contenido y recursos del artefacto. Un exit 0 sólo acredita el proceso, no la equivalencia científica ni editorial.

### 4. Migrar una familia utilizada por el piloto

Elegir una familia a partir del master efectivamente seleccionado. Identificar sus scripts, bloques llamantes, selecciones, salidas y efectos. Declarar los observables estables y la diferencia deseada: la implementación reutilizable pasa a funciones del paquete, con argumentos/retorno explícitos y sin dependencia del source local retirado.

Implementar el builder/helper pertinente en el candidato NGR y cambiar solamente sus consumidores en reports/sha. Mantener datos y decisiones científicas equivalentes. Reutilizar una función existente cuando ya ofrece el contrato; no añadir una exportación por cada archivo ni trasladar setup completo al namespace.

Comparar referencia y candidato con las mismas entradas aplicables. La comparación observa datos representados, unidades, series, orden, labels/referencias y presentación según lo que cambió; no exige identidad binaria de HTML cuando éste incorpora timestamps. La condición arquitectónica se comprueba aparte: el caller consume la API instalada y no depende del script local que se quiere retirar.

### 5. Retirar la copia sólo después de aceptar la sustitución

Si la comparación acepta la familia, integrar el cambio acordado en lib/ y comprobar la superficie integrada cuando cambie la identidad o el contexto de carga. Retirar de reports/sha los scripts ya sustituidos después de comprobar todos sus consumidores afectados. Si falla, conservar la referencia y el candidato fallido identificado; no seguir extrayendo familias sobre un resultado rechazado.

Repetir sobre la siguiente familia necesaria. El scaffold queda gradualmente como contenido, configuración y consumidor de librerías. Los originales de tools/psha permanecen intactos durante el piloto.

### 6. Ampliar cobertura de la fusión

El propietario precisó que la aceptación debe probar **todos los masters**. El primer deck sha apenas cubre _chapters y no puede acreditar esa superficie. Registrar la cadena efectiva y el resultado de cada master, incluidos los libros y DOCX, sin reducir el inventario al conjunto del primer piloto.

Una primera familia y un reporte aceptados no certifican toda la fusión. Ampliar por las capacidades requeridas: otros artefactos, DOCX, presentaciones, estáticos/productos externos consumidos y operaciones Netlify. La generación de mapas no es requisito de esta migración. Las pruebas remotas requieren destinos definidos y la autorización correspondiente; el piloto local no la implica.

La CLI ngr se utiliza desde el comienzo de los pilotos y se amplía hasta cubrir el inventario completo. QRT/PSHA permanecen instalados como referencias comparativas, sin mantenimiento futuro. El propietario decidirá cuándo desinstalarlos más adelante; no es un paso automático de esta migración. El mínimo inicial no equivale a la aceptación de toda la fusión.

## Criterio de avance

Cada paso aceptado deja una pareja identificada: versión del paquete y revisión del scaffold consumidor, junto con el piloto comprobado. Las actualizaciones del paquete pasan a ser una dependencia explícita; copiar menos scripts no elimina esa obligación. Ni el primer render ni la primera extracción autorizan la retirada de PSHA o las reinstalaciones personales aplazadas.
