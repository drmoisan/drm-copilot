# Baseline comparison (issue 1105, remediation cycle 1)

Timestamp: 2026-11-07T17-01
Task: [P3-T4]
Command: sh SCRATCH/issue-1105-c1changed.sh (pwsh -NoProfile -File SCRATCH/issue-1105-changedlines.ps1: for each hook, `git diff -U0 <merge-base of origin/main and HEAD> -- .claude/hooks/<file>` gives the changed lines, and each changed line is classified against `artifacts/pester/powershell-coverage.xml` of the final [P3-T2] run and the baseline coverage copy); the gate figures are read from the greatest `pester-parallel.*.md` and `pytest-parallel.*.md` under `evidence/baseline/` and `evidence/qa-gates/`
EXIT_CODE: 0
Output Summary:
- Baseline artifacts: `pester-parallel.2026-11-07T14-41.md` (15553 tests, 0 failed, repo line coverage 94.01%) and `pytest-parallel.2026-11-07T14-43.md` (16179 passed, 0 failed, 6 skipped).
- Final artifacts: `pester-parallel.2026-11-07T17-01.md` (15759 tests, 0 failed, repo line coverage 94.06%) and `pytest-parallel.2026-11-07T16-50.md` (16179 passed, 0 failed, 6 skipped).
- New failures relative to the baseline: none. Both final gates have zero failing tests.
- Helper `subagentstop-target-worktree.ps1`: 100.00% (92/92) against the 85% threshold. PASS.

## Per-hook changed-line coverage (merge-base diff; final run)

| Hook edited this cycle | Baseline line coverage | Final line coverage | Changed executable lines | Uncovered changed lines |
| --- | --- | --- | --- | --- |
| subagentstop-target-worktree.ps1 (new on the branch) | n/a | 100.00% (92/92) | 92 | 0 |
| validate-task-researcher-output.ps1 | 98.17% (107/109) | 98.33% (118/120) | 18 | 0 |
| validate-prd-feature-output.ps1 | 100.00% (66/66) | 100.00% (80/80) | 19 | 0 |
| validate-required-artifact-output.ps1 | 98.44% (63/64) | 98.73% (78/79) | 22 | 0 |
| validate-planner-output.ps1 | 99.53% (211/212) | 99.55% (221/222) | 13 | 0 |
| validate-executor-output.ps1 | 99.42% (170/171) | 100.00% (164/164) | 32 | 0 |
| validate-feature-review-coverage.ps1 | 100.00% (93/93) | 100.00% (124/124) | 44 | 0 |

## Branch files not edited this cycle (recorded for completeness)

- `validate-feature-review-coverage-metrics.ps1`: 100.00% (76/76); 13 changed executable lines, 0 uncovered.
- `validate-feature-review-coverage-rules.ps1`: 98.99% (98/99); 0 changed executable lines.
- `validate-feature-review-coverage-freshness.ps1` (new on the branch; not edited this cycle): 97.96% (48/49); 1 uncovered changed line.
  - The uncovered line is the default `GitInvoker` script-block parameter value of `Get-FeatureReviewCoverageFreshnessDecision`. It runs `git`, and every test replaces it with an injected invoker.
  - `baseline-comparison.2026-11-07T15-23.md` dispositioned the same line in the same way.

## Loop history

- First comparison: helper line 208 (the default `CheckpointIssueReader` script block) was uncovered.
- Fix: the case `places an issue-line-only prompt through Get-WorktreeItemCheckpointIssue when no reader is injected` was added to `subagentstop-target-worktree.Tests.ps1`. It mocks `Get-WorktreeItemCheckpointIssue`, so no file is read.
- The loop restarted from [P3-T1]. This comparison reads the resulting run.
