# Help Tokens: Codex Python Batch-Budget Hook (issue #1009)

Timestamp: 2026-10-30T17-40
Command: grep -F -c -- '<token>' .codex/hooks/enforce-python-batch-budget.ps1 (fixed-string line search of the working-tree file, not git grep), once per token
EXIT_CODE: 0
Output Summary: both retired sentences are gone and every required literal is present. File length 390 physical lines (at or below 500). The `.PARAMETER RepositoryRoot` help of `Invoke-PythonBatchBudgetCodexEntryPoint` states that the root locates the state directory and is the fallback root, and that the checkpoint comes from the resolved target worktree.

| Token | Matching lines | Required |
|---|---|---|
| `large path is detected from` | 0 | 0 |
| `left at the root` | 0 | 0 |
| `resolved target worktree` | 5 | at least 1 |
| `junction` | 1 | at least 1 |
| `8.3` | 1 | at least 1 |
