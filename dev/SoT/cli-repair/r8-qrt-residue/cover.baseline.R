# nolint start
# cover.R
# ----------------------------------------------------------------------
# Functions to build cover pages from params.yml data.
# Each function receives `params` (parsed from params.yml$params).
# ----------------------------------------------------------------------

# -- Internal helper ---------------------------------------------------
.escapeHtml <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub('"', "&quot;", x, fixed = TRUE)
  x
}

readRenderStamp <- function() {
  Stamp <- Sys.getenv("QRT_RENDER_STAMP")
  if (nzchar(Stamp)) return(Stamp)
  paste0("Pub: ", format(Sys.time(), "%d/%m/%Y"), " Rev.— · DRAFT")
}

.spanishMonthYear <- function(time) {
  MES <- c(
    "enero", "febrero", "marzo", "abril", "mayo", "junio", "julio",
    "agosto", "septiembre", "octubre", "noviembre", "diciembre"
  )
  paste0(MES[as.integer(format(time, "%m"))], " de ", format(time, "%Y"))
}

# -- Citation builder ---------------------------------------------------
# {consultant}. {year}. {title}: {site}. {location} prepared for {client}, {city}.
.buildCitation <- function(params) {
  paste0(
    params$consultant$name, ". ", params$year, ". ",
    params$title, ": ", params$site, ". ",
    params$location, " prepared for ",
    params$client$name, ", ", params$client$city, "."
  )
}

# -- Report cover ------------------------------------------------------
buildCoverReport <- function(
    params, language = "en", output = c("html", "docx"),
    stamp = readRenderStamp()) {
  h <- .escapeHtml
  output <- match.arg(output)
  Spanish <- grepl("^es", language)
  Labels <- if (Spanish) {
    list(
      client = "Preparado para", consultant = "Preparado por",
      authors = "Autores", reviewed = "Revisado por",
      project = "Proyecto", year = "Año",
      revision = "Pub", citation = "Cómo citar"
    )
  } else {
    list(
      client = "Prepared for", consultant = "Prepared by",
      authors = "Authors", reviewed = "Reviewed by",
      project = "Project", year = "Year",
      revision = "Pub", citation = "How to cite"
    )
  }

  SiteLocation <- paste0(params$site, ". ", params$location)
  ProjectLines <- paste0(
    '          <div class="srk-cover__project-line">', h(params$title), "</div>",
    collapse = "\n"
  )

  # Client block
  ClientAddr <- paste0("            <p>", h(params$client$address), "</p>", collapse = "\n")
  ClientWebDisplay <- sub("^https?://", "", params$client$web)
  ClientBlock <- paste0(
    '        <section class="srk-cover__block">\n',
    '          <h2 class="srk-cover__block-title">', Labels$client, ':</h2>\n',
    '          <div class="srk-cover__block-body">\n',
    '            <p>', h(params$client$name), '</p>\n',
    ClientAddr, '\n',
    '            <p><a href="', h(params$client$web), '">', h(ClientWebDisplay), '</a></p>\n',
    '          </div>\n',
    '        </section>'
  )

  # Consultant block
  ConsultAddr <- paste0("            <p>", h(params$consultant$address), "</p>", collapse = "\n")
  ConsultantBlock <- paste0(
    '        <section class="srk-cover__block">\n',
    '          <h2 class="srk-cover__block-title">', Labels$consultant, ':</h2>\n',
    '          <div class="srk-cover__block-body">\n',
    '            <p>', h(params$consultant$name), '</p>\n',
    ConsultAddr, '\n',
    '            <p><a href="', h(params$consultant$web), '">', h(params$consultant$web), '</a></p>\n',
    '          </div>\n',
    '        </section>'
  )

  Roles <- if (is.list(params$roles)) params$roles else list()
  RoleLabels <- vapply(Roles, function(Role) {
    if (is.null(Role$label) || !length(Role$label)) return("")
    tolower(trimws(as.character(Role$label[[1L]])))
  }, character(1))
  AuthorRoles <- Roles[RoleLabels == "lead author"]
  ReviewerRoles <- Roles[RoleLabels == "reviewer"]

  AuthorBlock <- ""
  if (length(AuthorRoles)) {
    AuthorLines <- vapply(AuthorRoles, function(Role) {
      if (is.null(Role$name) || !nzchar(trimws(Role$name))) return("")
      Title <- if (is.null(Role$title)) "" else trimws(Role$title)
      paste0(
        "            <p>", h(Role$name),
        if (nzchar(Title)) paste0("<br>", h(Title)) else "", "</p>"
      )
    }, character(1))
    AuthorLines <- AuthorLines[nzchar(AuthorLines)]
    if (length(AuthorLines)) {
      AuthorBlock <- paste0(
        '        <section class="srk-cover__block">\n',
        '          <h2 class="srk-cover__block-title">', Labels$authors, ':</h2>\n',
        '          <div class="srk-cover__block-body">\n',
        paste(AuthorLines, collapse = "\n"), '\n',
        '          </div>\n',
        '        </section>'
      )
    }
  }

  ReviewerBlock <- ""
  if (length(ReviewerRoles)) {
    ReviewerLines <- vapply(ReviewerRoles, function(Role) {
      if (is.null(Role$name) || !nzchar(trimws(Role$name))) return("")
      Title <- if (is.null(Role$title)) "" else trimws(Role$title)
      paste0(
        "            <p>", h(Role$name),
        if (nzchar(Title)) paste0("<br>", h(Title)) else "", "</p>"
      )
    }, character(1))
    ReviewerLines <- ReviewerLines[nzchar(ReviewerLines)]
    if (length(ReviewerLines)) {
      ReviewerBlock <- paste0(
        '        <section class="srk-cover__block">\n',
        '          <h2 class="srk-cover__block-title">', Labels$reviewed, ':</h2>\n',
        '          <div class="srk-cover__block-body">\n',
        paste(ReviewerLines, collapse = "\n"), '\n',
        '          </div>\n',
        '        </section>'
      )
    }
  }

  # Citation
  CitationText <- .buildCitation(params)
  CitationHtml <- paste0(
    '        <div class="srk-cover__meta-item srk-cover__meta-item--citation">\n',
    '          <div class="srk-cover__meta-label">', Labels$citation, ':</div>\n',
    '          <div class="srk-cover__meta-value">\n',
    '            ', CitationText, '\n',
    '          </div>\n',
    '        </div>'
  )

  if (output == "docx") {
    Text <- function(x) {
      if (is.null(x) || !length(x) || is.na(x[[1L]])) return("")
      trimws(as.character(x[[1L]]))
    }
    Lines <- c(
      paste0("**", Labels$client, ":**"),
      Text(params$client$name),
      vapply(params$client$address, Text, character(1)),
      Text(params$client$web),
      "",
      paste0("**", Labels$consultant, ":**"),
      Text(params$consultant$name),
      vapply(params$consultant$address, Text, character(1)),
      Text(params$consultant$web)
    )
    if (length(AuthorRoles)) {
      Authors <- vapply(AuthorRoles, function(Role) {
        Name <- Text(Role$name)
        Title <- Text(Role$title)
        if (!nzchar(Name)) return("")
        if (nzchar(Title)) paste0(Name, " — ", Title) else Name
      }, character(1))
      Authors <- Authors[nzchar(Authors)]
      if (length(Authors)) {
        Lines <- c(
          Lines, "", paste0("**", Labels$authors, ":**"),
          "", paste0("- ", Authors)
        )
      }
    }
    if (length(ReviewerRoles)) {
      Reviewers <- vapply(ReviewerRoles, function(Role) {
        Name <- Text(Role$name)
        Title <- Text(Role$title)
        if (!nzchar(Name)) return("")
        if (nzchar(Title)) paste0(Name, " — ", Title) else Name
      }, character(1))
      Reviewers <- Reviewers[nzchar(Reviewers)]
      if (length(Reviewers)) {
        Lines <- c(
          Lines, "", paste0("**", Labels$reviewed, ":**"),
          "", paste0("- ", Reviewers)
        )
      }
    }
    Lines <- c(
      Lines, "",
      paste0("**", Labels$project, ":** ", Text(params$project_id), "  "),
      paste0("**", Labels$year, ":** ", Text(params$year), "  "),
      paste0("**", Labels$revision, ":** ", Text(sub("^Pub: ", "", stamp))),
      "",
      paste0("**", Labels$citation, ":** ", CitationText),
      ""
    )
    return(paste(Lines, collapse = "\n"))
  }

  ProjectMeta <- paste0(
    '        <div class="srk-cover__meta-item">\n',
    '          <div class="srk-cover__meta-label">', Labels$project, ':</div>\n',
    '          <div class="srk-cover__meta-value">', h(params$project_id), '</div>\n',
    '        </div>\n',
    '        <div class="srk-cover__meta-item">\n',
    '          <div class="srk-cover__meta-label">', Labels$year, ':</div>\n',
    '          <div class="srk-cover__meta-value">', h(params$year), '</div>\n',
    '        </div>\n',
    '        <div class="srk-cover__meta-item">\n',
    '          <div class="srk-cover__meta-label">', Labels$revision, ':</div>\n',
    '          <div class="srk-cover__meta-value">', h(sub("^Pub: ", "", stamp)), '</div>\n',
    '        </div>'
  )

  # Assemble
  Html <- paste0(
    '<section class="srk-cover">\n',
    '  <div class="srk-cover__layout">\n',
    '    <div class="srk-cover__content">\n',
    '      <div class="srk-cover__title-group">\n',
    '        <div class="srk-cover__kicker">', h(SiteLocation), '</div>\n',
    '        <div class="srk-cover__project">\n',
    ProjectLines, '\n',
    '        </div>\n',
    '      </div>\n',
    '      <div class="srk-cover__blocks">\n',
    ClientBlock, '\n',
    ConsultantBlock, '\n',
    AuthorBlock, '\n',
    ReviewerBlock, '\n',
    '      </div>\n',
    '      <div class="srk-cover__meta">\n',
    ProjectMeta, '\n',
    CitationHtml, '\n',
    '      </div>\n',
    '    </div>\n',
    '  </div>\n',
    '</section>'
  )

  Html
}

buildCoverSignatureReport <- function(
    params, language = "en", output = c("html", "docx"),
    stamp = readRenderStamp()) {
  output <- match.arg(output)
  Spanish <- grepl("^es", language)
  Labels <- if (Spanish) {
    list(
      title = "Firmas", prepared = "Preparado por",
      reviewed = "Revisado por", signatory = "Firma"
    )
  } else {
    list(
      title = "Signatures", prepared = "Prepared by",
      reviewed = "Reviewed by", signatory = "Signature"
    )
  }
  Text <- function(x) {
    if (is.null(x) || !length(x) || is.na(x[[1L]])) return("")
    trimws(as.character(x[[1L]]))
  }
  Entry <- function(label, name, title) {
    name <- Text(name)
    if (!nzchar(name)) return(NULL)
    list(label = label, name = name, title = Text(title))
  }

  SIGN <- params$signature
  Entries <- list()
  if (is.list(SIGN) && length(SIGN)) {
    for (Person in SIGN$prepared) {
      Entries <- c(Entries, list(Entry(Labels$prepared, Person$name, Person$role)))
    }
    for (Person in SIGN$reviewed) {
      Entries <- c(Entries, list(Entry(Labels$reviewed, Person$name, Person$role)))
    }
    WHO <- SIGN$signatory
    if (is.list(WHO)) {
      Title <- Filter(nzchar, vapply(
        c(WHO$credentials, WHO$title, WHO$registration),
        Text, character(1)
      ))
      Entries <- c(Entries, list(Entry(
        Labels$signatory, WHO$name, paste(Title, collapse = " · ")
      )))
    }
  }
  Entries <- Filter(Negate(is.null), Entries)
  if (!length(Entries) && is.list(params$roles)) {
    for (Role in params$roles) {
      Entries <- c(Entries, list(Entry(Role$label, Role$name, Role$title)))
    }
    Entries <- Filter(Negate(is.null), Entries)
  }
  if (!length(Entries)) return("")

  Place <- if (is.list(SIGN)) Text(SIGN$place) else ""
  MonthYear <- if (Spanish) {
    .spanishMonthYear(Sys.time())
  } else {
    format(Sys.time(), "%B %Y")
  }
  PlaceLine <- if (nzchar(Place)) paste0(Place, ", ", MonthYear, ".") else ""

  if (output == "docx") {
    PageBreak <- c(
      "```{=openxml}",
      '<w:p><w:r><w:br w:type="page"/></w:r></w:p>',
      "```"
    )
    Lines <- c(PageBreak, "", paste0("**", Labels$title, "**"), "")
    for (Item in Entries) {
      Lines <- c(
        Lines, "&nbsp;", "", "____________________________", "",
        paste0("**", Item$label, "**  "),
        paste0(Item$name, "  ")
      )
      if (nzchar(Item$title)) Lines <- c(Lines, Item$title)
      Lines <- c(Lines, "")
    }
    if (nzchar(PlaceLine)) Lines <- c(Lines, PlaceLine, "")
    Consultant <- Text(params$consultant$name)
    if (nzchar(Consultant)) Lines <- c(Lines, paste0("**", Consultant, "**"), "")
    Lines <- c(
      Lines, Text(stamp), "", PageBreak, ""
    )
    return(paste(Lines, collapse = "\n"))
  }

  h <- .escapeHtml
  EntryHtml <- vapply(Entries, function(Item) {
    paste0(
      '<div style="min-width: 230px; margin: 2.4em 2.4em 0 0;">',
      '<div style="border-top: 1px solid #444; width: 210px; ',
      'margin-bottom: 0.5em;"></div>',
      '<div style="font-size: 0.7em; color: #666; ',
      'text-transform: uppercase; letter-spacing: 0.06em;">',
      h(Item$label), "</div>",
      '<div style="font-weight: 600;">', h(Item$name), "</div>",
      if (nzchar(Item$title)) {
        paste0('<div style="font-size: 0.85em; color: #444;">',
          h(Item$title), "</div>")
      } else "",
      "</div>"
    )
  }, character(1))
  paste0(
    '<section class="srk-cover__block" style="margin: 3.5em 0 2em 0; ',
    'page-break-before: always; page-break-after: always; ',
    'page-break-inside: avoid;">',
    '<div class="srk-cover__block-title">', Labels$title, "</div>",
    '<div style="display: flex; flex-wrap: wrap;">',
    paste(EntryHtml, collapse = "\n"),
    "</div>",
    if (nzchar(PlaceLine)) {
      paste0('<div style="margin-top: 2.6em;">', h(PlaceLine), "</div>")
    } else "",
    '<div style="font-weight: 600; margin-top: 1.2em;">',
    h(Text(params$consultant$name)), "</div>",
    '<div style="font-size: 12px; color: #888; margin-top: 0.6em;">',
    h(stamp), "</div>",
    "</section>"
  )
}

# -- Cover page entry point --------------------------------------------
# Single call for the cover document: resolves report title and language
# from the hoisted _quarto.yml (falling back to params), then emits the
# complete cover (report cover + signature block) for the current output.
knitCoverPage <- function(
    root, params,
    output = if (knitr::is_html_output()) "html" else "docx") {
  Title <- params$title
  Language <- "en"
  QuartoYml <- file.path(root, "_quarto.yml")
  if (file.exists(QuartoYml)) {
    Meta <- yaml::read_yaml(QuartoYml)
    if (!is.null(Meta$book$title)) Title <- Meta$book$title
    if (!is.null(Meta$lang) && grepl("^es", Meta$lang)) Language <- "es"
    if (!is.null(Meta$book$lang) && grepl("^es", Meta$book$lang)) Language <- "es"
    AUX <- unlist(c(Meta$book$chapters, Meta$book$appendices))
    if (any(grepl("\\.ES\\.qmd$", AUX))) Language <- "es"
  }
  ParamsCover <- params
  ParamsCover$title <- Title
  Stamp <- readRenderStamp()
  Cover <- buildCoverReport(ParamsCover, Language, output, Stamp)
  Signatures <- buildCoverSignatureReport(ParamsCover, Language, output, Stamp)
  if (output == "html") {
    cat("```{=html}\n", Cover, "\n", Signatures, "\n```\n", sep = "")
  } else {
    cat(Cover, "\n", Signatures, "\n", sep = "")
  }
  invisible(NULL)
}

# -- PPT signature slide -----------------------------------------------
# Closing deck slide with the signatures. Everything comes from params.yml:
# when the project declares no params.signature, the slide is omitted rather
# than publishing an empty or invented signature. A deck without signatures
# is a valid draft.
knitSignaturePpt <- function(params, language = "en", stamp = readRenderStamp()) {
  SIGN <- params$signature
  if (!is.list(SIGN) || !length(SIGN)) return(invisible(NULL))
  Spanish <- grepl("^es", language)
  Labels <- if (Spanish) {
    list(
      prepared = "Informe preparado por %s.", reviewed = "Informe revisado por %s.",
      and = "y", project = "Proyecto %s"
    )
  } else {
    list(
      prepared = "Report prepared by %s.", reviewed = "Report reviewed by %s.",
      and = "and", project = "Project %s"
    )
  }
  textOf <- function(x) {
    if (is.null(x) || !length(x)) return("")
    trimws(as.character(x)[[1L]])
  }
  peopleOf <- function(x) {
    if (!is.list(x) || !length(x)) return(character())
    OUT <- vapply(x, function(p) {
      Name <- textOf(p$name)
      Role <- textOf(p$role)
      if (!nzchar(Name)) return("")
      if (nzchar(Role)) sprintf("%s (%s)", Name, Role) else Name
    }, character(1))
    OUT[nzchar(OUT)]
  }
  joinAnd <- function(x) {
    if (length(x) <= 1L) return(paste(x, collapse = ""))
    paste(paste(head(x, -1L), collapse = ", "), Labels$and, tail(x, 1L))
  }

  LIST <- character()
  AUX <- joinAnd(peopleOf(SIGN$prepared))
  if (nzchar(AUX)) LIST <- c(LIST, sprintf(Labels$prepared, AUX))
  AUX <- joinAnd(peopleOf(SIGN$reviewed))
  if (nzchar(AUX)) LIST <- c(LIST, sprintf(Labels$reviewed, AUX))

  OUT <- character()
  WHO <- SIGN$signatory
  if (is.list(WHO)) {
    AUX <- textOf(WHO$name)
    Credentials <- textOf(WHO$credentials)
    if (nzchar(AUX)) {
      OUT <- c(OUT, if (nzchar(Credentials)) sprintf("%s (%s).", AUX, Credentials) else paste0(AUX, "."))
    }
    AUX <- trimws(paste(textOf(WHO$title), textOf(WHO$registration)))
    if (nzchar(AUX)) OUT <- c(OUT, AUX)
  }
  AUX <- textOf(SIGN$place)
  if (nzchar(AUX)) {
    MonthYear <- if (Spanish) .spanishMonthYear(Sys.time()) else format(Sys.Date(), "%B %Y")
    OUT <- c(OUT, sprintf("%s, %s.", AUX, MonthYear))
  }

  cat("\n---\n\n")
  cat('<div style="position: absolute; bottom: 10em; left: 0; width: 80%; ',
      'text-align: left; font-size: 0.65em; color: #444;">\n', sep = "")
  if (length(LIST)) cat(paste(LIST, collapse = "<br>"), "<br>\n", sep = "")
  cat(sprintf("<b>%s</b><br><br>\n", sprintf(Labels$project, textOf(params$project_id))))
  if (length(OUT)) cat(paste(OUT, collapse = "<br>"), "<br>\n", sep = "")
  cat(sprintf("<b>%s</b><br>\n", textOf(params$consultant$name)))
  cat('<span style="font-size: 12px; font-family: Arial, sans-serif; ',
      'color: var(--medium-grey);">',
      .escapeHtml(stamp), "</span><br></div>\n\n", sep = "")
  invisible(NULL)
}

# -- PPT cover (Markdown) ----------------------------------------------
buildCoverPpt <- function(params, title = params$title, language = "en") {
  Title <- title
  ProjectLabel <- if (grepl("^es", language)) "ID de proyecto: " else "Project ID: "
  Subtitle <- paste0(params$site, ". ", params$location)

  RoleLines <- vapply(params$roles, function(Role) {
    paste0(
      Role$label, ": ", Role$name, ". ", Role$title,
      ' <a href="mailto:', Role$email, '"><i class="fa fa-envelope"></i></a>'
    )
  }, character(1))

  Md <- paste0(
    '::: {.coverSlide}\n',
    '\n',
    '<div class="ppt-cover">\n',
    '<div class="ppt-cover__title-group">\n',
    '<div class="ppt-cover__title">', Title, '</div>\n',
    '<div class="ppt-cover__title">', params$site, '</div>\n',
    '<div class="ppt-cover__subtitle">', params$location, '</div>\n',
    '<div class="ppt-cover__subtitle">', params$client$name, '</div>\n',
    '</div>\n',
    '<p class="cover-authors" markdown="1">\n',
    ProjectLabel, params$project_id, '<br>\n',
    paste0(RoleLines, '<br>', collapse = "\n"), '\n',
    '</p>\n',
    '</div>\n',
    '\n',
    ':::'
  )

  Md
}

# nolint end
