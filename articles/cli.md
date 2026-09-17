# NGR command-line interface

**Development interface.** The repository contains `cli/main.R` and
`install/`. Installing the R package alone does not install the CLI. The
complete scaffold builder migration remains in progress.

NGR combines project resources, Quarto rendering and Netlify
publication. The CLI is implemented in `cli/`; the installed R package
is a separate dependency. Development builds are verified in isolated
installations. Complete project acceptance remains separate from command
and installer tests.

## Install

Run installation commands from the **repository root**, where `install/`
and `lib/` are siblings. Replace the example paths with your actual
destinations before running a command. Install R first and make
`Rscript` available. The installer does not install R or
operating-system tools.

### R package

Build and install only the package into an explicit, writable R library:

``` sh
bash install/install.sh --component lib --library /absolute/path/to/R/library --build /absolute/path/to/build
```

On Windows, run the corresponding entry from PowerShell:

``` powershell
./install/install.ps1 --component lib --library C:/R/library --build C:/Build/NGR
```

`--build` creates a development archive without building manuals or
vignettes; it does not run a release check. Choose a new build directory
for each attempt. Use `--tarball /absolute/path/to/NGR_version.tar.gz`
instead to select an existing archive with its adjacent `.tar.gz.rds`
build record. Keep the chosen R library visible through `R_LIBS` or
`R_LIBS_USER` in later sessions. Compatible visible dependencies are
reused; missing or incompatible requirements can be installed into the
selected library.

### System CLI

The CLI requires the installed NGR package, Python and Quarto. Select a
system CLI prefix and use the platform’s required privileges. For
example, on macOS:

``` sh
sudo bash install/install.sh --component cli --library /absolute/path/to/R/library --prefix /usr/local
```

On Windows, open PowerShell **as Administrator**, select the same R
library, and choose the system CLI destination:

``` powershell
./install/install.ps1 --component cli --library C:/R/library --prefix "C:/Program Files/NGR"
```

The CLI component does not install, update or remove R packages. The
macOS entry keeps R verification under the invoking user when elevating
the CLI installation. On Windows, use the explicitly selected library
when elevating. Add the prefix’s `bin` directory to PATH; neither
installer changes your shell profile. Repeat the same command to update
the CLI. Modified or foreign runtime files block replacement. These
installation templates do not certify a particular elevated destination
or change its ownership policy.

After installation, verify the selected environment:

``` sh
ngr --version
ngr --help
```

Package installation and CLI installation are separate effects. The
common entry can also coordinate both with `--component all`, an
explicit library, prefix and exactly one of `--build` or `--tarball`. A
CLI failure does not undo a completed package installation.

## Work from your project directory

Change to the project directory before using resource or render
commands. The source manifest and master in this example must already
exist. They are project choices, not files supplied by the installation.
Review the source’s declared checks before running `doctor`.

``` sh
ngr pull --from ngr --from /path/to/book/manifest.json
ngr status --check
ngr doctor
ngr render --manifest manifest.json --dry-run
ngr render _master/book.en.qmd --profile book
```

These are separate operation examples. Rendering the book also requires
all chapters, data and software referenced by its master. A successful
manifest dry run does not execute the book or prove those scientific
inputs are present.

`pull` incorporates and updates declared resources. Registered sources
remain in `manifest.json`; subsequent pulls reuse them. Select
destination paths positionally and registered sources with `--source`.
Use `--force` to replace differing managed files. Existing project seeds
and editable masters stay local; conflicting source contributions always
fail before copying.

Each scaffold also has its own `manifest.json`, declaring its resources.
The project manifest records the composition and provenance instead. For
existing projects, preserve a copy, rename `qrt.manifest.json`, and
update source associations and readers together. NGR rejects unmigrated
project manifests; it does not maintain two state files or silently fall
back to the old name. The [scaffold
guide](https://averriK.github.io/NGR/articles/scaffolds.md) explains
source and destination folders, builder ownership and the additional
source-association migration required by older PSHA projects.

Resource operations are provided by the installed R library through
[`pullResources()`](https://averriK.github.io/NGR/reference/pullResources.md),
[`compareResources()`](https://averriK.github.io/NGR/reference/compareResources.md)
and
[`checkResources()`](https://averriK.github.io/NGR/reference/checkResources.md).
They can also be used directly from R. Resource commands do not require
Python; the current CLI installer and DOCX correction still use it.
Windows render staging also uses Python’s standard library when a
project contains symbolic links. Scaffold checks can require additional
software declared by their source.

`render` supports HTML books, HTML documents, RevealJS presentations,
simple and composed DOCX, and preserves existing static artifacts. It
loads the installed NGR R package and calls
[`quartoRender()`](https://averriK.github.io/NGR/reference/quartoRender.md),
independently of a source checkout. That API owns staging, Quarto
execution, DOCX repair and output delivery; its Python repair resource
is included in the R package.
[`quartoRenderManifest()`](https://averriK.github.io/NGR/reference/quartoRenderManifest.md)
owns batch selection, preflight and execution. Static and legacy map
entries refer to external products; NGR does not run their producer
scripts.

`deploy` uploads existing outputs. `deploy init` associates Netlify
sites; `deploy domain` manages domains and HTTPS; `deploy unbind`
removes a local alias. Production requires `--prod`. Use
`ngr deploy --help` for direct and manifest forms. Resource
incorporation never publishes a site.

## Library operations

The Bash, CMD and PowerShell launchers enter `cli/main.R`; the installed
NGR package provides command dispatch and the reusable operations,
including
[`netlifyRegister()`](https://averriK.github.io/NGR/reference/netlifyRegister.md),
[`netlifyDeploy()`](https://averriK.github.io/NGR/reference/netlifyDeploy.md),
[`netlifyDomain()`](https://averriK.github.io/NGR/reference/netlifyDomain.md)
and
[`netlifyUnbind()`](https://averriK.github.io/NGR/reference/netlifyUnbind.md).
Runtime commands do not install dependencies or load R code from the
source checkout.

R consumers can call these operations without the CLI:

| Operation | R interface |
|----|----|
| Incorporate or update resources | [`pullResources()`](https://averriK.github.io/NGR/reference/pullResources.md) |
| Compare resources | [`compareResources()`](https://averriK.github.io/NGR/reference/compareResources.md) |
| Diagnose source requirements | [`checkResources()`](https://averriK.github.io/NGR/reference/checkResources.md) |
| Render one source or a manifest selection | [`quartoRender()`](https://averriK.github.io/NGR/reference/quartoRender.md), [`quartoRenderManifest()`](https://averriK.github.io/NGR/reference/quartoRenderManifest.md) |
| Inspect render provenance | [`quartoRenderStamp()`](https://averriK.github.io/NGR/reference/quartoRenderStamp.md) |
| Associate, publish or configure Netlify sites | [`netlifyRegister()`](https://averriK.github.io/NGR/reference/netlifyRegister.md), [`netlifyDeploy()`](https://averriK.github.io/NGR/reference/netlifyDeploy.md), [`netlifyDomain()`](https://averriK.github.io/NGR/reference/netlifyDomain.md), [`netlifyUnbind()`](https://averriK.github.io/NGR/reference/netlifyUnbind.md) |

Scaffolds use
[`buildPlot()`](https://averriK.github.io/NGR/reference/buildPlot.md)
for supported graphics. The scaffold or scientific producer owns data
selection and calculation; NGR owns the representation. Existing map
HTML is an input to reports. Rendering never starts a map producer or
OpenQuake.

Run `ngr --help`, `ngr pull --help`, `ngr render --help` or
`ngr deploy --help` for command arguments. Local verification does not
certify a remote deployment.
