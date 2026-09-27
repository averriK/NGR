# Bug NGR: el render anuncia una ruta interna como salida

Fecha: 2026-09-21. Reporte solicitado por el propietario para `aom-v0`.
Estado: reportado; sin reparación ni nueva ejecución.

## Incidente

Al regenerar el libro AR-S2L1W, el propietario recibió:

```text
Output created: _ngr-output/index.html
```

La ruta no permite a un usuario que usa NGR por primera vez encontrar su
informe. El mensaje expone el destino interno del render, sin identificar
con claridad la salida final del producto en el proyecto.

El manifest actual de AR-S2L1W, leído para este reporte, declara:
`report` → `_master/book.es.qmd`, perfil `book`, destino `html/book`.
Por tanto, la ruta final que NGR debe comunicar para ese producto es
`html/book/index.html`, una vez que haya terminado correctamente su entrega.
No se está afirmando aquí que el último render del propietario haya completado
esa fase: sólo aportó el mensaje citado.

## Evidencia existente

El mismo mensaje aparece en
`AR-S2J2J/dev/render-20260921/books.log:199,375`, seguido por
`[render manifest] complete` en la línea 377. Sus destinos declarados al
inicio de cada producto son `html/report.es` y `html/report.en`.
El log y su recibo fueron leídos en esta sesión; no se ejecutó otro render.

## Comportamiento esperado y aceptación

- Al completar cada producto, indicar su ruta final real, resoluble desde
  el contexto del usuario, con el alias cuando se ejecuta un manifest.
- No presentar `_ngr-output/index.html` como el resultado entregado.
  AOM/NGR debe resolver cómo tratar ese mensaje del motor durante el render.
- El anuncio de éxito final debe ocurrir después de la entrega del artefacto.
  Si falla esa entrega, el mensaje interno no debe aparentar éxito de NGR.
- Verificar que un usuario pueda localizar el archivo anunciado sin conocer
  los directorios temporales del motor; cubrir las formas directa y manifest
  que mantenga el producto con evidencia de alcance explícito.

El reclamo no se resuelve pidiendo al usuario crear o hidratar una carpeta
`_ngr-output`. Este reporte identifica una falla de comunicación del CLI;
no prueba una falta de insumos ni autoriza cambios de estructura del proyecto.
No se modificaron código, skill, datos o renders.
