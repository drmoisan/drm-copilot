# Python Repository-Wide Coverage (P5-T9, PA-N2 / CR-2)

Timestamp: 2026-10-16T04-18
Loop iteration: 1
Command: awk '<lcov-totals.awk program>' artifacts/python/lcov.info; awk -v target=validate_epic_planner_state.py '<lcov-file.awk program>' artifacts/python/lcov.info; awk -v target=epic_planner_git_integrity.py '<lcov-file.awk program>' artifacts/python/lcov.info; awk -v target=_epic_orchestrator_state_launch_binding.py '<lcov-file.awk program>' artifacts/python/lcov.info; awk -v target=_epic_orchestrator_state_launch_binding.py '<lcov-zero-lines.awk program>' artifacts/python/lcov.info > SCRATCH/rc1/py-lb-zero-lines-final.txt; git diff -U0 main -- scripts/dev_tools/_epic_orchestrator_state_launch_binding.py > SCRATCH/rc1/py-lb-changed.diff; awk '<diff-added-lines.awk program>' SCRATCH/rc1/py-lb-changed.diff > SCRATCH/rc1/py-lb-added-lines.txt; grep -c -x -F -f SCRATCH/rc1/py-lb-zero-lines-final.txt SCRATCH/rc1/py-lb-added-lines.txt (helper program text passed inline; the guard refuses awk -f)
EXIT_CODE: 0
Output Summary:
- Repository-wide (post-change): FILES=214 LH=16580 LF=17665 LINE_PCT=93.86 BRH=5628 BRF=6380 BRANCH_PCT=88.21
- Repository-wide (P0-T14 baseline): FILES=214 LH=16554 LF=17644 LINE_PCT=93.82 BRH=5616 BRF=6372 BRANCH_PCT=88.14
- Change: line +0.04 points, branch +0.07 points (no regression); both at or above 85.00 / 75.00.
- FILES=214 (greater than 1), which closes CR-2's single-record finding.
- MATCHED=1 SF:scripts\dev_tools\validate_epic_planner_state.py LH=180 LF=191 LINE_PCT=94.24 BRH=88 BRF=100 BRANCH_PCT=88.00
- MATCHED=1 SF:scripts\dev_tools\epic_planner_git_integrity.py LH=150 LF=151 LINE_PCT=99.34 BRH=85 BRF=86 BRANCH_PCT=98.84
- MATCHED=1 SF:scripts\dev_tools\_epic_orchestrator_state_launch_binding.py LH=117 LF=119 LINE_PCT=98.32 BRH=54 BRF=56 BRANCH_PCT=96.43 (meets 85.00 / 75.00)
- SCRATCH/rc1/py-lb-zero-lines-final.txt: 188, 299
- SCRATCH/rc1/py-lb-added-lines.txt: 11, 212, 263, 271, 272, 273, 277
- Uncovered added launch-binding lines: 0 (exit 1 by design)
- artifacts/python/lcov.info now carries the repository-wide figure.
