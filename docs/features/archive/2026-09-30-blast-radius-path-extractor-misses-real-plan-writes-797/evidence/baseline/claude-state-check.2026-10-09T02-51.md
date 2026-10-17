# Issue #510 State Guard (P0-T6)

Timestamp: 2026-10-09T02-51
Command: poetry run python -c "import glob; print(len([p for p in glob.glob('.claude/state/*-batch-budget.*.json')]))"; ls -a .claude/state
EXIT_CODE: 0
Output Summary: count 0. The .claude/state directory does not exist in this worktree (`ls: cannot access '.claude/state': No such file or directory`), so no batch-budget state file exists, including dot-prefixed names.

## Deviation (PowerShell route denied)

The plan runs `Get-ChildItem -Filter '*-batch-budget.*.json'` in the PowerShell tool; inline `pwsh` is denied by the worktree-isolation hook (denial text recorded in requirements-source.2026-10-09T02-51.md). The Python glob with the same pattern, plus a directory listing, establishes the same count. The same pair of commands is used wherever the plan re-runs the P0-T6 command.

## Output

```text
0
ls: cannot access '.claude/state': No such file or directory
```
