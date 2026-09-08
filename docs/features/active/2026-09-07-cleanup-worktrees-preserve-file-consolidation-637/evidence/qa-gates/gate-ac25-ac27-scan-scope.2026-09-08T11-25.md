# Gate — AC-25 and AC-27, the scan reads only the named source file and the identifier is advisory

Timestamp: 2026-09-08T11-25
Task: `[P7-T12]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: 0
Output Summary: DISCHARGED by CI round C, run 34219866134, conclusion success. TAP plan line `1..375`; 375 passing; the run carried zero `not ok` lines. Satisfies AC-25 and AC-27.

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f reads tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats'"`
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f governs tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P7-T12]` stays unchecked in the plan until then.**
- The plan preamble's claim that the CI route "produces no per-test TAP output" is refuted by
  direct observation: run 34213641449 emitted the plan line `1..349` and a per-test `ok N <name>`
  line for every test. The plan's targeted assertions therefore remain satisfiable; they are
  satisfied one round later, against the full-suite plan line rather than the targeted `1..N`.

## Assertion to be discharged from the CI run log

Each test below must appear as an `ok N <test name>` line, and no `not ok` line may name any of
them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats` and
`tests/shell/test_cleanup_worktrees_preserve_eol.bats`:

1. `the host token scan reads only the named source file`
2. `a pattern set id mismatch is reported and the local scan governs`

The plan's targeted form expects exit code 0 and the TAP plan line ``1..1`, `1..1`` for the filter
``reads`, `governs``. Under the full-suite CI substitute the plan line is the whole-suite count instead, so
the equivalent three-part assertion is: every `ok` line above present, no `not ok` line naming any
of them, and the tests' own exit status 0 (bats emits an `ok` line only for a test whose body
exited 0).

## Local pre-verification of the behavior under test

**AC-25, the scan scope.** The `scan-scope/` fixture puts a host path in the two places that
are deliberately out of scope and keeps the named source file clean:

    manifest.json                                    grep -c exampleaccount -> 1  (rc 0)
    consolidation/.../MEMORY.md                      grep -c exampleaccount -> 1  (rc 0)
    wt/.../scope-lesson.md                           grep -c exampleaccount -> 0  (rc 1)

    scan-scope  preserve_plan rc=0  BLOCKED=0  plan stream length 1
    ACTION|preserve-index|<index>|OK

No refusal. A pass that scanned the manifest, or the destination index, would have refused this
record, so the assertion can fail. The test asserts the three grep counts as well as the absence of
a refusal, so it also fails if the fixture ever stops carrying the tokens it is supposed to carry.

The manifest is out of scope because its own `worktree_path` values legitimately carry the very
tokens the scan refuses in staged content. The destination index and the rest of the consolidation
branch are out of scope because only the incoming bytes are this library's responsibility. The
repository tree and the push-down bundle are out of scope because tracked files legitimately contain
those strings and a repository-wide scan would flag them.

**AC-27, the pattern-set identifier.** Two sub-scenarios, both carrying the superseded identifier
`child-f-host-tokens-v1`:

    pattern-set-id/advisory-only        rc=0  ACTION|preserve-scan|null|PATTERN-SET-MISMATCH
                                              no refusal, plan stream length 1
    pattern-set-id/local-scan-governs   rc=3  ACTION|preserve-scan|null|PATTERN-SET-MISMATCH
                                              host token matched (HT1)
                                              ACTION|preserve-stage|null|HOST-TOKEN-BLOCKED

The mismatch is reported and changes nothing else, including the exit code: the first sub-scenario
returns 0 with the record planned. The local scan governs regardless of what the identifier claims,
which the second sub-scenario shows by refusing a record whose identifier is not one this library
owns and whose advisory result is `clean`.

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: DISCHARGED. The named test(s) each carry an `ok` line in run 34219866134 and no `not ok` line names any of them.

## Discharge — CI round C

Timestamp: 2026-09-08T12-10
Task: `[P7-T12]`
Run: 34219866134
URL: https://github.com/drmoisan/drm-copilot/actions/runs/34219866134
Head SHA: 62c7332923cab355e2bcf7f64b658a1e1ca07511
Conclusion: success
EXIT_CODE: 0
TAP plan line: `1..375`
Passing: 375. Failing: 0. **The run carried zero `not ok` lines.**

The suite grew from the 343-test baseline to 375 and no pre-existing test regressed.
Verbatim TAP `ok` line for each test this gate names, read from the run log:

    ok 310 the host token scan reads only the named source file
    ok 311 a pattern set id mismatch is reported and the local scan governs

The three-part assertion the plan states is satisfied in its full-suite substitute form:
the run exited 0, the plan line `1..375` was printed, and no `not ok` line appears
anywhere in the run, so none names any of the 2 test(s) above.
