# Handoff: prototipo CAN aprobado y defectos Word todavía sin resolver

Fecha: 24/09/2026. Entrega solicitada por el propietario: «olvida el commit push. decime como resolviste el problema antes. decile al proximo agente que hiciste antes que funciono y que pasa ahora que no funciona».

**No hay una solución verificada en Word para los defectos actuales de portada y apéndices de AR-SABP0. Sí hay dos muestras anteriores identificadas y aprobadas por el propietario. No son el mismo documento ni acreditan la integración con SABP0.** Commit y push cancelados antes de ejecutar staging, commit o push. Este cierre sólo reconstruye evidencia y prepara el relevo.

## 1. Qué se consiguió antes y cómo

### Primera carátula y separadores: candidato NA/CAN 5

Artefacto: [na-candidate-5/srk-prototype-na.docx](../plan/srk-prototype-20260924/na-candidate-5/srk-prototype-na.docx). SHA256 reobservado: `c6d9a30625f8300911d0742aff9116b7ea073907d7a71bd9e174c0c80a16bb19`.

Fuente: [reporte humano Crawford CAN](../lib/CAPR003324_Crawford_SeismicHazard_20260831.docx), SHA256 `7ec329ffa48eea32f473cd9efcf1b39c054bdc43b7f1e8de4d1c0884e83d7605`. No volver al DOTX Mendoza descartado por el propietario.

Método comprobado releyendo [srk_prototype.py](../plan/srk-prototype-20260924/na-candidate-5/srk_prototype.py):

1. `prepareTemplate` (línea 88) extrae del DOCX CAN la tabla de carátula, sus dos párrafos de anclaje, geometría de sección, logo WMF original, estilos y recursos de apéndices. No dibuja otra portada ni inventa una imagen.
2. Convierte los controles de título/cliente/empresa/código/fecha en slots, retira bindings de Crawford, el placeholder de logo de cliente y dos caracteres sueltos. Conserva la geometría de la tabla.
3. Explicita espaciado sencillo y antes/después cero donde faltaban valores, para que la portada no herede los espacios del cuerpo.
4. `_importStyles` (línea 210) importa el cierre de estilos y numeraciones con IDs propios, copia defaults de la fuente y elimina referencias al tema cuando ya existe una fuente explícita. Así la portada conserva sus estilos CAN en el documento NGR.
5. `_replaceText` (línea 68) conserva propiedades del primer run real. La corrección final evitó heredar accidentalmente `VerbatimChar` de otro run; no fue un reemplazo global de tipografías.
6. Los apéndices se seleccionan mediante bookmarks explícitos del spec. Se aplica el estilo CAN Heading8 —Arial 13 pt, negrita, alineación derecha y borde inferior— y se inserta un separador propio. `_appendixTable` (línea 332) materializa el centrado con una celda sin bordes, centrada verticalmente, del tamaño útil de la página; la sección queda alineada arriba para evitar doble centrado. Esta decisión nació de una diferencia entre motores, no se debe repetir ahora una campaña PDF.
7. El cuerpo ya estaba renderizado, con citas y bibliografía resueltas. Python compone presentación y preserva objetos; no son tres renders semánticos independientes.

Los detalles de dimensiones y tipografía están en [artifact.md](../plan/srk-prototype-20260924/na-candidate-5/artifact.md). El paquete del candidato tiene formato `ngr-srk-na-components-1`, tres apéndices y ocho secciones.

**Límite esencial:** este candidato tenía la primera carátula; no incorporaba la portadilla con contactos ni todos los preliminares del reporte humano. El cuerpo aún conservaba la referencia anterior. Su [README](../plan/srk-prototype-20260924/na-candidate-5/README.md) lo declara.

La [revisión histórica de Word](../plan/srk-cover-comparison-20260924/REVIEW.md) registra la aprobación del propietario «ahora se ve bie. implementamos lo spasos siguients?». Esa inspección no modificó código ni DOCX. Por tanto, no inventar un supuesto parche adicional que habría resuelto la última queja de fuentes en Word: el registro no identifica tal parche.

### Muestra con cuerpo CAN y apertura sin warning

Artefacto: [word-review/report.docx](../plan/srk-can-build-20260924/word-review/report.docx), SHA256 reobservado `9c5f03fef95a60d994edd3881a69a9d2ee797c1cee076ffd708f025a72b7ef56`. Formato `ngr-srk-can-components-1`, tres apéndices, ocho secciones.

El [resultado histórico](../plan/srk-can-build-20260924/RESULTADO.md) registra la integración de la referencia CAN y la aprobación «Perfeccto. aprobado». El warning de campos al abrir se trató retirando `w:updateFields`; no se debe reintroducir para forzar el índice.

**Master realmente usado:** [demo-numbered/_master/report.qmd](../plan/srk-can-build-20260924/demo-numbered/_master/report.qmd):

```yaml
chapters:
  - index.qmd
appendices:
  - apx-a.qmd
  - apx-b.qmd
  - apx-c.qmd
```

Su `index.qmd` era una demostración de objetos. No cargaba el `scripts/setup/cover.R` de SABP0. Sus apéndices eran tres archivos con H1 e IDs `sec-demo-apx-a/b/c`; las tablas flextable fijaban anchos explícitos. Tenía bibliografía común y una referencia cuerpo→apéndice. No probó la migración del master SHA, sus preliminares antiguos ni sus builders reales. Presentarlo como garantía de un reporte real fue una extrapolación incorrecta de esta tarea.

## 2. Qué falló al llevarlo a SABP0

La [auditoría de migración](20260924-docx-can-migration-incomplete.md) separa los artefactos históricos de los actuales:

- El master original incluía `_docx/appendices.ES.qmd` o su versión inglesa dentro de `chapters`, sin declarar `appendices`. El contrato R→Python entregaba una lista vacía. No significaba que el motor hubiese recibido cinco apéndices y fallado al formatearlos.
- `master → index.qmd:17–18 → knitCoverPage()` ejecutaba la portada provisional de `cover.R`, además de las firmas. El compositor añadía delante su primera carátula: convivían dos generadores.
- La primera implementación Python no incorporaba la segunda hoja CAN. Su ausencia no se arreglaba exclusivamente cambiando el master.
- Antes hubo intentos detenidos por bookmarks repetidos al reutilizar builders con `labels="keep"`. Están documentados en el [handoff anterior](20260924-handoff-docx-ar-sabp0.md); no confundir ese fallo histórico con los DOCX actuales, que sí fueron entregados.

## 3. Qué está cambiado ahora

En NGR local se añadió `title-page.xml` a los componentes, hidratación de direcciones/web/nombre de archivo, preliminares con numeración romana y cuerpo desde 1, TOC en el perfil, validación explícita de H1/IDs de apéndices y conservación de nivel de esquema 1 en sus separadores. Puntos de entrada: `lib/R/quartoDocx.R`, `lib/R/quartoRender.R` y `lib/inst/docx/compose_docx.py`. El compositor sigue siendo de biblioteca y el CLI lo usa por esa ruta.

En el piloto y en `reports/sha` se modificaron dos masters, se añadieron diez QMD —cinco por idioma— y se corrigieron nueve H3→H2 de Notación. Los apéndices son Notación, GMM, criterios normativos, sitio y Newmark. No borrar los antiguos archivos por su sola existencia; actualmente no los incluyen esos masters.

En SABP0, `cover.R` ya emite sólo firmas para DOCX. Se había omitido trasladar esa corrección al caller compartido de `reports/sha`; se cerró esa omisión tras la instrucción «solo deberia aplicar al html». La fuente compartida ahora genera la portada provisional únicamente en HTML, con HTML idéntico y firmas conservadas según `reports/cover-html/check-2.log` bajo la raíz de evidencia. El piloto conserva además su ajuste previo de salto antes de firmas; no copiarle ciegamente el archivo compartido completo.

**Esta omisión de promoción no explica por sí sola el defecto visual actual: el piloto ya tenía el caller corregido cuando generó los archivos que el propietario abrió.**

## 4. Qué pasa ahora y qué no se sabe

Archivos señalados por el propietario: `~/github/projects/AR-SABP0/docx/`. El propietario confirma que abrió la versión posterior a las 18:34; no atribuirlo a una vista antigua de Word.

| Archivo actual | SHA256 |
| --- | --- |
| `docx.es.docx` | `285cf37947083ec878d3d4c2f589cbd9dc78b7aa44616031bc28a29823937e09` |
| `docx.en.docx` | `8162d5231cc45d98bcbb6774ab131fa72ab95acd92639c4498fca1237c056b09` |

Ambos paquetes reobservados son `ngr-srk-can-components-2`, con seis elementos preliminares, catorce secciones y cinco apéndices registrados. Se encontró una tabla de portadilla con contactos y cinco separadores A–E con estilo `SRKHeading8`. **Esto acredita estructura, no apariencia en Word.**

El propietario reporta cuerpo y tablas correctos; portada sin la segunda parte esperada, otra portada que no corresponde y apéndices con formato incorrecto. No hice una inspección de esos archivos en Word que localice la diferencia exacta. No está demostrado si el defecto restante está en geometría, estilos, secciones, contenido de los preliminares o la correspondencia con CAN. No afirmar «sólo falta migrar el master» ni «todo el Python está roto».

Existe además una diferencia de instalación, verificada por hashes:

- Compositor local y biblioteca aislada: `f5a8ec2c19f88cbeb99e7dc735dd6452c5bb214e85101604c7d796334ea6090a`.
- Biblioteca habitual `/Users/averrik/Library/R/arm64/4.6/library/NGR/docx/compose_docx.py`: `868b010a02a642c04702ad5535da6cc111ed8000e1c2bd13f760350c495c4e17`.
- El recibo habitual informa instalación `2026-09-24T18:39:25Z`. Los últimos renders de esta tarea usaron instalación aislada en `dev/SoT/ngr-repair-build-20260924/installed/`. No asumir que ejecutar el CLI habitual reproduce esos mismos bytes.

## 5. Instrucciones de relevo y errores que no repetir

1. Partir de los dos DOCX actuales y de las dos muestras aprobadas arriba; contrastar el defecto concreto en Word antes de editar más código. La aceptación anterior es de muestras identificadas, no de SABP0.
2. Seguir master→index/includes→render→compositor. Para cada portada observada, identificar qué componente la produjo. Para apéndices, comprobar la correspondencia bookmark→separador y sus estilos efectivos y propiedades de sección frente a la muestra aprobada.
3. Preservar cuerpo y tablas. El propietario confirma que funcionaban en Word y tenían reparación Python. Las diferencias vistas al exportar con LibreOffice no prueban defectos de Word.
4. **No convertir a PDF:** el propietario lo detuvo expresamente. Un parche nuevo de anchos motivado por PDF se retiró; `table-repair/withdrawal.json` conserva los hashes. Las sondas matemáticas nunca se integraron. No reutilizarlas ni instalarlas.
5. No usar la validez XML, un test aprobado ni el código de salida del render como aprobación visual. La [revisión de código](../SoT/ngr-repair-build-20260924/review/REVIEW-FINAL.md) limitó su veredicto a tres correcciones estructurales y declaró Word pendiente.
6. No modificar ciencia, datos ni prosa para resolver formato. No reinstalar ni renderizar desde este handoff sin la siguiente instrucción del propietario. No reanudar commit/push: quedó revocado.

## 6. Estado entregado y localizadores

NGR permanece en rama `dev`, HEAD `24c99a5750f667f521a59fb10b1ddfa14f1eb565`; índice vacío al cierre de la inspección. Hay cambios locales de implementación/documentación/pruebas en quince rutas de `cli/` y `lib/`, además de estos informes y estados. No hubo nuevo commit, push ni staging. `reports` y SABP0 también contienen trabajo ajeno: no hacer reset, limpieza global ni add general.

Evidencia local: `dev/SoT/ngr-repair-build-20260924/`. Conserva baselines, instalación aislada, hashes, logs de render y revisión. Las salidas principales se identifican arriba; los artefactos de desarrollo no se publicaron. [Estado seleccionado](../plan/ngr-repair-build-20260924/STATE.md).

La entrega de este handoff **no declara reparado el formato actual**. El resultado anterior verificable fue la muestra preparada y aprobada; la integración completa con SABP0 sigue sin aceptación visual.
