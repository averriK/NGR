# R9 baseline — manifest coexistence guards

Date: 2026-09-18, ~21:34 -03. Repo HEAD: f74a173 (Admit R9).
CLI under test: /usr/local/bin/ngr (NGR 0.4.0 installed from 65795cc; lib/ unchanged since).

## Failing behaviour (pre-change, expected)

Scratch project `/tmp/ngr-r9-base` seeded with `ngr pull --from ngr`, then
`cp manifest.json qrt.manifest.json` (both files present, identical md5
8fa9f78a9110030057663feab8595ae3):

```
$ ngr status
ngr: Migrate qrt.manifest.json to manifest.json and update its source associations and consumers before continuing; do not keep both files.
exit=1

$ ngr render _master/slides.qmd --profile revealjs
ngr: Migrate qrt.manifest.json to manifest.json and update its consumers before rendering; do not keep both files.
exit=1
```

Guards under removal (R9, admitted in PLAN.md @ f74a173):

- `lib/R/resources.R:116-118` — `.readResourceProject` aborts pull/status/doctor
  when `qrt.manifest.json` exists next to the project.
- `lib/R/quartoRender.R:42-44` — `quartoRender` aborts when `manifest == "manifest.json"`
  (the default) and `qrt.manifest.json` exists.

Rationale (owner, 2026-09-18): qrt/psha and ngr must coexist in the same tree
during SoT verification; the old file is retired in a later per-project commit,
not by `mv`. ngr keeps reading/writing only `manifest.json` and treats
`qrt.manifest.json` as foreign state (already non-claimable: resources.R:90).

Frozen copies: `resources.R.baseline`, `quartoRender.R.baseline` (from HEAD).
