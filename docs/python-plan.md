# NGR (Python) development plan

This document describes how the **NGR Python** library fits into this
repository, which primarily contains the **NGR R** package (CRAN), and outlines
how both libraries will be maintained side by side.

## Goals

- Keep **NGR in R** as the primary package, without breaking the CRAN release
  workflow.
- Provide a **Python library `ngr` on PyPI**, installable via `pip install ngr`.
- Gradually replicate the **same public API** (function names and signatures)
  between R and Python where it is reasonable to do so.
- Enable R and Python developers to work in the same repository with clear
  workflows.

## Current state

- Existing R package with exports defined in `NAMESPACE` (e.g. `buildPlot`,
  `buildTable`, `showCode`, etc.). The R package lives under `R/` in this
  repository.
- Python subproject created under `python/` with:
  - `python/pyproject.toml` → the `ngr` project (initial version `0.0.1`).
  - `python/src/ngr/__init__.py` → initial Python API, with **stubs** for
    `buildPlot()` and `buildTable()` that mirror the R signatures.
  - `python/tests/` → space for tests of the Python API.
- `.Rbuildignore` (under `R/`) updated to ignore `python/` and common Python
  artifacts (`dist/`, `build/`, `venv/`, etc.), avoiding interference with
  `R CMD build` and CRAN.
- Name **`ngr`** already reserved on PyPI via an initial release (`0.0.1`).

## Repository structure

```text
NGR/
  R/                       # R package root (DESCRIPTION, NAMESPACE, R/, man/, inst/, ...)
  python/                  # Python subproject
    pyproject.toml
    README.md
    src/
      ngr/
        __init__.py
    tests/
  docs/
    python-plan.md         # this document
    api-parity.md
    ...
```

## Plan phases

### Phase 1 — Infrastructure (COMPLETED)

- [x] Create `python/` subfolder with an independent Python project.
- [x] Define standard packaging using `pyproject.toml` (PEP 621) and
      `setuptools`.
- [x] Ensure `R CMD build` ignores `python/` via `.Rbuildignore` (under `R/`).
- [x] Publish a minimal `0.0.1` version to PyPI to reserve the `ngr` name.

### Phase 2 — API design and R ↔ Python mapping (CURRENT)

1. **R API inventory**
   - Use the list of exported functions in `NAMESPACE`, e.g.:
     - `buildIndexTypewriter`, `buildPlot`, `buildPlot.Bar`, `buildPlot.Hist2D`,
       `buildPlot.Hist3D`, `buildPlot.Histogram`, `buildPlot.Model`,
       `buildTable`, `buildYAML`, `export`, `rotateTypewriter`, `showASCII`,
       `showCode`, `showGithubREADME`, `showHTML`, `showMarkdownRendered`,
       `showPDF`, `showTypewriter`.
2. **Python naming convention**
   - Keep the **same function names** for users where possible (`buildPlot`,
     `buildTable`, `showCode`, etc.).
   - Define how R-specific structures (e.g. `data.table`, formulas, lists) map
     to Python types (`pandas.DataFrame`, dicts, etc.).
3. **Internal Python organisation** (without changing the public API):
   - Example approach:
     - public functions live in `ngr.__init__` with the same names as in R;
     - internal modules (`ngr._plots`, `ngr._tables`, etc.) are used only for
       implementation structure.
4. **API mapping document R → Python** (this repo uses `docs/api-parity.md`):
   - For each exported R function, record:
     - R name;
     - Python name (ideally identical);
     - status: _not-implemented_, _partial_, _complete_;
     - notes about type or behaviour differences.

### Phase 3 — Implement a core Python subset

1. Prioritise the most frequently used and easiest-to-port helpers, e.g.:
   - `showCode`, `showHTML`, `showPDF`, `showMarkdownRendered`,
     `showGithubREADME`.
2. Implement these functions in Python using standard libraries:
   - file/path handling (`pathlib`, `os`),
   - appropriate rendering/visualisation for notebooks or terminal, etc.
3. Add tests in `python/tests/` that exercise the same usage patterns as the
   R examples.
4. Release `0.1.x` versions on PyPI as soon as the subset is practically
   useful.

### Phase 4 — Grow coverage for plots and tables

1. Design the mapping of `buildPlot*` to the Python plotting stack (e.g.
   `matplotlib`/`plotly`) and `buildTable` to `pandas` + table-formatting
   libraries.
2. Implement progressively:
   - `buildPlot` plus variants (`.Bar`, `.Histogram`, `.Hist2D`, `.Hist3D`,
     `.Model`),
   - `buildTable`.
3. Where feasible, add tests that compare visual/structural characteristics of
   R and Python outputs.
4. Add parallel examples in `docs/`: one snippet in R and the equivalent in
   Python.

### Phase 5 — Synchronisation and coordinated releases

1. Keep NGR R and NGR Python versions reasonably aligned (e.g. `0.4.x` in both
   when major capabilities are added).
2. For any change to the exported R API (`NAMESPACE`):
   - open an issue/task describing the impact on Python;
   - update the API parity document;
   - plan the corresponding Python implementation work.
3. Configure CI for both sides:
   - R: `R CMD check` for the package;
   - Python: `pytest`, linters (`ruff`, `mypy` where applicable) and build.
4. Keep a shared `CHANGELOG` or cross-reference that tracks API parity for each
   release.

## Next immediate steps

1. Use `docs/api-parity.md` to track the state of each exported R function in
   the Python implementation.
2. Decide the minimal subset of functions required for the first "useful"
   `ngr` release (beyond the 0.0.1 name-reservation release).
3. Implement and test that subset under `python/src/ngr/` and
   `python/tests/`.
4. Publish a new version on PyPI (e.g. `0.1.0`) once the initial subset is
   stable and documented.
