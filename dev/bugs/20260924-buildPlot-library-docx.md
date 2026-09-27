# buildPlot: argumento library deprecado y salida de figuras para DOCX

Estado: reportado para diagnóstico; no se ha reproducido un fallo DOCX.
Fecha: 2026-09-24.

El usuario solicita registrar esta observación como bug y comunicarla al agente de NGR. Surgió al preparar el memo local de AR-M2V4D, que debe incluir figuras kmax/kh en DOCX conservando las convenciones gráficas de SHA.

## Hechos comprobados

- En `lib/R/buildPlot.R:110`, `buildPlot()` conserva el argumento `library`. Las líneas 175–181 emiten una advertencia cuando se proporciona explícitamente e indican que se ignora. La documentación del propio archivo, líneas 2–4 y 15–16, describe un constructor Highcharts y declara deprecados `library` y `plot.type`.
- El perfil `/Users/averrik/Cloud/github/projects/AR-M2V4D/yml/_quarto-docx.yml`, leído completo, configura PNG a 300 dpi (líneas 19–20). **No contiene un argumento `library`.**
- Las llamadas a `buildPlot()` en los helpers del proyecto `scripts/fig/kmax.R:43` y `scripts/fig/kh.R:43` tampoco pasan `library`; después ajustan las series de `PLOT$x$hc_opts`.

Referencia del checkout NGR inspeccionado: rama `dev`, HEAD `416d272acb36f8293ca7470baebaa39ae543efa1`. La inspección es de código; no se ejecutó un render ni una reproducción de la advertencia.

## Alcance del diagnóstico solicitado

Determinar si hay un problema de contrato, documentación o callers obsoletos en la salida de figuras para DOCX, y establecer el mecanismo soportado para incorporar los gráficos de `buildPlot` como figuras estáticas. Verificar el recorrido real con una prueba pequeña antes de atribuir el problema al perfil o proponer una corrección.

La deprecación es verificable; por sí sola no demuestra un fallo. No está probado que el perfil DOCX invoque ese argumento ni que falle por él. Tampoco está establecido que `library` permita seleccionar otro backend. El argumento homónimo de otras funciones, por ejemplo `buildTable`, queda fuera de esta observación.

## Precisión sobre el reporte de origen

El plan del memo mencionó juntos el perfil PNG y la deprecación de `buildPlot`. Esa proximidad pudo sugerir una relación causal que no se había demostrado. Este ticket conserva la solicitud del usuario y separa los hechos de la hipótesis para evitar trasladar un diagnóstico inventado.

Solo se entrega el reporte para revisión. No se modificaron la implementación de NGR, el perfil del proyecto ni sus helpers.
