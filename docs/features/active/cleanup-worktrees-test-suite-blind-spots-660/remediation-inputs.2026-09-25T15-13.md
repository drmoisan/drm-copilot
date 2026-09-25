# Remediation Inputs — #660 — 2026-09-25T15-13

## Source

Plan-execution finding, reported by `atomic-executor` after running
`docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/plan.2026-09-25T08-25.md`
task-by-task through Phase 2. Independently corroborated by a second, unrelated executor run
in a parallel duplicate worktree that executed the same plan text. Both runs reproduced the
identical failure, byte-for-byte, from the plan's own literal task text — this is a defect in
the plan, not a transcription error by either executor.

## Finding 1 (Blocking — AC-5, AC-7) — P1-T6's injected line silences the channel its own assertion reads

`tests/shell/test_cleanup_worktrees_dirt_clear.bats`, the `@test` inserted by plan task P1-T6
(current file, line 227 test / line 230 injected `sed` line):

```bash
mutated="$(sed '/^run_report() {$/a\
	cleanup_wt_git add -- test-negative-control >/dev/null 2>&1 || true' "${LIB}")"
```

The injected line redirects **both stdout and stderr** (`>/dev/null 2>&1`) of the injected
`cleanup_wt_git add` call. The stub `tests/fixtures/cleanup_worktrees/stub-bin/git` reports
every invocation by writing `stub-git: <args>` to **stderr**
(`printf 'stub-git: %s\n' "$*" >&2`). The test's own observation line,
`log="$(printf '%s\n' "$output" | grep '^stub-git' || true)"`, and its assertion at line 247,
`[[ "$log" == *" add "* ]]`, both depend on that stderr channel reaching `$output`. Because the
injected line's own redirect discards stderr, the stub's `stub-git: add ...` line never reaches
`$output`, `$log` is empty of it, and the assertion fails unconditionally — the test cannot pass
however the mutation behaves.

Reproduced independently in two separate worktrees (this session's `atomic-executor` run and a
parallel duplicate run), both against the plan's literal, unmodified text. Local bats run in
this worktree: `1..463`, `462 ok`, `1 not ok` (the P1-T6 test), `EXIT_CODE: 1`. Baseline was
`1..460`, 0 failures.

**Downstream effect:** AC-5 (negative control proving AC-4 can fail) is unmet, and AC-7 (both
`shell-qc.sh` gates exit 0) is unmet because the test-stage gate exits 1.

**Minimal fix (for planner confirmation):** change the injected line's redirect from
`>/dev/null 2>&1` to `>/dev/null` so stdout is still suppressed but stderr — the channel the
stub's argv log and this test's own assertion depend on — reaches `$output`.

## Finding 2 (secondary, non-blocking) — P1-T5's acceptance grep count is wrong once P1-T6 lands

Plan task P1-T5's stated acceptance condition requires
`grep -F '[[ "$log" != *" add "* ]]' tests/shell/test_cleanup_worktrees_dirt_clear.bats` to
return **exactly one match**. Once P1-T6 is also applied (as it must be — P1-T5 and P1-T6 are
both required plan tasks), the literal string `[[ "$log" != *" add "* ]]` appears twice in the
file: once as P1-T5's actual assertion (line 222), and once inside P1-T6's own plan-mandated
explanatory comment (line 244:
`# ([[ "$log" != *" add "* ]], asserted in the test above against the real library)`). Confirmed
directly in this worktree: `grep -c` for that exact literal returns `2`, not `1`.

This does not block any acceptance criterion on its own — P1-T5's actual code edit is correct —
but the acceptance condition as literally stated in the plan is false against the plan's own
required end state, so it needs correction so a future preflight or re-run does not misreport
P1-T5 as failed.

## Requested plan revision

Revise `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/plan.2026-09-25T08-25.md`
(the single canonical plan file — no new timestamped sibling):

1. P1-T6: change the injected `sed` line's redirect from `>/dev/null 2>&1` to `>/dev/null` (or
   an equivalent fix the planner confirms preserves stdout suppression while letting the stub's
   stderr argv-log line reach `$output`).
2. P1-T5: correct the acceptance condition's expected match count for
   `[[ "$log" != *" add "* ]]` from exactly one match to exactly two matches (or otherwise
   qualify the grep so it counts only the assertion occurrence, e.g. by anchoring to the test
   body rather than the whole file) — planner's judgment on which is cleaner, so long as the
   corrected condition is true against the plan's own required end state and is not
   self-defeating (see G6/G5 guidance in `.claude/rules/plan-acceptance-gates.md`).
3. No other task is affected. P1-T1 through P1-T5 and P1-T7 are already complete, verified, and
   committed (commit `3e48b3b8` on branch `bug/cleanup-worktrees-test-suite-blind-spots-660`);
   the revision must not require re-doing them. P2-T1 and P2-T3 are already complete and
   committed (commit `78bd4ca0`); the revision must not require re-doing them either.

## Re-execution scope after revision

Only P1-T6 (re-inserted with the corrected text — the file already has an earlier, defective
version of this test on disk; it needs replacing, not appending) and P2-T2 (the final bats run,
to re-observe `N_final`, zero `not ok` lines, and the corrected AC-5/AC-7 evidence) need to be
re-run. AC-1 through AC-4 and AC-6 are already checked off in `issue.md` and evidenced; they are
not in scope for re-verification unless the P1-T6 fix is shown to disturb them (it should not:
the fix only changes a redirect on an already-inert stub-git call).
