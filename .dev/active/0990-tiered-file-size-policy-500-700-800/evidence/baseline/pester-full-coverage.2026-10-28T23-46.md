# Baseline full Pester coverage run (cycle 2, unchanged tree)

Timestamp: 2026-10-28T23-46
Command: `Invoke-PoshQCTest -ScanFolders tests/scripts` (self-hosted PoshQC module, coverage enabled) launched from a `sh` script under `SCRATCH` that invokes PowerShell 7.
EXIT_CODE: 0
Output Summary:
- `artifacts/pester/pester-junit.xml`: 11816 tests, 0 failures, 0 errors, 10 skipped (disabled).
- Repo-wide line coverage from `artifacts/pester/powershell-coverage.xml`: 92.88% (18232/19630).
- `.claude/lib/file-size-policy/FileSizePolicy.psm1`: 100.00% line coverage (104/104).
- `.codex/hooks/file-size-policy.ps1`: 100.00% line coverage (101/101); present in the coverage report.
