---
layout: default
title: Auditoría de READMEs
---

# Auditoría de READMEs - Problemas vs Reglas del Template

**Fecha:** 2025-11-06  
**Repositorios revisados:** tito, oqt, kashima, dsra, NGR, gmsp, newmark

---

## Orden estándar requerido (final del README)

1. **Dependencies** - librerías/paquetes requeridos
2. **References** - citas académicas, papers
3. **Contributing** - cómo contribuir
4. **Changelog** (opcional) - historial de versiones
5. **License** ← inicio del footer estándar
6. **Citation** ← siempre en formato bibtex
7. **Author** ← información de contacto completa
8. **Acknowledgments** (opcional) - solo si es necesario

---

## ✅ TITO - CUMPLE CORRECTAMENTE

**Orden actual:**
1. Dependencies ✅
2. Documentation (opcional)
3. Contributing ✅
4. License ✅
5. Citation ✅
6. Author ✅

**Email:** averri@srk.com.ar ✅ (correcto para proyecto comercial/SRK)

**Problemas:** NINGUNO - este README es el modelo a seguir

---

## ✅ OQT - CUMPLE CORRECTAMENTE

**Orden actual:**
1. Dependencies ✅
2. References ✅
3. Contributing ✅
4. License ✅
5. Citation ✅
6. Author ✅
7. Acknowledgments ✅
8. Changelog ✅ (al final, aceptable)
9. Roadmap (después de Changelog)

**Email:** averri@fi.uba.ar ✅

**Problemas:** NINGUNO

---

## ⚠️ KASHIMA - NECESITA CORRECCIONES MENORES

**Orden actual:**
1. Contributing ✅
2. **Changelog ❌ (debe ir ANTES de License)**
3. License ✅
4. Citation ✅
5. Author ✅

**Problemas:**
1. ❌ **Changelog está DESPUÉS de License** (debe ir antes)
2. ✅ Email correcto: averri@fi.uba.ar
3. ✅ Usa "## Author" (no "Contact")
4. ❌ **Falta sección "Dependencies"** (aunque están mencionadas en Installation)
5. ❌ **Falta sección "References"** (hay citas pero no formateadas como References)

**Acciones requeridas:**
- Mover Changelog antes de License
- Agregar sección Dependencies formal
- Considerar agregar sección References para citas académicas

---

## ⚠️ DSRA - NECESITA CORRECCIONES MENORES

**Orden actual:**
1. Datasets (contenido específico)
2. Computational Workflow (contenido específico)
3. Theory and Mathematical Background (contenido específico)
4. Dependencies ✅
5. References ✅
6. **Contributing ❌ FALTA**
7. License ✅
8. Citation ✅
9. Author ✅

**Problemas:**
1. ❌ **Falta sección "Contributing"**
2. ✅ Email correcto: averri@fi.uba.ar
3. ✅ Referencias bien formateadas

**Acciones requeridas:**
- Agregar sección Contributing antes de License

---

## 🚨 NGR - PROBLEMAS GRAVES (EJEMPLOS ALUCINADOS)

**Orden actual:**
1. Dependencies ✅
2. Project Structure (contenido específico)
3. Documentation (contenido específico)
4. License ✅
5. Citation ✅
6. Author ✅
7. **Changelog ❌ (debe ir ANTES de License)**
8. Contributing ✅
9. Acknowledgments ✅

**Problemas de orden:**
1. ❌ **Changelog está DESPUÉS de Author** (debe ir ANTES de License)
2. ❌ **Contributing está DESPUÉS de Author** (debe ir antes de License)
3. ❌ **Acknowledgments está DESPUÉS de Author** (debe ir inmediatamente después de Author)

**Problemas de contenido - EJEMPLOS ALUCINADOS:**

### Ejemplo 1: buildPlot - Datos inventados (líneas 128-161)
```r
DT <- data.table(
  ID = rep(c("Series A", "Series B", "Series C"), each = 50),
  X = rep(seq(0, 10, length.out = 50), 3),
  Y = c(
    sin(seq(0, 10, length.out = 50)) + rnorm(50, 0, 0.1),
    cos(seq(0, 10, length.out = 50)) + rnorm(50, 0, 0.1),
    exp(-seq(0, 10, length.out = 50)/5) + rnorm(50, 0, 0.05)
  )
)
```
❌ **Problema:** Ejemplo genérico sin contexto del paquete NGR

### Ejemplo 2: buildTable con iris (líneas 165-195)
```r
summary_table <- data.table(
  Species = c("setosa", "versicolor", "virginica"),
  Mean = c(5.01, 5.94, 6.59),
  ...
)
```
❌ **Problema:** Usa dataset iris que NO es parte de NGR, datos inventados

### Ejemplo 3: buildYAML - Estructura inventada (líneas 197-227)
```r
# project/
#   ├── index.qmd           # Main report content
#   ├── _params.yml         # Report parameters
#   ├── _authors.yml        # Author information
```
❌ **Problema:** Muestra estructura de proyecto que no está verificada con el código real

### Ejemplo 4: Bar Charts - Datos inventados (líneas 363-381)
```r
bar_data <- data.table(
  ID = rep(c("2020", "2021", "2022"), each = 4),
  X = rep(c("Q1", "Q2", "Q3", "Q4"), 3),
  Y = c(23, 25, 28, 30, 25, 28, 31, 33, 28, 32, 35, 38)
)
```
❌ **Problema:** Datos de ventas trimestrales inventados sin relación con reportes técnicos

### Ejemplo 5: Histograms - Datos inventados (líneas 392-405)
```r
hist_data <- data.table(
  ID = "Sample",
  X = rnorm(1000, mean = 5, sd = 2)
)
```
❌ **Problema:** Distribución normal genérica sin contexto de reportes

### Ejemplo 6: Model Comparison - Datos inventados (líneas 415-434)
```r
model_lines <- data.table(
  ID = "Prediction",
  X = 10^seq(-2, 2, length.out = 100),
  Y = 10^(0.5 * seq(-2, 2, length.out = 100))
)
```
❌ **Problema:** Modelo log-log genérico sin contexto real

### Ejemplo 7: Typewriter fonts - Tabla desactualizada (líneas 922-940)
La tabla incluye 13 fuentes pero NO verifica:
- Si todas están realmente implementadas en el código
- Si los nombres de fuente coinciden con typewriter.R
- Si los colores recomendados son válidos

### Ejemplo 8: buildPlot.Hist2D y buildPlot.Hist3D (líneas 239, 258-260)
Menciona estas funciones pero:
- ✅ Los archivos R existen: buildPlot.Hist2D.R, buildPlot.Hist3D.R
- ❌ NO hay ejemplos verificables con datos reales del contexto de reportes

**Acciones requeridas para NGR:**
1. REORDENAR secciones: Dependencies → References (si hay) → Contributing → Changelog → License → Citation → Author → Acknowledgments
2. REEMPLAZAR todos los ejemplos inventados con:
   - Ejemplos minimalistas verificables
   - O referencias a archivos de ejemplo reales en inst/examples/
3. VERIFICAR que cada ejemplo de código funciona con las funciones reales del paquete
4. ELIMINAR especificaciones de estructura de proyectos no verificadas
5. VERIFICAR tabla de fuentes typewriter contra el código real en R/typewriter.R

---

## ✅ GMSP - CUMPLE CORRECTAMENTE

**Orden actual:**
1. Dependencies ✅
2. Documentation ✅
3. Contributing ✅
4. License ✅
5. Citation ✅
6. Author ✅
7. Acknowledgements ✅

**Email:** averri@fi.uba.ar ✅

**Problemas:** NINGUNO

---

## ⚠️ NEWMARK - NECESITA CORRECCIONES MENORES

**Orden actual:**
1. Dependencies ✅
2. References ✅
3. Documentation ✅
4. Contributing ✅
5. License ✅
6. **Citation ❌ (orden incorrecto en bibtex: debe ser @software o @misc consistente)**
7. Author ✅

**Problemas:**
1. ⚠️ Citation usa `@misc` en lugar de `@software` (inconsistente con otros paquetes)
2. ✅ Email correcto: averri@fi.uba.ar
3. ✅ Orden de secciones correcto
4. ✅ Referencias académicas bien formateadas

**Acciones requeridas:**
- Cambiar `@misc{newmark2024,` a `@software{newmark2024,` para consistencia

---

## RESUMEN DE PROBLEMAS

### Por severidad:

**🚨 GRAVES (requieren atención inmediata):**
- NGR: Múltiples ejemplos alucinados, orden incorrecto de secciones

**⚠️ MENORES (correcciones simples):**
- kashima: Changelog mal ubicado, faltan Dependencies/References formales
- dsra: Falta sección Contributing
- newmark: Citation usa @misc en lugar de @software

**✅ SIN PROBLEMAS:**
- tito
- oqt
- gmsp

---

## CHECKLIST DE CORRECCIÓN

### Para TODOS los repos:
- [ ] Verificar orden de secciones vs template
- [ ] Email correcto según tipo de proyecto (fi.uba.ar académico, srk.com.ar comercial)
- [ ] Citation en formato @software con todos los campos
- [ ] Dependencies listadas formalmente
- [ ] Changelog (si existe) ANTES de License

### Para NGR específicamente:
- [ ] Revisar CADA ejemplo de código contra el código fuente real
- [ ] Eliminar o reemplazar ejemplos con datos inventados
- [ ] Verificar tablas de parámetros contra código real
- [ ] Asegurar que estructuras de archivos mostradas son reales
- [ ] Reordenar secciones finales correctamente
