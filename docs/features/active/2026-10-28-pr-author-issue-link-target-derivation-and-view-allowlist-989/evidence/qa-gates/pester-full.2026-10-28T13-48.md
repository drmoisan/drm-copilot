# Full Single-Process Pester Run (P6-T6, loop pass 1)

Timestamp: 2026-10-28T13-48
Command: sh SCRATCH/issue-989-full.sh (PowerShell 7, one fresh process: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts, coverage enabled; then SCRATCH/issue-989-summary.ps1 reads artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0

## Totals (artifacts/pester/pester-junit.xml)

- Test files: 417
- Total: 11448
- Passed: 11438
- Failed: 0
- Skipped: 10 (pre-existing skip conditions in suites outside this change; no new or edited suite carries a skip)

Pester run duration: 714.87 s. Aggregate command coverage over the 216-file population: 91.95%.

## Line coverage of the CHF in the full run (artifacts/pester/powershell-coverage.xml)

| File | Line coverage |
|---|---|
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 97.41% (113/116) |
| `.claude/hooks/enforce-pr-author-skill.current-branch.ps1` | 95.45% (21/22) |
| `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | 100.00% (77/77) |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 96.43% (81/84) |

Output Summary: 11438 passed, 0 failed, 10 skipped across 417 files in one process; zero failures, so no baseline comparison is required.
