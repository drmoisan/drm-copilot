# QA Gate: Coverage-Enabled Pester Run (Issue #973, Phase 4 pass 1)

Timestamp: 2026-10-17T13-39
Command: sh SCRATCH/issue-973-run.sh issue-973-test.ps1 -Root <worktree> -ScanList tests/scripts/ci,tests/scripts/workflows (PowerShell 7; Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -ScanFolders tests/scripts/ci,tests/scripts/workflows), then sh SCRATCH/issue-973-run.sh issue-973-report.ps1 (reads artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0

Counts from `artifacts/pester/pester-junit.xml` (written 2026-10-17T13-39): 238 test cases in 9 suites, 238 passed, 0 failed, 0 skipped; no container errors. (Baseline: 180 in 8 suites; the new suite and the new rows add 58.)

Per-file line coverage from `artifacts/pester/powershell-coverage.xml` (same run; population from `config/poshqc-coverage.json`, 215 files):

| File | Covered lines | Executable lines | Line coverage | Threshold |
|---|---|---|---|---|
| `scripts/ci/CiChangeScope.psm1` | 131 | 140 | 93.57% | >= 85% (met) |
| `scripts/ci/Invoke-CiChangeScope.ps1` | 103 | 113 | 91.15% | >= 85% (met) |

A copy of this coverage report is kept at `SCRATCH/issue-973-post-coverage.xml` for the [P4-T4] delta.

Output Summary: 238 passed, 0 failed. Line coverage `scripts/ci/CiChangeScope.psm1` 93.57%, `scripts/ci/Invoke-CiChangeScope.ps1` 91.15%; both at or above 85%.
