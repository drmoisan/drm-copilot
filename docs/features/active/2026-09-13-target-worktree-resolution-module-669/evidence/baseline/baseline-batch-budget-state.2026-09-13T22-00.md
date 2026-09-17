# Baseline — PowerShell Batch-Budget State

Timestamp: 2026-09-17T07:51:00-04:00
Command: Get-ChildItem -Path '.claude/state' -Filter 'powershell-batch-budget.*.json' -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName; Get-Content -LiteralPath $_.FullName -Raw }
EXIT_CODE: 0
Output Summary: none — no `powershell-batch-budget.*.json` file exists; `.claude/state` does not exist in this worktree, which is the expected state before the first PowerShell write of the session.

## Result

none

## Informational cross-check (not required by the plan)

The hook resolves its state directory from its own install root (`enforce-powershell-batch-budget.ps1`,
`Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent`). This session's hooks may be installed in
the parent checkout `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-13T08-30`, so that checkout's
`.claude/state` was also inspected: 0 `powershell-batch-budget.*.json` files (a `current-session-id` file
is present). Batch-budget resets in this plan are applied to both locations for that reason.
