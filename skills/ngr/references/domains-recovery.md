# Domains and recovery

Read `ngr deploy --help` and resolve the project root, exact alias and
`.netlify/sites.env` UUID before these operations. Registration and deploy do
not include a domain or HTTPS change.

## Bind a domain

```text
ngr deploy domain <alias> <domain> [--https] [--rebind] [--dry-run]
ngr deploy domain --manifest <file> [--https] [--dry-run] [--only <aliases>] [--except <aliases>]
```

Resolve the hostname without a scheme/path, provider site, HTTPS intent and
whether a recovery rebind is actually requested. Manifest mode takes domains
from its declarations, which must be unique across the complete manifest, and
every selected artifact must declare one; do not fill a null domain by
inventing a naming convention. `--rebind` exists only in direct mode and
clears before rebinding; it is not a diagnostic or routine retry flag.

Dry-run plans local commands without proving the provider's current domain or
DNS. Real manifest mode checks current-domain conflicts before mutation, then
changes sites sequentially. A later failure does not revert earlier bindings.
Preserve each affected UUID/domain and reconcile unknown attempts before
continuing only the authorized remainder.

For an end-to-end serving claim, distinguish these observations. A request
limited to binding can close with that observed effect while naming any
unverified serving layers; it need not expand into TLS or content work.

| Observation | What it establishes |
| --- | --- |
| Provider site/domain state | The intended hostname is associated with the intended UUID |
| Authoritative DNS | The hostname resolves through the intended DNS records |
| TLS/HTTPS | The requested hostname has usable HTTPS and a valid certificate |
| Served content | The intended current artifact is actually served at that URL |

NGR can return success with DNS warnings, including missing `dig`, unmanaged
DNS or unreadable nameservers. Preserve the warning and name the unverified
layer; success from binding does not prove DNS, TLS or content. `--https` may
provision TLS/force SSL; domain and TLS authority must already cover that
effect. Diagnose a missing prerequisite without adding HTTPS, rebind or a
provider administration workaround to the request.

## Remove a local binding

```text
ngr deploy unbind <alias>
```

Unbind removes the exact alias line from the local registry. It does not
delete the remote site or clear its domain. Read the mapping and resolve the
requested local mutation first; afterward verify that alias is absent and
every other registry entry is preserved. For stale-site recovery, this is only
one explicitly scoped step: [site registration](deploy.md#register-or-create-a-site)
and any creation, deploy or domain effects retain their own resolved scope.
