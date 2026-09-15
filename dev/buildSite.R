# Run from the repository root, after Jekyll has built docs/ into _site/.
stopifnot(file.exists("lib/DESCRIPTION"), file.exists("_site/index.html"))
PackageMeta <- read.dcf("lib/DESCRIPTION", fields = c("Package", "Version"))
if (as.character(utils::packageVersion(PackageMeta[1L, "Package"])) != PackageMeta[1L, "Version"]) {
  stop("The installed R package must match lib/DESCRIPTION before building its documentation. Use the package's maintenance scripts.")
}
pkgdown::build_site(pkg = "lib", preview = FALSE, install = FALSE)
stopifnot(file.exists("_site/lib/index.html"))
stopifnot(file.copy("lib/LICENSE", "_site/lib/LICENSE"))

# Keep published package links working after moving pkgdown below /lib/.
Site <- yaml::read_yaml("docs/_config.yml")
FILES <- list.files("_site/lib", pattern = "[.]html$", recursive = TRUE)
FILES <- setdiff(FILES, c("index.html", "404.html"))
for (FILE in FILES) {
  Destination <- file.path("_site", FILE)
  if (file.exists(Destination)) stop("Site path collision: ", Destination)
  Target <- paste0(Site$baseurl, "/lib/", FILE)
  dir.create(dirname(Destination), recursive = TRUE, showWarnings = FALSE)
  writeLines(c(
    '<!doctype html><html lang="en"><head><meta charset="utf-8">',
    paste0('<meta http-equiv="refresh" content="0;url=', Target, '">'),
    paste0('<link rel="canonical" href="', Site$url, Target, '">'),
    '<title>Documentation moved</title></head><body>',
    paste0('<a href="', Target, '">Open the R documentation</a>'),
    '<script>location.replace(document.querySelector("a").href + location.search + location.hash);</script>',
    '</body></html>'
  ), Destination)
}
# pkgdown consumers discover the new reference and article URLs through this file.
for (FILE in c("pkgdown.yml", "sitemap.xml", "llms.txt")) {
  stopifnot(file.copy(file.path("_site/lib", FILE), file.path("_site", FILE)))
}
file.create("_site/.nojekyll")
