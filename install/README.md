# Installation policy

Owner instruction, 2026-09-16: all installation tools belong in `install/`,
including R libraries, dependencies, CLI and CRAN tooling, with macOS and
Windows entry points.

## Location and ownership

| Location | Responsibility |
| --- | --- |
| `install/install.sh` | Public installation entry for macOS/Linux |
| `install/install.ps1` | Public installation entry for Windows, invoked with PowerShell |
| `install/` | Shared installation helpers, R dependency/package installation, component installation/update/removal, receipts and installation tests |
| `install/` | Package tooling: prepare dependencies, document, build, check exact artifacts, and explicit CRAN/R-hub release operations |
| `lib/` | Independently buildable R package and public APIs |
| `cli/` | CLI payload, argument adapter and operational resources/tests |
| `dev/` | Plans, experiments, SoT comparisons, audits and continuity |
| `lib/vignettes/`, `lib/man/` | Public documentation sources rendered by pkgdown |

There is one owner for each installer/helper, under `install/`. Move and
reuse the existing implementations without keeping duplicate versions.
Preserve executable behavior, callers and tests while migrating paths.

`lib/inst/` may contain resources needed by the installed R package. It must
not contain repository installation, development or release tooling. Neither
`install/` nor `dev/` is copied into the installed R package or CLI runtime.

## Product and component installation

The product entry coordinates installation of the selected R library, its
dependencies and the implemented CLI. R-only and CLI-only installation remain
explicit operations. Reserved app/skill/MCP components are not installed.
The runtime calls the installed library; it neither sources the checkout nor
installs or updates dependencies during normal commands.

Resolve dependencies from DESCRIPTION **and actual component operations**.
Respect version constraints, additional R packages, interpreters and external
tools. Install missing/incompatible R requirements in the selected library
and preserve compatible visible packages. An unloadable package is not simply
an absent package. Private/development dependencies require an explicitly
identified source or artifact; do not silently substitute a CRAN release.

Inspect destinations, ownership, conflicts and prerequisites before modifying
them. Identify the selected package artifact by hash and verify its installed
identity and required API. Package name and version alone do not identify a
development build. Installation of a selected tarball must not rebuild another
tarball or imply it passed a release check.

## Platforms and privileges

Each product uses `cli/main.R` as its single R command entry on macOS and
Windows. Platform launchers only locate the installed runtime and forward
arguments, streams and exit status. Command parsing and dispatch are shared;
calculations and reusable domain operations remain in the installed library.
Preserve required Python helpers where their operation needs Python. A new
filename alone does not complete the transition from an existing Bash driver.
Reserved products receive this entry when their CLI is implemented, not an
empty placeholder presented as an operational interface.

The CLI must be usable from Windows and macOS. Providing a `.ps1` file or
passing a macOS check is not evidence of Windows support. The maintainer owns
the choice and implementation of the required runtime; the user is not asked
to design that layer. Native R/Python code should be reused where applicable.
Existing Bash requirements must be handled by a deliberate Windows installation
contract with launchers and path handling; do not silently assume WSL or Git
Bash is already present.

The established macOS/Linux entry convention is
`sudo bash install/install.sh` when the selected system CLI destination
requires elevation. The Windows entry is `install/install.ps1` through
PowerShell. Privilege requirements must follow the actual destination and
component. Elevating CLI installation must not silently select root's R
library, create root-owned files in the caller's R library or change the
intended R user. Record and verify effective R, user, library and CLI paths.
No fallback to a different destination after a permission failure.

## Separate effects

Installation, documentation generation, build, package checks, CRAN submission,
R-hub dispatch and Pages publication are separate explicit operations, even
though their package/installation tools share `install/`.
CRAN tooling location does not authorize automatic submission, publication,
Git changes, credentials, OS-level installation or project-data migration.

Retain the robust checker contract: check the exact recorded tarball, retain
options/logs/results, expose errors and warnings, leave NOTEs for review and
never reuse a passed record after a failed or interrupted check. Contextual
CRAN review complements those checks; it does not replace them.

Preserve the existing installation, documentation, package-test, checker and
submission controls when moving them. Inventory each entry and its callers
before replacement, then prove that its safeguards still execute. Do not
replace the maintained workflow with a bare R CMD check. Submission is a
separate explicit operation: identify its actual implementation and its input
artifact, retain the receipt and do not retry an uncertain upload. Moving a
submitter does not authorize changing or executing it.

Updates and removal respect ownership receipts, preserve foreign/modified
files and keep shared R libraries/dependencies unless their removal is an
explicitly selected operation. Report partial success accurately: failure of
CLI installation does not undo an R installation. Preserve recovery evidence
when restoration is uncertain. Keep QRT/PSHA/SPT references until their owner
explicitly retires them.

## Acceptance and migration status

Validate the installed interfaces outside the checkout, including package/API
identity, a representative operation, missing dependencies, compatible
dependency preservation, file conflicts, update/removal and failure handling.
Exercise paths with spaces and Unicode, argument forwarding and exit status
on the actual supported platforms. Record macOS and Windows results separately.

This file defines the required policy. It does not certify that the current
scripts have completed migration or that Windows tests have passed. Before
declaring completion, migrate callers/manuals/tests to `install/`, remove the
superseded implementation paths and verify the installed product. Repository
sources remain private; public help links use Pages.

## NGR migration status

The entries and helpers are implemented in `install/`. Local macOS and Windows
results and their limits are recorded in `dev/plan/cli-fusion/CLOSURE.md`.
Scaffold builder migration and complete project acceptance remain in progress.
