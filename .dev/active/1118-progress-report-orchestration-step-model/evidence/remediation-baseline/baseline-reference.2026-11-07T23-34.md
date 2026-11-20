# Baseline Reference (remediation cycle 1, issue #1118)

Timestamp: 2026-11-07T23-34
Command: none - reference only
EXIT_CODE: 0
Output Summary:
- No test run was made for this step. The cycle compares its final gates with these Phase 0 baseline artifacts (the lexicographically greatest match of each name under `evidence/baseline/`):
  - `evidence/baseline/pester-parallel-baseline.2026-11-07T22-04.md`
  - `evidence/baseline/pytest-parallel-baseline.2026-11-07T22-09.md`
  - `evidence/baseline/format-baseline.2026-11-07T21-48.md`
  - `evidence/baseline/pssa-baseline.2026-11-07T21-48.md`
- Pester (one `Invoke-PoshQCParallelTest` run): 15994 tests, 15984 passed, 0 failed, 0 errors, 10 skipped; repo-wide line coverage 24578 covered, 1540 missed, 94.1%.
- `Get-EpicProgressReport.Render.ps1` line coverage at baseline: 102 covered, 0 missed, 100%.
- pytest (one `pytest -n auto` run): 16213 passed, 6 skipped, 0 failed, 0 errors; repo-wide lines 32456 of 33464 (96.99%), branches 11827 of 12560 (94.16%).
- Format baseline: 0 `Formatted: ` lines, 11 `Already formatted: ` lines. PSScriptAnalyzer baseline: 0 findings over 11 files.
- `Get-EpicProgressReport.Stages.ps1`, `Get-EpicProgressReport.Steps.ps1`, and `Get-EpicProgressReport.Gather.ps1` are new on the branch and have no pre-change run; they are judged against the 85% line threshold.
