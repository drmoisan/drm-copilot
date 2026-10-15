# Coverage Comparison (Issue #464)

Timestamp: 2026-09-30T09-52
Command: none (comparison of recorded artifacts)
EXIT_CODE: 0
Output Summary:
- Baseline `TOTAL` Cover: 91% (Stmts 16937, Miss 1126, Branch 6106, BrPart 584), from `evidence/baseline/pytest-dev-tools-baseline.md`.
- Post-change `TOTAL` Cover: 92% (Stmts 16974, Miss 1127, Branch 6110, BrPart 583), from `evidence/qa-gates/pytest-dev-tools-after.md`.
- Result: 92% is not below 91%; no coverage decrease.
- New-module ratios from P8-T8 (`evidence/qa-gates/coverage-new-modules.md`):
  - `scripts/dev_tools/validate_orchestrator_state_cli.py`: line 32/33 = 0.9697; branch 4/4 = 1.0000.
  - `scripts/dev_tools/_orchestrator_state_remediation_loop.py`: line 35/36 = 0.9722; branch 14/16 = 0.8750.
- Thresholds (line >= 0.85, branch >= 0.75) are met by both new modules.
