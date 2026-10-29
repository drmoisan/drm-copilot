# Final Coverage-Writing Pester Run (remediation cycle 1, PA-B1)

Timestamp: 2026-10-28T14-26
Command: sh SCRATCH/issue-989-pester-full.sh (PowerShell 7, one fresh process: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts, coverage enabled through scripts/powershell/PoshQC/settings/pester.runsettings.psd1); figures read by SCRATCH/issue-989-report.ps1 from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0

## Ordering

- artifacts/pester/powershell-coverage.xml and artifacts/pester/pester-junit.xml were written after pester-guards.2026-10-28T14-14.md (the Phase 1 evidence file); no coverage-enabled Pester invocation ran after this run.

## Totals (artifacts/pester/pester-junit.xml)

- Total: 11448
- Passed: 11438
- Failed: 0
- Skipped: 10

## LINE coverage (artifacts/pester/powershell-coverage.xml)

| Scope | Covered | Missed | Line coverage |
|---|---|---|---|
| Report level | 17787 | 1398 | 92.71% |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 113 | 3 | 97.41% |
| `.claude/hooks/enforce-pr-author-skill.current-branch.ps1` | 21 | 1 | 95.45% |
| `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | 77 | 0 | 100.00% |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 81 | 3 | 96.43% |

Output Summary: 11438 passed, 0 failed, 10 skipped. Report-level LINE coverage 92.71% (17787 of 19185 lines); the four changed hook files are at 97.41%, 95.45%, 100.00%, and 96.43%. The report no longer shows 0 covered lines.

Threshold Result: PASS
