# PowerShell Per-Batch Budget Reset — Issue #440 (F7)

Timestamp: 2026-08-08T21-46

Task: [P2-T3]

Purpose: reset the PowerShell per-batch budget before [P2-T4] writes the two `pester.runsettings.psd1` copies. This feature's PowerShell production surface is five files against a per-batch cap of three (`.claude/rules/powershell.md`, `## Change Budget`), and `.claude/hooks/enforce-powershell-batch-budget.ps1` classifies `.psd1` as production and scopes a batch to the whole executor session.

## Reset Command (first and only reset)

Command: `pwsh -NoProfile -Command 'Get-ChildItem -Path .claude/state -Filter "powershell-batch-budget.*.json" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("PRE-RESET " + $_.FullName + " " + (Get-Content -Raw $_.FullName)); Remove-Item -LiteralPath $_.FullName -Force }'`

Invoked from the repository root through the Bash tool with the entire `-Command` argument in single quotes, so the outer shell expanded no `$`.

EXIT_CODE: 1

Output Summary: **ZERO state files were enumerated. No `PRE-RESET` line was emitted and no file was deleted, because the budget state directory does not exist. The budget is already empty, so execution proceeds to [P2-T4] as the task's explicit zero-file branch directs.**

## Deleted State Files and Pre-Reset Counts

| State file (full path) | Pre-reset `prodFiles` | Pre-reset `testFiles` |
| --- | --- | --- |
| _(none — zero files enumerated)_ | n/a | n/a |

No state file was deleted because none existed to delete.

## Exit-Code Attribution

`EXIT_CODE: 1` does **not** indicate a failed reset. It is produced solely by `Get-ChildItem` resolving a non-existent `-Path`: the error is suppressed by `-ErrorAction SilentlyContinue`, but `$?` remains false, and `pwsh -Command` maps a false terminal `$?` to exit 1. Verified by contrasting the same construct against an existing directory:

```
pwsh -NoProfile -Command 'Get-ChildItem -Path .claude/state -Filter "powershell-batch-budget.*.json" -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count'
  -> 0    exit=1        (missing directory)

pwsh -NoProfile -Command 'Get-ChildItem -Path .claude -Filter "*.json" -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count'
  -> 2    exit=0        (existing directory, same construct)
```

The enumeration count is `0`, and the pipeline body (`Write-Output` + `Remove-Item`) never executed.

## Absence Verification (auditable negative claim)

SearchScope:
- `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a0b28ae2f972ac0ee\.claude\state` (this worktree, the executor session's repository root)
- `C:\Users\DanMoisan\repos\drm-copilot\.claude\state` (main checkout)
- recursive search from `C:\Users\DanMoisan\repos\drm-copilot` to depth 6, which covers the worktree's `.claude/state` at depth 5

SearchPatterns: `powershell-batch-budget.*.json`; and directory pattern `state` under any `.claude` path

SearchResult: `none`. `ls .claude/state` reports "No such file or directory" in both the worktree and the main checkout, and the recursive `find` returns no matching file and no matching directory.

Root-resolution note: `enforce-powershell-batch-budget.ps1` line 156 defaults `$Root` to `(Get-Location).Path` and line 188 joins `.claude/state` beneath it, so the state directory is created relative to the hook process's working directory. No such directory exists anywhere beneath the repository, so no session accumulated persisted budget state — the four PowerShell files written in Phase 1 left no state file behind.

## Second-Reset Branch

NOT EXERCISED. The task's contingency is: "If [P2-T4] is nevertheless denied by the batch-budget hook, delete the exact path named in that hook's deny reason, append the second reset to the same artifact, and retry [P2-T4] once."

Resolved after [P2-T4] executed: both `.psd1` writes (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`) were accepted with no batch-budget denial and no deny reason emitted. No second reset was required and none is appended. See `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/other/phase2-coverage-registration.2026-08-08T21-46.md`.
