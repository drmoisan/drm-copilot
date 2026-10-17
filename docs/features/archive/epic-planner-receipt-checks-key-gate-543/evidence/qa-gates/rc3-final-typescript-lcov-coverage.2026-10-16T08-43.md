# Remediation Cycle 3 Final TypeScript Lcov Coverage (P6-T6)

Timestamp: 2026-10-16T08-43
Loop iteration: 1
Command: awk 'AWK_TOTALS' extensions/drm-copilot/coverage/lcov.info; for ts-git / extensions/drm-copilot/src/lib/validate/epic-planner-git-integrity.ts and ts-ready / extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts: awk -v target=<target> 'AWK_FILE' extensions/drm-copilot/coverage/lcov.info; awk -v target=<target> 'AWK_ZERO' extensions/drm-copilot/coverage/lcov.info > SCRATCH/rc3/<stem>-zero-final.txt; grep -c -e '.' SCRATCH/rc3/<stem>-zero-final.txt; git diff -U0 b6be46b5ec394f75f99e16bc861be0380d5f1cba -- <path> > SCRATCH/rc3/<stem>-changed.diff; awk 'AWK_ADDED' SCRATCH/rc3/<stem>-changed.diff > SCRATCH/rc3/<stem>-added.txt; sort -u (zero and added); comm -12 SCRATCH/rc3/<stem>-zero-sorted.txt SCRATCH/rc3/<stem>-added-sorted.txt > SCRATCH/rc3/<stem>-uncovered-added.txt; grep -c -e '.' SCRATCH/rc3/<stem>-uncovered-added.txt (MAIN_BASE_SHA substituted; program texts inline, verbatim; one invocation per stem)
EXIT_CODE: 0
Output Summary:
- FILES=212 LH=51296 LF=52679 LINE_PCT=97.37 BRH=7649 BRF=8262 BRANCH_PCT=92.58 (baseline P0-T17: 97.33 / 92.49; not lower)
- MATCHED=1 SF:src\lib\validate\epic-planner-git-integrity.ts LH=369 LF=369 LINE_PCT=100.00 BRH=112 BRF=115 BRANCH_PCT=97.39 (baseline 100.00 / 97.35)
- MATCHED=1 SF:src\lib\validate\epic-planner-readiness-integrity.ts LH=350 LF=350 LINE_PCT=100.00 BRH=75 BRF=77 BRANCH_PCT=97.40 (baseline 93.43 / 88.41)
- ts-git zero-line count: 0
- ts-ready zero-line count: 0 (CR-15 TypeScript targets 45-50, 157-163, 172-173, 177-178, 204-207, 318-319 all covered; no line recorded as unreachable)
- ts-git added lines versus MAIN_BASE_SHA: 83; uncovered-added count: 0 (grep exit 1 by design)
- ts-ready added lines versus MAIN_BASE_SHA: 9; uncovered-added count: 0 (grep exit 1 by design)
- Python repository-wide: FILES=214 LH=16606 LF=17664 LINE_PCT=94.01 BRH=5650 BRF=6378 BRANCH_PCT=88.59 (from rc3-final-python-per-file-coverage.2026-10-16T08-39.md)
- Note: BRF for epic-planner-git-integrity.ts rose from 113 to 115 and for epic-planner-readiness-integrity.ts from 69 to 77 although only one parameter was renamed in the former and the latter was not edited; Jest's per-file branch records grew with the new tests reaching additional branch points. Both branch percentages rose or held, so the threshold and no-regression conclusions are unchanged.
- Required thresholds met: both per-file LINE_PCT >= 85.00 and BRANCH_PCT >= 75.00; repository-wide not lower than P0-T17 by more than 0.10 points.
