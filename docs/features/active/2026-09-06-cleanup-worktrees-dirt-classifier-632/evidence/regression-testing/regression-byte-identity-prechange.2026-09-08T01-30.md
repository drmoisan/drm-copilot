# P3-T1 — byte-identity regression suite, pre-change run

Timestamp: 2026-09-08T01-30
Command: `npx --yes bats tests/shell/test_cleanup_worktrees_dirt_regression.bats`
EXIT_CODE: 0
ExpectedExitCode: 0

Commit under test: `aa0d619d9e3b4c7e3ecca027fb4978541f265407`
Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2`
Tree state at capture: `scripts/bash/cleanup_worktrees_dirt_lib.sh` does not exist.

Route: the bash toolchain is denied to the delegated `atomic-executor`, so the orchestrator
executed this gate from its own context per EA-4 and returned the measurement. The plan's
`wsl -d Ubuntu -- bash -lc` form against the preparation worktree is not used, per EA-1.
The full run record is `expect-fail-gates.2026-09-08T02-05.md` in this same folder; this
artifact is the per-task record the plan's acceptance names.

Output Summary: 11 passed, 0 failed. This suite is a pin, not an expect-fail gate: it must
pass both before and after the implementation. The pre-change pass is what makes any later
difference in report-mode or apply-mode output attributable to this change rather than to
pre-existing drift. Eight tests compare report-mode stdout for `content_neutral`,
`merged_no_worktree`, `merged_with_worktree`, `unmerged`, `residual_on_main`,
`residual_unique_doc`, `current_exclusion`, and `main_divergence` against the checked-in
expected files; two compare apply-mode stdout for `dirty_worktree` and
`dirty_worktree_status_error`; the eleventh asserts over live `run_report` stdout that a
worktree whose status read returns nothing emits neither a `DIRTFILE|` nor a `DIRTSUM|`
record.

The post-change counterpart is P5-T10.
