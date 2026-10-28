# Baseline Pester GSS Run (P0-T4)

Timestamp: 2026-10-28T13-06
Command: sh SCRATCH/issue-989-run.sh SCRATCH/issue-989-pester.ps1 (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders <GSS files>, coverage enabled through pester.runsettings.psd1), then sh SCRATCH/issue-989-sum.sh (reads artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0

GSS file set (P0-T4 scope, `pr-author-issue-link-contract.Tests.ps1` not yet created): `tests/scripts/claude-hooks/enforce-pr-author-*.Tests.ps1`, `tests/scripts/claude-hooks/enforce-model-routing-receipt*.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1`, `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1`.

## Counts (from artifacts/pester/pester-junit.xml)

- Passed: 404
- Failed: 0
- Skipped: 0
- Pre-existing failures: none

## Line coverage (from artifacts/pester/powershell-coverage.xml, JaCoCo LINE counters)

| File | Covered | Missed | Line coverage |
|---|---|---|---|
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 111 | 3 | 97.37% |
| `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | 75 | 0 | 100.00% |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 67 | 6 | 91.78% |

Missed lines: helpers file - the receipt JSON parse failure return, the unreadable-body return, and the unparseable `created_at` return; model-routing hook - the six statements of the script entry tail after the dot-source guard.

Output Summary: 404 passed, 0 failed, 0 skipped; baseline line coverage helpers 97.37%, allowlist 100.00%, model-routing 91.78%.
