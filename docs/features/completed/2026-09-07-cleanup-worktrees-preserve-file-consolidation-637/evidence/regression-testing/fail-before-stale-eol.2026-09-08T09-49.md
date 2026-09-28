# Fail-before — a stale advisory `crlf` value is not re-derived (AC-16)

Timestamp: 2026-09-08T09-49
Task: [P2-T4] [expect-fail]
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: CI run 34213641449 (head SHA `005b7b3074db361060e841e3875e2424efa42110`) emitted the TAP plan line `1..349`. This test is red, which is the required outcome for this `[expect-fail]` task: `not ok 290 a stale advisory crlf value does not override an LF target`. Exactly three tests failed in the run - 289, 290, and 291 - and they are the three `[expect-fail]` cases and no others; the other 346 tests passed.

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f stale tests/shell/test_cleanup_worktrees_preserve.bats'"`
- Substitute: the CI route, for the reason recorded in
  `evidence/regression-testing/fail-before-untracked.2026-09-08T09-49.md`. The orchestrator
  dispatched the run and supplied the run-log values recorded below.

## Assertion to be discharged from the CI run log

The test below must appear as a **`not ok N <test name>`** line. Test name, verbatim from its
`@test` declaration in `tests/shell/test_cleanup_worktrees_preserve.bats`:

- `a stale advisory crlf value does not override an LF target`

## Why the test fails, stated so the failure reason is auditable

The test sources `scripts/bash/cleanup_worktrees_preserve_lib.sh` and calls `preserve_plan`. That
library does not exist in the tree at this point, so the `&&` chain stops at the missing source and
the first assertion `[ "$status" -eq 0 ]` fails. The failure is the absent behavior.

**Design note, recorded because it departs from the obvious shape.** This test drives
`preserve_plan`, the read-only phase, rather than the whole pass. Specification D6 places the
line-ending derivation and the `ADVISORY-MISMATCH` emission in phase 1, which performs no writes,
and specification D11's `/dev/null` technique does not extend to the index append: with a
`target_path` of `null` and `CLEANUP_WT_CONSOLIDATION_PATH=/dev`, the index path resolves to
`/dev/MEMORY.md`, which is not writable. Driving the whole pass against the real fixture index
would instead append to a checked-in file, making the test non-idempotent and mutating the
repository on every run. Driving phase 1 keeps the test write-free while asserting exactly the
property AC-16 names.

**Supporting material, verified independently of the missing library:**

- `tests/fixtures/cleanup_worktrees/preserve/eol-stale/manifest.json` exists and carries a record
  whose advisory `line_ending` is `crlf` while the destination index is LF terminated. That
  mismatch is the deliberate staleness the test detects.
- The canned `jq.out` carries the same record as 14 tab-separated columns in the D3 order, with
  column 10 (`line_ending`) set to `crlf` and column 9 carrying a string `memory_index_line`.
- The source file
  `tests/fixtures/cleanup_worktrees/preserve/eol-stale/wt/agent-memory/atomic-executor/stale-eol-lesson.md`
  exists and carries no host token.
- The destination index
  `tests/fixtures/cleanup_worktrees/preserve/eol-stale/consolidation/agent-memory/atomic-executor/MEMORY.md`
  exists and is LF terminated. It was checked for carriage returns directly and reported `NO_CR`,
  which is both the precondition of the scenario and the post-condition the test asserts.
- `check-ignore.agent-memory_atomic-executor_stale-eol-lesson.md.rc` contains `1`, and the git stub
  returned 1 for that key under this scenario, so the destination is reported as not ignored.
- The bats file passes a bash syntax check, and `bash scripts/bash/shell-qc.sh check` exits 0 with
  no output after these edits.

Together with `[P2-T3]` and `[P2-T5]` this contributes to **AC-42**.

## Discharge from the CI run log

- Run: `34213641449` at `https://github.com/drmoisan/drm-copilot/actions/runs/34213641449`
- Head SHA: `005b7b3074db361060e841e3875e2424efa42110`
- Run conclusion: `failure`. For this `[expect-fail]` task that conclusion is the required outcome,
  not a defect: the test named below is expected to be red until its implementing phase lands.
- TAP plan line: `1..349`
- The `not ok` line, verbatim from the run log:

      not ok 290 a stale advisory crlf value does not override an LF target

- Observed exit code: 1. `ExpectedExitCode: 1` is declared above, so this gate normalizes to `pass`.
- The three failing tests in the run are 289, 290, and 291, which are exactly the three
  `[expect-fail]` tests `[P2-T2]` authored. No pre-existing test regressed: the suite grew from the
  343-test baseline recorded in `evidence/baseline/baseline-shell-qc-test.2026-09-08T09-49.md` to
  349 tests, and 346 of them pass.

Verdict: PASS as an `[expect-fail]` record. The failure is recorded, is the expected outcome, and is
attributable to the absent implementation rather than to a defect in the test.

## Relocation note, added 2026-09-08T10-45

`[P5-T9]` took both pre-authorized splits. The test named above now lives in
`tests/shell/test_cleanup_worktrees_preserve_eol.bats` rather than in
`tests/shell/test_cleanup_worktrees_preserve.bats`, together with every other line-ending test.
The test name is unchanged and the CI discharge locates a test by its TAP `ok` or `not ok` line
rather than by file, so the record above is unaffected. The decision and its reasoning are
recorded in `evidence/other/library-split-decision.2026-09-08T10-30.md`.
