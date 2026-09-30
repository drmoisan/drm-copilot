Timestamp: 2026-09-30T12-03
Command: derivation from evidence/remediation-baseline/pytest-full-suite-coverage-baseline.2026-09-30T12-02.md (P0-T13) and evidence/remediation-baseline/lcov-sums-baseline.2026-09-30T12-02.md (P0-T14)
EXIT_CODE: 0
Output Summary:
- Raw integers (LCOV sums): LF 16937, LH 15811, BRF 6106, BRH 5270.
- TOTAL row (P0-T13): Stmts 16937, Miss 1126, Branch 6106, BrPart 584, Cover 91%.
- Line percentage = 100 * 15811 / 16937 = 93.35%.
- Branch percentage = 100 * 5270 / 6106 = 86.31%.
- Cross-check: 100 * (15811 + 5270) / (16937 + 6106) = 100 * 21081 / 23043 = 91.49%, rounds to 91, equal to the TOTAL Cover of 91% (pass).
- Scope: coverage source is `src` plus `scripts.dev_tools` per pyproject.toml; `src` holds no Python module.
- This replaces the single-module figure (line 70.0%, branch 21.43%) that the audit reported as the only coverage artifact; that figure covers scripts\dev_tools\compute_blast_radius.py alone.
LINE-VERDICT: MET
BRANCH-VERDICT: MET
