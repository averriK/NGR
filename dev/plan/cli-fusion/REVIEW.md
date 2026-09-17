# NGR: estado comprobado y trabajo pendiente

**Actualización posterior:** [LOCAL-VALIDATION.md](LOCAL-VALIDATION.md) registra
las correcciones de interfaz, el build/check real de NGR y su instalación R
aislada, realizados después de «avanza». Este documento conserva la revisión
anterior; sus pendientes de esas tres áreas ya no describen el estado actual.

Revisión del 2026-09-16, solicitada por el propietario tras detener el trabajo.
Alcance exclusivo: NGR, su instalación R, CLI candidata, mantenimiento, publicación
y planes de fusión. No es una auditoría completa de cada función científica ni una
certificación CRAN. No se cambió implementación, instaló software ni publicó Git.

## Conclusión

Existe un prototipo local de CLI, instalado en un prefijo de pruebas y todavía sin
commit. Carga NGR 0.3.11 previamente instalado. No está completada la integración
paquete–CLI–scaffold, la extracción de builders ni la migración de consumidores.
La arquitectura y documentación R están publicadas en main; el prototipo actual,
su manual y los nuevos scripts de mantenimiento no están publicados. dev no está
sincronizada con main.

## Respuestas comprobadas

| Pregunta | Estado observado |
|---|---|
| ¿Se reinstaló R desde el nuevo flujo? | No en esta tarea. La CLI sigue usando `/Users/averrik/Library/R/arm64/4.6/library/NGR`, versión 0.3.11, Built `2026-09-15 18:41:23 UTC`. Su DESCRIPTION no identifica RemoteSha ni RemoteSubdir. No hay recibo que acredite una instalación del NGR actual mediante los nuevos scripts. La instalación de paquete candidata sigue pendiente en PILOT.md. |
| ¿Existe dev/lib/? | Sí: setup, document, build, cran-check, install, rhub-check, package, testMaintenance y runbook cran-release. Son operaciones separadas. La mayoría está sin seguimiento Git; install.R tiene modificaciones locales. |
| ¿Está probado ese mantenimiento? | El log integrado de NGR registra seis grupos PASS sobre un paquete fixture. El núcleo actual coincide con el hash del informe de mantenimiento. Eso prueba límites concretos del mecanismo, no un check CRAN ni una instalación del paquete NGR actual. |
| ¿Está instalada la CLI? | Sí, sólo en `dev/SoT/cli-fusion/candidate-install/bin/ngr`, versión `ngr 0.1.0-dev`. `ngr` no está en el PATH personal observado. |
| ¿Funciona? | Hay implementación y comprobaciones locales previas registradas; el ejecutable arranca. La revisión actual encontró defectos de argumentos y ayuda. No corresponde presentarla como una sustitución terminada o lista para producción. |
| ¿Cuáles son los verbos? | El dispatcher implementa `pull`, `status`, `doctor`, `render`, `deploy` y la opción `--version`. `pull` incorpora y actualiza; recursos no tienen init/hydrate. Publicación aún usa `deploy init`, `deploy domain`, `deploy unbind`. La revisión posterior de convenciones no se completó ni produjo cambios de código. |
| ¿Se publicaron dev y main? | main remoto y local: `3b1493d609f90970752851c6fea582189538dac6`. dev remoto y local: `fbcb9e5753e0ef565202955d4a9e3b3395b34339`. El árbol actual de CLI y mantenimiento está fuera de esos commits. No se publicó este prototipo. |
| ¿Funcionan Pages? | El último run Pages de main, `35020941520`, terminó con build y deploy success. Portal, R, índice R y CLI respondieron HTTP 200. La página CLI publicada todavía dice que la interfaz está planificada: no contiene el manual local del prototipo. |
| ¿Hay plan PSHA/folders/builders? | Sí: PLAN.md, CONTRACT.md, COMPOSITION.md y PILOT.md. La composición de recursos está implementada; la extracción a APIs NGR está propuesta y secuenciada, pero no realizada. Hay observaciones antiguas en los planes que necesitan distinguirse del estado actual. |

## Evidencia y límites

### CLI

Reobservados los 409 archivos de `cli/` contra `candidate-SHA256.json`: ninguna
diferencia. Los 402 archivos de distribución coinciden con la instalación aislada.
Hash del recibo: `d93c3768a68fc82852138a421b0a5c05f30d335233cb5446f6cc127d2ae3d404`.
Esto acredita integridad, no ausencia de defectos.

[IMPLEMENTATION.md](IMPLEMENTATION.md) registra 16 pruebas anteriores: recursos,
render, publicación simulada e instalación; diez renders comparativos y un plan
de 21 artefactos SHA. No se repitió esa batería en esta revisión. No incluye un
informe científico completo ni operaciones reales Netlify. Las pruebas de
instalación están en [test_install.py](../../../cli/tests/test_install.py:15).

Sondas nuevas, mediante el ejecutable instalado y desde el proyecto técnico
`dev/SoT/cli-fusion/sha-project`, sin render ni publicación:

| Invocación | Resultado | Hallazgo |
|---|---|---|
| `ngr pull --help` | salida 0; encabezado `resources.py` y opciones de los tres comandos | Ayuda sin contexto del comando público. |
| `ngr render --manifest qrt.manifest.json --dry-run --unexpected-option` | salida 0; plan de 21 artefactos | Opción desconocida ignorada. `render.sh:941` la acumula y la rama manifest no consume ni rechaza ese contenido. |
| `ngr deploy init --help` | salida 1; sólo usage | La ayuda de esa operación se interpreta como falta de argumentos. |

Estos casos no quedaron cubiertos por las pruebas previas. Deben corregirse y
comprobarse antes del cierre de interfaz; no se implementó una corrección durante
esta revisión.

### Paquete y mantenimiento

[dev/lib/README.md](../../lib/README.md) define las entradas; se leyeron sus scripts
y el núcleo completo [package.R](../../lib/package.R). Desde `NGR/lib/`:

- `Rscript ../dev/lib/build.R <directorio>` construye el tarball y su recibo.
- `Rscript ../dev/lib/cran-check.R <tarball> <directorio>` comprueba ese artefacto.
- `Rscript ../dev/lib/install.R <tarball> <biblioteca-R>` instala ese artefacto.
- `Rscript ../dev/lib/testMaintenance.R` prueba el mecanismo con un fixture.

Son formas de uso, no comandos ejecutados en esta revisión ni destinos elegidos.
El instalador de la CLI es otra operación: `python3 cli/install.py --prefix <ruta>`;
no instala R ni sus paquetes.

`package.R:40` verifica SHA-256; `:100` construye y registra; `:129` selecciona
`--as-cran`, `--run-donttest`, incoming/remote y Suggests; `:145` registra running
antes de comprobar; `:171` instala con destino explícito y verifica versión.
Hash actual del núcleo: `65dc92e5327db356f611c0e27ef78ce1b8a64c0e282ad5d39da305f6ed66fcf4`.

Se leyó el log exacto
`/Users/averrik/Cloud/github/tools/qrt/dev/SoT/common-maintenance-20260916/integrated-NGR.log`
y su REPORT.md únicamente para recuperar evidencia de NGR. El test actual crea
un paquete mínimo versión 0.0.1; simula fallos del checker y varias dependencias.
No equivale a validar NGR 0.3.11 con sus datos, ejemplos, tests y viñetas.

No se localizó en la cadena activa un tarball NGR del nuevo flujo con su check
completo y recibo de instalación. NGR sólo tiene workflow Pages en main: no hay
workflow R-hub ni R-CMD-check allí. `cran-release.R` es un runbook sin acciones;
el envío CRAN no está integrado. Por tanto, hay herramientas de mantenimiento
con pruebas específicas, pero falta cerrar el flujo real para este paquete.

La [lista oficial de CRAN](https://cran.r-project.org/web/packages/submission_checklist.html)
trata R-hub como complemento; un check local o un fixture no certifican la
aceptación. [Writing R Extensions, Checking packages](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Checking-packages)
define el alcance de `--as-cran`. Fuentes consultadas 2026-09-16; no se efectuó una
auditoría contextual de todo NGR bajo esas normas.

### GitHub y documentación

Observados `git ls-remote`, Git local, API de Pages y los jobs del run nombrado.
El último fallo pkgdown visible en la consulta es `33867390102`, del 2026-09-04,
commit `f192453`; es anterior a tres runs Pages exitosos del 2026-09-15. No se
atribuyen a ese fallo antiguo problemas del prototipo no publicado.

Comprobaciones HTTP y contenido sin autenticación:

- [Portal NGR](https://averrik.github.io/NGR/): 200.
- [Paquete R](https://averrik.github.io/NGR/lib/): 200, HTML pkgdown.
- [Índice R](https://averrik.github.io/NGR/lib/reference/index.html): 200.
- [CLI](https://averrik.github.io/NGR/cli/): 200, reserva de interfaz futura.

No se comprobó cada enlace del sitio. El README R además conserva un badge y una
cita con 0.3.3 mientras DESCRIPTION declara 0.3.11: inconsistencia documental
observada, sin afirmar por ella un fallo del paquete.

## Plan existente y brecha de ejecución

La dirección en [COMPOSITION.md](COMPOSITION.md:155) asigna:

- `NGR/lib/`: builders reutilizables de presentación, con argumentos y retornos.
- `NGR/cli/`: recursos, render y publicación, consumiendo el paquete instalado.
- Cada scaffold: narrativa, captions, labels, composición y selección del caso.
- Proyecto: parámetros, datos, semillas y masters editables.

Los manifests permiten carpetas compartidas `_chapters/`, `_fig/`, `_tbl/`, etc.,
sin subcarpeta obligatoria por tema. Las contribuciones incompatibles se rechazan
antes de copiar; `--force` no resuelve conflictos entre fuentes. Las reglas
científicas conservan su propietario; no pasan automáticamente a NGR por parecerse
visualmente dos gráficos.

El candidato `reports/sha/ngr.source.json` mapea esas carpetas y aún incluye
`scripts/`. La cadena UHS leída conserva scripts locales y contexto de sesión.
No se implementó una API de builders PSHA nueva en `lib/`; `git status --short lib`
está vacío. [PILOT.md](PILOT.md:32) propone instalar un paquete candidato aislado,
elegir un master real, migrar una familia y comparar resultados antes de retirar
scripts. Blasting/SSEL y un documento mixto no están aceptados por esas pruebas.

El PLAN original aún dice que no hay ejecutable y propone hydrate/pull; son
observaciones del 2026-09-15, superadas por CONTRACT.md y el candidato. Esta
revisión sirve como índice del estado comprobado, no como aprobación de otra
gramática ni como reemplazo de la continuidad única en STATE.md.

## Secuencia pendiente, sin ejecutarla todavía

1. Corregir los defectos reproducidos y cerrar ayuda/argumentos/verbos contra el
   uso real. Mantener las capacidades ya probadas y una referencia SoT exacta.
2. Construir NGR desde `lib/`, comprobar el tarball con `dev/lib/cran-check.R` y
   verificar una instalación aislada de ese mismo artefacto. Atar la prueba CLI a
   esa identidad; la reinstalación personal continúa como operación separada.
3. Coordinar y extraer una familia de builders utilizada por el piloto elegido;
   migrar sus callers en reports/sha, comparar con la referencia y sólo después
   retirar las copias sustituidas. No trasladar todo setup ni inventar un builder
   universal por capítulo.
4. Ampliar aceptación a los consumidores y capacidades todavía no cubiertos.
   Los efectos Netlify necesitan destinos definidos; conservar QRT/PSHA mientras.
5. Publicar los cambios aceptados y el manual actual mediante el flujo Git
   autorizado, reconciliando dev/main. Verificar el run del commit publicado y
   el contenido público. Esta revisión no ejecuta ni autoriza ese efecto.

No se precisa empezar desde cero. Sí se precisa completar estas brechas antes de
llamar al resultado sustitución aceptada de QRT/PSHA. No se hizo handoff: esta
revisión pudo completarse; otra transferencia, si se pide, deberá usar las
identidades de este informe y STATE.md.
