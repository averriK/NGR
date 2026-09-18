# T9 — Suites del repo con la instalación nueva

2026-09-18 ~15:40 -03. HEAD `38a7faa`. `ngr` instalado 14:38 (build
`backup-before-typewriter-height-167-g65795cc`). PATH con `/usr/local/bin`
primero; `NGR_TEST_BIN=/usr/local/bin/ngr`; `NGR_TEST_ROOT=/tmp/ngr-tests`;
`NGR_REFERENCE_BIN=/usr/local/bin/qrt`;
`NGR_REFERENCE_LIBRARY=$HOME/Library/R/arm64/4.6/library`.

| Suite | Resultado |
| --- | --- |
| `bash install/cli/test-installers.sh` | 3 PASS (testManager fixture, testManager --native, testWrapper), exit 0 |
| `python3 -B -m unittest discover -s cli/tests` | 31 pruebas, OK, 3 SKIP, 127.6 s |
| `Rscript --vanilla -e 'devtools::test("lib")'` | FAIL 0, WARN 0, SKIP 0, PASS 407, 6.5 s |
