# Fail-before — a stale advisory `crlf` value is not re-derived (AC-16)

Timestamp: 2026-09-08T09-49
Task: [P2-T4] [expect-fail]
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: PENDING-CI
ExpectedExitCode: 1
Output Summary: PENDING-CI ROUND

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f stale tests/shell/test_cleanup_worktrees_preserve.bats'"`
- Substitute: the CI route, for the reason recorded in
  `evidence/regression-testing/fail-before-untracked.2026-09-08T09-49.md`. **`[P2-T4]` stays
  unchecked in the plan until the orchestrator supplies the run-log values.**

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

Verdict: PENDING-CI ROUND. The expected outcome is a recorded failure.
