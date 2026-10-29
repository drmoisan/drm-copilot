# Full Pester Baseline (issue #997)

Timestamp: 2026-10-29T16-24
Command: sh SCRATCH/issue-997-pester-full.sh (PowerShell 7 imports scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCTest -ScanFolders tests/scripts in one process with coverage; then SCRATCH/issue-997-read-results.ps1 reads artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary:
- JUnit (artifacts/pester/pester-junit.xml): tests=12104, failures=0, errors=0, skipped/disabled=10, passed=12094.
- Pre-existing failing tests: none.
- Line coverage, repository total: 18349 covered, 1397 missed, 92.93 percent.
- Line coverage `.claude/hooks/enforce-epic-merge-gate.ps1`: 129 covered, 0 missed, 100.00 percent.
- Line coverage `.claude/hooks/hook-docs-only-diff.ps1`: 124 covered, 3 missed, 97.64 percent.
- `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1`: not present (file does not exist before Phase 2).
- Pester console summary: Tests Passed: 12094, Failed: 0, Skipped: 10; Covered 92.2 percent of 29,042 analyzed commands in 225 files.
