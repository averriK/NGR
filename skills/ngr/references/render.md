# Render

```text
ngr render <input.qmd> --profile <book|revealjs|docx|html> [Quarto args...]
ngr render --manifest <file> [--dry-run] [--only <aliases>] [--except <aliases>]
```

Use direct form for the selected source/profile and manifest form for the
selected declarations. The input must be project-relative. Extra Quarto
arguments come from the request or project contract. Only manifest form
offers dry-run. A book rendered to HTML does not prove the independent
`html` profile was exercised.

## Inputs and dependencies

Read the actual source and its included chapters/appendices, YAML, scripts,
data and assets. The direct interface composes `yml/_quarto.yml` with
`yml/_quarto-<profile>.yml`; book masters supply chapters and appendices
through frontmatter. DOCX can be a standalone QMD or a master with
chapters/appendices; NGR owns composition and Word postprocessing. Missing
YAML does not authorize a pull without the corresponding resource scope.

Rendering can execute project code: check the selected project's dependencies
and data, not just the presence of a master. Quarto and the project's R
environment must work; the installed base resources use R/NGR/yaml and DOCX
has Python postprocessing. Check only dependencies needed by the requested
products and do not install or switch environments as a fallback.

For masters under subdirectories such as `_master`, check that
resource/include paths are valid from the project root; a parent-relative
path warning may leave content missing despite Quarto returning zero. The
manifest does not prove that scientific selections, runs or data required by
those sources exist. If a requested product lacks its data contract, stop
that product instead of inventing upstream science or declaring its older
HTML valid. A source chunk guard such as `stopifnot(exists("root"))` failing
names the missing input; report it as-is rather than working around it.

## What the plan proves

Read [manifest selection rules](resources-manifest.md#selection-and-planning)
when using that form. Render dry-run checks schema/selection, selected source
presence, Quarto output path agreement and whole-manifest output-claim
collisions. External entries (`static`, legacy `map`) are skipped for
rendering.

The plan does not run Quarto/R code, inspect every YAML/data dependency,
validate final/static outputs or perform content QA. A passing plan with
missing scientific data or a broken runtime dependency is still only a
passing plan.

Real manifest render runs in array order and stops at the first render
failure, retaining earlier successful outputs; a selector does not reorder
dependencies. Its final output gate checks `<path>/<stem>.docx` for DOCX and
`<path>/index.html` otherwise: a missing required output fails, a missing
optional one is reported. That existence gate is not content acceptance.

## Generation and output acceptance

Identify the existing destination and current inputs before rendering. After
the process ends, reconcile NGR's return status and log with the final
`html/<stem>/` or `docx/` output. For each attempted artifact, distinguish
the newly produced tree, an older preserved tree and partial output.

Read the rendered stamp when judging currency: `Pub: <date> Rev.<base> /
<source>` carries one revision per provenance (CLI build, source manifest),
renders `—` when a source has no Git revision, and appends `· DRAFT` when a
revision is dirty or provenance is unknown. Two renders of the same project
can differ only in their stamps and random widget ids; compare outputs with
those normalized before claiming a content difference.

Derive QA from the requested product and the master it actually includes:
required chapters/blocks, language, current tables/metrics/IDs, links, resources
and navigation. Inspect the rendered view when layout is part of acceptance.
Scientific target or input changes can invalidate a derived artifact even if
its record IDs and file paths are unchanged; do not rerender unrelated products
without a demonstrated dependency. Exit zero and `index.html` alone do not
accept content.

Keep a launched long render identified by its process/session and log, with a
result per artifact. NGR supplies neither a tmux mode nor a universal timeout.
Do not terminate or replay based on elapsed time alone. A batch containing
out-of-scope attempts retains those failures separately from its valid subset;
changing the denominator does not erase an orchestration error.

Publish only the outputs whose required generation and QA passed. If the user
requested publication of an already verified output, do not add a render by
habit. Continue with [deploy](deploy.md) only for the requested external effect.
