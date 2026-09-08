# Gate — AC-15 and AC-17, the unterminated final line and the advisory mismatch signal

Timestamp: 2026-09-08T11-05
Task: `[P6-T9]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: PENDING-CI
Output Summary: PENDING-CI ROUND

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f unterminated tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats'"`
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f ADVISORY-MISMATCH tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P6-T9]` stays unchecked in the plan until then.**
- The plan preamble's claim that the CI route "produces no per-test TAP output" is refuted by
  direct observation: run 34213641449 emitted the plan line `1..349` and a per-test `ok N <name>`
  line for every test. The plan's targeted assertions therefore remain satisfiable; they are
  satisfied one round later, against the full-suite plan line rather than the targeted `1..N`.

## Assertion to be discharged from the CI run log

Each test below must appear as an `ok N <test name>` line, and no `not ok` line may name any of
them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats` and
`tests/shell/test_cleanup_worktrees_preserve_eol.bats`:

1. `an unterminated final line receives a terminator before the append`
2. `an advisory line ending mismatch emits ADVISORY-MISMATCH`

The plan's targeted form expects exit code 0 and the TAP plan line ``1..1`, `1..1`` for the filter
``unterminated`, `ADVISORY-MISMATCH``. Under the full-suite CI substitute the plan line is the whole-suite count instead, so
the equivalent three-part assertion is: every `ok` line above present, no `not ok` line naming any
of them, and the tests' own exit status 0 (bats emits an `ok` line only for a test whose body
exited 0).

## Local pre-verification of the behavior under test

**AC-15, the unterminated final line.** `preserve_index_needs_terminator` reads the target's
final byte and answers whether a terminator is owed. Both directions were driven:

    unterminated fixture   rc=0   a terminator is owed
    terminated fixture     rc=1   nothing is owed

The negative control is in the test body, not only here: without it the test would pass against an
implementation that always answered yes.

The consequence was then asserted on the raw byte stream rather than on a captured string:

    render with pre=yes, line feeds counted   2   (expected 2)
    render with pre=no,  line feeds counted   1   (expected 1)

**Why the count is taken through a pipe.** Command substitution strips trailing line feeds, and on
a Windows host it strips a trailing CRLF pair whole, so a comparison against `$output` is not a byte
observation on every platform. This was found by direct observation during authoring: a first form
of the sibling AC-18 assertion captured both terminators as the empty string on the local host, so
it could not have failed. Counting bytes through a pipe discriminates everywhere, and the counts
above are the proof that it does.

Driven end to end, the `eol-unterminated/` fixture plans an append that owes a terminator:

    ACTION|preserve-index|<cwt>/agent-memory/atomic-executor/MEMORY.md|OK
    PRESERVE_INDEX_PRE=yes  PRESERVE_INDEX_TERM=lf

**AC-17, the advisory mismatch.** `preserve_plan_index` was driven with an advisory value of `crlf`
against an LF index:

    ACTION|preserve-eol|<index>|ADVISORY-MISMATCH
    cleanup-worktrees: advisory line_ending crlf disagrees with the derived lf: <index>
    ACTION|preserve-index|<index>|OK
    PRESERVE_INDEX_TERM=lf  PRESERVE_INDEX_ACTION=append  PRESERVE_INDEX_PRE=no

The re-derived value reached the write path; the advisory value reached only the report. The
control run, with an advisory value of `lf` that agrees, emitted no mismatch record at all, so the
assertion can fail.

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: PENDING-CI ROUND.
