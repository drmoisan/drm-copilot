# Gate — AC-07, AC-09, AC-10, AC-12 — preconditions, the modified path, ordering, and the null index

Timestamp: 2026-09-08T10-30
Task: `[P4-T14]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: 0
Output Summary: DISCHARGED by CI round C, run 34219866134, conclusion success. TAP plan line `1..375`; 375 passing; the run carried zero `not ok` lines. Satisfies AC-07, AC-09, AC-10, and AC-12.

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f MISSING-WORKTREE tests/shell/test_cleanup_worktrees_preserve.bats'"`
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f modified tests/shell/test_cleanup_worktrees_preserve.bats'"`
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f LC_ALL tests/shell/test_cleanup_worktrees_preserve.bats'"`
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f memory_index_line tests/shell/test_cleanup_worktrees_preserve.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P4-T14]` stays unchecked in the plan until then.**
- The plan preamble's claim that the CI route "produces no per-test TAP output" is refuted by
  direct observation: run 34213641449 emitted the plan line `1..349` and a per-test `ok N <name>`
  line for every test. The plan's targeted assertions therefore remain satisfiable; they are
  satisfied one round later, against the full-suite plan line rather than the targeted `1..N`.

## Assertion to be discharged from the CI run log

Each test below must appear as an `ok N <test name>` line, and no `not ok` line may name any of
them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats`:

1. `a missing consolidation worktree reports MISSING-WORKTREE and stages nothing`
2. `a modified preserve record is staged and reported`
3. `records are emitted in LC_ALL=C order regardless of manifest order`
4. `a null memory_index_line stages the file and touches no index`

The plan's targeted form expects exit code 0 and the TAP plan line ``1..1`, `1..1`, `1..1`, `1..1`` for the filter
``MISSING-WORKTREE`, `modified`, `LC_ALL`, `memory_index_line``. Under the full-suite CI substitute the plan line is the whole-suite count instead, so
the equivalent three-part assertion is: every `ok` line above present, no `not ok` line naming any
of them, and the tests' own exit status 0 (bats emits an `ok` line only for a test whose body
exited 0).

## Local pre-verification of the behavior under test

All four behaviors were driven directly in Git Bash against their checked-in fixtures.

**MISSING-WORKTREE.** With `CLEANUP_WT_CONSOLIDATION_PATH` naming a directory that does not exist:

    ACTION|preserve-stage||MISSING-WORKTREE
    cleanup-worktrees: consolidation worktree does not exist: <PRES>/no-worktree/absent-consolidation-worktree
    rc=1

No `stub-git:` line appears, so the precondition fails before any record is read. The directory
was not created, which the test asserts explicitly: the arm never creates the worktree.

**The modified path.** `change_class: modified` takes the identical staging path as `untracked`:

    PRESERVE|<wt>|agent-memory/atomic-executor/modified-lesson.md|STILL_RELEVANT
    stub-git: -C /dev check-ignore -q -- null
    stub-git: -C /dev add -- null
    ACTION|preserve-stage|null|OK
    rc=0

No `status` call is issued and no stub change was needed, because the two change classes differ
only in vocabulary and not in action.

**Ordering.** The `order/` fixture lists `zzz-lesson.md` first in the manifest array and
`aaa-lesson.md` second. The read-only phase emitted them in the opposite order:

    PRESERVE|<wt>|agent-memory/atomic-executor/aaa-lesson.md|GENUINELY_NEW
    PRESERVE|<wt>|agent-memory/atomic-executor/zzz-lesson.md|STILL_RELEVANT

The test compares the extracted sequence against an exact string, so an implementation that
iterated the array as written would produce the reverse of it and the assertion would fail. The
sort is field-aware (`sort -t <tab> -k1,1 -k2,2`) rather than whole-line, so a `worktree_path`
that is a prefix of another cannot reorder the pair.

**The null index.** The `untracked` record's `memory_index_line` is JSON null. The run staged the
file and emitted no `ACTION|preserve-index|` record of any kind, and `/dev/MEMORY.md` does not
exist. The index is not read, not created, and not appended to.

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: DISCHARGED. The named test(s) each carry an `ok` line in run 34219866134 and no `not ok` line names any of them.

## Discharge — CI round C

Timestamp: 2026-09-08T12-10
Task: `[P4-T14]`
Run: 34219866134
URL: https://github.com/drmoisan/drm-copilot/actions/runs/34219866134
Head SHA: 62c7332923cab355e2bcf7f64b658a1e1ca07511
Conclusion: success
EXIT_CODE: 0
TAP plan line: `1..375`
Passing: 375. Failing: 0. **The run carried zero `not ok` lines.**

The suite grew from the 343-test baseline to 375 and no pre-existing test regressed.
Verbatim TAP `ok` line for each test this gate names, read from the run log:

    ok 298 a missing consolidation worktree reports MISSING-WORKTREE and stages nothing
    ok 299 a modified preserve record is staged and reported
    ok 300 records are emitted in LC_ALL=C order regardless of manifest order
    ok 301 a null memory_index_line stages the file and touches no index

The three-part assertion the plan states is satisfied in its full-suite substitute form:
the run exited 0, the plan line `1..375` was printed, and no `not ok` line appears
anywhere in the run, so none names any of the 4 test(s) above.
