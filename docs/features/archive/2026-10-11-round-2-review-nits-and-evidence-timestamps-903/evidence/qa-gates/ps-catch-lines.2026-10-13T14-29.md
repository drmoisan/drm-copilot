# #565 CR-6 catch lines (P12-T25, AC-26)

Timestamp: 2026-10-13T14-29
Command: poetry -C <worktree> run python -I artifacts/scratch-903/ps_cov_extract_903.py artifacts/scratch-903/ci-final2-903/powershell-coverage.xml lines
EXIT_CODE: 0
Output Summary: Nine catch-line rows recorded from the coverage XML of CI run 38410234897. Eight are covered (`ci` > 0); one is uncovered: `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:41` (`ci` 0, also 0 at baseline). That line is listed for P13-T1. Every value equals its P1-T4 baseline.

Source: https://github.com/drmoisan/drm-copilot/actions/runs/38410234897 (headSha 17a6497e4ca2b50baca1dc2510108d7128ded79a). Path substitution: the plan names `artifacts/scratch-903/ci-final-903`; this pass reads `artifacts/scratch-903/ci-final2-903/powershell-coverage.xml` (the iteration 1 run uploaded no Windows artifact).

Line identity check: `git diff --stat origin/main...HEAD` over the five non-modes catch-line files is empty (exit 0), so their line numbers are unchanged; line 41 of both `-modes.ps1` copies reads `$script:OrchestrationFeatureFolderResolutionImportFailure = 'feature-folder-resolution.ps1'` (the P7 edits do not shift it).

| # | File | Line | `ci` | State | P1-T4 baseline `ci` |
|---|---|---|---|---|---|
| 1 | .claude/hooks/enforce-epic-wave-barrier.ps1 | 61 | 1 | covered | 1 |
| 2 | .claude/hooks/enforce-epic-wave-barrier.ps1 | 62 | 1 | covered | 1 |
| 3 | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 75 | 1 | covered | 1 |
| 4 | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 76 | 1 | covered | 1 |
| 5 | .claude/hooks/enforce-parallel-drift-gate.ps1 | 86 | 2 | covered | 2 |
| 6 | .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 41 | 1 | covered | 1 |
| 7 | .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 41 | 0 | uncovered | 0 |
| 8 | .claude/hooks/enforce-feature-folder-order.ps1 | 51 | 1 | covered | 1 |
| 9 | .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 39 | 1 | covered | 1 |

Summary: 8 of 9 covered, 1 uncovered.

Lines with `ci` equal to 0, listed for P13-T1:

- `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:41`

Acceptance: PASS (nine rows recorded; the one uncovered line is listed for P13-T1).
