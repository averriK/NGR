# Implementación candidata NGR — 2026-09-16

## Resultado

CLI propia en `cli/`, instalada para estas pruebas en
`dev/SoT/cli-fusion/candidate-install/bin/ngr`. Paquete R independiente en `lib/`,
sin cambios de implementación de esta tarea. La candidata carga NGR instalado;
no ejecuta qrt ni psha como backend.

Superficie: `pull`, `status`, `doctor`, `render`, `deploy`, `--version`.
Contrato y parámetros en [cli/README.md](../../../cli/README.md).
`pull` incorpora y actualiza con el mismo contrato, registra selección y fuentes
en `qrt.manifest.json`, preflightea todas las contribuciones implicadas, protege
semillas y deja intactos extras y datos científicos. Los permisos de reemplazo
local no resuelven incompatibilidades entre fuentes.

El scaffold de prueba `/Users/averrik/Cloud/github/reports/sha` añade únicamente
`ngr.source.json` y `scripts/setup/checkParameters.R` a sus 766 archivos iniciales.
El manifest lleva los 21 artefactos del seeder PSHA a la fuente y declara propiedad
de los recursos. El validador de parámetros pertenece a SHA, no al motor NGR.
Los destinos Netlify deben declararse explícitamente antes de publicar.
No se han extraído todavía builders a nuevas funciones R.

## Identidades SoT

- Referencia: `dev/SoT/cli-fusion/runtime-20260916/reference/`; 400 archivos QRT,
  771 PSHA y 39 de NGR instalado. `SHA256.json` identifica cada archivo. Al terminar
  se verificó que las tres instalaciones y sus referencias conservaban esos bytes.
- Scaffold PSHA original: sigue idéntico a la referencia congelada
  `dev/SoT/cli-fusion/scaffold-20260916/reference` mediante `diff -rq`.
- Candidato completo: `dev/SoT/cli-fusion/candidate-SHA256.json`, SHA-256
  `d93c3768a68fc82852138a421b0a5c05f30d335233cb5446f6cc127d2ae3d404`.
- Los 402 archivos declarados por `cli/manifest.json` coinciden byte a byte con
  la instalación candidata. Los recursos de presentación copiados conservan los
  bytes del scaffold QRT preservado.
- R 4.6.1; NGR 0.3.11 en
  `/Users/averrik/Library/R/arm64/4.6/library/NGR`; R normal y `--vanilla` resolvieron
  esa misma instalación. Dependencias cargadas, versiones, rutas y MD5 DESCRIPTION
  en `runtime-20260916/R-dependencies.json`.
- Quarto 1.9.35; Python 3.12.11; jq 1.8.2. Publicación comprobada con un sustituto
  local de Netlify, no con el servicio remoto.
- `baseline-contract.json` conserva la condición nueva: ambos ejecutables
  originales rechazan `pull --from` con salida 1 sin escribir en el proyecto;
  NGR incorpora y compone las fuentes mediante esa interfaz.

## Comprobaciones ejecutadas

Fase: diagnóstico y aceptación local de esta implementación; no certificación
de release ni autorización de publicación. Se ejecutaron los checks afectados
tras cada cambio pertinente, sin repetir los renders que ya eran equivalentes.

| Check | Resultado observado |
|---|---|
| 8 pruebas de recursos | Incorporación/actualización, conflictos antes de copiar, fuente no seleccionada, procedencia parcial, semillas, masters, datos `oq/`, dry-run, drift, rutas/symlinks, colisiones de mayúsculas, manifest personalizado, recursos retirados y restauración tras fallo de escritura. Todas pasaron. |
| 2 pruebas de render | Cinco renders reales por cada CLI: HTML, RevealJS, libro HTML, DOCX simple y libro DOCX; y ejecución deduplicada de mapas/estáticos con preflight de dependencias declaradas. Pasaron. |
| 4 pruebas de deploy | Registro/creación, lookup/cuenta, draft/producción, no-build, dominio/TLS/DNS, rebind, unbind, manifest/selecciones, dry-run sin invocar proveedor, preflight y rechazo de retarget. Pasaron contra proveedor simulado. |
| 2 pruebas de instalación | Instalación, actualización, rechazo de distribución incompleta/archivos ajenos, desinstalación y funcionamiento desde una instalación y consumidor fuera del checkout. Pasaron. |
| Composición SHA real | `pull --from ngr styles yml lua bib/apa.csl`, después `pull --from .../reports/sha/ngr.source.json`, `status --check`, `doctor` y plan de render de los 21 artefactos: todos salida 0. Log `dev/SoT/cli-fusion/sha-project.log`. No se renderizaron reportes científicos. |
| Integridad | Referencias e instalaciones originales sin cambios; R instalado sin cambios; runtime candidato igual a distribución; Bash y siete archivos Python parsean; `git diff --check` del alcance propio sin errores. |

En los diez renders, las entradas conservaron sus hashes. Coincidieron los textos
visibles de los HTML examinados y, para ambos DOCX, los XML de contenido, estilos
y numeración. Se comprobaron contenido esperado, tablas autofit y apéndice. No se
exigió igualdad del contenedor ZIP ni de timestamps.

Una aserción del test de instalación fuera del checkout falló inicialmente por
comparar `/var/...` con su ruta física `/private/var/...`; la operación ya había
terminado correctamente. Se corrigió la expectativa para comparar rutas
canónicas y esa prueba pasó. No se cambió el producto para ocultar ese resultado.

## Revisión estructural y diferencias deliberadas

Se revisó el alcance propio desde superficie hasta expresiones. Recursos y
render/publicación conservan límites distintos: propiedad/copia/procedencia frente
a productores y proveedor. La CLI reutiliza el motor observado de QRT con cambios
acotados; no mantiene sus antiguos seeders ni dos motores de copia.

Correcciones de la revisión: comprobar dependencias de cada alias de mapa antes
de deduplicar la ejecución; no eliminar una instalación previa si falla su primer
rename; conservar recuperación si falla rollback; validar archivos de distribución
antes de sustituir; proteger también `OQ`/`GMSP` en volúmenes sin distinción de
mayúsculas. Se quitaron imports no utilizados. Los checks afectados pasaron y la
última pasada no encontró otra reducción o cambio justificado por el contrato.

Cambios intencionales frente a QRT/PSHA:

- Un `pull`, con rechazo de diferencias administradas sin permiso en ambos usos.
- CWD uniforme, también para publicación; no requiere raíz Git.
- Sin movimiento/borrado previo de masters, ni eliminación de recursos retirados.
- Familias de artefactos y reglas de parámetros pertenecen a la fuente.
- Dependencias de mapas mediante `pythonModules`; Kashima deja de ser un requisito
  impuesto por el motor a cualquier mapa.
- Se conservan `qrt.manifest.json` y los campos de procedencia consumidos por TOC,
  transmittal y renderStamp. Las asociaciones/claims se agregan en ese mismo archivo.

## Límites y siguiente fase

Aceptación local del candidato, no aceptación de toda la sustitución en producción.
Quedan un piloto científico con proyecto/artefactos seleccionados, extracción
progresiva de builders con coordinación de `lib/`, migración de consumidores y
pruebas reales Netlify con destinos definidos. Las pruebas de mapas cubren la
orquestación y las dependencias, no un producto cartográfico científico de Kashima.
Los renders controlados no certifican todos los capítulos ni su contenido científico.

No hubo reinstalación personal, commit, push, publicación remota ni retirada de
PSHA. Cambios concurrentes en `dev/lib/` y `dev/ARCHITECTURE.md` pertenecen a la tarea
de mantenimiento coordinada y se dejaron intactos.
