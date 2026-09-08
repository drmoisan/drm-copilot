# Single-consecutive-pass declaration (P5-T11)

Timestamp: 2026-09-08T10-00
WorkingDirectory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ac72d35e7980bc69d`

## The four local stages, in executed order

| # | Stage | Task | Artifact | EXIT_CODE |
|---:|---|---|---|---:|
| 1 | Format | P5-T1 | `evidence/qa-gates/shell-qc-format.2026-09-08T10-00.md` | 0 |
| 2 | Lint | P5-T2 | `evidence/qa-gates/shell-qc-check.2026-09-08T10-00.md` | 0 |
| 3 | Test | P5-T3 | `evidence/qa-gates/shell-qc-test.2026-09-08T10-00.md` | 0 |
| 4 | Contract | P5-T11 (this task) | this artifact | **1** |

Stages 1 through 3 ran consecutively with no intervening edit to any file under the discovery
roots, and the format stage rewrote nothing: `git status --porcelain` was empty both before and
after it. Stage 3 reported plan line `1..411`, 411 `ok` and 0 `not ok`.

Note on stage 1: P5-T1 exits 0 but its own task remains unchecked, because the two tree-digest
observation fields it requires are denied by the environment. That denial does not affect this
declaration's stage-1 exit code, which is recorded above as observed.

## The contract stage — this task's own invocation

Command: `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
EXIT_CODE: 1
Output: `1 failed, 10 passed in 0.18s`

This `Command:` names this task's own invocation, run after the Phase 5 formatter and linter, and
not P4-T7's artifact. P4-T7 executes before Phase 5's format stage, so citing it would describe a
tree state the format stage could have changed and the four stages would not have run
consecutively.

The task's acceptance requires all four stages at exit code `0` and the contract stage's recorded
output to be `11 passed`. The contract stage exits 1 with `10 passed`, so **the acceptance is not
met and [P5-T11] remains unchecked**.

### Why the contract stage fails, and why it is not a regression

The failing test is
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`,
asserting `Repo file missing from bundle: .claude\state\current-session-id`. That path is excluded
by the repository ignore rules at `.gitignore:67` while the test's repo-side enumeration walks the
filesystem and excludes only `settings.local.json` and `.claude/agent-memory/**`. It is the
bundle-parity defect open as issue **#510**: it fails locally and is green in CI.

The identical failure was observed at the Phase 0 baseline by P0-T10, before any source change on
this branch, and again by P4-T7. Baseline-versus-post-change is the comparison that matters and
both ends carry the same pre-existing failure. The state file was not deleted to force a pass. The
adjudication is at `evidence/other/phase0-blocked-gates.2026-09-08T22-00.md`.

## The coverage stage

The coverage stage is **CI-measured, not local**. `kcov` has no local route in this worktree:
`bash scripts/bash/shell-qc.sh test --coverage` exits 127 here, as
`evidence/remediation-baseline/shell-coverage.2026-09-08T07-30.md` records. Coverage is measured
only by a dispatch of `.github/workflows/_shell-coverage.yml` against a pushed commit, and the
figures are read from that run's merged Cobertura artifact.

CoverageRunId: NOT AVAILABLE

The post-change dispatch (P5-T7), the artifact read (P5-T8) and the delta comparison (P5-T9) are
owned by the orchestrator, which holds the `gh` credential; this executor has no `gh` route. Those
three tasks are unrun and unchecked, so no post-change run id exists to name here. **No local run
is claimed, and no inferred, estimated or locally-derived coverage figure is substituted.**

This is the second reason this task's acceptance is not met: the acceptance requires the artifact to
name the coverage stage's run id, and that id does not yet exist.

The baseline figures remain those of CI run `34194469882`: 93.7% repository-wide line coverage and
94.05% on `scripts/bash/cleanup_worktrees_dirt_lib.sh`, against a threshold of 85.0. kcov measures
no branch coverage, so no branch gate applies to bash.

ExpectedExitCode: 1
