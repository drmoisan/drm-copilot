# CI Coverage Comparison (P7-T7, AC-08)

Timestamp: 2026-10-16T10-54
Command: sh SCRATCH/issue-953-compare.sh SCRATCH/issue-953-baseline-artifact-reselected/powershell-coverage.xml SCRATCH/issue-953-prhead-artifact/powershell-coverage.xml SCRATCH/issue-953-prhead-artifact/pester-junit.xml
EXIT_CODE: 0
Output Summary: Comparison baseline run 38885440106 (main at PR merge base, breakpoint mode) vs PR-head run 38887178530 (profiler mode). LINE totals equal (18170 = 18170); 0 baseline sourcefiles absent from the PR head; 0 sourcefiles added; 0 per-file totals differ. PR-head LINE 91.9% (baseline 90.45%). PRHEAD_FILE: scripts/powershell/poshqc/poshqc.psm1 covered=53 missed=7 pct=88.33 FILE_85=PASS PRHEAD_FILE: scripts/powershell/poshqc/poshqc.testing.psm1 covered=187 missed=13 pct=93.5 FILE_85=PASS 

BASELINE_LINE_TOTAL: 18170
PRHEAD_LINE_TOTAL: 18170
TOTAL_EQUAL: YES
MISSING_IN_PRHEAD: 0
PRHEAD_LINE_PERCENT: 91.9
THRESHOLD_85: PASS
PRHEAD_POSHQC_PSM1_FILE_85: PASS
