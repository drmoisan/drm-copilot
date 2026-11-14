# Coverage comparison (P5-T9)

Timestamp: 2026-11-14T07-02
Command: comparison of the Phase 0 baseline artifacts (evidence/baseline/pester.2026-11-11T04-32.md, pytest.2026-11-10T03-31.md, jest.2026-11-10T03-35.md) with the final gate artifacts (evidence/qa-gates/pester.2026-11-14T06-55.md, pytest.2026-11-14T06-59.md, jest.2026-11-14T07-01.md); new-code figures from intersecting `git diff -U0` added-line ranges (merge base of origin/main and HEAD) with the missed lines of artifacts/pester/powershell-coverage.xml, SCRATCH/issue-1162-cov-final.json (missing_lines, missing_branches), and SCRATCH/issue-1162-jest-lcov-final.info (DA with 0 hits)
EXIT_CODE: 0
Output Summary: no new failing test in any gate; no repository-wide or per-file coverage drop; every new file meets the thresholds; every added line in a changed file is covered. Verdict: PASS.

## Test counts

| Gate | Phase 0 baseline | Final | New failures |
|---|---|---|---|
| Pester | 21311 tests, 0 failed, 10 disabled | 24321 tests, 0 failed, 10 disabled | 0 |
| pytest | 16598 passed, 0 failed, 6 skipped | 16815 passed, 0 failed, 6 skipped | 0 |
| Jest | 5476 passed, 0 failed (340 suites) | 5624 passed, 0 failed (343 suites) | 0 |

## Repository-wide

| Language | Baseline | Final | Verdict |
|---|---|---|---|
| PowerShell line | 95.80% | 95.97% | no drop |
| Python line / branch (scripts.dev_tools) | 94.83% / 90.20% | 94.93% / 90.46% | no drop |
| TypeScript line / branch | 97.15% / 93.87% | 97.18% / 94.00% | no drop |

## Per file

| File | Baseline | Final | New-code | Threshold verdict |
|---|---|---|---|---|
| .claude/lib/epic-wave/EpicCrossDependency.psm1 (new) | no pre-change run | 98.03% line | 98.03% (whole file is new) | PASS (>= 85%) |
| .claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1 (new) | no pre-change run | 100.00% line | 100.00% | PASS |
| .claude/lib/orchestrator-state/OrchestratorStateEpicCrossDependency.psm1 (new) | no pre-change run | 100.00% line | 100.00% | PASS |
| .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.CrossEpic.ps1 (new) | no pre-change run | 100.00% line | 100.00% | PASS |
| .claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1 | 100.00% | 100.00% | 100.00% | PASS, no drop |
| .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 | 96.40% | 96.49% | 100.00% (added lines 503-507 covered; missed lines 204, 218, 232, 314 predate this item) | PASS, no drop |
| Get-EpicProgressReport.Logic.ps1 / Schedule.ps1 / CriticalPath.ps1 / Render.ps1 | 100.00% each | 100.00% each | 100.00% | PASS, no drop |
| scripts/dev_tools/_epic_orchestrator_state_resolution.py | 100.00% / 100.00% | 100.00% / 100.00% | 100.00% | PASS, no drop |
| scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py | 100.00% / 100.00% | 100.00% / 100.00% | 100.00% | PASS, no drop |
| scripts/dev_tools/validate_epic_orchestrator_state.py | 98.44% / 96.77% | 98.46% / 96.77% | 100.00% (missed lines 280, 285 and branches 279->280, 284->285 lie outside added lines 27-28, 343-345, 404-405) | PASS, no drop |
| scripts/dev_tools/validate_epic_planner_state.py | 100.00% / 99.00% | 100.00% / 99.21% | 100.00% (missed branch 177->181 lies outside added lines 15, 440-441) | PASS, no drop |
| extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-resolution.ts | 97.91% / 93.85% | 98.85% / 96.99% | 100.00% (missed lines 54-63 lie outside added lines 288-520) | PASS, no drop |
| extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts | 100.00% / 96.10% | 100.00% / 96.15% | 100.00% line | PASS, no drop |
| extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-wave-barrier.ts | 100.00% / 98.08% | 100.00% / 98.55% | 100.00% line | PASS, no drop |
| extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts | 100.00% / 96.85% | 100.00% / 96.97% | 100.00% line | PASS, no drop |

PowerShell has no branch figure (Pester measures line coverage only). Every value is numeric; no value is missing.
