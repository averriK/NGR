# Product installation

Run from the repository root. Installation is separate from documentation,
release checks, submission and publication.

```sh
sudo bash install/install.sh
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

The default always builds and installs the package from this checkout's `lib/`
together with its CLI, even if the installed version number is equal or newer.
No minimum package version selects or retains an older installation. The
installed package is checked for its selected artifact version, loading path
and required CLI exports. `--tarball FILE` explicitly selects an archive plus
its adjacent `.rds` record instead of building the checkout.
Repeated `--dependency FILE` installs recorded private dependency artifacts
in the supplied order before resolving the product's remaining dependencies.

`--component lib` always installs the selected package and does not write the
CLI. `--component cli` is the explicit exception: it installs no R packages and
requires the product and all CLI dependencies already visible. A non-default
library must remain visible to subsequent commands
through the user's normal R environment; no shell profile is edited.
Source builds omit manuals and vignettes; `build.R` remains the separate
documented maintenance operation.

Replacing any selected installed component asks once for the whole selected
operation, before creating build output or changing dependencies, the package
or the CLI. A new installation does not ask a replacement question. `n` or an
empty answer cancels without changes; end of input fails with an explicit
diagnostic. `--yes` skips the question only, and `--check` never asks or installs.
The header identifies the source, optional archive, component and destinations.

On Windows, use native PowerShell without elevation:

```powershell
powershell -ExecutionPolicy Bypass -File install\install.ps1
powershell -ExecutionPolicy Bypass -File install\install.ps1 -Component cli -Library "C:\R library" -Prefix "C:\Tools\product" -NoPath
```

Equivalent options are `-Yes`, `-Check`, `-Library`, `-Dependency`,
`-Tarball`, `-Component` and `-Prefix`. The default prefix is
`%LOCALAPPDATA%\Programs\<package>`. `-NoPath` prevents a user PATH change.
Removal only removes a PATH entry that this installer recorded adding.

The CLI lives in `PREFIX/bin/<command>` and `PREFIX/libexec/<runtime>`.
Updates and removal validate receipt paths, hashes and symlink ancestors,
preserve foreign files, and retain a backup until installed-command verification
passes. A CLI failure restores CLI files; it does not roll back an already
installed R package. Unknown legacy layouts are refused, never adopted by name.
Updates retire files no longer in the payload and remove empty directories
recorded as installer-created. Foreign files and nonempty directories remain.

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

The public wrappers no longer accept `--build`/`-Build`: source installation is
the default. The internal R entry still receives `--build DIR` from the wrapper
to locate its disposable build output; it is not a user mode or retention gate.
