# Remediation Cycle 3 Final Python Per-File Coverage (P5-T6)

Timestamp: 2026-10-16T08-39
Loop iteration: 1
Command: awk 'AWK_TOTALS' artifacts/python/lcov.info; for py-git / scripts/dev_tools/epic_planner_git_integrity.py and py-ready / scripts/dev_tools/epic_planner_readiness.py: awk -v target=<target> 'AWK_FILE' artifacts/python/lcov.info; awk -v target=<target> 'AWK_ZERO' artifacts/python/lcov.info > SCRATCH/rc3/<stem>-zero-final.txt; grep -c -e '.' SCRATCH/rc3/<stem>-zero-final.txt; git diff -U0 b6be46b5ec394f75f99e16bc861be0380d5f1cba -- <path> > SCRATCH/rc3/<stem>-changed.diff; awk 'AWK_ADDED' SCRATCH/rc3/<stem>-changed.diff > SCRATCH/rc3/<stem>-added.txt; sort -u SCRATCH/rc3/<stem>-zero-final.txt > SCRATCH/rc3/<stem>-zero-sorted.txt; sort -u SCRATCH/rc3/<stem>-added.txt > SCRATCH/rc3/<stem>-added-sorted.txt; comm -12 SCRATCH/rc3/<stem>-zero-sorted.txt SCRATCH/rc3/<stem>-added-sorted.txt > SCRATCH/rc3/<stem>-uncovered-added.txt; grep -c -e '.' SCRATCH/rc3/<stem>-uncovered-added.txt (MAIN_BASE_SHA substituted as b6be46b5ec394f75f99e16bc861be0380d5f1cba; program texts passed inline, verbatim; one invocation per stem)
EXIT_CODE: 0
Output Summary:
- FILES=214 LH=16606 LF=17664 LINE_PCT=94.01 BRH=5650 BRF=6378 BRANCH_PCT=88.59 (baseline P0-T11: 93.96 / 88.49; not lower)
- MATCHED=1 SF:scripts\dev_tools\epic_planner_git_integrity.py LH=159 LF=159 LINE_PCT=100.00 BRH=90 BRF=90 BRANCH_PCT=100.00
- MATCHED=1 SF:scripts\dev_tools\epic_planner_readiness.py LH=182 LF=182 LINE_PCT=100.00 BRH=80 BRF=86 BRANCH_PCT=93.02
- py-git zero-line count: 0
- py-ready zero-line count: 0 (CR-15 Python targets 113 114 202 203 207 215 218 219 238 all covered; no line recorded as unreachable)
- py-git added lines versus MAIN_BASE_SHA: 72; uncovered-added count: 0 (grep exit 1 by design)
- py-ready added lines versus MAIN_BASE_SHA: 7; uncovered-added count: 0 (grep exit 1 by design)
- Required thresholds met: both per-file LINE_PCT >= 85.00 and BRANCH_PCT >= 75.00; repository-wide >= 85.00 / 75.00 and not lower than P0-T11 by more than 0.10 points.
