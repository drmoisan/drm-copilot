# Unit Stage With Coverage: GSS (P6-T3, loop pass 1)

Timestamp: 2026-10-28T13-31
Command: sh SCRATCH/issue-989-pt.sh (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders <GSS files>, coverage enabled through pester.runsettings.psd1; then SCRATCH/issue-989-summary.ps1 reads artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0

GSS (25 files): `tests/scripts/claude-hooks/enforce-pr-author-*.Tests.ps1`, `tests/scripts/claude-hooks/enforce-model-routing-receipt*.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1`, `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`, `tests/scripts/claude-runtime/pr-author-issue-link-contract.Tests.ps1`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1`.

## Counts (artifacts/pester/pester-junit.xml)

- Passed: 454
- Failed: 0
- Skipped: 0

## Per-file line coverage (artifacts/pester/powershell-coverage.xml, JaCoCo LINE counters)

| File | Covered | Missed | Line coverage | Threshold 85% |
|---|---|---|---|---|
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 113 | 3 | 97.41% | met |
| `.claude/hooks/enforce-pr-author-skill.current-branch.ps1` | 21 | 1 | 95.45% | met |
| `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | 77 | 0 | 100.00% | met |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 78 | 6 | 92.86% | met |

Missed lines: helpers - the same three pre-existing receipt-check returns as in the baseline (invalid receipt JSON, unreadable body, unparseable `created_at`); current-branch - the default `GitInvoker` scriptblock body (`git @args`), which runs only against the real executable; model-routing - the six statements of the script entry tail after the dot-source guard, unchanged from the baseline.

Output Summary: 454 passed, 0 failed, 0 skipped; line coverage helpers 97.41%, current-branch 95.45%, allowlist 100.00%, model-routing 92.86%; every CHF is at or above 85%.
