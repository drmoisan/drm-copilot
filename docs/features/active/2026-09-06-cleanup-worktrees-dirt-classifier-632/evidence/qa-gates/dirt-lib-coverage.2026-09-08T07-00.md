# Final QC — per-file coverage from the merged Cobertura report

Timestamp: 2026-09-08T08-05

Task: [P8-T7] of `remediation-plan.2026-09-08T05-00.md`
Finding: R3, AC-45

Command:

```
gh run download 34194469882 --repo drmoisan/drm-copilot --name shell-coverage
```

then reading `kcov-merged/cov.xml` from the downloaded artifact.

EXIT_CODE: 0

## Derivation

The percentage for each file is computed as the count of `line` elements with a non-zero
`hits` attribute divided by the total count of `line` elements under the `class` element
whose `filename` attribute ends in that path. Both counts are recorded below so the
percentage is re-derivable by a third party from the same artifact.

The report root's `line-rate` attribute is `0.937`, which agrees with the `93.7%` headline
the run log printed.

## Per-file table, all eight `scripts/bash/cleanup_worktrees*` files

| File | Covered / instrumented | Line coverage | Baseline | Delta |
|---|---:|---:|---:|---:|
| `scripts/bash/cleanup_worktrees_scan_helper.sh` | 46 / 53 | 86.79% | 86.79% | 0.00 |
| `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 162 / 182 | 89.01% | 89.01% | 0.00 |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 82 / 89 | 92.13% | 92.13% | 0.00 |
| `scripts/bash/cleanup_worktrees_dirt_lib.sh` | **158 / 168** | **94.05%** | 82.63% | **+11.42** |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 159 / 169 | 94.08% | 94.08% | 0.00 |
| `scripts/bash/cleanup_worktrees_lib.sh` | 187 / 196 | 95.41% | 95.41% | 0.00 |
| `scripts/bash/cleanup-worktrees.sh` | 38 / 39 | 97.44% | 97.44% | 0.00 |
| `scripts/bash/cleanup_worktrees_detached_lib.sh` | 103 / 103 | 100.00% | 100.00% | 0.00 |

`scripts/bash/cleanup_worktrees_dirt_lib.sh` reports **94.05%**, which is at or above the
required 85.00 with 9.05 points of margin. No other file changed.

The instrumented total for the dirt library moved from 167 to 168 because the Phase 2
through Phase 4 edits added one instrumentable statement net.

## Residual uncovered lines in `scripts/bash/cleanup_worktrees_dirt_lib.sh`

Ten lines, down from 29:

`74, 75, 76, 77, 95, 161, 164, 173, 203, 334`

Every one is in the class the plan identified as unclosable by any scenario, and each is
accounted for by its content:

| Lines | Content | Why unclosable |
|---|---|---|
| 74-77 | the interior of the multi-line `CLEANUP_WT_SESSION_ARTIFACT_PATHS=(` array assignment | kcov attributes the statement to its closing line 78, which is not in the uncovered set |
| 95 | the first physical line of the backslash-continued `rev-list` command | attributed to its continuation line 96, which is not in the uncovered set |
| 161 | the first physical line of the backslash-continued cached `diff` | attributed to line 162 |
| 164 | the first physical line of the backslash-continued worktree `diff` | attributed to line 165 |
| 334 | the first physical line of the backslash-continued `log --find-object` | attributed to line 335 |
| 173 | the empty `case` arm `"+"* \| "-"*) ;;` | carries no statement to instrument; it is taken by every build-artifact fixture |
| 203 | the empty `case` arm `*.csproj \| packages.config \| ... ) ;;` | carries no statement to instrument; it is taken by every project-file fixture |

None of the ten is a fail-closed branch, a verdict emission, or an unexecuted decision. The
19 lines the baseline listed that are no longer here are precisely the fail-closed machinery
that finding R3 identified as the concentration of risk: the two probe hard-failure sites,
the no-match return, the diff read failure, the `log --find-object` failure, the four
fail-closed `UNIQUE` emissions, the second `CONTENT_ON_MAIN` emission site, the
non-build-artifact filename fallthrough, the staged-probe return propagation, and the
`dirt-clear FAILED` record.

Output Summary: `scripts/bash/cleanup_worktrees_dirt_lib.sh` is at 94.05% line coverage,
158 of 168 instrumented lines, against a floor of 85.00. No pre-existing file's coverage
changed. The ten residual uncovered lines are all kcov multi-line-statement attribution
artifacts or empty `case` arms, none of which any scenario can close.
