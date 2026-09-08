# Gate — AC-23 and AC-24, every pattern is detected and revision syntax is not

Timestamp: 2026-09-08T11-25
Task: `[P7-T11]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: PENDING-CI
Output Summary: PENDING-CI ROUND

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f detected tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats'"`
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f revision tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P7-T11]` stays unchecked in the plan until then.**
- The plan preamble's claim that the CI route "produces no per-test TAP output" is refuted by
  direct observation: run 34213641449 emitted the plan line `1..349` and a per-test `ok N <name>`
  line for every test. The plan's targeted assertions therefore remain satisfiable; they are
  satisfied one round later, against the full-suite plan line rather than the targeted `1..N`.

## Assertion to be discharged from the CI run log

Each test below must appear as an `ok N <test name>` line, and no `not ok` line may name any of
them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats` and
`tests/shell/test_cleanup_worktrees_preserve_eol.bats`:

1. `each host token pattern is detected`
2. `HEAD~1 and other revision syntax do not match the short-name pattern`

The plan's targeted form expects exit code 0 and the TAP plan line ``1..1`, `1..1`` for the filter
``detected`, `revision``. Under the full-suite CI substitute the plan line is the whole-suite count instead, so
the equivalent three-part assertion is: every `ok` line above present, no `not ok` line naming any
of them, and the tests' own exit status 0 (bats emits an `ok` line only for a test whose body
exited 0).

## Local pre-verification of the behavior under test

**AC-23, one fixture per identifier.** `tests/fixtures/cleanup_worktrees/preserve/ht-patterns/`
carries six checked-in source files, one per pattern identifier, each written so that it matches
exactly one pattern and therefore names that identifier in the diagnostic. Driven through the
read-only phase:

    HT1  ht1-windows-user-profile.md      host token matched (HT1)
    HT2  ht2-wsl-mount.md                 host token matched (HT2)
    HT3  ht3-posix-home.md                host token matched (HT3)
    HT4  ht4-short-name.md                host token matched (HT4)
    HT5  ht5-email.md                     host token matched (HT5)
    HT6  ht6-environment-variable.md      host token matched (HT6)

    preserve_plan rc=3   PRESERVE_BLOCKED=1   plan stream length 0
    six ACTION|preserve-stage|null|HOST-TOKEN-BLOCKED records

Every identifying value in those fixtures is fabricated: the account name is not a real account and
the host is not a real host.

Each pattern was additionally probed against a one-line string, in both directions:

    HT1 windows backslash    rc=1    HT1 windows forward slash  rc=1
    HT2 wsl mount            rc=1    HT3 posix home             rc=1
    HT4 short name segment   rc=1    HT5 email                  rc=1
    HT6 environment variable rc=1

    plain prose              rc=0    markdown index line        rc=0
    relative repository path rc=0    drive letter without users rc=0

**AC-24, the near-miss.** The short-name pattern requires a delimiter on BOTH sides of the tilde
segment, so ordinary revision syntax is not a match. The `ht-revision/` fixture carries `HEAD~3`,
`HEAD~1..HEAD`, `main~2`, `origin/main~1`, `refs/heads/main~1`, and the near-miss
`docs/notes~1.md`, whose tilde segment is followed by a dot rather than by a path delimiter:

    ht-revision  preserve_plan rc=0  BLOCKED=0  plan stream length 1
    no HOST-TOKEN-BLOCKED record and no `host token matched` diagnostic

**This is the second direction the feature exists to deliver.** The refusal is pinned as a
fail-closed property AND the legitimate payload is pinned as still accepted, so the refusal is not
a blanket reject. Nineteen further scenarios were driven in the same session and every one that
carries no token returned a non-blocked result, which is the broader control.

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: PENDING-CI ROUND.
