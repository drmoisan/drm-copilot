# Baseline: Coverage-Enabled Pester Run (Issue #973)

Timestamp: 2026-10-17T13-08
Command: sh SCRATCH/issue-973-run.sh issue-973-test.ps1 -Root <worktree> -ScanList tests/scripts/ci,tests/scripts/workflows (PowerShell 7; Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -ScanFolders tests/scripts/ci,tests/scripts/workflows), then sh SCRATCH/issue-973-run.sh issue-973-report.ps1 (reads artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0

Counts from `artifacts/pester/pester-junit.xml` (written 2026-10-17T13-08): 180 test cases, 180 passed, 0 failed, 0 skipped; 8 suites, none with container errors.

Per-file line coverage from `artifacts/pester/powershell-coverage.xml` (written 2026-10-17T13-08, read before any later run; coverage population source `config/poshqc-coverage.json`, 215 files):

| File | Covered lines | Executable lines | Line coverage |
|---|---|---|---|
| `scripts/ci/CiChangeScope.psm1` | 121 | 130 | 93.08% |
| `scripts/ci/Invoke-CiChangeScope.ps1` | 78 | 88 | 88.64% |

A copy of the baseline coverage report is kept at `SCRATCH/issue-973-baseline-coverage.xml` for the [P4-T4] delta.

Output Summary: 180 passed, 0 failed. Baseline line coverage: `scripts/ci/CiChangeScope.psm1` 93.08% (121/130); `scripts/ci/Invoke-CiChangeScope.ps1` 88.64% (78/88).
