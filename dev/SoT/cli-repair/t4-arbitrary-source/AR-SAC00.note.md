# T4 — Hidratar desde una ubicación arbitraria (R1) en copia convertida de AR-SAC00

2026-09-18, `/tmp/ngr-real/T1-AR-SAC00` (copia liviana, borrada al terminar).
`ngr` = `/usr/local/bin/ngr` (reinstalación 14:38).

1. `cp -Rc /Users/averrik/Cloud/github/reports/sha /tmp/ngr-real/sha-copy`.
2. `ngr pull --from /tmp/ngr-real/sha-copy/manifest.json --force scripts` →
   `[pull] source sha now at /private/tmp/ngr-real/sha-copy/manifest.json (was /Users/averrik/Cloud/github/reports/sha/manifest.json)`;
   `[pull] complete: 80 resource contributions`; `ngr status --check` → **exit 0**.
3. `rm -rf /tmp/ngr-real/sha-copy`; `ngr status` → **exit 1** con
   `ngr: Source sha is registered at /private/tmp/ngr-real/sha-copy/manifest.json, which does not exist here; use --from its source manifest`
   (nombra la fuente y pide `--from`).
4. `ngr pull --from /Users/averrik/Cloud/github/reports/sha/manifest.json --force scripts` →
   `[pull] source sha now at /Users/averrik/Cloud/github/reports/sha/manifest.json (was /private/tmp/ngr-real/sha-copy/manifest.json)`;
   `[pull] complete: 80 resource contributions`; `ngr status --check` → **exit 0**.

La identidad de la fuente es su `id`: el `--from` explícito redirige la
asociación informándolo, y la ruta inexistente produce un error nombrado.
