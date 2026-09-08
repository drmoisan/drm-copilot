# Gate — AC-20, the CRLF fixture-integrity test

Timestamp: 2026-09-08T09-49
Task: [P1-T11]
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: PENDING-CI
Output Summary: PENDING-CI ROUND

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f carriage tests/shell/test_cleanup_worktrees_preserve.bats'"`
- Substitute: the CI route, for the same reason recorded in
  `evidence/qa-gates/gate-ac32-stub-replays.2026-09-08T09-49.md`. This executor holds no
  `Bash(gh *)` grant, so the orchestrator dispatches the run and supplies the values.
  **`[P1-T11]` stays unchecked in the plan until then.**

## Assertion to be discharged from the CI run log

The test below must appear as an `ok N <test name>` line, with no `not ok` line naming it. Test
name, verbatim from its `@test` declaration in
`tests/shell/test_cleanup_worktrees_preserve.bats`:

- `the crlf fixture still contains a carriage return in the working tree`

## Local pre-verification of the property under test

The property the test asserts was verified directly in Git Bash, together with a negative control
that establishes the assertion can fail:

- CRLF fixture `tests/fixtures/cleanup_worktrees/preserve/eol-crlf/MEMORY.md`: detection reported
  `HAS_CR`.
- LF control `tests/fixtures/cleanup_worktrees/preserve/eol-stale/consolidation/agent-memory/atomic-executor/MEMORY.md`:
  detection reported `NO_CR`.

**A defect in the first-written form of this test was found and corrected during authoring, and is
recorded because it is not visible in the final file.** The test was first written as
`run grep -c $'\r' <fixture>`. Run against the CRLF fixture in Git Bash that form reported **0**
matches and exited 1, because `grep` on that host opens the file in text mode and strips the
carriage returns before matching. An `od -An -c <fixture> | grep -c '\\r'` form was also tried and
was rejected for a different reason: the backslash escaping did not survive the shell layers, the
pattern degraded to a bare `r`, and the negative control then matched 4 lines of an LF-only file,
so that form could not fail. The test as committed detects the carriage return in bash itself —
`content="$(cat <fixture>)"` followed by `[[ "$content" == *$'\r'* ]]` — which is byte-exact,
carries no backslash-escaping hazard, and discriminated correctly on both the fixture and the
control.

This is pre-verification of the property, not a discharge of the gate. The gate is the bats run.

Verdict: PENDING-CI ROUND.
