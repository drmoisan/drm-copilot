Timestamp: 2026-09-25T16-48
Command: npx --yes bats tests/shell
EXIT_CODE: 0
Output Summary: TAP header read `1..463` (N_final = 463). N_baseline (recorded in
`evidence/baseline/baseline-shell-qc-test.2026-09-25T14-45.md`) was 460; N_final equals
N_baseline plus exactly 3, matching the three new `@test` blocks added by P1-T2, P1-T3,
and P1-T6 (P1-T5 edited an existing test and added no new one). The captured output
contains 463 `ok` lines and zero `not ok` lines. The literal string `bats not installed;
skipping shell tests.` (the `run_test()` silent-no-op hazard string) is ABSENT from the
captured output, confirming a real bats run executed. All three target test descriptions
appear on `ok` lines: `ok 274 dirt_typechange_delta: an MT entry whose working-tree
content is on main is UNIQUE`; `ok 275 dirt_typechange_delta: mutating [MARCTU] to
[MARCU] changes the verdict away from UNIQUE (negative control)`; `ok 297
dirt_staged_tree_is_commit: injecting a git add call into run_report makes the widened
non-mutation assertion fail (negative control)`. Test numbers 275 and 297 are the exact
positions CI previously reported as `not ok` for the `git diff origin/main` triple removed
by P1-T3 and P1-T6 this round (see `remediation-inputs.2026-09-25T17-00.md`); both now
pass locally after the triple's removal, confirming the fix. `test_shell_qc_commands.bats`
emits several unrelated BW01 warnings (bats' own `run`-usage-style deprecation notice)
against intentional exit-127 assertions for missing tool binaries; these are pre-existing,
outside this plan's blast radius, and do not affect the pass/fail outcome of any test.
Run took approximately 4-5 minutes wall time (multiple bats-tap-stream progress checks
observed, consistent with prior runs of this suite on this Windows host).
