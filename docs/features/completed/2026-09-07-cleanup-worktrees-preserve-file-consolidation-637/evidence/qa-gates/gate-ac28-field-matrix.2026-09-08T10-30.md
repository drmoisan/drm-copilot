# Gate — AC-28, each missing or out of vocabulary field skips the record and reports

Timestamp: 2026-09-08T10-30
Task: `[P3-T12]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: 0
Output Summary: DISCHARGED by CI round C, run 34219866134, conclusion success. TAP plan line `1..375`; 375 passing; the run carried zero `not ok` lines. Satisfies AC-28.

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f vocabulary tests/shell/test_cleanup_worktrees_preserve.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P3-T12]` stays unchecked in the plan until then.**
- The plan preamble's claim that the CI route "produces no per-test TAP output" is refuted by
  direct observation: run 34213641449 emitted the plan line `1..349` and a per-test `ok N <name>`
  line for every test. The plan's targeted assertions therefore remain satisfiable; they are
  satisfied one round later, against the full-suite plan line rather than the targeted `1..N`.

## Assertion to be discharged from the CI run log

Each test below must appear as an `ok N <test name>` line, and no `not ok` line may name any of
them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats`:

1. `each missing or out of vocabulary field skips the record and reports`

The plan's targeted form expects exit code 0 and the TAP plan line ``1..1`` for the filter
``vocabulary``. Under the full-suite CI substitute the plan line is the whole-suite count instead, so
the equivalent three-part assertion is: every `ok` line above present, no `not ok` line naming any
of them, and the tests' own exit status 0 (bats emits an `ok` line only for a test whose body
exited 0).

## Local pre-verification of the behavior under test

The test drives `preserve_validate_record`, created by `[P3-T4]`, once per sub-scenario of
`tests/fixtures/cleanup_worktrees/preserve/field-matrix/` — one case per skip-bearing field of
the D4 table. All eight were driven directly in Git Bash and every one skipped and reported:

    worktree-path-empty              rc=1  worktree_path is empty
    source-path-absolute             rc=1  source_path is absolute: /absolute/agent-memory/lesson.md
    change-class-out-of-vocabulary   rc=1  change_class out of vocabulary: renamed
    disposition-not-preserve         rc=1  disposition is not PRESERVE: DISCARD
    verdict-out-of-vocabulary        rc=1  verdict out of vocabulary: PROBABLY_USEFUL
    target-path-empty                rc=1  target_path is empty
    memory-index-line-key-absent     rc=1  memory_index_line key is absent
    evidence-empty                   rc=1  evidence is empty

Each printed `ACTION|preserve-stage|<target-path>|SKIPPED-INVALID`. The `target-path-empty` case
correctly prints an empty target field, `ACTION|preserve-stage||SKIPPED-INVALID`, because the
invalid field is the one that names the target.

`line_ending` is deliberately absent from this matrix. It is advisory, it describes the target
file rather than the record, and it is re-derived on the write path, so a stale value must not
remove an otherwise sound record. The upstream contract marks it ADVISORY for exactly that
reason.

The test asserts a sub-scenario count of exactly 8 in addition to the per-case assertions, so a
glob that matched nothing cannot pass vacuously. The positive control recorded in the AC-26
artifact — the valid `untracked` record returning rc=0 — applies here as well and establishes
that the validator is not refusing every record it is handed.

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: DISCHARGED. The named test(s) each carry an `ok` line in run 34219866134 and no `not ok` line names any of them.

## Discharge — CI round C

Timestamp: 2026-09-08T12-10
Task: `[P3-T12]`
Run: 34219866134
URL: https://github.com/drmoisan/drm-copilot/actions/runs/34219866134
Head SHA: 62c7332923cab355e2bcf7f64b658a1e1ca07511
Conclusion: success
EXIT_CODE: 0
TAP plan line: `1..375`
Passing: 375. Failing: 0. **The run carried zero `not ok` lines.**

The suite grew from the 343-test baseline to 375 and no pre-existing test regressed.
Verbatim TAP `ok` line for each test this gate names, read from the run log:

    ok 294 each missing or out of vocabulary field skips the record and reports

The three-part assertion the plan states is satisfied in its full-suite substitute
form: the run exited 0, the plan line `1..375` was printed, and no `not ok` line
appears anywhere in the run, so none names any of the 1 test(s) above.
