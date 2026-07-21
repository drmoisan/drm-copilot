# QA Gate — Python Toolchain Post-Removal (P3-T6) (Issue #393)

Timestamp: 2026-07-21T18-45

Full four-stage Python loop, single clean pass (no stage rewrote files or failed, so no
restart was required):

## Stage 1 — Format
Command: poetry run black .
EXIT_CODE: 0
Output Summary: "329 files left unchanged" (was 330 at baseline; reflects the deletion of
scripts/dev_tools/shell_qc.py). No files reformatted.

## Stage 2 — Lint
Command: poetry run ruff check .
EXIT_CODE: 0
Output Summary: "All checks passed!" 0 findings.

## Stage 3 — Type Check
Command: poetry run pyright
EXIT_CODE: 0
Output Summary: 0 errors, 0 warnings, 0 informations.

## Stage 4 — Test + Coverage
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
- Result: 2069 passed (unchanged; shell_qc.py had no tests, so deletion removed no tests).
- Statements: 12252 total (baseline 12474; -222), 1114 missed (baseline 1336; -222).
  The 222-statement drop is exactly the removed shell_qc.py.
- Branches: 4446 total (baseline 4530; -84).
- Combined TOTAL coverage: 88% (baseline 87%; +1 point).
- Line coverage: (12252-1114)/12252 = 90.9% (baseline 89.3%; improved).
- Branch coverage improved: removing a file whose 84 branches were entirely missed reduces
  both total and missing branches equally, which raises the branch rate; no regression.
- Thresholds met: >= 85% line, >= 75% branch. No regression on changed lines
  (fix_all_branches.py change is covered by the 37-test fix_all suites, P3-T2).

Residual-importer check: `grep -rn "dev_tools.shell_qc|import shell_qc|from scripts.dev_tools.shell_qc"
--include=*.py .` -> no hits. No Python module imports the deleted file.
