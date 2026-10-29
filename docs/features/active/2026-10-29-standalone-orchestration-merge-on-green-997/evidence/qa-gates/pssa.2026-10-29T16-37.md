# PSScriptAnalyzer (issue #997)

Timestamp: 2026-10-29T16-37
Command: sh SCRATCH/issue-997-static.sh (analyze step: Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information over the P5-T1 file set)
EXIT_CODE: 0
Output Summary: PSSA_TOTAL_FINDINGS=0 files=9.

| File | Findings |
| --- | --- |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 0 |
| `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1` | 0 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1` | 0 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1` | 0 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiRegression.Tests.ps1` | 0 |
| `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` | 0 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` | 0 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` | 0 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` | 0 |

Prior pass findings and fixes: PSUseShouldProcessForStateChangingFunctions on the fixture builders `New-GreenCiCheckpointJson` and `New-GreenCiDecisionJson` (fixed with a function-level SuppressMessage attribute and justification, the pattern the suites' existing `Set-*` helpers use); PSReviewUnusedParameter on the `Invoke-DocsOnlyGhExe` mock's `WorkingRoot` and `GhArgs` parameters, which exist for mock signature parity (fixed with a file-level SuppressMessage attribute and justification, the pattern of `enforce-completion-consistency.Tests.ps1`).
