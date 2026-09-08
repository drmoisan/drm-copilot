# Fail-before — a host token does not abort the pass (AC-22)

Timestamp: 2026-09-08T09-49
Task: [P2-T5] [expect-fail]
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: PENDING-CI
ExpectedExitCode: 1
Output Summary: PENDING-CI ROUND

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f aborts tests/shell/test_cleanup_worktrees_preserve.bats'"`
- Substitute: the CI route, for the reason recorded in
  `evidence/regression-testing/fail-before-untracked.2026-09-08T09-49.md`. **`[P2-T5]` stays
  unchecked in the plan until the orchestrator supplies the run-log values.**

## Assertion to be discharged from the CI run log

The test below must appear as a **`not ok N <test name>`** line. Test name, verbatim from its
`@test` declaration in `tests/shell/test_cleanup_worktrees_preserve.bats`:

- `a host token match aborts the pass before any staging`

## Why the test fails, stated so the failure reason is auditable

The test sources `scripts/bash/cleanup_worktrees_preserve_lib.sh` and calls `run_preserve`. That
library does not exist in the tree at this point, so the `&&` chain stops at the missing source and
the pass exits 1 rather than the 3 the test asserts. The failure is the absent behavior.

**The absence assertion is written so it can fail.** AC-22 words the second obligation as "the
output carries no `stub-git: add` line". Taken as a literal search that assertion could never fail:
the stub logs its full argv, and the production call carries a leading `-C <consolidation-worktree>`
operand, so the exact string `stub-git: add` is never printed even when staging does occur. The
test therefore asserts the absence of `add -- null`, which is the operand the staging call for this
record would actually carry and which was confirmed to be printed when the stub's `add` arm is
reached.

**Supporting material, verified independently of the missing library:**

- `tests/fixtures/cleanup_worktrees/preserve/host-token/manifest.json` exists and carries one
  record with all ten required fields.
- The record's `host_token_scan.result` is deliberately `clean` while the source bytes do carry a
  host token. This is the discriminating shape specification D12 requires: the consumer performs its
  own scan unconditionally, so a pass that trusted the advisory value instead of scanning would
  stage the file and the test would fail. A fixture asserting `tokens_present` would be satisfied by
  the cheap short-circuit alone and would not exercise the local scan.
- The source file
  `tests/fixtures/cleanup_worktrees/preserve/host-token/wt/agent-memory/atomic-executor/host-token-lesson.md`
  exists and carries an absolute host path on its own line.
- The canned `jq.out` carries the record as 14 tab-separated columns in the D3 order.
- `check-ignore.null.rc` contains `1`, so the destination is reported as not ignored and the record
  would otherwise reach staging. Without that file the stub's `respond` would default to exit 0,
  which `git check-ignore -q` means "the path IS ignored", and the record would be refused for the
  wrong reason before the host-token scan mattered.
- The bats file passes a bash syntax check, and `bash scripts/bash/shell-qc.sh check` exits 0 with
  no output after these edits.

The destination is `/dev/null` (`CLEANUP_WT_CONSOLIDATION_PATH=/dev` with `target_path` of `null`),
so even a pass that wrongly proceeded would create no file.

Together with `[P2-T3]` and `[P2-T4]` this contributes to **AC-42**.

Verdict: PENDING-CI ROUND. The expected outcome is a recorded failure.
