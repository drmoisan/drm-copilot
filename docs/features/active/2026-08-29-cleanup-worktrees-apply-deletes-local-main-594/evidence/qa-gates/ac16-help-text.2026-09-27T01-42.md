# P5-T5 — AC-16 help text documents the base-branch protection

Timestamp: 2026-09-27T01-42
Task: [P5-T5]
Working directory: repository worktree root (HEAD `7e54e0e1`)

## Command 1 — help exit code

Command: `sh scripts/bash/cleanup-worktrees.sh --help`
EXIT_CODE: 0

(Standard output was discarded for this exit-code observation; the content is checked by commands 2 and 3.)

## Command 2 — base-branch paragraph

Command: `sh scripts/bash/cleanup-worktrees.sh --help | grep -c -F 'covers the base branch main'`
EXIT_CODE: 0

Output: `1`

## Command 3 — action result token

Command: `sh scripts/bash/cleanup-worktrees.sh --help | grep -c -F 'BLOCKED-PROTECTED-BASE'`
EXIT_CODE: 0

Output: `1`

Supplementary view of the printed paragraph (`--help` output lines 67-70):

```
PROTECTED_CURRENT also covers the base branch main, which is protected by name in every
checkout topology: main is never deleted and a worktree checked out on main is never
removed. As a second guard, apply mode refuses a deletion request for main with the
action result BLOCKED-PROTECTED-BASE.
```

Output Summary:
- `--help` exits 0.
- `covers the base branch main` count 1 (pipeline exit 0); `BLOCKED-PROTECTED-BASE` count 1 (pipeline exit 0).
- Result: PASS.
