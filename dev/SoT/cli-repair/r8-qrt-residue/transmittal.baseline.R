# nolint start
# Transmittal letter: deliverable table and letter body per language.

# La tabla de entregables se deriva de manifest.json: ahí está lo que el
# propietario decidió publicar, con el dominio de cada artefacto ya declarado
# (mismo criterio que toc.R). La lista propia con URLs adivinadas
# https://<base>-<sufijo>.srk.ar dejaba enlaces muertos en los proyectos que
# publican un subconjunto.
.transmittalDeliverables <- function(root, language) {
  FILE <- file.path(root, "manifest.json")
  if (!file.exists(FILE)) {
    stop("manifest.json not found at the project root; the deliverable table is built from it.", call. = FALSE)
  }
  LIST <- jsonlite::fromJSON(FILE, simplifyVector = FALSE)$artifacts
  LIST <- Filter(function(a) !is.null(a$domain) && nzchar(a$domain), LIST)

  # Orden curado de la carta: índice, reportes y presentaciones como en toc.R,
  # luego la familia de selección de sismos. Un alias que no figure acá se
  # lista al final, en el orden del manifest, de modo que un producto nuevo
  # aparece sin tener que tocar nada.
  ORDER <- c(
    "toc", "report", "sha", "sdc", "gmdp", "srs",
    "at", "vt", "dt", "ai", "cav", "cav5", "psa", "psv", "sd", "its", "ipsa"
  )
  LIST <- LIST[order(match(vapply(LIST, function(a) a$alias, character(1)), ORDER, nomatch = length(ORDER) + 1L))]

  # Ficha por alias: nombre visible (en el idioma del producto, como en toc.R
  # como en toc.R) y categoría en cada
  # idioma de la carta. Un alias sin ficha se lista por su alias, con
  # categoría vacía.
  MAP <- data.frame(
    alias = c(
      "toc", "report", "sha", "sdc", "gmdp", "srs",
      "at", "vt", "dt", "ai", "cav", "cav5", "psa", "psv", "sd", "its", "ipsa"
    ),
    name = c(
      "Master index",
      "Executive Report",
      "Seismic Hazard Assessment",
      "Seismic Design Criteria",
      "Ground-Motion Design Parameters",
      "Seismic Record Selection",
      "Acceleration time series",
      "Velocity time series",
      "Displacement time series",
      "Arias intensity",
      "Cumulative absolute velocity",
      "CAV5",
      "Pseudo-spectral acceleration",
      "Pseudo-spectral velocity",
      "Spectral displacement",
      "Intensity-target spectra",
      "Individual PSA matches"
    ),
    en = c(
      "Index", "Report", "Presentation", "Presentation",
      "Presentation", "Presentation",
      "Time histories", "Time histories", "Time histories",
      "Cumulative intensity", "Cumulative intensity", "Cumulative intensity",
      "Response spectra", "Response spectra", "Response spectra",
      "Spectral matching review", "Spectral matching review"
    ),
    es = c(
      "Índice", "Informe", "Presentación", "Presentación",
      "Presentación", "Presentación",
      "Historias de tiempo", "Historias de tiempo", "Historias de tiempo",
      "Intensidad acumulada", "Intensidad acumulada", "Intensidad acumulada",
      "Espectros de respuesta", "Espectros de respuesta", "Espectros de respuesta",
      "Revisión del ajuste espectral", "Revisión del ajuste espectral"
    ),
    stringsAsFactors = FALSE
  )

  ALIAS <- vapply(LIST, function(a) a$alias, character(1))
  DOMAIN <- vapply(LIST, function(a) a$domain, character(1))
  IDX <- match(ALIAS, MAP$alias)
  data.frame(
    Category = ifelse(is.na(IDX), "", MAP[[language]][IDX]),
    Deliverable = ifelse(is.na(IDX), ALIAS, MAP$name[IDX]),
    URL = paste0("[https://", DOMAIN, "/](https://", DOMAIN, "/)"),
    stringsAsFactors = FALSE
  )
}

knitTransmittalLetter <- function(language = "en") {
  if (!language %in% c("en", "es")) stop("transmittal: unrecognized language: ", language)
  if (language == "en") {
  root <- normalizePath(getwd())
  FILE <- file.path(root, "params.yml")
  if (!file.exists(FILE)) stop("Missing params.yml.", call. = FALSE)
  P <- yaml::read_yaml(FILE)$params
  if (is.null(P$project_id)) stop("params.project_id is required.", call. = FALSE)

  Deliverables <- .transmittalDeliverables(root, language)
  fmt <- function(x) paste(unlist(x), collapse = "  \n")
  Lead <- P$roles[[1]]

  cat(P$consultant$name, "\n")
  cat(fmt(P$consultant$address), "\n\n")
  cat(format(Sys.Date(), "%d %b %Y"), "\n\n")

  cat(P$client$name, "\n")
  cat(fmt(P$client$address), "\n\n")

  cat("**Subject**  \n")
  cat(P$title, "- Transmittal Letter\n\n")
  cat("**Project**  \n")
  cat(P$project_id, "\n\n")

  cat("Dear ", P$client$name, ",\n\n", sep = "")
  cat(
    "This transmittal letter provides the public delivery links for the final ",
    "technical deliverables prepared by ", P$consultant$name, " for ",
    P$site, ", ", P$location, ". The links below provide direct access to the ",
    "official report, the design-parameter presentation, the seismic record ",
    "selection products, and the full GMDB map.\n\n",
    sep = ""
  )

  cat(knitr::kable(Deliverables, format = "markdown", col.names = c("Category", "Deliverable", "Public URL")), sep = "\n")
  cat("\n")

  cat("\n\nRegards,\n\n")
  cat(P$consultant$name, "\n\n")
  cat(Lead$name, "  \n", sep = "")
  cat(Lead$title, "\n")
  }
  if (language == "es") {
  root <- normalizePath(getwd())
  FILE <- file.path(root, "params.yml")
  if (!file.exists(FILE)) stop("Missing params.yml.", call. = FALSE)
  P <- yaml::read_yaml(FILE)$params
  if (is.null(P$project_id)) stop("params.project_id is required.", call. = FALSE)

  Deliverables <- .transmittalDeliverables(root, language)

  Mes <- c(
    "enero", "febrero", "marzo", "abril", "mayo", "junio",
    "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"
  )
  Fecha <- paste0(
    as.integer(format(Sys.Date(), "%d")), " de ",
    Mes[as.integer(format(Sys.Date(), "%m"))], " de ",
    format(Sys.Date(), "%Y")
  )
  fmt <- function(x) paste(unlist(x), collapse = "  \n")
  Lead <- P$roles[[1]]

  cat(P$consultant$name, "\n")
  cat(fmt(P$consultant$address), "\n\n")
  cat(Fecha, "\n\n")

  cat(P$client$name, "\n")
  cat(fmt(P$client$address), "\n\n")

  cat("**Asunto**  \n")
  cat("PSHA ", P$site, " - Carta de entrega\n\n", sep = "")
  cat("**Proyecto**  \n")
  cat(P$project_id, "\n\n")

  cat("Estimados:\n\n")
  cat(
    "Esta carta de entrega proporciona los enlaces públicos de acceso a los ",
    "entregables técnicos finales preparados por ", P$consultant$name, " para ",
    P$site, ", ", P$location, ". Los enlaces siguientes permiten acceder ",
    "directamente al informe oficial, la presentación de parámetros de diseño, ",
    "los productos de selección de registros sísmicos y el mapa completo GMDB.\n\n",
    sep = ""
  )

  cat(knitr::kable(Deliverables, format = "markdown", col.names = c("Categoría", "Entregable", "URL pública")), sep = "\n")
  cat("\n")

  cat("\n\nSaludos cordiales,\n\n")
  cat(P$consultant$name, "\n\n")
  cat(Lead$name, "  \n", sep = "")
  cat(Lead$title, "\n")
  }
  Stamp <- Sys.getenv("QRT_RENDER_STAMP")
  if (nzchar(Stamp) && !knitr::is_html_output()) cat("\n", Stamp, "\n", sep = "")
  invisible(NULL)
}
# nolint end
