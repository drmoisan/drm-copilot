# Baseline — Repository State

- **Task:** [P0-T6]
- **Issue:** #505

Timestamp: 2026-08-25T09-17

Command: `git rev-parse HEAD`

Supplementary line-count command (PowerShell, run from the worktree root):

```
@('scripts/dev_tools/fix_all_runtime.py','tests/scripts/dev_tools/test_fix_all_failure_paths.py','tests/scripts/dev_tools/test_fix_all.py') | ForEach-Object { $c = @(Get-Content $_); '{0}: total={1} nonblank={2}' -f $_, $c.Count, ($c | Measure-Object -Line).Lines }
```

EXIT_CODE: 0

## Branch and Commit

- Branch: `bug/fix-all-json-cancel-thread-race-505`
- Commit SHA: `d5e3a462f51c1dd1612b4f2009aaea4552a35ec7`
- Working tree at baseline: clean (`git status --porcelain --untracked-files=all` produced no output)
- Worktree root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a75166ce0ad92cc5f`

## Baseline Line Counts

`Get-Content` piped to `Measure-Object -Line` reports NON-BLANK lines, because an empty string
contributes zero lines to that cmdlet's tally. The 500-line file-size limit in
`.claude/rules/general-code-change.md` is measured against the TOTAL physical line count, so both
figures are recorded and the total is the authoritative one.

| File | Total lines | Non-blank lines (`Measure-Object -Line`) |
| --- | --- | --- |
| `scripts/dev_tools/fix_all_runtime.py` | 183 | 157 |
| `tests/scripts/dev_tools/test_fix_all_failure_paths.py` | 492 | 403 |
| `tests/scripts/dev_tools/test_fix_all.py` | 434 | 375 |

All three totals agree exactly with the figures recorded in the plan's File-Size Budget table
(183, 492, 434), confirming the worktree matches the state the plan was authored against.

Output Summary: Baseline captured on branch `bug/fix-all-json-cancel-thread-race-505` at commit
`d5e3a462f51c1dd1612b4f2009aaea4552a35ec7` with a clean working tree. The three numeric baseline
line counts are 183 for `scripts/dev_tools/fix_all_runtime.py`, 492 for
`tests/scripts/dev_tools/test_fix_all_failure_paths.py`, and 434 for
`tests/scripts/dev_tools/test_fix_all.py`. The 492-line figure confirms the plan's stated 8 lines of
headroom against the 500-line limit, which is the constraint that forces the new-test-file layout.
