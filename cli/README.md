# NGR CLI

The CLI lives in `cli/`; the R package remains independently buildable in
`lib/`. Follow the [public installation guide](https://averrik.github.io/NGR/articles/cli.html#install)
from the repository root. Installation and package tooling live in `install/`,
with macOS and Windows entries `install/install.sh` and `install/install.ps1`.
The CLI component checks the installed NGR package and never installs, updates
or removes R packages. The common entry coordinates the selected components.
Modified or foreign runtime files block replacement or removal.

Requirements depend on the operation. All commands use `cli/main.R` and the
installed NGR package. The macOS launcher uses Bash; Windows uses `ngr.cmd`
from CMD and `ngr.ps1` from PowerShell. Both are installed in the same bin directory.
The installer needs
Python >=3.8; DOCX correction needs Python >=3.9. On Windows, staging a project
with symbolic links also uses Python's standard `os.symlink` operation to preserve
file/directory links, including dangling links. Rendering needs Quarto and
its selected engine. Manifest operations use the R package's JSON reader. Publication
uses the Netlify CLI; DNS diagnostics use dig when available. A scaffold's
declared checks and scientific content can require additional software.

## Project workflow

Run in the project directory. All paths, including `.netlify/sites.env`, resolve
there. No enclosing Git checkout or `--project` argument is needed.

The following commands illustrate separate operations. Replace the source
manifest, source ID, artifact alias and master with entries that exist in your
project; this is not a sequence that creates a complete scientific report.
`--force` authorizes replacement of differing managed resources.

```sh
ngr pull --from ngr --from /path/to/book/manifest.json
ngr status --check
ngr doctor
ngr pull --source sha scripts _fig --force
ngr render --manifest manifest.json --dry-run --only report
ngr render _master/book.en.qmd --profile book
ngr deploy --help
```

`pull` handles both incorporation and updates. The first invocation names each
source (`--from` is repeatable); `ngr` names the installed presentation base.
Later invocations use the registered associations, optionally narrowed by
repeatable `--source`. Positional paths are destination files or directory
prefixes. A partial initial incorporation stays partial on later default pulls.
Unknown sources/paths fail. `--source` and `--from` cannot be combined.

Missing files are created; identical files are retained. Differing managed files
require `--force`; existing seeds are always preserved. The entire selection is
preflighted before writing, including applied claims from unselected sources.
Different source bytes or ownership at the same destination are incompatible,
even with `--force`. Equal contributions can share a path. Case collisions and
file/directory conflicts fail. No files are removed, and no master is moved.
Extras and scientific data stay in the project. `--dry-run` validates the same
plan without writes; differing managed files still require `--force` to plan
their replacement. Ordinary write failures trigger restoration; crash or
concurrent-writer transactionality is not promised.

`status` compares source, project and per-file receipt; `--check` exits 1 for
drift/missing/retired files. Edited seeds are reported as project-owned.
`doctor` reports the loaded R package and runs the checks explicitly declared
by the registered sources. Source checks are argv arrays executed in the project,
so review a source before running its checks. Neither command updates resources.

## Source manifest

Each book owns a JSON manifest and can map arbitrary folders within its source
tree to shared project folders. Paths are canonical relative paths; symlinks,
parent traversal and resources targeting `.git`, `.ngr`, `oq`, `gmsp` or the
project manifest are rejected.

```json
{
  "schemaVersion": 1,
  "id": "my-book",
  "resources": [
    {"from": "chapters", "to": "_chapters", "ownership": "managed"},
    {"from": "masters", "to": "_master", "ownership": "seed"}
  ],
  "artifacts": [],
  "checks": []
}
```

`artifacts` can seed an empty project artifact list using the existing QRT
schema; an existing nonempty list remains project-owned. Source authors supply
the family, paths and optional publication identities. NGR does not infer a
hosting domain from the book's name. The SHA candidate supplies 21 artifact
seeds without provider destinations; define those before deploying.

Each scaffold declares its resources in its own `manifest.json`. The project's
`manifest.json` records its composition and is read by TOC, transmittal and
render-stamp consumers. These are separate objects in separate directories;
the source manifest is never copied over the project's manifest.
The installed base supplies formatting resources, including `bib/apa.csl`;
the scientific bibliography belongs to the book source. The base does not
claim `bib/references.bib`.
`scaffolds.<id>` records the source manifest
path, enrolled selection, applied source claims, checks and per-file receipts.
Managed receipts retain `commit`, `dirty`, `md5` and add SHA-256; seeds never gain
a receipt for customized local bytes. A non-Git source has revision `unknown`
and content hashes remain exact. Partial updates preserve other file receipts.
Legacy provenance without a source association requires explicit `--from`.

### Migrating an existing project

Preserve a copy before migration. Rename the project's `qrt.manifest.json` to
`manifest.json`; if both exist, reconcile their contents first. Rename each
scaffold's `ngr.source.json` to `manifest.json` and update the exact paths stored
in `scaffolds.<id>.manifest`. Keep artifact metadata, claims and per-file
receipts intact. Update project consumers such as `scripts/setup/toc.R`,
`transmittal.R` and `utils.R` to read the new name, then run `ngr status` and
render the affected masters. The SHA candidate already has these readers.
For original PSHA receipts under `scaffolds.psha`, explicitly migrate that
association to the new source ID `sha`, preserve its receipts and set its
manifest and enrolled selection. Keeping both identities creates unresolved
claims; renaming only the JSON file is insufficient. See the
[scaffold migration guide](https://averrik.github.io/NGR/articles/scaffolds.html).

Resource commands and default direct rendering reject a project that still
contains `qrt.manifest.json`. They do not rename it, fall back to it or create
a second state file. The original QRT/PSHA installations keep their old contract;
use preserved project copies when comparing them with NGR.

## Render and deploy

Render retains the direct profiles book, html, revealjs and docx, including
composed Word books, nested masters, temporary staging, DOCX correction, custom
manifest outputs and existing static artifacts. Publication retains the
`deploy`, `deploy init`, `deploy domain` and `deploy unbind` forms, direct and
manifest selection, draft/production, site creation, domains, TLS and DNS
diagnostics. `deploy init` registers sites; it does not incorporate resources.
See `ngr render --help` and `ngr deploy --help` for exact arguments.

The single `cli/main.R` loads the installed NGR package through normal R library
resolution. `pull`, `status` and source checks use `NGR::pullResources()`,
`NGR::compareResources()` and `NGR::checkResources()`. These APIs also work
from R without the CLI. `NGR::quartoRender()` owns staging, YAML composition,
publication provenance, Quarto execution, DOCX repair and output delivery.
The unchanged Python repair script is distributed inside the R package and
resolved through `system.file()`. `install/cli/checkRuntime.R` reads the single
`install/requirements.R` contract and checks the installed exports, CLI entry
and `manifest.json` default before replacing the CLI; an incompatible package
must be updated separately, even if it has the same development version label.
`NGR::quartoRenderManifest()` owns batch selection, preflight and execution.
Static and legacy map entries represent external products; NGR never runs their
producer scripts. Netlify operations use `netlifyRegister()`, `netlifyDeploy()`,
`netlifyDomain()` and `netlifyUnbind()` from the package. Publication uploads
existing directories with `--no-build`; dry runs do not contact the provider.
Preflight precedes batch mutations; a later failure can retain earlier completed
effects. The CLI never invokes QRT or PSHA.

## Focused checks

With an authorized installed candidate and a test destination, run:

```sh
NGR_TEST_BIN=/absolute/prefix/bin/ngr NGR_TEST_ROOT=/absolute/test/root python3 -B -m unittest discover -s cli/tests -v
```

These tests exercise the installed public interface. Remote publication requires
separate explicitly selected destinations; local checks do not certify Netlify
service behavior.
