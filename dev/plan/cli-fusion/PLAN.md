# Plan vigente: fusión QRT + recursos PSHA en NGR

Actualizado el 2026-09-17 tras contrastar estructura, manifiesto SHA y consumidores.
La entrega e identidad actual están en CLOSURE.md; las pruebas anteriores en LOCAL-VALIDATION.md;
no equivale a aceptación completa de la fusión.

La única continuidad operativa es [STATE.md](STATE.md), seleccionada por
`dev/SoT/ACTIVE.md`. Este plan reúne el alcance y la secuencia; no tiene
un segundo próximo paso independiente del estado.

## Objetivo

Una CLI `ngr` en `cli/` y un paquete R NGR en `lib/`. La CLI instalada
opera desde el proyecto consumidor, funciona fuera del checkout y carga la
biblioteca instalada. Toda la instalación y el mantenimiento de paquetes deben
vivir en `install/`, con entradas macOS/Linux y Windows, según
[la política común](../../../install/README.md). El coordinador posee la migración
de esas herramientas; los comandos normales nunca instalan dependencias.
El propietario exige además un único `cli/main.R` para macOS/Windows, con
launchers mínimos y dominio en la biblioteca. Esa entrada está implementada;
las reglas de lote y publicación salieron de Bash y pertenecen al paquete.

La fusión reúne recursos de múltiples fuentes, informes Quarto y publicación.
NGR proporciona la lógica reutilizable de reporting; cada scaffold conserva
contenido, composición y llamadas consumidoras. Las reglas y datos científicos
conservan sus propietarios. No se convierte NGR en un ejecutor de OpenQuake.

## Correcciones a las últimas preguntas

| Pregunta | Respuesta y límite |
| --- | --- |
| ¿La CLI consume toda NGR? | Consume las APIs necesarias; recursos, render individual/lotes y publicación se proporcionan desde el paquete instalado. main.R es la única entrada R de runtime. |
| ¿Qué falta en la biblioteca? | Migrar los builders compartidos cuya responsabilidad corresponda a NGR, con consumidores y comparación científica. La operación de los comandos ya está en la biblioteca. |
| ¿Por qué Python? | Instalador y fix_docx; además, copia de enlaces en Windows mediante os.symlink estándar tras fallar R/fs en esa plataforma. El motor de recursos es R; ninguna de esas operaciones necesita OpenQuake. |
| ¿Dónde queda fix_docx? | En `lib/inst/docx/`, distribuido una sola vez como recurso privado de NGR y llamado por quartoRender. El algoritmo se conservó byte idéntico. |
| ¿Bash o R para recursos e instalación? | Recursos se implementó en R. La instalación tiene contrato común macOS/Windows y dueño en install/; no se decide por copiar el lenguaje de otro producto. Cada operación conserva juntas sus invariantes y recuperación. |
| ¿Mapas desde QRT/NGR? | El propietario aclaró que nunca los renderizan desde QRT. Se retira ese supuesto. La rama presente en el prototipo y sus pruebas sintéticas no son un requisito aceptado. Consumir o publicar un producto externo no equivale a generarlo. |

Lectura actual: [launcher](../../../cli/bin/ngr),
[adaptadores y frontera](CLI-LIBRARY.md),
[recursos](../../../lib/R/resources.R),
[instalador](../../../install/cli/install.py),
[reparación DOCX](../../../lib/inst/docx/fix_docx.py).
El [setup del scaffold](../../../../../reports/sha/scripts/setup/global.R)
lee resultados de `oq/data/`; esa lectura no acredita una ejecución del motor
OpenQuake por la CLI.

## Contrato ya cerrado

La aprobación «ok. implementa» corresponde a un único `pull`.
Las alternativas históricas init/hydrate/update no se reabren.

| Interfaz | Responsabilidad |
| --- | --- |
| `pull` | Incorporar y actualizar; primera fuente explícita con `--from`, luego asociaciones guardadas; `--source` y rutas acotan la selección |
| `status` | Comparar; `--check` convierte diferencias en salida 1 |
| `doctor` | Comprobar requisitos y validadores declarados por las fuentes |
| `render` | Producir documentos, libros y presentaciones desde entrada/perfil o manifest |
| `deploy` | Publicar salidas existentes; init, domain y unbind pertenecen a esta familia |
| `--version` | Identificar la distribución |

Raíz por omisión: CWD del consumidor; sin `--project` obligatorio.
`--force` permite reemplazar recursos administrados diferentes, nunca semillas
ni incompatibilidades entre fuentes. `--dry-run` mantiene el preflight sin
escribir. Detalles y límites: [CONTRACT.md](CONTRACT.md) y
[manual del prototipo](../../../cli/README.md). Una rama documentada como
presente en el prototipo no amplía el contrato aprobado.

## Carpetas, fuentes y builders

- Cada libro mantiene fuente y manifest propios, con mapeos explícitos.
  El motor no enumera temas PSHA/blasting/SSEL ni requiere una carpeta por tema.
- En el destino pueden compartirse `_chapters/`, `_fig/`, `_tbl/`,
  `_master/` y demás rutas. Nombres diferenciados ayudan; no prueban que
  todos los recursos, labels, parámetros o entornos de ejecución sean compatibles.
- `manifest.json` reúne artefactos, asociaciones y procedencia por archivo.
  No se agrega otra base de datos en `.ngr/`. El preflight considera también
  las contribuciones ya aplicadas de fuentes no seleccionadas.
- Se preservan parámetros, semillas, masters editables, extras y datos
  `oq/` y `gmsp/`; un pull no elimina recursos retirados ni mueve masters.
- Los builders reutilizables de representación se consumen mediante funciones
  con argumentos y retorno explícitos. Primero se reutiliza `buildPlot`,
  `buildTable`, `knitBlock` y las APIs pertinentes; no hay una exportación
  por script ni un dispatcher universal por capítulo.
- La selección editorial pertenece al scaffold/proyecto. Las transformaciones
  científicas compartidas pertenecen a su biblioteca responsable. No se traslada
  todo `setup.R` o todo `scripts/fig/` mecánicamente a NGR.

[COMPOSITION.md](COMPOSITION.md) conserva el análisis y sus alternativas;
[FUNCTION-MIGRATION.md](FUNCTION-MIGRATION.md) precisa la propuesta de reparto.
Sus hipótesis sobre otros temas no equivalen a renders conjuntos aceptados.

### Organización y composición pendiente

La fuente SHA ya existe en `~/github/reports/sha`, con `manifest.json`.
Es la copia de trabajo del scaffold PSHA, no un informe ni una copia de su CLI.
No existe `reports/psha`. No se propone duplicar o renombrar SHA por ahora.
Otros libros pueden ocupar carpetas hermanas —por ejemplo blasting o SSEL—
o vivir en otros repositorios. Esas ubicaciones son propuestas, no fuentes
creadas, inventariadas o aceptadas.

En el proyecto consumidor, conservar un solo `_master/`, `_chapters/`,
`_fig/` y `_tbl/`, más sus parámetros y datos. Cada manifest fuente mapea
sus recursos a esas rutas. La incorporación y actualización se hacen con
`pull`; un único `manifest.json` registra las fuentes y la procedencia.
NGR no compone automáticamente un nuevo master mezclando los libros.

Los builders de representación compartida pertenecen a la API de NGR;
los bloques del scaffold los llaman con los datos seleccionados. Eliminar
copias de builders requiere migrar y comprobar sus consumidores. Hasta ahora
esa sustitución está terminada sólo para UHS/MCE. Los scripts de selección,
setup y demás builders existentes siguen presentes donde aún son necesarios.

Antes de admitir un segundo scaffold real, revisar sus recursos raíz, setup,
esquema de parámetros y nombres de artefactos junto con SHA. Diferentes bytes
o propiedad para una misma ruta producen un conflicto previo a copia;
`--force` no arbitra entre fuentes. Extraer un builder común no resuelve por
sí solo un `params.yml` incompatible ni funciones homónimas de setup.
La prueba decisiva pendiente es la composición efectiva de dos fuentes reales,
con sus masters y datos; no otra demostración del motor con fixtures.

### Naming aprobado

El propietario aprobó `manifest.json` el2026-09-17 y pidió implementar y probar.
El scaffold declara recursos. El proyecto tiene otro manifiesto porque registra composición,
artefactos y procedencia de lo incorporado; ese estado no pertenece a la fuente
compartida por varios proyectos. No son dos manifiestos paralelos del proyecto.

Contrato: `manifest.json` en la raíz del scaffold y `manifest.json`
en la raíz del proyecto, nombrados por el objeto y distinguidos por su contexto.
Sin prefijos de motor ni calificadores sin una distinción real. Los esquemas
y responsabilidades siguen siendo distintos; el nombre común no los fusiona.
La migración cambia conjuntamente productores, lectores, llamadas y pruebas.
`scripts/setup/toc.R`, `transmittal.R` y `utils.R` de SHA leen el nombre nuevo.
Los proyectos existentes deben renombrar su manifiesto y actualizar las rutas
de fuente persistidas sin perder artefactos ni recibos. No hay fallback ni doble
escritura; se rechaza el estado antiguo antes de copiar. El proyecto científico
AR-M2V4D original permanece intacto; la comparación usa copias SoT.

La revisión de `install/README.md` y `dev/ARCHITECTURE.md` de NGR, gmsp,
newmark, hazard, dbAudit y zot confirma el reparto común `lib/`, `cli/`,
`install/`, `dev/` y las entradas macOS/Windows. Los documentos no están
completamente sincronizados: NGR conserva instrucciones antiguas de docs/Jekyll
y algunas reglas de privilegios difieren. Esas divergencias se comunicaron al
coordinador propietario de la política común; no se consideran excepciones
arquitectónicas decididas por esta tarea.

## Qué está comprobado y qué sigue pendiente

Estado y evidencia por tramo:

- `pullResources`, `compareResources` y `checkResources` están implementadas en
  `lib/R/resources.R`; `cli/main.R` carga el paquete instalado y su
  entrada de argumentos. La referencia Python y las identidades de pruebas se
  conservan en `dev/SoT/cli-fusion/resources-api-20260916/`.
  candidate-4.log registra 15 pruebas aprobadas; candidate-install coincide con
  fuente/recibo/candidato aceptado en ese tramo. La identidad vigente de ensayo
  se registra en LOCAL-VALIDATION.md.
- `quartoRender` proporciona render individual completo y usa fix_docx desde
  el paquete. Comparación de cinco casos con QRT y API instalada independiente:
  `render-api-20260916/`. quartoRenderManifest proporciona el lote; las cuatro
  operaciones Netlify y su despacho están ahora en la biblioteca.
- La extracción previa de `quartoRenderStamp` conserva su comparación aprobada;
  no se repitieron renders sin cambios. Cada tarball y su alcance constan en
  LOCAL-VALIDATION.md; un número de versión compartido no acredita identidad.
- La entrada MCETable real permitió completar SHA y aceptar la familia UHS/MCE.
  Los cuatro bloques de esa familia usan `NGR::buildSpectrumPlot()`;
  `reports/sha/scripts/fig/UHS.R` se retiró del candidato tras comprobar sus
  consumidores. CLOSURE.md registra las comparaciones e identidades.
- El backend CLI reside en install/cli; requisitos y guard de instalación tienen
  un solo propietario. Las entradas comunes y herramientas R ya están en install/.
  Se retiró el motor Bash de render/publicación; no se migró generación de mapas.
- Hay 25 comparaciones de masters registradas: 21 RevealJS y 4 DOCX.
  La corrida CFD permitió comparar once masters SRS y 77 widgets en
  `srs-20260917`; IPSA tiene equivalencia CSS nativa documentada tras un fallo
  de igualdad de assets por bytes. Dinámica/Newmark y los informes completos siguen pendientes
  de ShearTable/DnTable/kmaxTable. El deck sha no acredita `_chapters/` completo.
  Tampoco hay una composición real SHA + blasting/SSEL aceptada.

[LOCAL-VALIDATION.md](LOCAL-VALIDATION.md) conserva comandos, identidades y
límites de las pruebas anteriores. El check del tarball anterior no certifica
los tarballs posteriores. La revisión actual no comprueba ni modifica GitHub
Pages, instalaciones personales, ramas remotas o Netlify.

## Secuencia

1. **Recursos en la biblioteca: cerrado.** API instalada independiente de
   CLI/checkout, comparación pública y conservación de conflictos, semillas,
   selección y procedencia en el dominio ejercitado. Identidad y límites en
   LOCAL-VALIDATION.md; no repetir ese tramo sin cambio material.
2. **Instalación y datos de proyecto coordinados.** Entradas comunes integradas
   en install/; backend CLI separado de instalación R. El mapa acordado
   con Hazard/Newmark/gmsp resolverá las raíces científicas una sola vez;
   su esquema pendiente no se inventa en el motor de recursos.
3. **Lotes, publicación y main.R implementados.** APIs de biblioteca, un único
   parser R y launchers mínimos; el motor Bash fue retirado. Pruebas en macOS y
   Windows real con identidades/límites en LOCAL-VALIDATION.md. La publicación
   simulada no sustituye aceptación remota con destinos autorizados.
4. **Builders y consumidores.** Trabajar en `reports/sha`, preservando
   `tools/psha`. Reutilizar APIs primero; extraer sólo una familia con
   consumidores y comparación definidos. Coordinar `lib/` con el orquestador
   contra una identidad estable del paquete; no editar el trabajo ajeno de
   `install/` común ni `dev/ARCHITECTURE.md`.
5. **Aceptación completa.** Conservar el oráculo SRS con CFD y resolver
   las entradas de dinámica/Newmark para los 12 masters pendientes, hasta sus bloques/datos. Cubrir HTML, libros, RevealJS, DOCX,
   recursos estáticos y productos externos realmente consumidos. Separar
   pruebas Netlify simuladas de efectos remotos con destinos autorizados.
6. **Migrar consumidores y conservar referencias.** QRT/PSHA dejan de mantenerse
   y permanecen instalados. El propietario los desinstalará más adelante cuando
   NGR funcione completamente; no hay retirada automática. Sus capítulos y
   recursos permanecen. Instalación personal y publicación continúan aplazadas.

## Skills y continuidad

Se releyeron las copias instaladas de `code` y sus veinte tarjetas,
`sot`, `r` y mecánica de paquetes, `bash`, `python`, `qrt` y su
referencia de render, y `datatable`. Sus árboles coinciden con las releases
del catálogo aprobado.

- `code`: requisitos observados, reutilización, responsabilidades y revisión
  estructural; no crear mecanismos por copiar otro CLI.
- `sot`: antes de modificar implementación existente; referencia exacta,
  candidato identificable y comprobación que observe el cambio real.
- `r`, `bash`, `python`: según el código revisado/modificado.
- `datatable`: sólo cuando se usa/revisa su interfaz; no por todo código R.
- `qrt`: operaciones consumidoras de la referencia instalada; no autoriza
  mantener sus fuentes ni transforma una mención del skill en uso del propietario.
- `cran` corresponde a una auditoría CRAN; `git` a mutaciones Git
  explícitamente autorizadas. Ninguna forma parte de esta revisión documental.

El selector y el estado se conservan en el `dev/` existente. Las tres misiones
de investigación están terminadas y no se relanzan. Los planes históricos de
QRT son antecedentes, nunca una segunda continuidad o aprobación automática.
