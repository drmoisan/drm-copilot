# Coverage delta against the Phase 0 baseline ([P7-T2])

Timestamp: 2026-11-18T01-46
Command: comparison of `evidence/qa-gates/pester-parallel.2026-11-18T01-46.md`, `pytest-parallel.2026-11-18T01-46.md` and `jest-coverage.2026-11-18T01-46.md` with `evidence/baseline/pester-parallel.2026-11-17T18-50.md`, `pytest-parallel.2026-11-17T18-50.md` and `jest-coverage.2026-11-17T18-50.md`
EXIT_CODE: 0
Output Summary:
- **Failures.** No new failing test: all three gates report 0 failures, as at Phase 0.
- **Repository totals.** No repository-wide total dropped: Pester line, pytest line and branch, and Jest line and branch all rose.
- **Converter files.** Every changed TypeScript and Python converter file is at or above 85% line and 75% branch, and none is below its Phase 0 figure.
- **New PowerShell files.** Each of the seven new PowerShell files is at or above 85% line coverage.

## Repository totals

| Gate | Phase 0 | Final | Delta |
| --- | --- | --- | --- |
| Pester tests passed | 28109 | 28292 | +183 |
| Pester line coverage | 96.69% | 96.73% | +0.04 |
| pytest tests passed | 17111 | 17122 | +11 |
| pytest line coverage | 97.98% | 98.00% | +0.02 |
| pytest branch coverage | 95.39% | 95.46% | +0.07 |
| Jest tests passed | 5881 | 5895 | +14 |
| Jest line coverage | 97.25% | 97.29% | +0.04 |
| Jest branch coverage | 94.20% | 94.31% | +0.11 |

## Converter files (line / branch)

| File | Phase 0 | Final |
| --- | --- | --- |
| `mapping.ts` | 99.19 / 95.12 | 99.24 / 95.12 |
| `engine-pipeline.ts` | 98.01 / 84.78 | 99.29 / 90.24 |
| `pipeline.ts` | 100.00 / 100.00 | 100.00 / 100.00 |
| `pipeline-render.ts` | 93.80 / 77.78 | 100.00 / 96.00 |
| `validation.ts` | 99.46 / 92.59 | 100.00 / 94.23 |
| `mapping.py` | 96.36 / 92.31 | 96.43 / 92.31 |
| `engine.py` | 97.03 / 91.18 | 98.97 / 96.88 |
| `pipeline.py` | 95.74 / 88.64 | 98.77 / 95.00 |
| `validation.py` | 96.61 / 93.75 | 98.28 / 96.88 |

## New PowerShell files (line; no Phase 0 figure, as the files are new)

`HarnessGeneration.psm1` 100.00%, `HarnessMcpConfig.psm1` 100.00%, `HarnessInstructions.psm1` 100.00%, `HarnessSkillMirror.psm1` 100.00%, `HarnessRuleGeneration.psm1` 100.00%, `HarnessAgentGeneration.psm1` 100.00% and `Invoke-HarnessGeneration.ps1` 86.67%.
