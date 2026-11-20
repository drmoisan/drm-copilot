# Gate — AC-11, the memory index line is appended verbatim to the destination index

Timestamp: 2026-09-08T10-45
Task: `[P5-T6]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: 0
Output Summary: DISCHARGED by CI round C, run 34219866134, conclusion success. TAP plan line `1..375`; 375 passing; the run carried zero `not ok` lines. Satisfies AC-11.

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f verbatim tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P5-T6]` stays unchecked in the plan until then.**
- The plan preamble's claim that the CI route "produces no per-test TAP output" is refuted by
  direct observation: run 34213641449 emitted the plan line `1..349` and a per-test `ok N <name>`
  line for every test. The plan's targeted assertions therefore remain satisfiable; they are
  satisfied one round later, against the full-suite plan line rather than the targeted `1..N`.

## Assertion to be discharged from the CI run log

Each test below must appear as an `ok N <test name>` line, and no `not ok` line may name any of
them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats` and
`tests/shell/test_cleanup_worktrees_preserve_eol.bats`:

1. `the memory index line is appended verbatim to the destination index`

The plan's targeted form expects exit code 0 and the TAP plan line ``1..1`` for the filter
``verbatim``. Under the full-suite CI substitute the plan line is the whole-suite count instead, so
the equivalent three-part assertion is: every `ok` line above present, no `not ok` line naming any
of them, and the tests' own exit status 0 (bats emits an `ok` line only for a test whose body
exited 0).

## Local pre-verification of the behavior under test

The test asserts two halves, both driven directly in Git Bash.

**Half one: the read-only phase resolves the index and plans an append.** Against the
`index-append/` fixture, whose consolidation index exists, is LF terminated, and carries no link to
the target's basename:

    PRESERVE|<wt>|agent-memory/atomic-executor/appended-lesson.md|GENUINELY_NEW
    ACTION|preserve-index|<cwt>/agent-memory/atomic-executor/MEMORY.md|OK
    rc=0  PRESERVE_EXIT=0

The index path is the `MEMORY.md` sibling of `target_path`, derived from `target_path`'s own
directory and never from the source's.

**Half two: the rendered bytes are the line's own bytes plus one terminator and nothing else.**
`preserve_render_index_append` was driven with `/dev/stdout` as the index path:

    RENDER_MATCH=yes
    - [Appended lesson](appended-lesson.md) — carried across verbatim, separator included

The em dash separator and the parenthesised markdown link survive unchanged. An implementation
that normalized the separator, or that re-rendered the line from its parts, would fail the exact
string comparison the test makes.

**Why `/dev/stdout` rather than a file.** Observing the appended bytes requires the append to
happen somewhere readable. Writing to a checked-in index would mutate the repository on every run
and break idempotence, and creating a scratch file is prohibited outright. `/dev/stdout` is a
character device, so the same reasoning that makes `/dev/null` acceptable for the byte copy applies
here, and the bytes land where `run` captures them.

**The checked-in index is unchanged by the test.** A `grep -c -F -- appended-lesson.md` against it
exits 1 having printed `0`, which is the untouched state and is asserted in the test body.

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: DISCHARGED. The named test(s) each carry an `ok` line in run 34219866134 and no `not ok` line names any of them.

## Discharge — CI round C

Timestamp: 2026-09-08T12-10
Task: `[P5-T6]`
Run: 34219866134
URL: https://github.com/drmoisan/drm-copilot/actions/runs/34219866134
Head SHA: 62c7332923cab355e2bcf7f64b658a1e1ca07511
Conclusion: success
EXIT_CODE: 0
TAP plan line: `1..375`
Passing: 375. Failing: 0. **The run carried zero `not ok` lines.**

The suite grew from the 343-test baseline to 375 and no pre-existing test regressed.
Verbatim TAP `ok` line for each test this gate names, read from the run log:

    ok 305 the memory index line is appended verbatim to the destination index

The three-part assertion the plan states is satisfied in its full-suite substitute form:
the run exited 0, the plan line `1..375` was printed, and no `not ok` line appears
anywhere in the run, so none names any of the 1 test(s) above.
