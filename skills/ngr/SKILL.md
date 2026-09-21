---
name: ngr
description: "Operate the installed NGR CLI to pull and reconcile project resources from named sources, render Quarto books, documents and presentations, and register, deploy or configure Netlify sites directly or through a manifest. Use for NGR consumer workflows. Do not use to maintain NGR source, author scientific content, or perform unrelated Netlify administration."
---

# NGR

Use the installed `ngr` public CLI. It owns project resources, local render
and its Netlify operations; a producer checkout, internal Pandoc command or
helper is not a consumer entry point. NGR does not calculate missing
scientific inputs, translate content, or administer Netlify passwords.

Resolve the intended project directory and `command -v ngr`, then read
`ngr --version`, `ngr --help` and the relevant operation help. The interface represented here
has no `init`, `push`, `clean` or standalone `validate`: the first
`ngr pull --from ngr` seeds a project, and `ngr --version` reports the
package, library, CLI and build lines. If the installed interface differs,
resolve the affected public contract before an effect; do not silently
switch to a source checkout or install a replacement.

## Choose the operation

Read only the reference needed by the request:

| Request | Reference | Public help |
| --- | --- | --- |
| Seed, update, compare or restore resources; author/review a manifest | [Resources and manifest](references/resources-manifest.md) | `ngr pull --help`, `ngr status --help` |
| Run source-declared project checks | [Resources and manifest](references/resources-manifest.md#doctor) | `ngr doctor --help` |
| Render one source or a manifest selection | [Render](references/render.md) | `ngr render --help` |
| Register/create sites or upload existing outputs | [Deploy and site registration](references/deploy.md) | `ngr deploy --help` |
| Bind domains, HTTPS, rebind or remove a local alias | [Domains and recovery](references/domains-recovery.md) | `ngr deploy --help` |

For a heavy render that must continue after the agent disconnects, or when
resuming one, also read [Detached jobs](references/long-jobs.md).

`ngr pull --from ngr` copies installed base resources. `ngr deploy init`
registers a provider site. Render generates local artifacts; deploy uploads
existing artifacts without building them. Use each operation only when the
request includes its effect. An authorized combined request can proceed
through its verified phases without repeated confirmation.

## Resolve identities before effects

With CLI 0.3.0-dev or later, select the project with `--root DIR`. DIR must
exist; a relative DIR resolves from the caller's working directory. Supply
the option once, before any `--` separator; it may appear before or after
the command and also accepts `--root=DIR`. Without it, or on an older CLI
that does not offer it, run from the selected project directory. There is
no Git worktree resolution.

Relative manifests, sources, outputs and `.netlify/sites.env` use that project.
Existing path restrictions still apply: Quarto masters must remain
project-relative, and selecting a root does not permit arbitrary output or
resource destinations. Bind this context before inspecting or executing a
plan; the caller's nested shell directory must not redirect it.

Resources come from named sources recorded in the project `manifest.json`:
the installed base `ngr` plus any scientific source. The first pull names its
sources with `--from`; a later `--from` whose `id` is already associated
re-points it, with a `source <id> now at ...` message. Seeds stay local:
a customized seed compares as `project-seed` and is never replaced.

For direct render, resolve the source and explicit profile. For manifest work,
read the selected manifest and exact alias subset, using
[its identity rules](references/resources-manifest.md#manifest-identities).
Do not derive publication intent from a directory listing, existing outputs,
provider sites or the resource seeds. Check the actual master/includes and
their required data before attributing a product to the requested scope.

Preserve the distinctions among source, profile, local output, alias, site name,
provider UUID, domain and generation. Choices already fixed by the request or
project contract need no question. Resolve only a still-missing material input,
replacement scope or provider destination before its effect.

## Finish the requested phase

Use only the native dry-run forms shown by the operation help: `ngr pull
--dry-run`, manifest render plans, and direct or manifest domain/deploy
plans. They validate local plans with operation-specific limits; they neither
authorize nor prove their real counterparts. Do not add a dry-run flag to
another direct form or emulate it with a wrapper.

Before execution, identify the existing outputs that may be replaced and the
inputs/generation being consumed. Afterward retain the exact command, CWD and selected root,
selection, return status and final output or provider identity needed to
distinguish this attempt. A file's presence or an internal `Output created`
line cannot prove the final NGR artifact is current or fit for publication.

Rendered pages carry a `Pub: <date> Rev.<base> / <source>` stamp with a
`· DRAFT` marker when a revision is dirty, a source has no Git revision or
provenance is unknown. Read the stamp when judging currency; a missing Git
revision renders as `—`, never as an invented hash.

Batches are sequential, not transactions. On failure distinguish completed,
failed, unattempted and unknown aliases. Reconcile an unknown attempt against
its output/provider identity before proposing a retry; preserve verified
successes and continue only the still-authorized unfinished scope. Missing
data, stale UUIDs or partial outputs do not authorize `--force`, `--create`,
production, domain changes, dropping aliases or changing scientific scope.
