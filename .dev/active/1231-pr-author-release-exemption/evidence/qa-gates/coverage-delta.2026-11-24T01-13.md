# Coverage Delta (issue #1231)

Timestamp: 2026-11-24T01-13
Command: pwsh -NoProfile -File SCRATCH/issue-1231-coverage-delta.ps1 -Baseline SCRATCH/issue-1231-p0-coverage.xml -Current SCRATCH/issue-1231-p4-coverage.xml (JaCoCo LINE counters; the baseline file is the copy of artifacts/pester/powershell-coverage.xml from the Phase 0 run, and the current file is the copy from the P4-T2 run)
EXIT_CODE: 0
Output Summary:

## Repo-wide line coverage
- Baseline (Phase 0): 47285 covered, 1542 missed, 96.84%.
- Post-change (P4-T2): 47435 covered, 1541 missed, 96.85%. No drop.

## New hook files (no pre-change run; judged against the 85% line threshold)
| File | Post-change | Missed lines |
|---|---|---|
| .claude/hooks/hook-release-pull-request-context.ps1 | 27/27, 100.00% | none |
| .claude/hooks/enforce-pr-author-skill.release.ps1 | 53/53, 100.00% | none |
| .claude/hooks/enforce-model-routing-receipt-release.ps1 | 28/28, 100.00% | none |
| .claude/hooks/enforce-orchestration-preimplementation-gate-release-receipt.ps1 | 24/24, 100.00% | none |

## Edited hook files (baseline compared with post-change)
| File | Baseline | Post-change | Change | Missed lines (post-change) |
|---|---|---|---|---|
| .claude/hooks/enforce-pr-author-skill.ps1 | 52/57, 91.23% | 52/57, 91.23% | 0.00 | 337, 361, 362, 363, 366 (entry-point tail; header-only change) |
| .claude/hooks/enforce-pr-author-skill.cleanup.ps1 | 63/64, 98.44% | 72/73, 98.63% | +0.19 | 80 (pre-existing `return [string[]]@()` in Get-PrAuthorCleanupSegmentToken) |
| .claude/hooks/enforce-model-routing-receipt.ps1 | 106/110, 96.36% | 112/116, 96.55% | +0.19 | 164, 437, 439, 441 (pre-existing `continue` and entry-point tail) |
| .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 173/179, 96.65% | 175/181, 96.69% | +0.04 | 153, 472, 496, 497, 498, 501 (pre-existing branch and entry-point tail) |

## Changed-line coverage
- New files: 132 of 132 executable lines covered (100%).
- Edited files: none of the missed lines lies in a changed hunk of `git diff -U0` against the index base (hunks at cleanup 56-62, 61, 223-267; model-routing 56-62, 88-89, 398, 412-417, 424; gate 43, 442, 444; pr-author header 46-53), so every changed executable line is covered (100%).

## Thresholds and verdict
- Each new hook file is at least 85% (all 100%); the new-code figure is also at or above 90%.
- No edited hook file and no repo-wide figure dropped.
- Every new behavior has a named test: hook-release-pull-request-context.Tests.ps1, enforce-orchestration-preimplementation-gate-release-receipt.Tests.ps1, enforce-pr-author-skill.Release.Tests.ps1, enforce-model-routing-receipt.Release.Tests.ps1, release-pull-request.Parity.Tests.ps1.
- PowerShell has no branch-coverage gate. Outcome: PASS (no value missing).
