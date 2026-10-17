# Coverage delta (P3-T12)

Timestamp: 2026-10-16T03-32
Command: comparison of evidence/baseline/coverage-baseline.2026-10-16T01-33.md and evidence/qa-gates/coverage-final.2026-10-16T03-32.md; per-file attribution via poetry run python -I SCRATCH/jacoco_compare.py SCRATCH/ci-baseline-windows/powershell-coverage.xml SCRATCH/ci-final-windows/powershell-coverage.xml
EXIT_CODE: 1
Output Summary: Both targets copies rise from 99.39 to 99.40 with changed-line coverage 3/3 (lines 40, 228, 229 instrumented and covered). The report total falls from 90.42 to 90.41 (-0.01 points), so the condition "no post-change value is below its baseline" is not met for the report row. The drop comes entirely from two lines (116, a `throw`; 335, an early `return`) in `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`, a module this branch does not modify. EXIT_CODE 1 records the unmet condition.

## Delta table

| Scope | Baseline line_pct | Post-change line_pct | Changed-line coverage (covered / instrumented) |
|---|---|---|---|
| `.claude/hooks` targets copy | 99.39 | 99.40 | 3 / 3 (lines 40, 228, 229) |
| `.codex/hooks` targets copy | 99.39 | 99.40 | 3 / 3 (lines 40, 228, 229) |
| Report | 90.42 | 90.41 | 6 / 6 (the two copies above; no other production file changed) |

No changed executable line is absent from `instrumented_lines`. The added comment lines (38, 39), the blank line (41), and the closing brace (230) are not executable and are not counted.

## Report-row attribution

Command: poetry run python -I SCRATCH/jacoco_compare.py SCRATCH/ci-baseline-windows/powershell-coverage.xml SCRATCH/ci-final-windows/powershell-coverage.xml
EXIT_CODE: 0

```
DIFF D:/a/drm-copilot/drm-copilot/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 baseline=(162, 1) final=(165, 1)
DIFF D:/a/drm-copilot/drm-copilot/.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 baseline=(104, 0) final=(102, 2)
DIFF D:/a/drm-copilot/drm-copilot/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 baseline=(162, 1) final=(165, 1)
```

Tuples are (covered, missed). Only three files differ between the baseline and final reports. The two targets copies each gain 3 covered lines and no missed line. `WorktreeTargetResolution.psm1` loses 2 covered lines: line 116 (`throw "A target result with Status '$Status' requires a WorktreeRoot."`) and line 335 (`return $root`, the branch taken when the repo-relative path normalizes to null) are covered in the baseline run and uncovered in the final run (each `mi="1" ci="0"` in the final report; absent from the baseline missed set).

That module is unchanged between the baseline head (2fe0469956f4a3ce916e31350d5090bd1097b9d6) and HEAD: `git diff --quiet 2fe0469956f4a3ce916e31350d5090bd1097b9d6 HEAD -- .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` exits 0. No test file that this branch edits targets it (the three edited test files cover the targets module and the two epic-scope gates). The difference is therefore run-to-run variation in which test executions reach those two error paths, not an effect of this change. The specific cause of that variation was not investigated in this task and is unknown.

## Acceptance

| Condition | Observed | Result |
|---|---|---|
| All three values numeric for each row | yes | met |
| Both copies: `if` (228) and `return` (229) instrumented and covered | yes | met |
| Both copies: covered changed lines equal instrumented changed lines | 3 = 3 | met |
| No post-change value below its baseline | Report 90.41 < 90.42 | not met |

Task outcome: not met (one condition). Recorded as a deviation; P3-T12 is left unchecked in the plan.

PowerShell has no branch-coverage gate (Pester does not measure branch coverage).
