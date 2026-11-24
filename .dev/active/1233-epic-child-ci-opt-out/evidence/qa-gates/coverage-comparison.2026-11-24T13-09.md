# Coverage comparison: final gates against the Phase 0 baseline (P5-T7)

Timestamp: 2026-11-24T13-09
Command: sh SCRATCH/issue-1233-covcompare.sh p5c-pester SCRATCH/p5c-py-coverage.json p5c-jest (reads the Phase 0 reports SCRATCH/issue-1233-p0-pester.coverage.xml, SCRATCH/p0-py-coverage.json, SCRATCH/issue-1233-p0-jest.coverage-summary.json and the final reports of final-qc-pester.2026-11-24T13-00.md, final-qc-pytest.2026-11-24T13-06.md, final-qc-jest.2026-11-24T13-09.md; changed lines come from `git diff -U0 <merge base of origin/main and HEAD>`)
EXIT_CODE: 0
Output Summary: every changed PowerShell file is at or above 85% line coverage, every changed Python and TypeScript file is at or above 85% line and 75% branch coverage, no per-file or repo-wide figure drops, the new TypeScript module meets its own threshold, changed-line coverage is at least 95.65% in every file, and no test fails.

## PowerShell (line coverage; Pester does not measure branches)

| File | Baseline | Final | Changed executable lines covered |
| --- | --- | --- | --- |
| .claude/hooks/enforce-epic-merge-gate-child-ci.ps1 | 83/83 (100%) | 158/158 (100%) | 77/77 (100%) |
| .codex/hooks/enforce-epic-merge-gate-child-ci.ps1 | 81/83 (97.59%) | 156/158 (98.73%) | 77/77 (100%) |
| .claude/hooks/enforce-epic-merge-gate.ps1 | 145/147 (98.64%) | 145/147 (98.64%) | 1/1 (100%) |
| .codex/hooks/enforce-epic-merge-gate.ps1 | 180/181 (99.45%) | 180/181 (99.45%) | 0/0 (comment-only change) |
| .claude/hooks/enforce-completion-helpers.ps1 | 62/67 (92.54%) | 84/90 (93.33%) | 22/23 (95.65%; line 196, the non-object `return $false` of `Test-CompletionChildCiIntegrationOnly`, runs only in the Codex helper suite, which loads the byte-identical .codex copy) |
| .codex/hooks/enforce-completion-helpers.ps1 | 67/67 (100%) | 90/90 (100%) | 23/23 (100%) |
| .claude/hooks/enforce-completion-consistency.ps1 | 153/160 (95.62%) | 155/161 (96.27%) | 4/4 (100%) |
| .codex/hooks/enforce-completion-consistency.ps1 | 163/163 (100%) | 164/164 (100%) | 4/4 (100%) |
| .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1 | 115/117 (98.29%) | 145/147 (98.64%) | 31/31 (100%) |
| Repo-wide | 96.85% | 96.87% | - |

## Python

| File | Baseline | Final | Changed statements covered |
| --- | --- | --- | --- |
| scripts/dev_tools/validate_orchestrator_state.py | lines 170/172 (98.84%), branches 80/82 (97.56%) | lines 209/210 (99.52%), branches 99/100 (99%) | 39/39 (100%) |
| Repo-wide | lines 98.01%, branches 95.47% | lines 98.02%, branches 95.48% | - |

## TypeScript

| File | Baseline | Final | Changed lines covered |
| --- | --- | --- | --- |
| src/lib/validate/orchestrator-state-core.ts | lines 456/461 (98.91%), branches 77/80 (96.25%) | lines 456/461 (98.91%), branches 77/80 (96.25%) | 2/2 (100%) |
| src/lib/validate/orchestrator-state-child-ci.ts (new; judged against its 85/75 threshold) | no pre-change run | lines 146/146 (100%), branches 28/28 (100%) | 146/146 (100%) |
| Repo-wide | lines 97.59%, branches 94.96% | lines 97.59%, branches 94.98% | - |

## Tests

No new failing test: Pester 29521 tests, 0 failures (baseline 29292, 0 failures); pytest 17126 passed, 0 failed (baseline 17104); Jest 6730 passed, 0 failed (baseline 6707).

One earlier shortfall (validate_orchestrator_state.py at 98.57% / 97%) was remediated and P5-T1 to P5-T6 were re-run (final-qa-remediation.2026-11-24T12-54.md).
