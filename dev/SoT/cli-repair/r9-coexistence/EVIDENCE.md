# R9 result — manifest coexistence

Date: 2026-09-18, ~21:40 -03. Base: f74a173 (+ 71eb268 installer fixes by owner).
Change: removed the two «do not keep both files» guards
(`lib/R/resources.R` `.readResourceProject`, `lib/R/quartoRender.R` default-manifest branch).
ngr reads/writes only `manifest.json`; `qrt.manifest.json` stays foreign state,
already non-claimable (`resources.R`, project-owned destination list).

## Oracle

- Baseline (pre-change, see BASELINE.md): `ngr status` and `ngr render` aborted
  with «do not keep both files» (exit 1) in a scratch project holding both files.
- Candidate, same scratch project: `ngr status` exit 0, `ngr doctor` exit 0,
  `ngr render` now reaches the downstream check («Render input not found»);
  `qrt.manifest.json` md5 unchanged (8fa9f78a9110030057663feab8595ae3).
- `devtools::test("lib")`: FAIL 0 | WARN 0 | SKIP 0 | PASS 407.
- cli/tests (critical env: /usr/local/bin first, NGR_REFERENCE_BIN=/usr/local/bin/qrt):
  Ran 31 tests, OK (skipped=3, pre-existing).
- Package reinstalled into the user library
  (`R CMD INSTALL --library=~/Library/R/arm64/4.6/library lib`, no sudo);
  `ngr --version` still reports 0.4.0. /usr/local untouched.

## Tests rewritten as coexistence

- `lib/tests/testthat/test-quartoRender.R`: with `qrt.manifest.json` present
  (alone and next to `manifest.json`) render no longer aborts on the guard and
  leaves every file byte-identical.
- `cli/tests/test_resources.py::testLegacyManifestCoexistsUnchanged`: pull/status/doctor
  succeed with the legacy file present and the legacy file content is unchanged.

## Real-tree verification (copy /tmp/ngr-r9-coop of AR-S2L1W)

Recipe: `cp qrt.manifest.json manifest.json`, deleted the copy's `scaffolds`
block (21 artifacts kept), then
`ngr pull --from ngr --from /Users/averrik/Cloud/github/libraries/reports/sha/manifest.json --force`
→ 1156 resource contributions, exit 0.

Same tree, both tool generations green:

| Command | Result |
| --- | --- |
| `ngr status --check` | exit 0 |
| `ngr doctor` | declared checks passed |
| `ngr render --manifest manifest.json --dry-run` | dry-run ok |
| `ngr deploy --manifest manifest.json --dry-run` | exit 0, prod=FALSE |
| `qrt render --manifest qrt.manifest.json --dry-run` | dry-run ok: 21 render job(s) |
| `psha status` | exit 0; `params.yml` WARNING is pre-existing (identical warning in the untouched real project) |

`qrt.manifest.json` md5 identical before and after (3317b5f0b6d4deb9418952bc457f4123).

Final per-project state remains a single `manifest.json` (R3), reached by a
later per-project commit removing `qrt.manifest.json` — not by `mv`.
Scratch dirs /tmp/ngr-r9-base and /tmp/ngr-r9-coop removed after the run.
