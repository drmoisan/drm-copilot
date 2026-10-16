# Remediation Cycle 1 Baseline Python Per-File Coverage (P0-T12)

Timestamp: 2026-10-16T03-47
Command: awk -v target=validate_epic_planner_state.py '<lcov-file.awk program>' artifacts/python/lcov.info; awk -v target=validate_epic_planner_state.py '<lcov-zero-lines.awk program>' artifacts/python/lcov.info > SCRATCH/rc1/py-zero-lines-baseline.txt; awk -v target=epic_planner_git_integrity.py '<lcov-file.awk program>' artifacts/python/lcov.info; awk -v target=epic_planner_git_integrity.py '<lcov-zero-lines.awk program>' artifacts/python/lcov.info > SCRATCH/rc1/py-git-zero-lines-baseline.txt (helper program text passed inline; the guard refuses awk -f)
EXIT_CODE: 0
Output Summary:
- MATCHED=1 SF:scripts\dev_tools\validate_epic_planner_state.py LH=174 LF=188 LINE_PCT=92.55 BRH=86 BRF=100 BRANCH_PCT=86.00
- MATCHED=1 SF:scripts\dev_tools\epic_planner_git_integrity.py LH=131 LF=133 LINE_PCT=98.50 BRH=76 BRF=78 BRANCH_PCT=97.44
- SCRATCH/rc1/py-zero-lines-baseline.txt: 121, 127, 143, 144, 149, 150, 152, 154, 156, 189, 271, 280, 282, 346
- SCRATCH/rc1/py-git-zero-lines-baseline.txt: 220, 259
- Both modules meet 85.00 line and 75.00 branch; the plan continues.
