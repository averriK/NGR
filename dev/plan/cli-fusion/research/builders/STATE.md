## Objective

Investigar con evidencia del código si builders en scripts/fig pueden compartirse entre scaffolds PSHA, blasting y SSEL cuando cambia el slicing. Recorrer al menos tres cadenas master → bloque _fig → builder → datos/setup, identificar funciones agnósticas al capítulo, selección de datos, globals, side effects, outputs/caches y dependencias. Separar hechos observados y escenarios hipotéticos. Comparar compartir mismo archivo, API común con slicings fuera, copia por scaffold y aislamiento de entornos. No proponer renombrar builders por capítulo por defecto.

## Rulings

- Misión literal: cli-fusion-builders-composition-20260916. Coordinador: dev/plan/cli-fusion/STATE.md en /Users/averrik/Cloud/github/libraries/NGR. Validar el locator exacto contra Delegations antes de actuar.
- Encargo nuevo del propietario del 2026-09-16: análisis profundo con varios agentes sobre coexistencia de scaffolds PSHA/blasting/SSEL, builders agnósticos al capítulo salvo slicings y fusión de carpetas. Este es análisis previo a contratos, no implementación.
- Escribir sólo en dev/plan/cli-fusion/research/builders/; entregar REPORT.md allí, con referencias absolutas y líneas. No editar fuentes, instalaciones, lib/, proyectos consumidores ni estado del coordinador. No instalar, renderizar, copiar recursos, publicar ni mutar Git.
- Leer skills instalados code y veinte tarjetas antes de análisis de diseño; r/bash/python según fuente revisada; datatable si se usa su interfaz. QRT skill sólo si se opera CLI pública instalada, no como ruta para mantener productor. No sustituir instrucciones de skill por conocimiento improvisado.
- Fuentes de evidencia inicial: /Users/averrik/Cloud/github/tools/psha/scaffold, /usr/local/libexec/psha/scaffold, /Users/averrik/Cloud/github/tools/qrt; proyectos /Users/averrik/Cloud/github/projects/AR-S2L1W y AR-SAD40. Leer antes de atribuir contenido; bounded reads por bytes/líneas; no _ref ni archivos privados ajenos. Plan vigente: /Users/averrik/Cloud/github/libraries/NGR/dev/plan/cli-fusion/PLAN.md. Leer lo pertinente, no reabrir tareas históricas.
- No tomar CONTRACT.md como contrato: propuesta retirada. No están decididos nuevos flags ni mecanismos. La arquitectura contempla manifests fuente, destinos compartidos y procedencia por archivo; el análisis puede criticar y comparar alternativas sin declararlas aprobadas.
- Comunicar avances y hallazgos al coordinador por collaboration. Si contexto se compacta, revalidar locator y abrir este estado. Al terminar, cerrar el Next con evidencia de REPORT.md, dejar Next none y Status DONE; el coordinador hará join.

## Evidence and no-repeat

- Locator exacto validado contra Delegations del coordinador y selector dev/SoT/ACTIVE.md, ambos leídos el 2026-09-16. Skills instalados code + veinte tarjetas, r y datatable leídos; PLAN vigente leído.
- REPORT.md escrito y releído completo: tres cadenas master → bloque → builder → datos/setup (PSHA UHS, PSHA TS/SRS y AR-SAD40 Resultants), contraste kh, límites de knitBlock, globals/efectos, cinco alternativas y recomendación sin nuevas APIs ni contrato aprobado.
- SHA-256 de UHS.R y TS.R iguales entre fuente PSHA, instalación PSHA y AR-S2L1W; hashes completos en REPORT.md. Esa identidad está acotada a dos archivos, no a runtimes ni renders.
- Leídas pruebas existentes de Resultants para conocer observables; no se ejecutó R, render ni prueba científica. No se leyeron scaffolds completos blasting/SSEL; se tratan como escenarios del propietario. AR-SAD40 no se identifica como SSEL.
- Hallazgos comunicados al coordinador. No repetir esta misión ni convertir la recomendación en implementación sin nuevo objetivo del propietario.

NEXT-CLOSED {"evidence":"REPORT.md existe y fue releído completo; contiene tres cadenas sustentadas con rutas absolutas y líneas, comparativa de alternativas y límites explícitos de investigación estática.","id":"cli-fusion-builders-composition-20260916-analysis"}

## Effects

- Creado dev/plan/cli-fusion/research/builders/REPORT.md; actualizado sólo este estado hijo. Sin mutación de fuentes, instalaciones, proyectos consumidores, lib/ ni Git.

## Blocker

none

## Next

none

## Status

DONE
