# Gate — AC-18 and AC-19, the CRLF target and the mixed-ending refusal

Timestamp: 2026-09-08T11-05
Task: `[P6-T10]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: PENDING-CI
Output Summary: PENDING-CI ROUND

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f crlf[[:space:]]target tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats'"`
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f EOL-MIXED tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P6-T10]` stays unchecked in the plan until then.**
- The plan preamble's claim that the CI route "produces no per-test TAP output" is refuted by
  direct observation: run 34213641449 emitted the plan line `1..349` and a per-test `ok N <name>`
  line for every test. The plan's targeted assertions therefore remain satisfiable; they are
  satisfied one round later, against the full-suite plan line rather than the targeted `1..N`.

## Assertion to be discharged from the CI run log

Each test below must appear as an `ok N <test name>` line, and no `not ok` line may name any of
them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats` and
`tests/shell/test_cleanup_worktrees_preserve_eol.bats`:

1. `a crlf target receives a crlf terminated index line`
2. `a mixed line ending target is refused and reported as EOL-MIXED`

The plan's targeted form expects exit code 0 and the TAP plan line ``1..1`, `1..1`` for the filter
``crlf[[:space:]]target`, `EOL-MIXED``. Under the full-suite CI substitute the plan line is the whole-suite count instead, so
the equivalent three-part assertion is: every `ok` line above present, no `not ok` line naming any
of them, and the tests' own exit status 0 (bats emits an `ok` line only for a test whose body
exited 0).

## Local pre-verification of the behavior under test

**AC-18, the CRLF target.** `preserve_derive_line_ending` answers `crlf` for the checked-in
CRLF fixture, and the terminator the writer selects is asserted in bytes:

    derive on tests/fixtures/cleanup_worktrees/preserve/eol-crlf/MEMORY.md   -> crlf
    terminator crlf, byte count                    2   (expected 2)
    terminator lf,   byte count                    1   (expected 1)
    render with the crlf token, carriage returns   1   (expected 1)
    render with the lf token,   carriage returns   0   (expected 0)

Both directions are pinned, so neither a writer that always emits CRLF nor one that never does can
pass. The raw bytes were also read directly:

    preserve_line_terminator crlf  ->  \r  \n
    preserve_line_terminator lf    ->  \n
    end-to-end render, crlf token, last four bytes  ->  d  )  \r  \n
    end-to-end render, lf token,   last four bytes  ->  m  d  )  \n

**AC-19, the mixed refusal.** The `eol-mixed/` fixture's index target mixes a CRLF-terminated and
an LF-terminated line. Driven through the read-only phase:

    derive -> mixed
    ACTION|preserve-eol|<index>|ADVISORY-MISMATCH
    ACTION|preserve-index|<index>|EOL-MIXED
    cleanup-worktrees: refusing an index with mixed line endings: <index>
    PRESERVE_EXIT=1   plan_stream_len=0

The record is skipped entirely. The empty plan stream is the decisive observation: no copy, no
stage, and no append is planned for it, which is what distinguishes a refusal from an append that
merely reports a warning. Refusal is chosen over a majority rule because there is no convention to
normalize to and a majority rule would silently rewrite the operator's file.

**Where the mixed index fixture lives, and why.** A mixed-ending fixture is only meaningful if its
carriage returns survive checkout, which requires the `.gitattributes` `-text` exception. Rather
than add a second exception line that no plan task authorizes, the index target was placed inside
the one subtree the existing exception already covers,
`tests/fixtures/cleanup_worktrees/preserve/eol-crlf/mixed-index/`, and the `eol-mixed/` scenario
directory points its consolidation path there. The `eol-unterminated/` fixture needs no exception:
it is LF only, and git's end-of-line normalization never adds a trailing newline to a file that
lacks one. The bytes of both fixtures were read back after creation and are as intended.

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: PENDING-CI ROUND.
