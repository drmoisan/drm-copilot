# Gate — AC-16, a stale advisory crlf value does not override an LF target

Timestamp: 2026-09-08T11-05
Task: `[P6-T8]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: 0
Output Summary: DISCHARGED by CI round C, run 34219866134, conclusion success. TAP plan line `1..375`; 375 passing; the run carried zero `not ok` lines. Satisfies AC-16 and completes the pass-after half of the fail-before record.

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f stale tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P6-T8]` stays unchecked in the plan until then.**
- The plan preamble's claim that the CI route "produces no per-test TAP output" is refuted by
  direct observation: run 34213641449 emitted the plan line `1..349` and a per-test `ok N <name>`
  line for every test. The plan's targeted assertions therefore remain satisfiable; they are
  satisfied one round later, against the full-suite plan line rather than the targeted `1..N`.

## Assertion to be discharged from the CI run log

Each test below must appear as an `ok N <test name>` line, and no `not ok` line may name any of
them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats` and
`tests/shell/test_cleanup_worktrees_preserve_eol.bats`:

1. `a stale advisory crlf value does not override an LF target`

The plan's targeted form expects exit code 0 and the TAP plan line ``1..1`` for the filter
``stale``. Under the full-suite CI substitute the plan line is the whole-suite count instead, so
the equivalent three-part assertion is: every `ok` line above present, no `not ok` line naming any
of them, and the tests' own exit status 0 (bats emits an `ok` line only for a test whose body
exited 0).

## Local pre-verification of the behavior under test

This is the test `[P2-T4]` recorded failing against the pre-change tree. It is expected to
turn green in this phase. It now lives in `tests/shell/test_cleanup_worktrees_preserve_eol.bats`,
which the pre-authorized suite split created; the test name is unchanged.

**The signature check `[P2-T4]`'s design note asked for.** That fail-before record states that the
test drives `preserve_plan`, the read-only phase, rather than the whole pass, because a
`target_path` of null would resolve the index to an unwritable `/dev/MEMORY.md` and driving the
whole pass against the real fixture index would append to a checked-in file on every run. Phase 5
and Phase 6 both changed what `preserve_plan` does, and neither changed its signature: it still
takes no argument, still resolves the manifest from `CLEANUP_WT_MANIFEST_PATH` and the worktree
from `consolidation_worktree_path`, and still returns 0 on this scenario. The test therefore still
drives the function it names rather than passing silently against a moved target. The observed run
confirms it: the assertion the test makes is on records that only the Phase 6 code path emits.

Driven directly in Git Bash against the `eol-stale/` fixture, whose advisory `line_ending` is
`crlf` while its destination index is LF terminated:

    PRESERVE|<wt>|agent-memory/atomic-executor/stale-eol-lesson.md|STILL_RELEVANT
    ACTION|preserve-eol|<cwt>/agent-memory/atomic-executor/MEMORY.md|ADVISORY-MISMATCH
    cleanup-worktrees: advisory line_ending crlf disagrees with the derived lf: <index>
    ACTION|preserve-index|<cwt>/agent-memory/atomic-executor/MEMORY.md|OK
    rc=0

The mismatch is reported and the re-derived `lf` governs. The destination index was checked
byte-wise after the run and carries no carriage return:

    eol-stale      NO_CR
    eol-crlf       HAS_CR
    mixed-index    HAS_CR
    index-append   NO_CR

The two `HAS_CR` rows are the control: the same detection idiom reports a carriage return where one
is present, so the `NO_CR` result on the target is a real observation rather than a detector that
always answers no.

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: DISCHARGED. The named test(s) each carry an `ok` line in run 34219866134 and no `not ok` line names any of them.

## Discharge — CI round C

Timestamp: 2026-09-08T12-10
Task: `[P6-T8]`
Run: 34219866134
URL: https://github.com/drmoisan/drm-copilot/actions/runs/34219866134
Head SHA: 62c7332923cab355e2bcf7f64b658a1e1ca07511
Conclusion: success
EXIT_CODE: 0
TAP plan line: `1..375`
Passing: 375. Failing: 0. **The run carried zero `not ok` lines.**

The suite grew from the 343-test baseline to 375 and no pre-existing test regressed.
Verbatim TAP `ok` line for each test this gate names, read from the run log:

    ok 313 a stale advisory crlf value does not override an LF target

The three-part assertion the plan states is satisfied in its full-suite substitute form:
the run exited 0, the plan line `1..375` was printed, and no `not ok` line appears
anywhere in the run, so none names any of the 1 test(s) above.

### Fail-before / pass-after transition

This gate completes the pass-after half of a fail-before record. The same test was red at
the Phase 2 checkpoint and is green now.

**Red** — run 34213641449,
`https://github.com/drmoisan/drm-copilot/actions/runs/34213641449`, plan line `1..349`,
which carried exactly three `not ok` lines:

    not ok 289 an untracked preserve record is staged and reported
    not ok 290 a stale advisory crlf value does not override an LF target
    not ok 291 a host token match aborts the pass before any staging

**Green** — run 34219866134,
`https://github.com/drmoisan/drm-copilot/actions/runs/34219866134`, plan line `1..375`,
zero `not ok` lines, with this gate's test carrying the `ok` line quoted above.

The TAP sequence numbers differ between the two runs because the suite grew by thirty-two
tests between them. The test *names* are the stable identity and they match exactly.
