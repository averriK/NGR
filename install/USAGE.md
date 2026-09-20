# Product installation

Run from the repository root. The public operation installs the complete R
library + CLI product. R must already be installed.

```sh
sudo bash install/install.sh
bash install/install.sh --yes --library "/chosen/R/library" --prefix "/chosen/prefix"
bash install/install.sh --check --prefix "/writable/test/prefix"
```

The Unix prefix defaults to `/usr/local`. Under sudo, Bash owns prefix writes;
every R process runs as the validated invoking user. Without sudo choose a
writable prefix. `--check` validates prerequisites and destinations without
installing. Receipt handling requires `jsonlite` already visible to R.

The default builds `lib/` without manuals or vignettes and installs it even
when the existing version is equal or newer. `--tarball FILE` selects a recorded
archive and its adjacent `.rds` instead. Repeat `--dependency FILE` to install
private dependency archives in the supplied order. DESCRIPTION and the package
solver own dependencies. `requirements.R` lists CLI packages by name, without
version constraints; the installer does not impose a minimum version of pak.
The installed product must load from the selected library, match the selected
artifact and expose its declared CLI exports.

Replacing an existing package or CLI asks once before any build or installation.
`n` or an empty answer cancels unchanged; EOF fails. `--yes` skips that question.
There are no public `--component` or `-Component` modes. R package maintenance
and documentation building remain separate operations in `build.R`.

## Current R and its libraries

Installers, uninstallers and generated launchers share the same resolver.
macOS uses the current Framework alias, then an unversioned Homebrew R prefix;
Linux uses `/usr/local/bin/Rscript`, then `/usr/bin/Rscript`. An arbitrary
`Rscript` first on PATH cannot replace these system locations. A private R
installation outside these locations is not supported by this resolver.
On Windows, the current R-core registry version selects the installation,
with HKCU before HKLM. R's installer must register it; see the
[R Windows FAQ](https://cran.r-project.org/bin/windows/base/rw-FAQ.html).

The receipt records installation history. Launchers do not read its interpreter
or library path and do not retain a version-specific `RSCRIPT` file. Each call
uses the current R's normal library search and user startup. After upgrading R,
install the product for that R when it is absent from the new search path.
`--library` defaults to that R's `R_LIBS_USER`; a custom library must remain
visible through the caller's normal `R_LIBS`/`R_LIBS_USER`. No profile is edited.

## Local acceptance and rollback

Before committing a CLI transaction, both publishers run only `--version` and
`--help`, with the selected library and explicitly empty R environment/profile
files. Those two operations must be local and require no service credentials.
`doctor`, APIs and scientific operations belong to product acceptance tests.
Normal CLI invocations keep their normal user environment. This distinction
uses R's documented [startup controls](https://stat.ethz.ch/R-manual/R-patched/library/base/html/Startup.html).

The CLI lives in `PREFIX/bin/<command>` and `PREFIX/libexec/<runtime>`.
Receipt paths, hashes and symlink ancestors are validated. Failed publication
restores the previous CLI; an already installed R package remains installed.
Updates retire previously owned files absent from the new payload. Foreign
files and nonempty directories survive. Unknown or modified files are refused.

```sh
sudo bash install/uninstall.sh
sudo bash /usr/local/libexec/<runtime>/install/uninstall.sh
```

Removal works without the source checkout. Supply the chosen `--prefix` again;
`--library` selects a library for receipt-reading dependencies, not a removal
target. The final notice reports the historical package library from the receipt
(or unknown if absent). It never removes an R package.

## Windows

```powershell
powershell -ExecutionPolicy Bypass -File install\install.ps1 -Yes -Library "C:\R library" -Prefix "C:\Tools\product" -NoPath
```

Options are `-Yes`, `-Check`, `-Library`, `-Dependency`, `-Tarball`, `-Prefix`
and `-NoPath`. The default prefix is `%LOCALAPPDATA%\Programs\<package>`.
Unless `-NoPath`, installation adds its bin directory to the user PATH; removal
only removes an entry its receipt records adding. Use `install\uninstall.ps1`
(or the installed copy) with `-Prefix`, `-Library`, `-Yes` and `-NoPath`.
macOS checks do not certify native Windows or real sudo.

## Product declarations and tests

`requirements.R` names `command`, optional `runtime`, `exports`, `packages`
(an unnamed character vector), `tools` and optional tools. NGR declares
`pathEnv = "NGR_COMMAND_PATH"` to preserve the caller's executable search path.
`manifest.json` lists the payload and the command's three `bin/` entries.
The manager generates those launchers from the managed `install/cli/command.*`
templates; old product-owned launchers are not read. There is no `launchers`
or `verify` policy switch. Run `bash install/update-manifest.sh` after changing
payload files. Domain code and public APIs remain product-owned.

`bash install/cli/test-installers.sh [R_LIBRARY]` runs disposable fixtures.
Supplying an installed library also runs `install/acceptance.R` through the
installed CLI without replacing that library. Windows uses
`powershell -File install/cli/test-installers.ps1 [-Library R_LIBRARY]`.
The internal manager supports these isolated CLI tests; it is not a public
partial-installation mode.
