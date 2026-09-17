# QRT: cómo y dónde se usa

Lectura del 2026-09-15 tras la corrección del propietario. Describe el uso
observado; no aprueba una nueva gramática NGR ni admite un baseline SoT.

## Lugar de trabajo

El usuario trabaja en el **proyecto consumidor**. `qrt` es un ejecutable
instalado, resuelto por PATH; el checkout del productor no es el directorio de
trabajo ni un requisito del consumidor. El [skill instalado](/Users/averrik/.agents/skills/qrt/SKILL.md:9)
y la ayuda pública consultada sitúan scaffold y render en el CWD.

La [guía PSHA](/Users/averrik/Cloud/github/tools/psha/README.md:72) describe,
dentro del proyecto, `qrt init`, `psha init`, `psha doctor`, y después
`psha pull` o una selección como `psha pull --force _fig _tbl _revealjs scripts`.
La instalación de la herramienta y la copia de recursos al proyecto son
operaciones distintas. Los builders se ejecutan después, durante el render.

Hay una diferencia actual de raíz que debe resolverse expresamente para NGR:
la familia deploy de QRT asciende a la raíz Git, incluso en dry-run;
scaffold y render usan CWD. No es evidencia a favor de hacer obligatorio un
selector de proyecto en cada llamada.

## Dos formas de render, ambas reales

- **Fuente y perfil:** las [instrucciones de AR-SAD40](/Users/averrik/Cloud/github/projects/AR-SAD40/AGENTS.md:47)
  prescriben ejecutar desde el proyecto
  `qrt render _master/report.qmd --profile book`. Su
  [master](/Users/averrik/Cloud/github/projects/AR-SAD40/_master/report.qmd:1)
  declara capítulos en `_index/`. El
  [manifest](/Users/averrik/Cloud/github/projects/AR-SAD40/qrt.manifest.json:3)
  contiene además un producto con perfil `html`. Este consumidor no depende
  de seleccionar un libro PSHA para llamar a QRT. Aquí se leyeron las entradas;
  no se ejecutó su render ni se certificó su contenido.
- **Selección del manifest:** en
  [AR-S2L1W](/Users/averrik/Cloud/github/projects/AR-S2L1W/qrt.manifest.json:3),
  `report` identifica `_master/book.es.qmd`, perfil `book`, salida `html/book`
  y su destino de publicación. `toc` usa otro master y `revealjs`. El alias,
  idioma del master y nombre de salida son decisiones distintas ya guardadas
  en el proyecto; la llamada no vuelve a suministrarlas.

El render directo sigue siendo útil aunque exista un manifest editorial.
La fuente de recursos no se vuelve a elegir para cada render: se ejecutan
los archivos que están en el proyecto, con sus perfiles y datos locales.

## Qué pertenece al proyecto

En AR-S2L1W, el [master de libro](/Users/averrik/Cloud/github/projects/AR-S2L1W/_master/book.es.qmd:1)
declara su composición y bibliografías. Su
[portada](/Users/averrik/Cloud/github/projects/AR-S2L1W/index.qmd:12)
llama al [setup local](/Users/averrik/Cloud/github/projects/AR-S2L1W/scripts/setup/setup.R:14),
que carga paquetes instalados, parámetros y datos opcionales del proyecto.
La [introducción](/Users/averrik/Cloud/github/projects/AR-S2L1W/_book/intro.ES.qmd:9)
combina contenido local con includes compartidos. Copiar recursos no equivale
a decidir capítulos ni a reemplazar entradas científicas.

El manifest participa también en el documento: el
[master TOC](/Users/averrik/Cloud/github/projects/AR-S2L1W/_master/toc.es.qmd:23)
incluye un bloque que llama a [toc.R](/Users/averrik/Cloud/github/projects/AR-S2L1W/scripts/setup/toc.R:8).
Ese lector abre `qrt.manifest.json` y construye enlaces con los dominios
declarados. Renombrar el archivo afecta al contenido, además de la CLI.

## Entrega

La [familia pública deploy](/Users/averrik/.agents/skills/qrt/references/deploy.md:9)
sube salidas existentes; permite forma directa y selección por manifest.
`deploy init` registra sitios; `deploy domain` configura dominios;
`deploy unbind` quita una asociación local. Son efectos separados ya expresados
en la interfaz actual. En AR-SAD40, las instrucciones locales seleccionan
`report` del manifest para publicar sólo cuando el propietario lo pide.

## Comprobación ejecutada

- CWD: `/Users/averrik/Cloud/github/projects/AR-S2L1W`.
- Ejecutable: `/usr/local/bin/qrt`.
- Comando: `qrt render --manifest qrt.manifest.json --dry-run --only report,toc`.
- Salida 0: planificó `toc` y después `report`, en el orden del manifest;
  resolvió respectivamente `html/toc` y `html/book`.
- No ejecutó render, builders ni publicación. El resultado verifica ese plan
  local, no datos, contenido, dependencias de ejecución ni salidas generadas.

La ayuda instalada y este plan admiten la salida declarada en el manifest.
La frase del skill que atribuye siempre la salida al stem está desactualizada
en ese punto. El [README de QRT](/Users/averrik/Cloud/github/tools/qrt/README.md:38)
también contiene instrucciones de una etapa anterior, incluido un estado v0
que contradice la ayuda pública; no se usa para definir la interfaz vigente.

## Decisión que falta para la incorporación de libros externos

QRT aporta el contexto de uso anterior. La selección inicial entre cientos de
fuentes externas es una decisión nueva: el plan admite manifest explícito o
catálogo más ID, sin aprobar aún la forma. Se consultó al propietario con una
recomendación concreta: manifest fuente explícito en la primera incorporación
y asociación guardada en el proyecto para las actualizaciones siguientes.
La respuesta no se presume; las otras decisiones de contrato siguen pendientes.
