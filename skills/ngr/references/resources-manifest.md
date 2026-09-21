# Resources and manifest

## Local resource operations

```text
ngr pull --from <manifest.json> [--from <manifest.json> ...] [paths...]
ngr pull [--source <id> ...] [--force] [--dry-run] [paths...]
ngr status [--source <id> ...] [--check] [paths...]
```

Read the selected local files and any existing `manifest.json` before a
write. The first pull in a project must name its sources with `--from`;
`--from ngr` selects the installed base. Without `paths`, a `--from` pull
selects the complete source and a later pull uses the enrolled selection.

A source is identified by the `id` in its manifest. Pulling a manifest whose
`id` is already associated re-points the association and prints
`source <id> now at <path> (was <path>)`; pulling from a registered location
that no longer exists fails with an error naming the source and asking for
`--from`. All implicated claims are checked before any write, including
claims of sources not selected for update. Incompatible source claims always
fail; `--force` never overrides them.

`pull` preserves existing seeds, extra project files and scientific data;
files retired from a source are not deleted. `--force` replaces different
managed files only — never seeds. Ordinary write errors restore the files
already written; concurrent writers and process termination are not covered
by that recovery. After an authorized write, compare the selected files and
copied/skipped results and verify project-unique files are unchanged.

`status` compares local files with their registered sources per-file:
`equal`, `different`, `missing`, `retired`, `project-seed` (customized seed)
or `locally-modified` (edited against its receipt). Capture stdout, stderr
and exit status. `--check` makes drift exit 1; customized seeds alone do not
set drift. A nonzero result without a report is inconclusive, never "clean";
preserve that observation and use bounded read-only comparisons if further
diagnosis is requested.

`status --from` compares against another manifest without re-pointing the
association. A refusal or a `different` report does not authorize adding
force, broadening a file to a whole source or re-pulling everything.

## Doctor

```text
ngr doctor [--source <id> ...]
```

Doctor validates all applied source claims, then runs each selected source's
declared check commands in the project directory. Those commands can have
effects; this is not a read-only query. A failed check stops the operation
with `Source check failed: <id> (exit <status>)`. A doctor failure on data
the project never had (for example missing `params.yml` values) is a project
condition, not a CLI defect; confirm against the project before attributing.

## Manifest identities

Keep source-resource and artifact manifests distinct. A source manifest has
`schemaVersion`, a source `id`, and `resources` entries with `from`, `to`
and `ownership` (`managed` or `seed`). Read the selected source's public
manifest before enrolling it; the installed base currently declares managed
resources only, so it does not imply that a project master is a seed.
The artifact schema below describes render/deploy products, not resource
ownership. Do not put artifact fields into a source declaration.

The explicit artifact manifest owns the artifact set and publication choices.
Resolve values from that contract; the same alias can refer to a differently
named master and output. `qrt.manifest.json` is foreign state: NGR never reads
or writes it, and the two files may coexist while a migration is verified; the
earlier file is removed in a later commit of the project.

| Field or record | Role |
| --- | --- |
| `alias` | Unique local artifact identity; also selects a registry entry for deploy |
| `renderSource`, `profile` | Source to execute and its explicit Quarto profile |
| `path` | Local output directory; it does not rename NGR's generated destination |
| `siteSlug` | Provider site name used for lookup/creation |
| `.netlify/sites.env` | Local `alias=UUID` mapping under the project root |
| `domain` | Custom hostname, without a scheme or URL path |
| `required` | Whether missing final output fails its output gate; not optionality of a selected render source |

NGR accepts schema versions 1 and 2. Use explicit V2 for newly authored work;
do not migrate an existing valid V1 manifest merely to run it. Both require a
nonempty `artifacts` array, unique nonempty aliases, nonempty paths and boolean
`required`. `siteSlug` and `domain` may be null or nonempty strings; the chosen
site/domain operation imposes its further requirements.

| V2 `kind` | `renderSource` | `profile` | Render behavior |
| --- | --- | --- | --- |
| `quarto` | Nonempty source path | `book`, `revealjs`, `docx` or `html` | Runs that source/profile |
| `map` | Nonempty pipeline path | null | External: checked as an existing output; its producer never runs |
| `static` | null | null | No render; an output must be supplied by its own producer |

V1 uses null source/profile for static entries; otherwise it uses a Quarto
source/profile pair. Do not infer or add a map kind to V1. Unlike the
predecessor CLI, NGR never executes a map pipeline; supply its product
through its own producer before the output gate.

For a Quarto source, `stem` is its basename without `.qmd` or `.md`:
`book`, `html` and `revealjs` publish to `html/<stem>`; `docx` publishes into
`docx`, with final file `<stem>.docx`. The alias and `siteSlug` do not determine
these paths. In particular, an alias named `report` does not turn a source
named `book.es.qmd` into `html/report`.

## Selection and planning

Manifest forms accept comma-separated aliases via `--only` and `--except`.
No selector means all declarations; an unknown alias or empty selection is an
error. Filters preserve array order. NGR has no dependency graph: read the
actual included content and upstream products to establish the required order,
then use an authorized manifest order or sequence of selections that respects
it. Do not assume one project's deck/hub/report relationships apply to another.

Use the native dry-run for the intended operation. Render planning checks
output claims across the whole manifest, even when a subset is selected.
Case-folded equal claims collide; two Quarto sources with the same basename can
target the same output despite different parent directories. A selector cannot
hide a collision or correct a declared path that disagrees with NGR's output.

Do not set `required=false`, remove declarations or change aliases to get a
plan through. A selected missing source still fails render planning even when
its final output is optional. Render-only entries such as DOCX need an
explicit editorial selection for the deploy operation; its website checks
are not a reason to silently rewrite the manifest.
