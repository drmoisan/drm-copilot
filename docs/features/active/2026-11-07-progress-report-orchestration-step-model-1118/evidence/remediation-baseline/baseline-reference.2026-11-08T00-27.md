# Baseline Reference (remediation cycle 2, issue #1118)

Timestamp: 2026-11-08T00-27
Command: none - reference only
EXIT_CODE: 0
Output Summary:
- No test run was made for this step. The cycle compares its final gates with these Phase 0 baseline artifacts (the lexicographically greatest match of each name under `evidence/baseline/`):
  - `evidence/baseline/pester-parallel-baseline.2026-11-07T22-04.md`
  - `evidence/baseline/pytest-parallel-baseline.2026-11-07T22-09.md`
  - `evidence/baseline/format-baseline.2026-11-07T21-48.md`
  - `evidence/baseline/pssa-baseline.2026-11-07T21-48.md`
- Pester (one `Invoke-PoshQCParallelTest` run): 15994 tests, 15984 passed, 0 failed, 0 errors, 10 skipped; repo-wide line coverage 24578 covered, 1540 missed, 94.1%.
- Baseline line coverage of the two changed files with a pre-change run:
  - `Get-EpicProgressReport.Render.ps1`: 102 covered, 0 missed, 100%.
  - `Get-EpicProgressReport.Metrics.ps1`: 52 covered, 0 missed, 100%.
- pytest (one `pytest -n auto` run): 16213 passed, 6 skipped, 0 failed, 0 errors; repo-wide lines 32456 of 33464 (96.99%), branches 11827 of 12560 (94.16%).
- Format baseline: 0 `Formatted: ` lines, 11 `Already formatted: ` lines. PSScriptAnalyzer baseline: 0 findings over 11 files.
- `Get-EpicProgressReport.Stages.ps1` and `Get-EpicProgressReport.Gather.ps1` are new on the branch and have no pre-change run; they are judged against the 85% line threshold.
- Cycle 1 figures for reference (from `evidence/qa-gates/pester-parallel-final.2026-11-07T23-53.md`, the lexicographically greatest match): Render 149/149 (100%), Metrics 65/65 (100%), Stages 60/60 (100%), Gather 141/142 (99.3%); repo-wide 25135 covered, 1540 missed, 94.23%; 16092 tests, 0 failed.
