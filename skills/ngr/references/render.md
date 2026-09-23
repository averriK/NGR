# Render

## Render the selected product

Use the master and profile explicitly validated by the user, directly or through
the identified project contract. Existence or a familiar filename does not
select them; ask and wait if either is missing. Typical
forms, with example master names:

```text
ngr render report.qmd --profile html
ngr render ppt.qmd --profile revealjs
ngr render _master/book.en.qmd --profile book
ngr render _master/book.en.qmd --profile docx
ngr render --manifest manifest.json --only report-web,slides --dry-run
ngr render --manifest manifest.json --only report-web,slides
```

Use direct form for one source/profile, manifest form for artifact declarations.
Direct form accepts additional Quarto arguments; take them from the task or
project. `--dry-run`, `--only` and `--except` require manifest form; that form
does not accept extra Quarto arguments or a separate input/profile.

### Resolve inputs

Read the master, the chapters/includes it actually reaches, its setup and
configuration. Follow their data/script references sufficiently to establish
the requested product and the input generation it consumes. A folder listing
or an older output cannot establish those dependencies. A reporting master can
need only tables/audits from a much larger signal dataset; do not regenerate
or copy unrelated upstream products merely because they share the project.
Resolve missing source or method validation before render; a dependency read
does not authorize adopting that dependency as scientific input.

Distinguish missing measured inputs from missing computed tables or identifiers.
Trace a missing object's producer before asking the user: an identifier derived
from a table is not a new scientific input. When producing that table is already
authorized and its inputs/method are validated, complete the upstream workflow
through its selected public interface before rendering. Otherwise state the
specific missing input or scope. Do not ask the user to supply a result that the
authorized workflow is meant to calculate, or repeatedly render around the gap.

NGR uses `yml/_quarto.yml` plus `yml/_quarto-<profile>.yml`. Resolve missing
base resources through [Resources](resources-manifest.md#resources). Project
code runs during render and needs its R packages/data; DOCX also uses the
Python repair distributed with NGR. Diagnose the actual missing prerequisite
without replacing the installed environment or fabricating data.

For books, inspect frontmatter `chapters` and `appendices`, including a home
page such as `index.qmd`. A YAML fixture listing chapters is not necessarily
a complete Quarto book. DOCX accepts either a standalone document or a book
master; NGR handles composition and Word repair.

NGR renders in a temporary project copy. Individual masters below directories
such as `_master/` are staged at its root: their includes/assets must resolve
from the project root. Investigate parent-relative path warnings and missing
content even if Quarto exits zero. Existing top-level generated folders,
including `html/` and `docx/`, are excluded from staging; a report that depends
on an existing product there needs its intended input arrangement resolved.

### Plan and run a manifest

Read [Artifact manifests](resources-manifest.md#artifact-manifests) for schema,
destinations and selection. A dry-run validates schema, selection, HTML/DOCX
path rules, whole-manifest output collisions and selected Quarto source
presence. It does not execute Quarto, discover all data dependencies or check
final/static outputs.

Real execution follows array order and stops at the first render failure.
`static` and `map` entries are external products: NGR skips their producers.
After rendering, the output check expects `<path>/index.html`, or
`docx/<master-stem>.docx` for DOCX. Missing required output fails; missing
optional output is reported. An optional selected Quarto master must still
exist and render successfully.

## Verify the delivered output

For direct HTML, book or RevealJS the default destination is
`html/<master-stem>/`; direct DOCX writes `docx/<master-stem>.docx`. Manifest
HTML writes to its explicit `path`, even when the name differs from the stem.
The alias never renames the output by itself.

Identify the existing destination before running: delivery replaces the HTML
tree and can overwrite corresponding DOCX files. Quarto execution and DOCX
repair finish before delivery starts. A failure in those stages preserves the
previous delivered output; an interruption or filesystem failure during final
copy can leave partial output. Reconcile the final NGR exit and destination,
not just Quarto's temporary `_ngr-output` message.

Check the product against the actual master: chapters/slides present, current
table values and IDs, figures/widgets populated, local resources and links
available. For interactive HTML, exercise navigation and representative tabs.
When layout matters, inspect the rendered pages/slides or Word document;
successful execution can still leave titles, captions or footers overlapping.
Compare representative displayed values with the consumed data when the task
requires confidence in current numerical results.

The `Pub: <date> Rev.…` stamp describes recorded provenance of **all registered
scaffolds**, not just the chosen master. Missing/modified resources, dirty
revisions or unknown provenance produce `· DRAFT`; unknown revision is `—`.
It does not certify the scientific generation or content quality. Preserve
resource receipts when maintaining a manifest so provenance remains meaningful.

For a partial batch, read the log and verify outputs of completed aliases.
Resolve the failed entry's specific dependency, then resume with `--only`
for failed/unattempted aliases that remain in scope. Do not repeat the verified
prefix or pass pull's `--force` as a render recovery flag. For an unknown or
still-running attempt, use [Long jobs](long-jobs.md) before launching again.

Return the final paths and verification limits. Continue to
[Deploy](deploy.md) when publication was requested; an already accepted
output can be deployed without rendering it again.
