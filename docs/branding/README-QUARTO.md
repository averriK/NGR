# Configuración de Quarto - PSHA

> Nota: esta documentación tenía originalmente un único `_quarto.yml` en la raíz. A partir de noviembre 2025 se utiliza una configuración **multi-proyecto**; ver la sección siguiente.

## Estado actual: proyectos separados (book / slides)

Estructura relevante:

- `yml/book.yml` → proyecto **book** (HTML, DOCX, PDF)
- `yml/revealjs.yml` → proyecto **default** (RevealJS para `ppt.qmd`)
- `yml/_brand.yml` → branding corporativo (colores, tipografías, logo)
- `yml/_language-en.yml` → textos de interfaz en inglés
- `yml/params.yml` → parámetros compartidos (`params$client`, `params$site`, etc.)

Comandos típicos (usando el wrapper `./render` que gestiona el symlink `_quarto.yml`):

- Libro HTML: `./render --to html`
- Libro DOCX: `./render --to docx`
- Libro PDF: `./render --to pdf`
- Slides RevealJS: `./render ppt.qmd --to revealjs`

Salidas:

- Ambos proyectos (`yml/book.yml` y `yml/revealjs.yml`) están configurados con `output-dir: _publish`, de modo que todos los HTML/DOCX/PDF/RevealJS se escriben en `_publish/` en la raíz del repo (gracias a que `_quarto.yml` es un symlink al YAML activo).
- Los parámetros comunes (`client`, `site`, `background`, etc.) se definen una sola vez en `yml/params.yml` y se cargan desde R en `psha/R/run.R` (objeto `params`).

### Pendiente / TODO

- Validar que `output-dir: ../_publish` se comporte correctamente con tu versión de Quarto (si falla, usar `_publish` y aceptar `project/_publish`).
- Decidir si `_quarto.yml` en la raíz se mantiene como configuración legacy o se elimina.
- Revisar que los scripts R que usan `here::here()` funcionen bien con el root de proyecto en `project/` cuando se usa `--project`.

---

## Estructura del Proyecto (diseño anterior, LEGACY)

```
AR-S2J2E/
├── _brand.yml                    # Branding corporativo unificado
├── _quarto.yml                   # Configuración unificada para todos los formatos
├── _language-en.yml              # Configuración de idioma
├── html_index.qmd                # 📄 ACTIVO: Reportes HTML/Word/PDF
├── revealjs_index.qmd            # 🎬 ACTIVO: Presentaciones RevealJS
│
├── bib/                          # Bibliografía
│   ├── references.bib            # Referencias del proyecto (consolidado)
│   ├── references-revealjs.bib   # Backup referencias RevealJS
│   └── apa.csl                   # Estilo de citación APA
│
├── styles/                       # 🎨 Estilos unificados (EN RAÍZ)
│   ├── theme.scss                # Tema profesional modo claro
│   ├── theme-dark.scss           # Tema profesional modo oscuro
│   ├── styles.css                # Estilos CSS adicionales
│   ├── logo.png                  # Logo corporativo
│   ├── reference.docx            # Plantilla Word
│   └── reference-new.docx        # Plantilla Word actualizada
│
├── html/                         # Contenido de reportes
│   ├── _local/
│   │   ├── C1.qmd
│   │   └── A1.qmd
│   └── (NO usar index.qmd aquí - OBSOLETO)
│
└── revealjs/                     # Contenido de presentaciones
    ├── psha/
    └── (NO usar index.qmd aquí - OBSOLETO)
```

## 🚀 Comandos de Uso

### Reportes HTML
```bash
# Renderizar HTML
quarto render html_index.qmd --to html

# Renderizar Word
quarto render html_index.qmd --to docx

# Renderizar PDF
quarto render html_index.qmd --to pdf

# Preview en vivo
quarto preview html_index.qmd
```

### Presentaciones RevealJS
```bash
# Renderizar presentación
quarto render revealjs_index.qmd --to revealjs

# Preview en vivo
quarto preview revealjs_index.qmd
```

## 📁 Archivos Clave

### Configuración Principal
- **`_quarto.yml`**: Configuración unificada con todos los formatos (HTML, RevealJS, Word, PDF)
- **`_brand.yml`**: Branding corporativo (colores, tipografía, logos)
- **`_language-en.yml`**: Traducciones y textos de interfaz
- **`html_index.qmd`**: Archivo principal para reportes
- **`revealjs_index.qmd`**: Archivo principal para presentaciones

### Estilos
Todos los estilos están centralizados en la carpeta **`styles/`** en la raíz:
- Temas SCSS profesionales con modo claro/oscuro
- Plantillas Word personalizables
- Logo corporativo
- CSS adicional

## ✨ Características Implementadas

### Reportes HTML
- ✅ Búsqueda overlay profesional
- ✅ Temas claro/oscuro automáticos
- ✅ Code-tools interactivos
- ✅ Navegación mejorada (back-to-top, smooth-scroll)
- ✅ Footer corporativo
- ✅ Figuras en SVG (alta calidad)
- ✅ Tablas profesionales con hover
- ✅ TOC con indicador activo
- ✅ Tipografía optimizada (Inter, Roboto Slab, Fira Code)

### Presentaciones RevealJS
- ✅ Plugins (search, chalkboard, zoom, menu)
- ✅ Dimensiones optimizadas (1920x1080)
- ✅ Transiciones suaves
- ✅ Fragmentos habilitados
- ✅ Logo corporativo

### Documentos Word
- ✅ Plantilla personalizada
- ✅ TOC automático
- ✅ Numeración de secciones
- ✅ Estilos profesionales

## 🎨 Personalización

### Cambiar Colores Corporativos
Edita `_brand.yml`:
```yaml
color:
  palette:
    srk-blue: "#003366"      # Tu color primario
    srk-light-blue: "#0066CC" # Tu color secundario
    srk-accent: "#FFB81C"     # Tu color de acento
```

### Cambiar Tipografía
Edita `_brand.yml`:
```yaml
typography:
  fonts:
    - family: "Tu Fuente"
      source: "google"
```

### Personalizar Plantilla Word
1. Abre `styles/reference-new.docx` en Word
2. Modifica los estilos (Home > Estilos)
3. Guarda como `styles/reference.docx`

### Agregar Logo
Reemplaza `styles/logo.png` con tu logo corporativo

## 📝 Notas Importantes

1. **NO** editar `html/index.qmd` ni `revealjs/index.qmd` (obsoletos)
2. **SÍ** usar `html_index.qmd` y `revealjs_index.qmd` en la raíz
3. Todos los estilos están en `styles/` en la raíz
4. La configuración está unificada en `_quarto.yml`
5. El branding está centralizado en `_brand.yml`

## 🔧 Limpieza

```bash
# Limpiar archivos generados
quarto clean

# Limpiar todo el cache
rm -rf _publish .quarto
```

## 📚 Recursos

- [Documentación Quarto](https://quarto.org/)
- [Branding en Quarto](https://quarto.org/docs/authoring/brand.html)
- [Temas HTML](https://quarto.org/docs/output-formats/html-themes.html)
- [RevealJS](https://quarto.org/docs/presentations/revealjs/)
