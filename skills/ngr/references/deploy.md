# Deploy and site registration

Read `ngr deploy --help` for all nested forms. Every form resolves paths from
the project root (the command CWD); there is no Git worktree resolution. The
registry is `.netlify/sites.env` under the project root. Check the form's
Netlify requirements and jq for manifest/site/domain operations; do not
install or authenticate a replacement environment as an implicit repair.

## Upload an existing output

```text
ngr deploy <alias> <dir> [--prod]
ngr deploy --manifest <file> [--dry-run] [--prod] [--only <aliases>] [--except <aliases>]
```

Resolve the exact output, alias and `.netlify/sites.env` UUID with the intended
provider context. Verify that the output's generation and requested QA already
passed; uploading does not repair old or incomplete renders. NGR invokes
Netlify with no build, so it does not render, create sites, write the registry
or bind domains during deploy.

The CLI defaults to a draft; `--prod` changes production. Resolve the intended
mode from the request/contract before upload. A request already choosing that
mode and destination authorizes proceeding without another approval ritual.

Direct deploy has no dry-run and does not require `index.html`; verify the
directory against the requested product. Manifest deploy requires a website
directory with `index.html` for each selected deployable entry. Missing optional
outputs skip before alias validation; missing required outputs fail. For
render-only DOCX entries, resolve the intended publication subset rather than
silently excluding them or changing `required`.

A real manifest deploy without `.netlify/sites.env` stops with
`Missing .netlify/sites.env; register aliases first.` Manifest dry-run checks
local paths, website entry points and UUID-shaped registry entries. It does
not query the provider, prove authentication or establish that those sites
still exist. Once uploading begins, jobs run sequentially and a later failure
leaves earlier uploads live.

Capture per alias the provider site UUID, deploy identity, mode, response and
URL needed to verify the effect. A provider `ready` state proves that deploy's
state, not who created an old deploy or that its content passed QA. Check the
served requested artifact when claiming publication. Reconcile a timeout or
unknown last response against that exact identity before resuming only the
authorized uncompleted aliases. Do not replay the successful prefix, widen the
selection or switch to production to recover.

## Register or create a site

```text
ngr deploy init <alias> <site-name> [--create] [--account <slug>]
ngr deploy init --manifest <file> [--dry-run] [--create] [--account <slug>] [--only <aliases>] [--except <aliases>]
```

Resolve alias, provider site name (`siteSlug` in a manifest), intended account
where material, and whether missing-site creation is authorized. An alias,
slug, domain and UUID are different identities; do not guess one from another.
Registration looks up an existing site and writes `alias=UUID` locally.
`--create` additionally permits creation if absent. Neither form renders,
uploads or sets a domain. Direct init has no dry-run.

Site slugs must be unique across the complete manifest, not only the
selection, and every selected artifact must declare a slug. Manifest init
dry-run checks schema, selection and slug uniqueness and prints the plan; it
reads neither the provider nor the registry. It cannot confirm an alias is
unused, a site is absent or the account is authenticated. Use a bounded
public provider read when those facts are needed; an error or timeout from
lookup is not proof of absence.

Real init refuses to retarget an alias already pointing at another UUID. Stop
on that conflict and reconcile the current site/registry identity; do not
remove the alias to make the command pass. If exact stale-binding replacement
is authorized, [unbind](domains-recovery.md#remove-a-local-binding) removes
only that local mapping before the separately authorized registration/create.

After init, verify both the actual provider UUID and the exact local mapping.
A batch can leave earlier sites/mappings complete, or a newly created site
without its final registry write. Preserve that site's UUID and recovery hint
before any retry so creation is not duplicated. A historical UUID returning
Not Found establishes current lookup failure only; it does not establish who
removed it or authorize a new site.
