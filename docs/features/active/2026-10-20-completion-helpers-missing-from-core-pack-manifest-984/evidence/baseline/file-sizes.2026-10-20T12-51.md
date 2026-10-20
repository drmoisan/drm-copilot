# Baseline File Sizes (Issue #984)

Timestamp: 2026-10-20T12-51
Command: wc -l <each path below>
EXIT_CODE: 0
Output Summary: nine files counted; the largest is `.claude/hooks/enforce-python-batch-budget.ps1` at 495 physical lines; all are at most 500.

| Path | Physical lines |
|---|---|
| `.claude/hooks/enforce-completion-consistency.ps1` | 488 |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 239 |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 495 |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 492 |
| `.codex/hooks/enforce-python-batch-budget.ps1` | 350 |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` | 347 |
| `.codex/hooks/enforce-completion-consistency.ps1` | 491 |
| `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1` | 160 |
| `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` | 461 |
