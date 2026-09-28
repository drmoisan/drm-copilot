Timestamp: 2026-09-25T15-08
Command: npx --yes bats tests/shell
EXIT_CODE: 1
Output Summary: TAP header read `1..463` (N_final = 463). N_final equals N_baseline (460,
recorded in P0-T7) plus exactly 3, matching the three new `@test` blocks added by P1-T2,
P1-T3, and P1-T6. The literal string `bats not installed; skipping shell tests.` is ABSENT
(a real run executed, not a vacuous skip). 462 `ok` lines and 1 `not ok` line were observed.
This does NOT satisfy this task's stated acceptance condition ("zero `not ok` lines"). The
following individual test results were confirmed by name:
- `ok 274 dirt_typechange_delta: an MT entry whose working-tree content is on main is UNIQUE` (P1-T2 / AC-1: PASS)
- `ok 275 dirt_typechange_delta: mutating [MARCTU] to [MARCU] changes the verdict away from UNIQUE (negative control)` (P1-T3 / AC-2: PASS)
- `ok 277 every verdict emitted across the checked-in dirt scenarios is one of the six defined tokens` (P1-T4 list-coupling: PASS)
- `ok 296 dirt_staged_tree_is_commit: report mode issues no mutating git command and redirects no index` (P1-T5 widened AC-4 assertion, exercised against unmutated production code: PASS)
- `not ok 297 dirt_staged_tree_is_commit: injecting a git add call into run_report makes the widened non-mutation assertion fail (negative control)` (P1-T6 / AC-5: FAIL)

Root-cause finding for the single failure (independently verified by direct reproduction
of the test's exact `bash -c` command outside bats, using the identical `sed` mutation
sourced from the plan text and confirmed byte-identical to the plan's on-disk command
span): the injected line the plan specifies verbatim for P1-T6,
`cleanup_wt_git add -- test-negative-control >/dev/null 2>&1 || true`, redirects both
stdout and stderr of the injected `git add` invocation to `/dev/null`. The git stub used
throughout this suite (`tests/fixtures/cleanup_worktrees/stub-bin/git`) reports every
invocation by writing `stub-git: <args>` to stderr; that is the sole channel the test's
own `log="$(printf '%s\n' "$output" | grep '^stub-git' || true)"` line and its
`[[ "$log" == *" add "* ]]` assertion depend on. Because the plan's injected snippet
redirects that same stderr to `/dev/null` as part of the mutation it composes, the
injected call's stub-echo line can never reach `$output`, so the assertion the plan wrote
for this test cannot pass however the mutation behaves. This was confirmed by directly
reproducing the identical `bash -c` invocation outside bats: the injected `add` call runs
with the mutated library (confirmed present, immediately after `run_report() {` in the
mutated source) but produces no `stub-git: add ...` line in the captured output, because
of the injected line's own `>/dev/null 2>&1` redirection.

This is a defect in the plan's own literal task text for P1-T6 (`plan.2026-09-25T08-25.md`),
not an execution error: the exact command span was verified byte-for-byte against the
on-disk plan text (`cat -A` inspection of the sed line, including the literal tab
character preceding `cleanup_wt_git`) before this conclusion was reached, and the plan's
own text is what specifies the self-silencing redirection. No file under `tests/` or
`scripts/` was modified as a workaround; the test as inserted matches the plan's quoted
text exactly. AC-1, AC-2, AC-4 (widened-assertion existence and its pass against real
code) are confirmed by this run. AC-5 (a negative control that demonstrably proves AC-4
can fail) is NOT satisfied by the currently-inserted test, because the test's own
observability channel is silenced by its own injected redirection; this requires a plan
revision removing or narrowing the `>/dev/null 2>&1` on the injected line (or restructuring
the assertion to observe something other than the stub's stderr echo) before AC-5 can be
verified. This gate does not pass as literally specified.
