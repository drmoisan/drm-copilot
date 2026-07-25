# Coverage Delta and Threshold Verification (Coverage Evidence Contract, issue #409)

Timestamp: 2026-07-25T11-40

Command:
1. PowerShell baseline / post-change percentages sourced from the recorded runs: [P0-T4] (`baseline-poshqc-test.2026-07-25T10-46.md`) and [P4-T3] (`final-poshqc-test.2026-07-25T11-26.md`).
2. Python baseline / post-change percentages sourced from [P0-T9] (`baseline-python-pytest.2026-07-25T10-58.md`) and [P4-T9] (`final-python-pytest.2026-07-25T11-38.md`), each computed via `poetry run coverage json --data-file=artifacts/.coverage`.
3. Changed-line extraction:
   `pwsh -NoLogo -NoProfile -Command "$post = [xml](Get-Content -Raw docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/powershell-coverage.post-change.xml); ... $sf.line | Where-Object { [int]$_.nr -ge 346 -and [int]$_.nr -le 366 } ..."`

EXIT_CODE: 0

## Per-language coverage

| Language | Metric | Baseline | Post-change | Threshold | Result |
|---|---|---|---|---|---|
| PowerShell | Line coverage | 90.19% | 90.22% | >= 85% | PASS (improved) |
| PowerShell | Command/instruction coverage | 89.64% | 89.68% | (no threshold) | improved |
| PowerShell | Branch coverage | not measurable | not measurable | >= 75% | N/A — documented limitation |
| Python | Line (statement) coverage | 90.99% | 90.99% | >= 85% | PASS (unchanged) |
| Python | Branch coverage | 81.83% | 81.83% | >= 75% | PASS (unchanged) |

PowerShell branch coverage is not separately measurable in this toolchain: Pester 5.6.1's JaCoCo output emits `INSTRUCTION`, `LINE`, `METHOD`, and `CLASS` counters only, with no `BRANCH` counter. This is the documented limitation recorded in `spec.md` Test Strategy and is not a gap introduced by this change.

## Changed-line coverage — `scripts/powershell/PoshQC/PoshQC.Testing.psm1`

Extracted from `evidence/qa-gates/powershell-coverage.post-change.xml` (the [P4-T4] fixed-module run). The change is a single hunk at `@@ -346 +346,21 @@`, so the changed region is lines 346-366.

Instrumented lines in the changed region: **8 of 8 covered, 0 missed — 100.00% changed-line coverage.**

| Line | Covered instructions (`ci`) | Missed instructions (`mi`) | Statement |
|---|---|---|---|
| 352 | 4 | 0 | `$survivingCoveragePaths = @($resolvedCoveragePaths \| Where-Object { & $TestPathExists $_ })` |
| 353 | 4 | 0 | `foreach ($prunedPath in @($resolvedCoveragePaths \| Where-Object { $survivingCoveragePaths -notcontains $_ }))` |
| 355 | 1 | 0 | `& $Logger "Pruned nonexistent code coverage path: $prunedPath"` |
| 358 | 1 | 0 | `if ($survivingCoveragePaths.Count -gt 0)` |
| 359 | 1 | 0 | `$config.CodeCoverage.Path = $survivingCoveragePaths` |
| 363 | 1 | 0 | `$config.CodeCoverage.Enabled = $false` |
| 364 | 1 | 0 | `$coverageEnabled = $false` |
| 365 | 1 | 0 | `& $Logger "Code coverage disabled for this invocation: ..."` |

File-level totals for the changed module: LINE covered 195 -> 202, missed 0 -> 0 (100.00% both before and after). INSTRUCTION covered 263 -> 276, missed 4 -> 4 (98.50% -> 98.57%). The missed count did not increase.

Changed-line coverage for Python: **not applicable — this change modifies no Python source file.** The two production files and the one test file are all PowerShell. The Python surface participates only as the unmodified mirror-parity contract `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.

## Threshold checks

- Line coverage >= 85%: PowerShell 90.22% PASS; Python 90.99% PASS.
- Branch coverage >= 75%: Python 81.83% PASS; PowerShell N/A (not separately measurable — documented limitation).
- No regression on changed lines: PASS. Every instrumented line added by this change is covered (8/8), the changed module's missed-line count remains 0, and its missed-instruction count remains 4 (unchanged from baseline, pre-existing).
- No regression overall: PASS. PowerShell line coverage rose 90.19% -> 90.22%; Python line and branch coverage are identical to baseline.

All required numeric values are present. No value is a placeholder, and no threshold check failed, so this task's outcome is PASS rather than remediation-required.
