# QA gate: final gates versus Phase 0 baseline (issue 1105)

Timestamp: 2026-11-07T15-23
Task: [P4-T4]
Command: comparison of `evidence/baseline/pester-parallel.2026-11-07T14-41.md` and `evidence/baseline/pytest-parallel.2026-11-07T14-43.md` with `evidence/qa-gates/pester-parallel.2026-11-07T15-20.md` and `evidence/qa-gates/pytest-parallel.2026-11-07T15-23.md` (the greatest file of each name); changed-line coverage from sh SCRATCH/issue-1105-changedlines.sh final1 (`git diff -U0 <merge base of origin/main and HEAD> -- <file>` new-side line numbers matched against the JaCoCo `line` elements of the baseline and final `powershell-coverage.xml`)
EXIT_CODE: 0
Output Summary:
- New failures: none. Pester baseline 0 failed of 15553, final 0 failed of 15671. pytest baseline 0 failed (16179 passed, 6 skipped), final 0 failed (16179 passed, 6 skipped).
- Changed executable lines left uncovered in the final run, per edited hook: 0 in every file, so no changed line lost coverage.
- Both new files at or above 85%: subagentstop-target-worktree.ps1 100.00%, validate-feature-review-coverage-freshness.ps1 97.96%.
- Verdict (AC-15): PASS.

## Edited hooks (baseline / final per-file line coverage; changed lines)

| File | Baseline | Final | Changed lines (diff) | Changed executable | Changed uncovered |
|---|---|---|---|---|---|
| validate-task-researcher-output.ps1 | 98.17% (107/109) | 98.31% (116/118) | 32 | 16 | 0 |
| validate-prd-feature-output.ps1 | 100.00% (66/66) | 100.00% (76/76) | 46 | 15 | 0 |
| validate-required-artifact-output.ps1 | 98.44% (63/64) | 98.68% (75/76) | 31 | 19 | 0 |
| validate-planner-output.ps1 | 99.53% (211/212) | 99.54% (218/219) | 19 | 10 | 0 |
| validate-executor-output.ps1 | 99.42% (170/171) | 100.00% (153/153) | 37 | 20 | 0 |
| validate-feature-review-coverage.ps1 | 100.00% (93/93) | 100.00% (118/118) | 59 | 37 | 0 |
| validate-feature-review-coverage-metrics.ps1 | 100.00% (72/72) | 100.00% (76/76) | 27 | 13 | 0 |
| validate-feature-review-coverage-rules.ps1 | 98.99% (98/99) | 98.99% (98/99) | 2 | 0 | 0 |

## New files (final per-file line coverage against the 85% threshold)

| File | Final | Threshold | Result |
|---|---|---|---|
| subagentstop-target-worktree.ps1 | 100.00% (73/73) | 85% | PASS |
| validate-feature-review-coverage-freshness.ps1 | 97.96% (48/49) | 85% | PASS |

The one uncovered line in `validate-feature-review-coverage-freshness.ps1` is the default `GitInvoker` script-block parameter value of `Get-FeatureReviewCoverageFreshnessDecision`, which runs `git` and is replaced by an injected invoker in every test.
