# Help Tokens: Claude PowerShell Batch-Budget Hook (issue #1009)

Timestamp: 2026-10-30T17-35
Command: grep -F -c -- '<token>' .claude/hooks/enforce-powershell-batch-budget.ps1 (fixed-string line search of the working-tree file, not git grep), once per token
EXIT_CODE: 0
Output Summary: both retired sentences are gone and every required literal is present. File length 532 physical lines (below 801).

| Token | Matching lines | Required |
|---|---|---|
| `large path is detected from` | 0 | 0 |
| `left at the root` | 0 | 0 |
| `resolved target worktree` | 5 | at least 1 |
| `junction` | 1 | at least 1 |
| `8.3` | 1 | at least 1 |
