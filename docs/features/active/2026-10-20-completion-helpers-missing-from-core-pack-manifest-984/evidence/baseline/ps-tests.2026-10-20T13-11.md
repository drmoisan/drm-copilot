# Baseline Coverage-Enabled Pester Run (Issue #984)

Timestamp: 2026-10-20T13-11
Command: sh SCRATCH/issue-984-run-hooks-cov.sh (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-hooks,tests/scripts/codex-hooks,tests/scripts/claude-runtime -DisableKoverageCopy; then SCRATCH/issue-984-parse.ps1 over artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary: 7619 passed, 0 failed, 0 skipped (JUnit, 254 suites). Line coverage per repository hook: completion-consistency 93.29%, discovery gate 95.65%, Claude Python batch 90.58%, Claude PowerShell batch 90.58%, Codex Python batch 95.24%, Codex PowerShell batch 95.24%.

Counts from `artifacts/pester/pester-junit.xml`: total 7619, passed 7619, failed 0, skipped 0.

Failing tests: none.

Line coverage from `artifacts/pester/powershell-coverage.xml` (read before any later run overwrote it):

| Repository hook | Covered | Missed | Line coverage |
|---|---|---|---|
| `.claude/hooks/enforce-completion-consistency.ps1` | 139 | 10 | 93.29% |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 66 | 3 | 95.65% |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 125 | 13 | 90.58% |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 125 | 13 | 90.58% |
| `.codex/hooks/enforce-python-batch-budget.ps1` | 100 | 5 | 95.24% |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` | 100 | 5 | 95.24% |

Pester process summary line: "Covered 64.08% / 0%. 28,075 analyzed Commands in 215 Files." (aggregate command coverage over the derived population; informational only).
