# Gate — AC-22, a host token match aborts the pass before any staging

Timestamp: 2026-09-08T11-25
Task: `[P7-T10]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: 0
Output Summary: DISCHARGED by CI round C, run 34219866134, conclusion success. TAP plan line `1..375`; 375 passing; the run carried zero `not ok` lines. Satisfies AC-22 and completes the pass-after half of the fail-before record.

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f aborts tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P7-T10]` stays unchecked in the plan until then.**
- The plan preamble's claim that the CI route "produces no per-test TAP output" is refuted by
  direct observation: run 34213641449 emitted the plan line `1..349` and a per-test `ok N <name>`
  line for every test. The plan's targeted assertions therefore remain satisfiable; they are
  satisfied one round later, against the full-suite plan line rather than the targeted `1..N`.

## Assertion to be discharged from the CI run log

Each test below must appear as an `ok N <test name>` line, and no `not ok` line may name any of
them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats` and
`tests/shell/test_cleanup_worktrees_preserve_eol.bats`:

1. `a host token match aborts the pass before any staging`

The plan's targeted form expects exit code 0 and the TAP plan line ``1..1`` for the filter
``aborts``. Under the full-suite CI substitute the plan line is the whole-suite count instead, so
the equivalent three-part assertion is: every `ok` line above present, no `not ok` line naming any
of them, and the tests' own exit status 0 (bats emits an `ok` line only for a test whose body
exited 0).

## Local pre-verification of the behavior under test

This is the test `[P2-T5]` recorded failing against the pre-change tree. It is expected to
turn green in this phase. Driven directly in Git Bash against the `host-token/` fixture:

    PRESERVE|<wt>|agent-memory/atomic-executor/host-token-lesson.md|GENUINELY_NEW
    cleanup-worktrees: host token matched (HT1) in <source>
    ACTION|preserve-stage|null|HOST-TOKEN-BLOCKED
    run_preserve rc=3   PRESERVE_BLOCKED=1   plan stream length 0

Exit status 3, and no `add` invocation of any kind: the plan stream is empty and the writing phase
is never entered, so the consolidation worktree is byte-unchanged and there is nothing to undo.

**The fixture is the discriminating shape.** The record's own `host_token_scan.result` is `clean`
while its source bytes carry a fabricated Windows user-profile path. A pass that trusted the
advisory value instead of scanning would have staged it. A fixture asserting `tokens_present`
would be satisfied by the cheap short-circuit alone and would not exercise the local scan at all.

**The absence assertion uses the plan's prescribed form.** AC-22 words the second obligation as
"the output carries no `stub-git: add` line". Taken as a literal search that assertion could never
fail: the stub echoes its whole argv at `tests/fixtures/cleanup_worktrees/stub-bin/git` line 65 and
strips `-C <path>` only afterwards, so the exact string `stub-git: add` is never printed even when
staging does occur. The test asserts the extended regular expression

    stub-git: .*[[:space:]]add[[:space:]]

which is the substitution the plan prescribes in its `## Known deviations` section. The test was
authored in Phase 2 with a different absence assertion, `add -- null`, which observes the same fact
but is a third variant; `[P7-T10]` replaced it with the plan's form so that the plan and the
implementation agree, and the same expression is now used by the ignored-target test so both
refusal paths are asserted identically. No other assertion in this work uses a different form.

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: DISCHARGED. The named test(s) each carry an `ok` line in run 34219866134 and no `not ok` line names any of them.

## Discharge — CI round C

Timestamp: 2026-09-08T12-10
Task: `[P7-T10]`
Run: 34219866134
URL: https://github.com/drmoisan/drm-copilot/actions/runs/34219866134
Head SHA: 62c7332923cab355e2bcf7f64b658a1e1ca07511
Conclusion: success
EXIT_CODE: 0
TAP plan line: `1..375`
Passing: 375. Failing: 0. **The run carried zero `not ok` lines.**

The suite grew from the 343-test baseline to 375 and no pre-existing test regressed.
Verbatim TAP `ok` line for each test this gate names, read from the run log:

    ok 289 a host token match aborts the pass before any staging

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
