# PowerShell Static Baseline (remediation cycle 1, P0-T3)

Timestamp: 2026-11-14T12-56
Command: sh SCRATCH/issue-1158-ps-gate-static.sh SCRATCH/issue-1158-r1-p0t3-static.txt (Invoke-PoshQCFormat -Root . with a no-op -WriteFile and a capturing -Logger; Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 over every file of Get-PoshQCFileList -Root ., which includes scripts/powershell/PoshQC/PoshQC.Parallel.psm1; Invoke-PoshQCLeakScan -Root .; git status --porcelain before and after)
EXIT_CODE: 0
Output Summary: Format check: 0 Formatted lines, 1741 Already formatted lines (scripts/powershell/PoshQC/PoshQC.Parallel.psm1 among them). PSScriptAnalyzer: 0 findings over 1741 files. Leak scan: 831 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures (exit 0). git status --porcelain was identical before and after (TREE unchanged).

| Step | Command | EXIT_CODE | Findings |
|---|---|---|---|
| format (check form) | Invoke-PoshQCFormat -Root . (no write) | 0 | 0 |
| lint | Invoke-ScriptAnalyzer with pssa.settings.psd1, 1741 files | 0 | 0 |
| leak scan | Invoke-PoshQCLeakScan -Root . | 0 | 0 failures |

Type check: not applicable (PowerShell).

## Reused Phase 0 Baseline Test Artifacts (comparison base for P3-T5)

| Artifact | Fields found |
|---|---|
| evidence/baseline/pester-suite.2026-11-10T04-17.md | Timestamp, Command, EXIT_CODE 0, Output Summary with 21311 tests, 0 failures, 0 errors, 10 skipped, repo-wide line coverage 95.80% (37558 covered, 1645 missed), and a per-file table including scripts/powershell/PoshQC/PoshQC.Parallel.psm1 at 97.37% (148 covered, 4 missed) |
| evidence/baseline/pytest-suite.2026-11-10T04-23.md | Timestamp, Command, EXIT_CODE 0, Output Summary with 16598 passed, 6 skipped, 0 failed, and line 72.91% and branch 65.44% over the seven modules from the JSON report |
| evidence/baseline/jest-extension-suite.2026-11-10T04-26.md | Timestamp, Command, EXIT_CODE 0, Output Summary with 340 suites and 5476 tests passed, 0 failed; coverage N/A (no TypeScript production change) |
