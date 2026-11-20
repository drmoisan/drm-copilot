# Final full Pester coverage run (cycle 2, [P5-T4])

Timestamp: 2026-10-29T00-08
Command: `Invoke-PoshQCTest -ScanFolders tests/scripts` (self-hosted PoshQC module, coverage enabled, full population) launched from a `sh` script under `SCRATCH` that invokes PowerShell 7.
EXIT_CODE: 0
Output Summary:
- `artifacts/pester/pester-junit.xml`: 11861 tests, 0 failures, 0 errors, 10 skipped (disabled). Baseline was 11816 tests; the 45 added tests are the 44 accessor tests and the gate traversal test.
- Repo-wide line coverage from `artifacts/pester/powershell-coverage.xml`: 92.88% (18234/19632); baseline 92.88% (18232/19630). Not below the baseline, and above 85%.
- `.claude/lib/file-size-policy/FileSizePolicy.psm1`: 100.00% line coverage (105/105); baseline 100.00% (104/104).
- `.codex/hooks/file-size-policy.ps1`: 100.00% line coverage (102/102); baseline 100.00% (101/101); present in the coverage report.
- PowerShell has no branch-coverage gate.
