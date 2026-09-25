Timestamp: 2026-09-25T15-37
Command: npx --yes bats tests/shell
EXIT_CODE: 0
Output Summary: TAP header read `1..463` (N_final = 463). N_final equals N_baseline (460,
recorded in P0-T7) plus exactly 3, matching the three new `@test` blocks added by P1-T2,
P1-T3, and P1-T6. 463 `ok` lines and 0 `not ok` lines were observed (confirmed by a direct
count of `not ok` over the captured output: zero matches). The literal string `bats not
installed; skipping shell tests.` is ABSENT from the captured output (confirmed by a direct
search: zero matches), confirming a real bats run executed, not a vacuous skip. This run
follows the P1-T6 correction that changed the injected test's redirect from
`>/dev/null 2>&1` to `>/dev/null`, allowing the git stub's stderr argv-log line to reach the
`$output` the test observes.

All three new tests' exact description strings are present on `ok` lines:
- `ok 274 dirt_typechange_delta: an MT entry whose working-tree content is on main is UNIQUE` (P1-T2 / AC-1: PASS)
- `ok 275 dirt_typechange_delta: mutating [MARCTU] to [MARCU] changes the verdict away from UNIQUE (negative control)` (P1-T3 / AC-2: PASS)
- `ok 297 dirt_staged_tree_is_commit: injecting a git add call into run_report makes the widened non-mutation assertion fail (negative control)` (P1-T6 / AC-5: PASS)

The prior run recorded at `final-shell-qc-test.2026-09-25T15-08.md` observed 1 `not ok` line
against this same test (test 297) before the P1-T6 redirect correction; that artifact is
left in place as the historical record of the defect and is not overwritten by this run.

Five `BW01` bats warnings were printed for pre-existing tests in
`test_cleanup_worktrees_preserve.bats` and `test_shell_qc_commands.bats`, each documenting
an intentionally-triggered exit code 127 (a stubbed-missing-tool scenario) that the test
already captures via `run`'s return code; these are informational bats linter notices, not
test failures, and none of the five is attributed to a test this plan added or modified.

This run's acceptance condition (AC-1, AC-2, AC-4, AC-5, AC-7) is satisfied.
