# Baseline — bash line coverage (kcov, measured in CI)

Timestamp: 2026-09-08T05-09

Task: [P0-T7] of `remediation-plan.2026-09-08T05-00.md`

This task records the coverage baseline from the last measured run without re-dispatching.
The source is `evidence/qa-gates/shell-qc-test-coverage.2026-09-08T04-30.md`, which records
the run described below.

Command: `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-dirt-classifier-632-r2`

EXIT_CODE: 0

Run id: `34182198357`
Run URL: <https://github.com/drmoisan/drm-copilot/actions/runs/34182198357>
Event: `workflow_dispatch`
headSha: `ad6bc946bbf0ad9e69756b2155eae19771a232d8`
Conclusion: `success`

`kcov` has no local route in this worktree — `bash scripts/bash/shell-qc.sh test --coverage`
exits 127 with `kcov not installed; cannot run shell tests with coverage.` — so the CI
dispatch is the measurement path and this baseline is read from the recorded run rather than
re-measured locally.

## Per-file figures from the merged Cobertura report

| File | Line coverage | Covered / instrumented |
|---|---|---|
| `scripts/bash/cleanup_worktrees_dirt_lib.sh` | 82.63% | 138 / 167 |
| `scripts/bash/cleanup_worktrees_scan_helper.sh` | 86.79% | 46 / 53 |
| `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 89.01% | 162 / 182 |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 92.13% | 82 / 89 |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 94.08% | 159 / 169 |
| `scripts/bash/cleanup_worktrees_lib.sh` | 95.41% | 187 / 196 |
| `scripts/bash/cleanup-worktrees.sh` | 97.44% | 38 / 39 |
| `scripts/bash/cleanup_worktrees_detached_lib.sh` | 100.00% | 103 / 103 |

## Uncovered lines in `scripts/bash/cleanup_worktrees_dirt_lib.sh` (29 entries, verbatim)

`74, 75, 76, 77, 95, 98, 113, 114, 117, 148, 151, 155, 160, 190, 191, 233, 234, 258, 259, 269, 270, 273, 274, 305, 308, 309, 343, 415, 416`

Output Summary: Repo-wide bash line coverage is `92.9` percent, which clears the uniform
85% floor. `scripts/bash/cleanup_worktrees_dirt_lib.sh` is at `82.63` percent, being
`138 / 167` instrumented lines, which is below the floor and is finding R3. The 29-entry
uncovered-line list above ends `415, 416`, the `ACTION|dirt-clear|...|FAILED` emission. The
uncovered set is concentrated on the fail-closed machinery: the branches deciding what
happens when a classifier git read fails. The TAP figures from the same run were plan line
`1..390`, 390 `ok` lines, and 0 `not ok` lines.
