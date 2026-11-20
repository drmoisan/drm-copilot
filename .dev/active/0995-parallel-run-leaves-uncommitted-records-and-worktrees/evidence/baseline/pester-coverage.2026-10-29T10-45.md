# Baseline Pester with Coverage

Timestamp: 2026-10-29T10-45
Task: [P0-T5]
Command: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <repo root> -ScanFolders tests/scripts (PowerShell 7 launched by `sh SCRATCH/issue-995-pester-full.sh`; results read by `SCRATCH/issue-995-read-results.ps1`)
EXIT_CODE: 0
Output Summary: artifacts/pester/pester-junit.xml reports 11861 test cases: 11851 passed, 0 failed, 10 skipped. artifacts/pester/powershell-coverage.xml reports total line coverage 92.87% (18233 covered, 1399 missed). Per-file line coverage for the five existing production files is listed below. No pre-existing failing test.

Counts (from `artifacts/pester/pester-junit.xml`):

- Passed: 11851
- Failed: 0
- Skipped: 10

Per-file line coverage (from `artifacts/pester/powershell-coverage.xml`):

| File | Covered | Missed | Line coverage |
| --- | --- | --- | --- |
| .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 149 | 0 | 100.00% |
| .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1 | 100 | 8 | 92.59% |
| .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 102 | 8 | 92.73% |
| .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 110 | 5 | 95.65% |
| .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 50 | 1 | 98.04% |

Pre-existing failing tests: none.
