# Branding & Styling – Analysis and Plan

This document resumes the current state of Quarto branding/styling in the project, the corrections applied, what was learned from the existing docs, and how the corporate Word sample will be used to align SRK branding across outputs.

---

## 1. Qué se corrigió y cómo quedaron organizados YML / SCSS / CSS

### 1.1. Configuración principal de Quarto (`_quarto.yml`)

Estado actual relevante:

- `language: styles/_language-en.yml`
- `format.html`:
  - `brand: styles/_brand.yml`
  - `theme.light: [slate, styles/theme.scss]`
  - `theme.dark: slate`
  - **sin** `css: styles/styles.css` (ya no se aplica CSS de slides a los reportes HTML).
- `format.revealjs`:
  - `theme: simple`
  - `logo: styles/logo.png`
  - `css: styles/styles.css` (CSS específico de slides).
- `format.docx`:
  - `reference-doc: styles/reference.docx` (a reemplazar por una nueva plantilla corporativa basada en `docs/Sample Report.docx`).

**Correcciones clave**:

1. El HTML antes intentaba cargar `psha/styles/theme.scss`; se corrigió a `styles/theme.scss`.
2. Se eliminó `css: styles/styles.css` del bloque `html` para que ese CSS (hecho para RevealJS) no afecte los reportes.
3. Se añadió `brand: styles/_brand.yml` para que el branding YAML se aplique a HTML.
4. Se movieron `_brand.yml` y `_language-en.yml` a `styles/` y se actualizaron las rutas en `_quarto.yml`.

Resultado: ahora HTML usa **brand YAML + tema SCSS**, y RevealJS usa **tema simple + CSS específico de slides**.

---

### 1.2. Branding YAML (`styles/_brand.yml`)

Rol de `styles/_brand.yml`:

- Actúa como **fuente de verdad de marca** para HTML (y potencialmente RevealJS en el futuro):
  - Paleta de colores SRK (azules, grises, acentos).
  - Tipografía base y de encabezados.
  - Overrides de variables Bootstrap (`$body-bg`, `$body-color`, `$link-color`, `$primary`, etc.).
- Actualmente define:
  - Colores base SRK (`srk-blue`, `srk-light-blue`, `srk-accent`, grises, etc.).
  - Colores semánticos (`primary`, `secondary`, `success`, etc.).
  - Tipografías: `Inter` (texto), `Roboto Slab` (encabezados), `Fira Code` (código) para HTML.
  - Defaults Bootstrap para cuerpo, enlaces, bordes, tablas, etc.

**Aún pendiente**: ajustar la paleta y algunos defaults para reflejar 100% el branding observado en `Sample Report.docx` (por ejemplo colores específicos de encabezados y pies de página SRK).

---

### 1.3. Tema SCSS para HTML (`styles/theme.scss`)

Rol de `styles/theme.scss`:

- Define **cómo se ven** los elementos en HTML usando las variables de marca:
  - Títulos (`h1`–`h6`), tablas, callouts, TOC, título de portada, buscador, etc.
- Contiene un bloque `/*-- scss:defaults --*/` más un bloque `/*-- scss:rules --*/`.

Ajustes realizados para evitar conflictos con el brand YAML:

1. Se añadió un **conjunto de variables Bootstrap con `!default`**:
   - `$body-bg`, `$body-color`, `$border-color`.
   - `$primary`, `$secondary`, `$success`, `$info`, `$warning`, `$danger`, `$light`, `$dark`.
   - `$font-family-sans-serif`, `$font-family-monospace`.
   - `$link-color`, `$link-hover-color`.

   Esto permite que `theme.scss` **compile por sí solo**, pero que `_brand.yml` pueda sobrescribir estos valores al aplicarse.

2. Se documentó que las familias tipográficas base vienen del brand YAML; en `theme.scss` se define sobre todo:
   - Serif para encabezados (`$font-family-serif`/`$headings-font-family`).
   - Tamaños relativos y espaciados.

3. Se eliminaron dependencias rotas que producían errores de compilación (por ejemplo, `$link-color` y `$primary` sin definir).

Resultado: `theme.scss` ahora funciona como **capa de presentación** que consume variables del brand YAML, sin pelearse con él.

---

### 1.4. CSS para RevealJS (`styles/styles.css`)

Rol de `styles/styles.css`:

- Archivo pensado casi **exclusivamente para RevealJS**.
- La inmensa mayoría de selectores son `.reveal ...`:
  - Layout de slides, portadas (`.coverSlide`, `.coverChapter`).
  - Logo, footer, número de slide.
  - Tablas, captions, checklists, etc., dentro de la presentación.
- Para HTML normal, solo afecta mínimamente a:
  - Código (`.sourceCode code`) y tablas con clase `.customTable`.

Cambio clave:

- Dejó de aplicarse en `format.html` y se mantiene solo en `format.revealjs`, evitando que la estética de slides contamine los reportes.

---

## 2. Qué se aprendió de la documentación en `docs/README-QUARTO.md`

Del archivo `docs/README-QUARTO.md` se confirma y se refuerza la intención de diseño:

- El proyecto está organizado alrededor de una **configuración unificada**:
  - `_quarto.yml` para todos los formatos (HTML, RevealJS, Word, PDF).
  - Branding centralizado en un archivo de marca (`_brand.yml`, ahora `styles/_brand.yml`).
- Los archivos activos deberían ser:
  - `html_index.qmd` para reportes.
  - `revealjs_index.qmd` para presentaciones.
- Todos los estilos se concentran en la carpeta `styles/`.
- La plantilla Word (`styles/reference.docx`) es el mecanismo previsto para controlar estilo DOCX.

Desalineación menor detectada:

- El README aún asume `_brand.yml` y `_language-en.yml` en la raíz, mientras que ahora se usan `styles/_brand.yml` y `styles/_language-en.yml`. Esto es solo documentación; la configuración real ya apunta a `styles/`.

Conclusión: la documentación conceptual es sólida (un único punto de verdad para configuración y estilos), y solo necesita un pequeño ajuste de rutas para reflejar el estado actual.

---

## 3. Análisis del Word corporativo `docs/Sample Report.docx`

Se extrajo `word/styles.xml` del DOCX para inspeccionar los estilos corporativos SRK.

### 3.1. Estilos base

- `w:docDefaults`:
  - Tamaño de fuente por defecto: `w:sz w:val="22"` → 11pt.
  - Color del texto por defecto: negro (`#000000`).
  - Interlineado por defecto: `w:spacing w:before="180" w:line="264"` → ~1.3 líneas con espacio antes.
- Estilo `Normal`:
  - Idioma: `en-CA`.
  - Fuente heredada del tema (no aparece el nombre explícito aquí; se deduce de la plantilla de Word, probablemente familia tipo *Aptos* dada la presencia de `Aptos SemiBold` en otros estilos).

### 3.2. Encabezados

- `Heading1`, `Heading2`, `Heading3`… definidos en cascada, vinculados a estilos `TOC1Heading`, `TOC2Heading`, `TOC3Heading`.
- Características de tamaño (vía estilos `HeadingNChar`):
  - `Heading1Char`: `w:sz w:val="40"` → 20pt.
  - `Heading2Char`: `w:sz w:val="28"`, `w:szCs w:val="32"` → ~14pt.
  - `Heading3Char`: `w:sz w:val="24"` → 12pt.
  - Otros niveles usan combinaciones de color, cursiva, y tintes/grises.
- Colores de encabezados:
  - `Heading5` usa color explícito `0F4761` con `themeColor="accent1"`: un azul/verdoso oscuro SRK.
  - Niveles inferiores (`Heading6`–`Heading9`) usan variantes de `text1` con distintos `themeTint` (grises más claros).
- Se observa un estilo de numeración especial `SRKHeadings` vinculado a la numeración de capítulos/secciones (`w:style w:type="numbering" w:styleId="SRKHeadings"`).

### 3.3. Título y portadas

- Estilos de título:
  - `Title`: tamaño `44` (≈ 22pt) y basado en fuente de tema mayor.
  - `Title2` / `Title3`: tamaños 28–24; usados para subtítulos o títulos secundarios.
- Estilos de portada específicos:
  - `SectionCover`: estilo de sección de portada con:
    - Página nueva (`pageBreakBefore`).
    - Marco que ocupa el ancho de texto (`w:w="9360"`) y una línea superior de color `F37021` (naranja SRK).
    - Fuente **explícita** `Aptos SemiBold` (`w:rFonts w:ascii="Aptos SemiBold" w:hAnsi="Aptos SemiBold"`).
  - `CoverHeading`, `CoverText`, `CoverTelephone`: variantes de texto para portada con tamaños 18–20pt.

### 3.4. Encabezado y pie de página

- Estilo `Header`:
  - Borde inferior: línea naranja SRK (`color="F37021" w:themeColor="text2"`).
  - Tabulado a la derecha (para número de proyecto/fecha, etc.).
  - Tamaño de texto: `16` (≈ 8pt).
- Estilo `Footer`:
  - Borde superior naranja (`F37021`).
  - Texto en versales (`<w:caps/>`) con tamaño `16` (≈ 8pt).

Estos dos estilos son clave para replicar el “look corporativo” en DOCX y, si se desea, en HTML (por ejemplo, emulando una franja superior/inferior en el reporte).

### 3.5. Tablas, captions y notas

- Estilo de tabla `Table Grid`:
  - Bordes simples (`w:val="single" w:sz="4"`) en todos los lados y dentro de la tabla.
- Estilo de caption:
  - `Caption` y `CaptionWide` con tamaño ≈ 10pt–11pt, itálico, indentación y posible sangría para “Figure X: …”.
- Estilos de notas y referencias:
  - `FootnoteReference`: superíndice, negrita, naranja (`F37021`).
  - `TableFootnote`, `TableFootnoteWide`, `Notes`, `NotesWide` para notas bajo tablas, con tamaños 8–9pt y sangrías específicas.

### 3.6. Listas y numeraciones

- Estilos `SRK Bullet List`, `SRK Numbered List`, `SRKTableFootnotes`, `SRKTableNumberedList`, etc., que controlan cómo se ven bullets y numeraciones dentro de texto y tablas.
- En Quarto, esto se puede mapear mediante estilos de lista por defecto en la plantilla Word de referencia.

---

## 4. Plan pendiente para branding SRK (HTML + Word)

### 4.1. Para HTML (Quarto + brand.yml + theme.scss)

**Objetivo:** parecerse razonablemente al reporte corporativo, sin depender de fuentes propietarias (como Aptos) en la web.

Pasos propuestos:

1. **Ajustar paleta de `_brand.yml`** para reflejar mejor los colores encontrados:
   - Añadir (o documentar) el naranja SRK `#F37021` usado en header/footer y footnotes.
   - Añadir el azul oscuro `#0F4761` asociado a algunos encabezados.
2. **Ajustar tamaños relativos en `styles/theme.scss`**:
   - Revisar `$h1-font-size`…`$h4-font-size` para aproximarse a los ratios de 22/20/14/12pt.
   - Ajustar `line-height` y `paragraph-margin-bottom` para parecerse más a los defaults de Word (espacio antes/después de párrafos, interlineado ~1.3).
3. **Emular header/footer corporativos en HTML** (opcional pero deseable):
   - Crear un partial o bloque SCSS que dibuje una franja superior e inferior usando el naranja SRK.
   - Incluir logo y texto corporativo en un footer HTML consistente.
4. **Actualizar `docs/README-QUARTO.md`**:
   - Corregir referencias de ruta (`_brand.yml` y `_language-en.yml` → `styles/_brand.yml`, `styles/_language-en.yml`).

### 4.2. Para Word (DOCX de referencia)

**Objetivo:** que `quarto render ... --to docx` produzca entregables idénticos a un reporte SRK.

Pasos propuestos:

1. **Crear una nueva plantilla Word de referencia** a partir de `docs/Sample Report.docx`:
   - Abrir `Sample Report.docx`.
   - Eliminar contenido específico del cliente, conservar estilos, portada, header/footer, numeraciones, tablas, captions.
   - Guardar como `styles/reference-srk.docx` (o reemplazar `styles/reference.docx`).
2. **Actualizar `_quarto.yml`** para apuntar a la nueva plantilla:
   - `docx.reference-doc: styles/reference-srk.docx`.
3. **Probar un flujo completo**:
   - `quarto render html_index.qmd --to docx`.
   - Verificar que:
     - Encabezados usan la numeración y estilos SRK.
     - Header y footer se ven con las líneas naranjas y tipografía adecuada.
     - Tablas, captions y footnotes siguen el formato corporativo.
4. **(Opcional avanzado)**: mapear aún más los estilos de Quarto (por ejemplo, listas, notas, captions) a estilos específicos SRK en la plantilla de Word para un control fino.

---

## 5. Resumen rápido para futuras sesiones

- **Estado actual (branding general):**
  - HTML (antes de la depuración de fuentes): `brand: styles/_brand.yml` + `theme: [slate, styles/theme.scss]`.
  - RevealJS: `theme: simple` + `css: styles/styles.css`.
  - Word: `reference-doc: styles/reference.docx`, pero la referencia real deseable es una plantilla SRK derivada de `docs/Sample Report.docx`.
- **Correcciones ya hechas:**
  - Rutas de theme y brand arregladas.
  - Separación clara de estilos HTML vs RevealJS.
  - `theme.scss` saneado para no romper compilación y trabajar bien con el brand YAML.
- **Próximos pasos recomendados (branding, sin fuentes propietarias):**
  1. Ajustar `_brand.yml` con colores SRK extraídos del Word (naranja `F37021`, azul `0F4761`, etc.).
  2. Retocar `styles/theme.scss` para acercar tamaños y espaciados a los de la plantilla SRK.
  3. Construir y configurar `styles/reference-srk.docx` como nueva plantilla Word corporativa.
  4. Probar y refinar hasta que HTML y DOCX se vean coherentes con la identidad visual de SRK.

---

## 6. Depuración de fuentes HTML (2025-11-16) – Qué se probó y qué funcionó

### 6.1. Problema observado

- En el reporte HTML final (libro Quarto), el usuario veía **tipografía serif** ("Times-like"), tanto localmente como en Netlify.
- La inspección inicial del CSS mostraba una pila sans-serif con "IBM Plex Sans" o `system-ui` en las variables Bootstrap, pero el resultado visual seguía viéndose serifado.
- Había además restricciones de licencia y preferencia:
  - No usar **Aptos** ni depender de fuentes propietarias en HTML.
  - Idealmente usar **IBM Plex Sans** sólo si está instalada localmente, pero aceptar un stack neutro `system-ui / Segoe UI / Helvetica / Arial / sans-serif`.

### 6.2. Experimentos que se probaron y no resolvieron completamente el problema

1. **Estado inicial con brand + slate + theme.scss**
   - Configuración HTML aproximada (previa a los últimos cambios):
     - `brand: styles/_brand.yml` (forzaba tipografías IBM Plex Sans).
     - `theme: [slate, styles/theme.scss]`.
   - El CSS compilado (`bootstrap-*.min.css`) mostraba:
     - `--bs-font-sans-serif: 'IBM Plex Sans', system-ui, ...`.
   - Aun así, el usuario percibía el resultado como **serifado o incómodo**.

2. **`theme: simplex` sin brand ni theme.scss**
   - Se simplificó el HTML a:
     - `theme: simplex`.
     - **Sin** `brand:` ni `styles/theme.scss`.
   - Resultado:
     - Las fuentes volvieron a verse claramente sans-serif y agradables.
     - Pero se perdió casi todo el branding SRK: colores, header corporativo, footer, etc.

3. **`simplex + styles/theme.scss`**
   - Se añadió `styles/theme.scss` encima de `simplex`.
   - Resultado:
     - Tipografía razonable, pero el control de branding no era completo; `simplex` seguía imponiendo ciertas decisiones.
   - El usuario no quería depender de un tema Bootstrap genérico para la identidad de marca.

4. **`theme.scss` como único tema (sin `simplex`, sin `brand` para HTML)**
   - Configuración HTML de prueba:
     - `theme: styles/theme.scss`.
     - Sin `brand:`.
   - Resultado:
     - Volvieron todos los colores y layouts profesionales (tablas, callouts, portada, footer).
     - Pero el usuario seguía viendo la fuente como serifada.
   - Inspección del CSS compilado mostraba todavía rastros del stack anterior (en una fase intermedia seguía apareciendo `IBM Plex Sans` en alguna build).

5. **Eliminar referencias a IBM/Aptos en `fonts.css` y `_brand.yml`**
   - `styles/fonts.css` ya no declaraba ninguna `@font-face`.
   - `_brand.yml` se limpió para no forzar `$font-family-sans-serif`.
   - Aun así, la apariencia seguía sin coincidir con lo esperado: algo en la cadena de compilación seguía produciendo un comportamiento de fallback extraño.

6. **Overrides puntuales de `body { font-family: ... }`**
   - Se probaron overrides para `body`, `p`, listas, etc., pero se descartaron porque:
     - No solucionaban de raíz el problema.
     - Introducían complejidad y riesgo de peleas con Bootstrap/Quarto.

### 6.3. Causa raíz encontrada

La causa principal resultó ser un detalle de cómo se definía la pila de fuentes en SCSS:

- En `styles/theme.scss` la variable se había definido así (estado intermedio):

  ```scss
  $font-family-sans-serif: "system-ui, -apple-system, 'Segoe UI', 'Helvetica Neue', Arial, sans-serif" !default;
  ```

- Eso produce en el CSS **una sola cadena**:

  ```css
  --bs-font-sans-serif: "system-ui, -apple-system, 'Segoe UI', 'Helvetica Neue', Arial, sans-serif";
  ```

- El navegador interpreta esto como **una fuente con ese nombre literal**, que obviamente no existe.
- Al no encontrarla, cae al **fallback por defecto del sistema**, que normalmente es **serif** (tipo Times/New Roman).
- De ahí la sensación de que “el CSS dice sans-serif pero se ve serifado”: la pila no estaba escrita como lista de fuentes.

### 6.4. Solución final aplicada

1. **Corregir la definición de la pila sans-serif en SCSS**

   En `styles/theme.scss` se cambió a:

   ```scss
   // Typography families (brand.yml may override sans/mono)
   // IMPORTANT: define the stack as a font-family *list*, not a single quoted string,
   // so the browser can choose each face correctly.
   $font-family-sans-serif: system-ui, -apple-system, "Segoe UI", "Helvetica Neue", Arial, sans-serif !default;
   $font-family-monospace: Menlo, Monaco, Consolas, "Courier New", monospace !default;
   ```

   Y se alineó `styles/theme-dark.scss` con la misma pila para consistencia.

2. **Recompilar el libro (`./render index.qmd --to html`)**

   El nuevo Bootstrap compilado (`publish/site_libs/bootstrap/bootstrap-3ee1723....min.css`) ahora contiene:

   ```css
   :root,[data-bs-theme=light]{
     ...
     --bs-font-sans-serif: system-ui, -apple-system, "Segoe UI", "Helvetica Neue", Arial, sans-serif;
     --bs-body-font-family: system-ui, -apple-system, "Segoe UI", "Helvetica Neue", Arial, sans-serif;
   }
   body {
     font-family: var(--bs-body-font-family);
   }
   h1,.h1,h2,... {
     font-family: system-ui,-apple-system,"Segoe UI","Helvetica Neue",Arial,sans-serif;
   }
   ```

   Es decir, ahora sí es una **lista de fuentes sans-serif real** que el navegador puede resolver correctamente.

3. **Unificar también los gráficos interactivos (Highcharts)**

   Algunos capítulos contienen gráficos Highcharts cuyo tema Javascript pedía explícitamente `fontFamily: "IBM Plex Sans"`.
   Para evitar inconsistencia visual, se añadió en `styles/theme.scss`:

   ```scss
   .highcharts-root,
   .highcharts-title,
   .highcharts-subtitle,
   .highcharts-axis-labels text,
   .highcharts-axis-title text,
   .highcharts-legend-item text,
   .highcharts-data-label text,
   .highcharts-label text,
   .highcharts-tooltip text {
     font-family: $font-family-sans-serif !important;
   }
   ```

   Esto fuerza toda la tipografía de Highcharts a la misma pila `system-ui / Segoe UI / Helvetica / Arial / sans-serif`, aun si el tema JS menciona IBM Plex.

4. **Verificación final**

   - En el CSS compilado ya no hay ninguna referencia a Aptos ni a IBM Plex en las variables de Bootstrap.
   - El usuario confirmó que **“PERFECTO!!!!!!! LO LOGRASTE”**: todo el libro HTML se ve ahora con fuentes sans-serif limpias, sin fallback serif.

### 6.5. Estado actual de fuentes (HTML)

- No se usan fuentes propietarias (Aptos) en HTML.
- IBM Plex Sans no se utiliza como fuente principal; solo permanece como referencia en algunos temas JS de gráficos, neutralizados por el CSS global.
- La pila tipográfica efectiva del libro HTML es:

  ```text
  system-ui, -apple-system, "Segoe UI", "Helvetica Neue", Arial, sans-serif
  ```

- Esto garantiza un aspecto profesional, consistente y 100 % sans-serif en macOS, Windows y Linux, usando las fuentes nativas de cada sistema.
