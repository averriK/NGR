# Contrato CLI NGR

El propietario aprobó implementar el 2026-09-16 la propuesta de un único `pull` para incorporar y actualizar recursos. La implementación vive en `NGR/cli/`, junto al paquete independiente `NGR/lib/`.

La superficie implementada, opciones, selección, propiedad, defaults y límites están en [cli/README.md](../../../cli/README.md). Las decisiones y correcciones del propietario recogidas aquí delimitan el contrato aprobado; una rama del prototipo no lo amplía. Las propuestas históricas init/hydrate/update están sustituidas.

## Decisiones

- `pull`: primera incorporación con `--from` explícito; actualizaciones por asociaciones guardadas. `--source` selecciona asociaciones, los argumentos posicionales seleccionan rutas destino. Son la misma operación.
- `--force`: reemplaza sólo recursos administrados diferentes; las semillas y los conflictos entre fuentes conservan su propia regla. `--dry-run` aplica el mismo preflight sin escrituras.
- `status`: diferencias y procedencia; `--check` convierte drift en salida 1.
- `doctor`: requisitos R comunes y validadores declarados por las fuentes. Las reglas SHA están en su scaffold, no en el motor.
- `render`: conserva los cuatro perfiles y las formas directa/manifest de QRT. Corrección posterior del propietario: nunca renderizan mapas desde QRT. La rama de mapas y `pythonModules` presentes en el prototipo no acreditan un requisito aprobado; no se usarán como contrato de la migración. Los mapas consumidos como productos externos siguen separados de su generación.
- `deploy`: conserva registro (`init`), upload, dominio/TLS/DNS y unbind dentro de la familia. Sólo aquí init tiene un efecto independiente: asociar un sitio. Draft por defecto, producción únicamente con `--prod`.
- `--version`: identidad de distribución. Sin otro verbo operativo.
- Raíz: CWD para todas las operaciones, sin dependencia de Git ni `--project` obligatorio. El cambio respecto del antiguo deploy desde Git root es deliberado.
- Naming aprobado el2026-09-17: `manifest.json` en cada scaffold declara recursos; `manifest.json` en el proyecto reúne artefactos, asociaciones y procedencia. Son objetos de distintas carpetas y responsabilidades. Las fuentes no escriben otro registro `.ngr/`. La migración conserva campos y recibos, actualiza rutas de fuentes y consumidores; no hay fallback ni doble escritura. Un proyecto con `qrt.manifest.json` requiere migración explícita antes de pull/status/doctor o render directo por omisión.
- Las familias de artefactos pertenecen a las fuentes; pueden sembrar una lista vacía. Una lista existente conserva su propiedad de proyecto. La fuente SHA declara 21 artefactos; destinos remotos deben declararse antes de publicar, sin inferir un dominio corporativo.

## Diferencias deliberadas respecto de las referencias

No se mantiene el skip silencioso de init para archivos administrados distintos: requieren permiso de reemplazo. Nunca se migran ni eliminan masters antes del preflight. Se comparan las contribuciones administradas, no los extras del proyecto. Las fuentes comparten carpetas sólo si las contribuciones a una misma ruta tienen bytes y propiedad compatibles. Una fuente no seleccionada conserva sus claims aplicados; force no los cancela.

## Aceptación

El código y una instalación candidata no equivalen a aceptación completa. Referencias exactas en `dev/SoT/cli-fusion/runtime-20260916/reference`, candidato instalado en `dev/SoT/cli-fusion/candidate-install`. Las comprobaciones y límites se registran en el informe de implementación. Las instalaciones personales y las fuentes originales permanecen preservadas.
