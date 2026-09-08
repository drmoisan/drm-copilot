# Single-consecutive-pass declaration — local stages

Timestamp: 2026-09-09T02-30
Task: [P5-T11] `[expect-fail]`
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`

## Status of this declaration

INCOMPLETE — the coverage stage is blocked on the caller's CI dispatch.

The plan's P5-T11 acceptance requires this artifact to name the coverage stage as
CI-measured **with the run id from P5-T8**. P5-T8 dispatches
`.github/workflows/_shell-coverage.yml` through `gh` and P5-T9 and P5-T10 read that run's
merged Cobertura artifact. Those tasks are the caller's under this run's carve-out: the
executor has no `gh`, `kcov` has no local route, and the caller's rules forbid recording
an inferred or locally-derived substitute. **No run id is recorded here and none is
inferred.** P5-T11 is therefore left **unchecked** in the plan alongside P5-T8, P5-T9 and
P5-T10. The four local stages below did run consecutively and are recorded in full.

## The four stages, in executed order

| # | Stage | Task | Command | Artifact | EXIT_CODE |
|---:|---|---|---|---|---:|
| 1 | format | P5-T1 | `bash scripts/bash/shell-qc.sh format` (paired with a `check` run) | `evidence/qa-gates/shell-qc-format.2026-09-09T02-30.md` | 0 |
| 2 | lint | P5-T2 | `bash scripts/bash/shell-qc.sh check` | `evidence/qa-gates/shell-qc-check.2026-09-09T02-30.md` | 0 |
| 3 | test | P5-T3 | `env SHELL_QC_BATS_BIN=<resolved path> bash scripts/bash/shell-qc.sh test` | `evidence/qa-gates/shell-qc-test.2026-09-09T02-30.md` | 0 |
| 4 | contract | this task | `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` | this artifact | 1 |

The first three stages are recorded with exit code `0`. No stage rewrote a file and no
restart of the toolchain loop was required; the loop completed in a single pass.

## Stage 4 — the contract run

Command: `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`

EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:

```
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
1 failed, 10 passed in 0.16s
```

Assertion message:

```
AssertionError: Repo file missing from bundle: .claude\state\current-session-id
```

The single failure is issue **#510**. `.claude/state/current-session-id` is gitignored at
`.gitignore:68`, whose rule is `.claude/state/`, while the test's repo-side enumeration
walks the filesystem and therefore sees a file the bundle cannot carry. The failure is
**identical at the P0-T10 baseline** for this cycle
(`evidence/remediation-baseline/pytest-push-down-contract.2026-09-09T00-00.md`, which also
recorded `EXIT_CODE: 1` and `1 failed, 10 passed`), and it is **green in CI**, where the
enumeration does not see the gitignored file. It is not attributable to this branch and no
work in this cycle was planned to close it. The state file was not deleted.

The contract run is repeated in this task rather than cited from P0-T10 because P0-T10
executes before this cycle's own edits pass through P5-T1's format stage, so a citation of
it would describe a superseded tree state and the four stages would not have run
consecutively.

## The half of this contract that this feature owns

The half of the push-down contract this feature owns is the `SKILL.md` **mirror parity**
leg, and it passes. `evidence/qa-gates/skill-mirror-parity.2026-09-09T02-00.md` records
that `.claude/skills/cleanup-merged-worktrees/SKILL.md` and
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
both carry md5 `2b4ce615d507371a2d50777d68358df0` and that `diff` between them produces no
output. That leg is among the 10 passing tests in the run above.

## Coverage stage

Coverage is **CI-measured**, not local. `kcov` has no local route in this worktree and
`bash scripts/bash/shell-qc.sh test --coverage` exits 127 here, so no locally derived bash
coverage figure is asserted anywhere in this cycle. The run id that would complete this
declaration comes from P5-T8's `workflow_dispatch` of
`.github/workflows/_shell-coverage.yml`, which is the caller's to run. This field is left
blocked rather than filled with a substitute:

RunId: BLOCKED — pending the caller's CI dispatch (P5-T8)
PostChangeRepoLineCoverage: BLOCKED — pending P5-T9
PostChangeDirtLibLineCoverage: BLOCKED — pending P5-T9

For reference and not as a post-change claim, the cycle-start baseline recorded in P0-T5
from CI run `34229386300` was 93.69% repository-wide and 94.12% on
`scripts/bash/cleanup_worktrees_dirt_lib.sh`. Those are baseline figures for the tree
before this cycle's edits and are not offered as the post-change position.
