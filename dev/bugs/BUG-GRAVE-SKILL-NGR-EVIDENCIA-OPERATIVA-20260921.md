# BUG GRAVE — el skill NGR no acredita el procedimiento recomendado

Fecha: 2026-09-21. Destinatario solicitado: tarea `aom-v0`
(`01a0a5b0-d006-7ee3-b2d5-e2748ef82519`, repositorio `agents`).
Prioridad solicitada por el propietario: grave. Estado: reportado; sin reparación.

## Reclamo del propietario

> los parametros del skill deberian ser cosas probadas, no inferidas de un help

El propietario pidió reportar este incidente a `aom-v0`. El problema que se
debe resolver es la procedencia y validación de las recetas del skill, no
defender una recomendación porque una opción aparece en la ayuda instalada.

## Incidente observado

En la tarea `Auditar NGR contra QRT y PSHA`, el propietario pidió los comandos
para regenerar el libro AR-S2L1W con el lector SSM corregido. El asistente
recomendó:

```text
ngr render --manifest manifest.json --only report --root ~/github/projects/AR-S2L1W
```

Ante «no se usa root», el asistente respondió «La ayuda instalada admite
`--root`» y ofreció una variante desde el directorio del proyecto. Cuando el
propietario cuestionó el skill, el asistente volvió a usar la coincidencia
entre skill y ayuda para defender la recomendación. Ése es el fallo de criterio
observado: no aportó aceptación del flujo real solicitado para sostener su
respuesta. La responsabilidad de esa respuesta es del asistente, aunque haya
seguido el mecanismo de consulta prescrito por el skill.

No se ejecutó ese render en este intercambio; el propietario había pedido
sólo comandos. No se adjunta una traza de fallo del parser ni se presenta este
reporte como una reproducción de tal fallo.

## Evidencia del skill distribuido

Leído `/Users/averrik/.agents/skills/ngr/SKILL.md`:

- Líneas 13–19: exige consultar versión y ayudas para resolver la interfaz.
- Líneas 44–49: prescribe seleccionar el proyecto con `--root DIR` para
  CLI 0.3.0-dev o posterior; también describe ejecución desde CWD.
- Líneas 77–87: distingue planes de efectos y pide evidencia posterior a la
  ejecución, pero no vincula la receta recomendada con una aceptación previa.
- `references/render.md:3–12` presenta las formas de render; líneas 46–49
  reconocen que un plan no prueba la ejecución. Esa distinción no impidió
  que el asistente presentara una recomendación como resuelta por el help.

La copia instalada y `agents/skills/ngr` coinciden mediante `diff -qr`, salida
0. `agents/hosts/approved.json` y el recibo instalado declaran la misma release
`46828e0ff9f891f254772f1131a871e743e3536335820ca906270d0fdf398ace`.
`git blame` sitúa la instrucción de raíz en `agents` commit `224824a` del
21/09. La aprobación de distribución y la igualdad de copias no constituyen
por sí mismas aceptación del comportamiento documentado.

La ayuda instalada sí contiene `--root`; ese hecho no cierra este bug.
`NGR/dev/plan/cli-root/RESULTS.md:34–58` documenta pruebas de transporte de
rutas y planes, y declara que no ejecutó renders reales ni Netlify. No se debe
transformar esa cobertura limitada en prueba del libro completo con sus
lectores. Tampoco se afirma que nunca se haya probado ningún uso de la opción.

## Corrección solicitada a AOM/agents

1. Revisar la procedencia de los parámetros y recetas publicados en el skill
   NGR. Cada recomendación operativa debe corresponder a un procedimiento
   probado, con versión, comando, contexto de ejecución y resultado trazables.
2. Usar la ayuda para detectar diferencias de interfaz, no para inferir nuevas
   recetas ni acreditar que funcionan. Separar explícitamente sintaxis
   declarada, aceptación del procedimiento y requisitos del proyecto concreto.
3. Recuperar la evidencia existente; retirar o marcar como no acreditadas las
   variantes cuya aceptación no pueda demostrarse. No añadir parámetros por
   extrapolación de otra herramienta o de una convención general.
4. Probar la corrección del skill con una consulta de «sólo comandos»: debe
   recuperar una receta acreditada, sin lanzar renders/deploys por su cuenta
   y sin defenderla únicamente citando el help. La publicación del skill es
   quien debe acreditar la receta; no trasladar pruebas costosas al usuario
   en cada consulta.

El cierre requiere señalar la receta respaldada y su evidencia, corregir la
fuente y la distribución que corresponda, y demostrar que el agente no repite
la inferencia observada. Repetir `--help` o comparar hashes no basta.

Este reporte no autoriza renders, publicaciones, cambios científicos ni
eliminar opciones del CLI. No se modificaron el skill, NGR ni AR-S2L1W.
