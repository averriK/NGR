# Interacción CLI y biblioteca NGR

2026-09-16. Código leído tras conectar main.R; aceptación por objeto y plataforma
en [LOCAL-VALIDATION.md](LOCAL-VALIDATION.md).

## Frontera implementada

La CLI consume las operaciones de NGR que necesita; no tiene que consumir toda
la biblioteca. Su único archivo R de runtime es [cli/main.R](../../../cli/main.R):
carga el paquete instalado, identifica sus recursos distribuidos, pasa argumentos
y traduce condiciones a códigos de salida. Los launchers Bash, CMD y PowerShell son mínimos.

| Responsabilidad | Propietario actual |
|---|---|
| Argumentos, ayuda y despacho | [cliNgr.R](../../../lib/R/cliNgr.R) y cliResources.R, privados de NGR |
| Incorporación, comparación, conflictos y recibos | [resources.R](../../../lib/R/resources.R): pullResources, compareResources, checkResources |
| Render individual, staging, YAML, firma y entrega | [quartoRender.R](../../../lib/R/quartoRender.R), reutiliza quartoYaml y quartoRenderStamp |
| Selección y preflight del lote | [quartoRenderManifest.R](../../../lib/R/quartoRenderManifest.R), con lectura común de artefactos |
| Registro, upload, dominios/TLS y baja local | [netlify.R](../../../lib/R/netlify.R): netlifyRegister, netlifyDeploy, netlifyDomain, netlifyUnbind |
| Reparación DOCX | lib/inst/docx/fix_docx.py, recurso privado del paquete sin cambio de algoritmo |
| Compatibilidad al instalar CLI | [install/cli/checkRuntime.R](../../../install/cli/checkRuntime.R), consume install/requirements.R |
| Instalación y mantenimiento común | install/; entradas install.sh e install.ps1 |

Se retiraron los drivers resources.R/render.R, el guard del runtime y el motor
render.sh. main.R no vuelve a Bash ni invoca QRT/PSHA. NGR se carga mediante el
mecanismo normal de bibliotecas R; no se usa source() sobre lib/R del checkout.
Las nueve operaciones públicas de recursos/render/Netlify funcionan como APIs R.

## Herramientas y límites

Quarto produce documentos; Netlify CLI transporta operaciones del proveedor.
fix_docx conserva Python por decisión del propietario. El motor de recursos es R.
Para copiar enlaces simbólicos en Windows, quartoRender llama sólo a os.symlink
de Python estándar: R base falla por privilegios y fs crea junctions. No se
introduce otro motor de manifests/copia/recuperación en Python. La consulta de
enlaces usa fs declarado en Imports. Esas diferencias tienen pruebas focales.

El backend install/cli/install.py conserva recibos, preflight y recuperación;
sólo administra la CLI. El instalador común coordina explícitamente biblioteca
y CLI como componentes separados. Ningún comando normal instala dependencias.
La instalación personal no fue sustituida en estos ensayos.

Los artefactos static y el kind legado map representan productos externos:
render no ejecuta sus productores. Deploy sube salidas existentes con --no-build.
Los ensayos Netlify usan proveedor simulado; no certifican el servicio remoto.

## Trabajo restante de la fusión

La separación CLI/biblioteca está implementada; cerrar el prototipo de comandos
no completa la migración científica de scaffolds. Los builders SHA conservan
sus consumidores actuales hasta una comparación específica. Reutilizar APIs de
dibujo no significa trasladar selección científica o todo setup a NGR.

[FUNCTION-MIGRATION.md](FUNCTION-MIGRATION.md) y [COMPOSITION.md](COMPOSITION.md)
mantienen el reparto de carpetas, builders y fuentes. Todos los masters y sus
cadenas efectivas siguen en la aceptación global. AR-M2V4D/sha aún requiere la
entrada MCE pendiente; el primer deck no cubre libros ni capítulos. QRT/PSHA
permanecen instalados como referencias sin mantenimiento futuro.
