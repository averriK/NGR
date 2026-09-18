# Product installation

Run from the repository root. Installation is separate from documentation,
release checks, submission and publication.

```sh
sudo bash install/install.sh
sudo bash install/install.sh --build
sudo bash install/install.sh --component cli
bash install/install.sh --component lib --library "/path/to/R/library"
bash install/install.sh --check --prefix "/writable/test/prefix"
```

The default Unix prefix is `/usr/local`. Under sudo, the original Bash process
owns writes to that prefix. Every R process runs as the validated invoking
`SUDO_USER`, including receipt preparation. R does not request elevation.
Without sudo, select a prefix writable by the current user.

R must be installed. The CLI installer requires `jsonlite` in a visible R
library to validate its manifest and receipt before modifying the product.
If absent, the diagnostic gives its installation command; `--check` never
installs it. The selected library defaults to R's `R_LIBS_USER`;
`--library` overrides it while retaining the existing library search chain.

The default installs a missing package from `lib/`, or retains an installed
package that satisfies the CLI's minimum version, loads and exports. An equal
version string alone is insufficient. An incompatible existing package fails
with an explicit rebuild instruction. `--build` replaces it from source;
`--tarball FILE` selects an archive plus its adjacent `.rds` record.
Repeated `--dependency FILE` installs recorded private dependency artifacts
in the supplied order before resolving the product's remaining dependencies.
It requires a build/tarball when the product is already installed.

`--component lib` does not write the CLI. `--component cli` installs no R
packages and requires all CLI dependencies already visible. When a package is
retained, the default also checks existing CLI dependencies without updating
R packages. A non-default library must remain visible to subsequent commands
through the user's normal R environment; no shell profile is edited.
Source builds omit manuals and vignettes; `build.R` remains the separate
documented maintenance operation.

On Windows, use native PowerShell without elevation:

```powershell
powershell -ExecutionPolicy Bypass -File install\install.ps1
powershell -ExecutionPolicy Bypass -File install\install.ps1 -Build
powershell -ExecutionPolicy Bypass -File install\install.ps1 -Component cli -Library "C:\R library" -Prefix "C:\Tools\product" -NoPath
```

Equivalent options are `-Yes`, `-Check`, `-Library`, `-Dependency`,
`-Tarball`, `-Build`, `-Component` and `-Prefix`. The default prefix is
`%LOCALAPPDATA%\Programs\<package>`. `-NoPath` prevents a user PATH change.
Removal only removes a PATH entry that this installer recorded adding.

The CLI lives in `PREFIX/bin/<command>` and `PREFIX/libexec/<runtime>`.
Updates and removal validate receipt paths, hashes and symlink ancestors,
preserve foreign files, and retain a backup until installed-command verification
passes. A CLI failure restores CLI files; it does not roll back an already
installed R package. Unknown legacy layouts are refused, never adopted by name.

```sh
sudo bash install/uninstall.sh
# After deleting the checkout, use the installed copy:
sudo bash /usr/local/libexec/<runtime>/install/uninstall.sh
```

For another prefix or library, pass `--prefix` and `--library` again. Windows
uses `install/uninstall.ps1` (also copied below the runtime), with `-Prefix`,
`-Library`, `-Yes` and `-NoPath`. The installed removal bundle contains only
the wrappers, manager, path validator, Bash publisher and metadata it needs.
It contains no package implementation or release tooling.

# Maintainer checks

`bash install/cli/test-installers.sh [R_LIBRARY]` runs the common disposable
fixtures; supplying an already installed test library also exercises the
product's installed CLI without modifying that library.
`powershell -File install/cli/test-installers.ps1 [-Library R_LIBRARY]` is the
native Windows entry. A macOS result does not certify Windows or real sudo.

Product declarations are `requirements.R` and `manifest.json`. A product with
legacy source launchers can set `launchers = TRUE` and supply the three files
under `install/launchers/`; the manager copies them and records its chosen
Rscript in `RSCRIPT`. Regenerate the payload manifest with
`bash install/update-manifest.sh`. Do not edit package or CLI APIs to adapt
an installer.
