# Fail-Before: Issue Repro

Timestamp: 2026-11-03T12-35
Task: [P3-T2] [expect-fail]
Route: B (local, `npx --yes bats`, Bats 1.13.0 under Git Bash, launched by `sh SCRATCH/issue-1027-bats.sh` from the worktree root)
State: `cleanup_worktrees_preserve_lib.sh` unchanged from the merge base (`git status --porcelain -- .claude/skills` empty); `cleanup_worktrees_preserve_merge_lib.sh` present and sourced by the suite, but not yet called by `preserve_plan_one`.
Command: npx --yes bats --filter 'older modified snapshot' tests/shell/test_cleanup_worktrees_preserve_merge.bats
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary:
- TAP: `1..1`, `not ok 1 an older modified snapshot never overwrites newer main lines`.
- Failing assertion: `merge_assert_merge_entry merge-repro` (the column-9 `merge` check).
- Diagnostic printed by the test: `plan entry columns: 8, mode: ''`. The unchanged library planned the `merge-repro` record as an eight-column entry, which is the whole-file copy of the older worktree snapshot over the newer `main` version. It did not plan a mode `merge` entry.
