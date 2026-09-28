# Batch-Budget Reset (issue #671)

Timestamp: 2026-09-17T08-04
Task: [P2-T3]
Command: pwsh -NoProfile -NonInteractive -File <scratchpad>/reset.ps1 — `Get-ChildItem -Path .claude/state -Filter 'powershell-batch-budget.*.json' -ErrorAction SilentlyContinue` and `Remove-Item -LiteralPath <each> -Force`, then the same `Get-ChildItem` again (worktree root, via a scratchpad `sh` wrapper)
EXIT_CODE: 0

Output Summary:
- Before: 1 state file, `.claude/state/powershell-batch-budget.worktree-agent-a6dbf51ad3a3ac686-4c625983.json`, recording prodFiles = [`.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`] and testFiles = [].
- The file was deleted.
- After: `Get-ChildItem` returned 0 items.
- The two mirrors made so far used `Copy-Item` and consumed no budget slot, as the plan predicted.

## Second reset — [P4-T1] contingency (test side)

- Timestamp: 2026-09-17T08-14
- Command: the same `reset.ps1` (`Get-ChildItem` / `Remove-Item` / `Get-ChildItem`)
- EXIT_CODE: 0
- Before: 1 state file (same name), recording prodFiles = [] and testFiles = [the Claude and Codex command-exemption suites], two of three test slots used. The third mirror ([P2-T4]) again consumed no production slot.
- After: `Get-ChildItem -Path .claude/state -Filter 'powershell-batch-budget.*.json' -ErrorAction SilentlyContinue` returned 0 items, before the parity suite was created.
