# Native dependency and artifact installation, using an offline repository.
runChecks <- function(kit) {
  source(file.path(kit, "package.R"), local = TRUE)
  stopifnot(!any(grepl("pak::", readLines(file.path(kit, "package.R")), fixed = TRUE)))
  Work <- tempfile("native dependencies ü ")
  dir.create(Work)
  on.exit(unlink(Work, recursive = TRUE), add = TRUE)
  Libraries <- .libPaths()
  on.exit(.libPaths(Libraries), add = TRUE)
  Options <- options()
  on.exit(options(Options), add = TRUE)
  Repository <- file.path(Work, "repository", "src", "contrib")
  dir.create(Repository, recursive = TRUE)
  Library <- file.path(Work, "selected")
  Other <- file.path(Work, "read only")
  dir.create(Library)
  dir.create(Other)
  options(repos = c(CRAN = paste0("file://", dirname(dirname(Repository)))), pkgType = "source")
  .libPaths(c(Library, Other, Libraries))

  buildFixture <- function(name, version, imports = character(), code = "probe <- function() TRUE") {
    Root <- file.path(Work, paste0(name, version), name)
    dir.create(file.path(Root, "R"), recursive = TRUE)
    writeLines(c(paste0("Package: ", name), paste0("Version: ", version),
      "Title: Native Installation Fixture", "Description: Exercises native installation boundaries.",
      "Author: Fixture", "Maintainer: Fixture <fixture@example.org>", "License: GPL-3",
      if (length(imports)) paste0("Imports: ", paste(imports, collapse = ", "))), file.path(Root, "DESCRIPTION"))
    writeLines("export(probe)", file.path(Root, "NAMESPACE"))
    writeLines(code, file.path(Root, "R", "probe.R"))
    FILE <- buildPackage(path = Root, output = dirname(Root), documents = FALSE)
    list(root = Root, file = FILE)
  }
  expectFailure <- function(expr, pattern) {
    OUT <- tryCatch(force(expr), error = identity)
    if (!inherits(OUT, "error") || !grepl(pattern, conditionMessage(OUT), fixed = TRUE)) {
      stop("Expected failure containing: ", pattern, "\nObserved: ", paste(OUT, collapse = "\n"))
    }
  }
  Leaf <- buildFixture("aomleaf", "1.0.0")
  Dependency <- buildFixture("aomdependency", "1.0.0", "aomleaf (>= 1.0.0)")
  .installPackages(Leaf$file, library = Other, repos = NULL, type = "source")
  .installPackages(Dependency$file, library = Other, repos = NULL, type = "source")
  Preserved <- tools::md5sum(list.files(Other, recursive = TRUE, full.names = TRUE))
  Leaf <- buildFixture("aomleaf", "2.0.0")
  Dependency <- buildFixture("aomdependency", "2.0.0", "aomleaf (>= 2.0.0)")
  stopifnot(file.copy(c(Leaf$file, Dependency$file), Repository))
  tools::write_PACKAGES(Repository, type = "source")
  Product <- buildFixture("aomproduct", "1.0.0", "aomdependency (>= 2.0.0)")
  Paths <- .libPaths()
  installRequirements(path = Product$root, library = Library, packages = character(), dependencies = NA)
  stopifnot(identical(.libPaths(), Paths),
    .packageInfo(file.path(Library, "aomdependency"))$version == "2.0.0",
    .packageInfo(file.path(Library, "aomleaf"))$version == "2.0.0",
    identical(Preserved, tools::md5sum(names(Preserved))))
  message("PASS native: outdated direct/transitive dependencies replaced only in selected library")

  options(repos = c(CRAN = paste0("file://", Work, "/unavailable")))
  installRequirements(path = Product$root, library = Library, packages = character(), dependencies = NA)
  expectFailure(installRequirements(path = Product$root, library = Library,
    packages = "aommissing", dependencies = FALSE), "Package installation failed")
  stopifnot(identical(.libPaths(), Paths))
  message("PASS native: compatible dependencies reused without network; unavailable dependency fails")

  # The selected archive stays valid even when the checkout has changed.
  write("Imports: aommissing", file = file.path(Product$root, "DESCRIPTION"), append = TRUE)
  installPackage(file = Product$file, library = Library)
  installPackage(file = Product$file, library = Library)
  stopifnot(.packageInfo(file.path(Library, "aomproduct"))$version == "1.0.0")
  Broken <- buildFixture("aombroken", "1.0.0")
  installPackage(file = Broken$file, library = Library)
  # Keep the same package/version but make lazy loading fail in a new artifact.
  writeLines("stop('fixture lazy loading failure')", file.path(Broken$root, "R", "probe.R"))
  FILE <- buildPackage(path = Broken$root, output = file.path(Work, "broken build"), documents = FALSE)
  expectFailure(installPackage(file = FILE, library = Library), "Package installation failed")
  stopifnot(.packageInfo(file.path(Library, "aombroken"))$version == "1.0.0",
            identical(.libPaths(), Paths))
  write("tampered", file = FILE, append = TRUE)
  expectFailure(installPackage(file = FILE, library = file.path(Work, "forbidden")), "SHA-256")
  stopifnot(!dir.exists(file.path(Work, "forbidden")))
  message("PASS native: selected DESCRIPTION, same-version reinstall, real failed replacement and tamper guard")
}
runChecks(normalizePath(commandArgs(TRUE)[1L], mustWork = TRUE))
