# P3-T12 Coverage delta

Timestamp: 2026-10-09T20-26
Command: Read of evidence/baseline/p0-python-pytest-coverage.md (P0-T11), evidence/baseline/p0-ts-jest-coverage.md (P0-T17), evidence/qa-gates/final-python-pytest-coverage.md (P3-T4), evidence/qa-gates/final-ts-jest-coverage.md (P3-T10), evidence/qa-gates/changed-lines-coverage.md (P3-T11)
EXIT_CODE: 0
Output Summary: All comparisons PASS.

Python, scripts.dev_tools.validate_epic_orchestrator_state:

| Metric | Baseline (P0-T11) | Post-change (P3-T4) |
|---|---|---|
| Line percent (LH/LF) | 85.04 (108/127) | 93.75 (120/128) |
| Branch percent (BRH/BRF) | 75.81 (47/62) | 87.10 (54/62) |
| Terminal Cover | 82% | 92% |

TypeScript, src/lib/validate/epic-orchestrator-state-core.ts (no production change):

| Metric | Baseline (P0-T17) | Post-change (P3-T10) |
|---|---|---|
| Line percent (LH/LF) | 97.96 (481/491) | 97.96 (481/491) |
| Branch percent (BRH/BRF) | 91.11 (82/90) | 91.21 (83/91) |

Changed-code coverage (P3-T11): lines 238-240 and 323-324 are all executed and every branch arc sourced at them is taken; none appears in the Missing column.

Comparisons:
- Python post-change line percent at least 85: PASS (93.75)
- Python post-change branch percent at least 75: PASS (87.10)
- Python post-change line percent at least baseline: PASS (93.75 >= 85.04)
- Python post-change branch percent at least baseline: PASS (87.10 >= 75.81)
- Python changed-code coverage: PASS
- TypeScript post-change line percent at least baseline: PASS (97.96 >= 97.96)
- TypeScript post-change branch percent at least baseline: PASS (91.21 >= 91.11)
