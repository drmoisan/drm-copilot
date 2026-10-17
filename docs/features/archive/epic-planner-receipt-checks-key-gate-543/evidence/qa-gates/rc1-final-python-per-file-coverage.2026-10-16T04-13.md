# Remediation Cycle 1 Final Python Per-File and Changed-Line Coverage (P5-T6)

Timestamp: 2026-10-16T04-13
Loop iteration: 1
Command: awk -v target=validate_epic_planner_state.py '<lcov-file.awk program>' artifacts/python/lcov.info; awk -v target=validate_epic_planner_state.py '<lcov-zero-lines.awk program>' artifacts/python/lcov.info > SCRATCH/rc1/py-zero-lines-final.txt; git diff -U0 main -- scripts/dev_tools/validate_epic_planner_state.py > SCRATCH/rc1/py-changed.diff; awk '<diff-added-lines.awk program>' SCRATCH/rc1/py-changed.diff > SCRATCH/rc1/py-added-lines.txt; grep -c -x -F -f SCRATCH/rc1/py-zero-lines-final.txt SCRATCH/rc1/py-added-lines.txt; the same five steps for epic_planner_git_integrity.py into SCRATCH/rc1/py-git-zero-lines-final.txt, SCRATCH/rc1/py-git-changed.diff, SCRATCH/rc1/py-git-added-lines.txt (helper program text passed inline; the guard refuses awk -f)
EXIT_CODE: 0
Output Summary:
- MATCHED=1 SF:scripts\dev_tools\validate_epic_planner_state.py LH=180 LF=191 LINE_PCT=94.24 BRH=88 BRF=100 BRANCH_PCT=88.00 (meets 85.00 / 75.00)
- MATCHED=1 SF:scripts\dev_tools\epic_planner_git_integrity.py LH=150 LF=151 LINE_PCT=99.34 BRH=85 BRF=86 BRANCH_PCT=98.84 (meets 85.00 / 75.00)
- SCRATCH/rc1/py-zero-lines-final.txt: 121, 127, 151, 152, 154, 156, 158, 194, 277, 286, 356
- SCRATCH/rc1/py-added-lines.txt: 133-136, 141, 148, 159, 162-164, 167, 171, 186, 214, 227-276, 278, 291-297, 314-319, 337-338, 340-343, 360-363, 374, 377
- SCRATCH/rc1/py-git-zero-lines-final.txt: 295
- SCRATCH/rc1/py-git-added-lines.txt: 6, 167-211, 236-237
- Uncovered added validator lines: 0 (exit 1 by design)
- Uncovered added git-integrity lines: 0 (exit 1 by design)
- No added executable line on the branch is uncovered in either module. The git-integrity zero-hit line 295 is the pre-existing optional-plan-hash format message (baseline line 259), not an added line.
