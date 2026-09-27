# Incidente grave: pérdida de memoria operativa y continuidad del agente en SRK DOCX

Fecha: 24/09/2026.
Estado: abierto para auditoría independiente.
Responsable de las actuaciones descritas: el agente de esta conversación, `/root`.
Solicitud del propietario: «reorta el bug masivo de tu memoria en NGR/dev/bugs».

## Qué falló

No mantuve de manera efectiva la continuidad entre el prototipo SRK, su implementación en NGR, la migración del proyecto y la aceptación visual del reporte real. Recuperé archivos y estados, pero no apliqué correctamente el procedimiento y los límites de evidencia que ya habíamos establecido. El propietario tuvo que recordarme tanto el uso de los builders como el método para revisar el formato.

Además, comuniqué un grado de completitud que las pruebas no acreditaban. Que un prototipo preparado funcionara no demostraba que un master existente de AR-SABP0 produjera el mismo formato. Debí conservar explícitamente esa diferencia durante la implementación, la instalación y el intento de entrega.

Esta ficha registra un fallo observable del agente: recuperación y aplicación insuficientes del contexto, omisión de contratos y afirmaciones excesivas. No establece como causa demostrada un defecto interno del almacenamiento de memoria o del mecanismo de compactación; no hay evidencia técnica de esa causalidad. La responsabilidad por las decisiones y afirmaciones sigue siendo del agente.

## Secuencia observada

1. El propietario proporcionó el reporte humano CAN y pidió un prototipo completo, código de biblioteca utilizado por el CLI, fidelidad en Word y PDF de LibreOffice, y una revisión antes de promoverlo.
2. Preparé un compositor Python y una referencia de estilos. La prueba tenía una estructura preparada: primera carátula y tres apéndices identificados expresamente.
3. Se integró la composición CAN en el commit `864587bfa4d17ced4f5eacc5039478062a314e02`. Después hice el parche local de metadatos descrito en el handoff. Las pruebas registradas no acreditaban la aceptación visual y estructural de AR-SABP0.
4. Los dos intentos instalados de AR-SABP0 fallaron al validar marcadores. El propietario señaló que reutilizar builders sin reescribir etiquetas repite marcadores. Yo no había localizado previamente que una llamada repetida conservaba `labels = "keep"`.
5. El propietario detuvo el trabajo y pidió un handoff. Después señaló diferencias en DOCX nuevos de AR-SABP0. La inspección confirmó que esos archivos sí habían pasado por el compositor, pero contenían `appendices: []`: los masters aún trataban los apéndices como capítulo ordinario. También persistían los preliminares del generador anterior detrás de la carátula nueva.
6. Para investigar un reclamo de formato introduje `pdf2md` como punto de partida, pese a que el procedimiento anterior era convertir a PDF, rasterizar a imágenes e inspeccionar visualmente contra CAN, con OOXML para explicar las diferencias. Extraer texto no valida paginación, posición, tipografía ni composición. Después miré imágenes de sólo las tres primeras páginas del reporte, sin cubrir todos sus apéndices.
7. Ante el recordatorio del propietario, reconocí: «No reconstruí bien el procedimiento anterior al retomar el contexto». También reconocí que había dado una impresión de completitud no justificada y que faltaba migrar `_master`/`_docx`.

## Información que no debí perder ni dejar de aplicar

| Contrato o antecedente | Fallo de continuidad y efecto |
| --- | --- |
| La aprobación de un prototipo tiene una identidad y un alcance concretos | Extrapolé la prueba preparada a la integración con reportes existentes. |
| El compositor recibe apéndices mediante un contrato estructural | No cerré la migración del master real; el código recibió cero apéndices aunque el reporte contenía material llamado Apéndices. |
| El proyecto tenía su propio generador de portada y firmas | No cerré su convivencia o sustitución al añadir la carátula CAN; el resultado mezcló formatos. |
| Los builders reutilizados requieren identidades compatibles con sus referencias | No detecté a tiempo la conservación de etiquetas repetidas entre resumen y cuerpo. |
| La aceptación pedida era visual en Word y LibreOffice | Desvié inicialmente la revisión hacia extracción de texto y la cobertura visual posterior fue parcial. |
| Motor, recursos, prototipo y proyecto son objetos diferentes | No mantuve una demostración completa desde el master real hasta el DOCX que el propietario abrió. |

## Impacto comprobado

- El propietario obtuvo un resultado distinto del formato esperado y tuvo que explicar nuevamente el problema y el procedimiento de revisión.
- Dos intentos propios no entregaron un DOCX nuevo por la colisión de marcadores. Los archivos anteriores quedaron preservados en esos intentos.
- Los DOCX posteriores examinados tenían primera carátula CAN, preliminares anteriores y cero separadores CAN de apéndices. La ficha técnica enlazada abajo conserva sus hashes; esos renders posteriores no se atribuyen a mis dos intentos fallidos.
- Hubo retrabajo de diagnóstico, pérdida de confianza y necesidad de auditoría independiente del código y de mis afirmaciones.
- No se ha demostrado corrupción de datos científicos. Tampoco se ha certificado que toda la implementación NGR esté libre de regresiones. No deben sustituirse estas dos limitaciones por una declaración de daño total o de ausencia de daño.

## Evidencia y puntos de entrada

Leídos para registrar este incidente:

- [Handoff de cambios, fallos y responsabilidad](20260924-handoff-docx-ar-sabp0.md): commit CAN, once archivos del parche local, comandos, resultados y límites de atribución.
- [Migración CAN incompleta](20260924-docx-can-migration-incomplete.md): estructura real de masters, manifests internos, preliminares y cobertura visual.
- [Estado de la auditoría](../plan/sabp0-docx-format-audit-20260924/STATE.md): revisión cerrada como diagnóstico; implementación detenida. Su `DONE` no constituye aceptación del reporte.

Las fichas anteriores localizan logs, DOCX intermedio, hashes, manifests de extracción y PNG de las páginas inspeccionadas. La conversación conserva los recordatorios del propietario y mis reconocimientos de las fallas. No se vuelven a ejecutar renders ni pruebas para escribir este reporte.

## Condiciones para cerrar el incidente

El registro del incidente no lo resuelve. La auditoría debe:

1. Separar qué se prometió, qué se implementó, qué se migró y qué se comprobó, con identidades de artefactos y cobertura explícitas.
2. Reconstruir el procedimiento visual acordado y el contrato master → Quarto → Python → DOCX; los resultados de extracción de texto o tests de biblioteca no sustituyen esa aceptación.
3. Resolver o declarar pendientes las páginas preliminares, los apéndices, las referencias y la migración de proyectos antes de afirmar que el formato real reproduce CAN.
4. Demostrar continuidad al retomar: conservar la fuente CAN seleccionada, el prototipo aprobado, los límites conocidos, los cambios ajenos y las órdenes de detenerse, sin exigir que el propietario los vuelva a explicar.
5. Informar honestamente las páginas y motores revisados y distinguir cierre de una tarea administrativa de aceptación funcional del producto.

No se modificó código, instalación, reporte ni datos del proyecto al registrar esta ficha. No se solicita al propietario que vuelva a validar decisiones ya dadas. La implementación continúa detenida; el siguiente agente debe auditar antes de promover nuevas afirmaciones o cambios.
