# Final QC — coverage delta against the baseline

Timestamp: 2026-09-08T08-08

Task: [P8-T8] of `remediation-plan.2026-09-08T05-00.md`

Command: the [P8-T6] dispatch
`gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-dirt-classifier-632-r2`,
compared against the baseline artifact
`evidence/remediation-baseline/shell-qc-test-coverage.2026-09-08T05-30.md` written by
[P0-T7].

EXIT_CODE: 0

## Headline figures

BaselineRepoLineCoverage: 92.9
PostChangeRepoLineCoverage: 93.7
BaselineDirtLibLineCoverage: 82.63
PostChangeDirtLibLineCoverage: 94.05
Threshold: 85.0

The post-change repository-wide value of `93.7` is at or above `85.0`.
The post-change dirt-library value of `94.05` is at or above `85.00` and is greater than the
baseline `82.63`, by 11.42 points.

## Run provenance

| | Baseline | Post-change |
|---|---|---|
| Run id | `34182198357` | `34194469882` |
| headSha | `ad6bc946bbf0ad9e69756b2155eae19771a232d8` | `ea1baef8aad811c6c9d6d12e32c8ab05f636ecaa` |
| Conclusion | `success` | `success` |
| TAP | `1..390`, 390 ok, 0 not ok | `1..404`, 404 ok, 0 not ok |

## Per-file regression check

Every file listed in the [P0-T7] baseline table, with its baseline and post-change
percentage:

| File | Baseline | Post-change | Fell below baseline |
|---|---:|---:|---|
| `scripts/bash/cleanup_worktrees_dirt_lib.sh` | 82.63% | 94.05% | no |
| `scripts/bash/cleanup_worktrees_scan_helper.sh` | 86.79% | 86.79% | no |
| `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 89.01% | 89.01% | no |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 92.13% | 92.13% | no |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 94.08% | 94.08% | no |
| `scripts/bash/cleanup_worktrees_lib.sh` | 95.41% | 95.41% | no |
| `scripts/bash/cleanup-worktrees.sh` | 97.44% | 97.44% | no |
| `scripts/bash/cleanup_worktrees_detached_lib.sh` | 100.00% | 100.00% | no |

## Changed-lines check

The only production file this cycle modified is
`scripts/bash/cleanup_worktrees_dirt_lib.sh`, and its coverage rose. The three edited
regions are all executed by tests added in this cycle:

- the rung-1 Y-column gate, by `dirt_staged_tree_worktree_delta` in both directions;
- the `R`/`C`-only payload split, by `dirt_rename_split` in both directions;
- the anchored header skip, by `dirt_build_artifact_plus_content` and
  `dirt_build_artifact_added_file` in both directions.

No changed line is in the residual uncovered set of ten recorded at [P8-T7].

Output Summary: Repository-wide bash line coverage rose from 92.9 to 93.7. The one file
finding R3 named rose from 82.63 to 94.05, clearing the 85.0 floor with 9.05 points of
margin. No file listed in the [P0-T7] baseline table fell below its baseline percentage;
seven are unchanged and one improved. No branch-coverage gate applies to bash, because kcov
does not measure branch coverage, and none is asserted.
