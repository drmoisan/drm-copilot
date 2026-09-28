# P6-T6 — QC step 4 (tests, local), loop pass 1

Timestamp: 2026-09-27T01-57
Task: [P6-T6]
Loop pass: 1
Working directory: repository worktree root
Tool: bats-core 1.13.0 via `npx --yes bats`
Run window (UTC): 2026-09-27T01-48-03 to 2026-09-27T01-56-56

## Precondition — porcelain status over IMPL_PATHS

Command: `git status --porcelain -- scripts/ tests/ .claude/skills/cleanup-merged-worktrees/ extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/`
EXIT_CODE: 0
Output: empty. No re-commit was needed; no re-commit SHA to record.

## T1-T10 result lines (verbatim, full-suite numbering)

| Test | Line |
|---|---|
| T1 | `ok 166 compute_protected emits protected-branch main when the primary worktree is on another branch` |
| T2 | `ok 167 compute_protected emits protected-branch main under current_exclusion` |
| T3 | `ok 168 compute_protected emits exactly one protected-branch main when the current branch is main` |
| T4 | `ok 20 classify_branch main is PROTECTED_CURRENT when the primary worktree is on another branch` |
| T5 | `ok 21 classify_branch main is PROTECTED_CURRENT when main is checked out in a linked worktree` |
| T6 | `ok 50 run_report classifies main PROTECTED_CURRENT when the primary worktree is on another branch` |
| T7 | `ok 51 run_apply does not delete main when the primary worktree is on another branch` |
| T8 | `ok 52 run_apply neither removes nor deletes main checked out in a linked worktree` |
| T9 | `ok 53 delete_candidate refuses the base branch before re-verification` |
| T10 | `ok 54 delete_candidate refuses the base branch before removing its linked worktree` |

## Non-result output

One pre-existing bats advisory warning, identical in kind to the P0-T10 baseline: `BW01` from `tests/shell/test_cleanup_worktrees_preserve.bats` line 133 (a `run` command exiting 127 in the no-jq fixture). It does not change any test result.

## Full bats run (gate)

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_*.bats`
EXIT_CODE: 0

Output Summary:
- Final porcelain status before bats: empty (the `dirt_clear` negative control precondition holds).
- TAP plan: `1..241` = P0-T10 plan `1..231` plus 10.
- `ok` count: 241; `not ok` count: 0. No P0-T10 `ok` test regressed.
- T1 through T10 each report `ok` (table above).
- `not ok` set: empty, a subset of the empty P0-T10 baseline failure set.
- Result: PASS.
