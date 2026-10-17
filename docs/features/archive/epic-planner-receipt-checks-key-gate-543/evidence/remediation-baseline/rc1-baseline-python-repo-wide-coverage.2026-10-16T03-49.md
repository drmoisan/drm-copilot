# Remediation Cycle 1 Baseline Python Repository-Wide Coverage (P0-T14)

Timestamp: 2026-10-16T03-49
Command: awk '<lcov-totals.awk program>' artifacts/python/lcov.info; awk -v target=_epic_orchestrator_state_launch_binding.py '<lcov-file.awk program>' artifacts/python/lcov.info; awk -v target=_epic_orchestrator_state_launch_binding.py '<lcov-zero-lines.awk program>' artifacts/python/lcov.info > SCRATCH/rc1/py-lb-zero-lines-baseline.txt (helper program text passed inline; the guard refuses awk -f)
EXIT_CODE: 0
Output Summary:
- FILES=214 LH=16554 LF=17644 LINE_PCT=93.82 BRH=5616 BRF=6372 BRANCH_PCT=88.14
- Line 93.82 >= 85.00 (meets); branch 88.14 >= 75.00 (meets).
- MATCHED=1 SF:scripts\dev_tools\_epic_orchestrator_state_launch_binding.py LH=116 LF=119 LINE_PCT=97.48 BRH=53 BRF=56 BRANCH_PCT=94.64
- SCRATCH/rc1/py-lb-zero-lines-baseline.txt: 188, 227, 296
- The launch-binding module meets 85.00 line and 75.00 branch; the plan continues.
