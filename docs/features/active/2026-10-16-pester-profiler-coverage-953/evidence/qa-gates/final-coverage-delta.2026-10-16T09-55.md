# Final Local Coverage Delta (issue #953, P6-T4, post-split restart pass)

Timestamp: 2026-10-16T09-55
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; ...CRP steps 1-7 applied to SCRATCH/issue-953-baseline-coverage.xml and SCRATCH/issue-953-final-coverage.xml; L(key, nr) lookups on the final file; per-file LINE counters for both changed keys...' (script SCRATCH/issue-953-p6-t4.sh, run with sh)
EXIT_CODE: 0
Output Summary: Baseline LINE 16387/18116 = 90.46% (breakpoint mode); final LINE 16647/18116 = 91.89% (profiler mode, FULL_RUN started 2026-10-16T09:39:03.7871724Z). LINE_TOTAL equal (18116 = 18116); SOURCEFILE_COUNT 203 in both, 0 keys missing, 0 keys added, 0 per-file totals differ. Final 85% threshold PASS. Every listed changed line is present in the final file with ci > 0. Per-file: scripts/powershell/poshqc/poshqc.psm1 40/60 = 66.67% -> 53/60 = 88.33% (PASS); scripts/powershell/poshqc/poshqc.testing.psm1 200/200 = 100% -> 187/200 = 93.5% (PASS; totals unchanged, the covered-count change reflects profiler-mode attribution). The bundled copy (extensions/drm-copilot/resources/...) is outside COVERAGE_ROOTS and is not measured. The runsettings .psd1 files are not in the coverage population (only .ps1 and .psm1 files are measured).

BASELINE_LINE_COVERED: 16387
BASELINE_LINE_TOTAL: 18116
BASELINE_LINE_PERCENT: 90.46
FINAL_LINE_COVERED: 16647
FINAL_LINE_TOTAL: 18116
FINAL_LINE_PERCENT: 91.89
LINE_TOTAL_EQUAL: YES
FINAL_THRESHOLD_85: PASS

## Changed-line values (final file, post-P3 line numbers)

- L('scripts/powershell/poshqc/poshqc.psm1', 55): ci=1 mi=0
- L('scripts/powershell/poshqc/poshqc.psm1', 56): ci=3 mi=0
- L('scripts/powershell/poshqc/poshqc.psm1', 58): ci=3 mi=0
- L('scripts/powershell/poshqc/poshqc.psm1', 62): ci=5 mi=0
- L('scripts/powershell/poshqc/poshqc.psm1', 75): ci=5 mi=0
- L('scripts/powershell/poshqc/poshqc.testing.psm1', 169): ci=1 mi=0
- L('scripts/powershell/poshqc/poshqc.testing.psm1', 306): ci=1 mi=0

## CHANGED_FILE_LINE_PERCENT

| Key | Baseline covered/missed | Baseline % | Final covered/missed | Final % | Final 85% |
|---|---|---|---|---|---|
| scripts/powershell/poshqc/poshqc.psm1 | 40/20 | 66.67 | 53/7 | 88.33 | PASS |
| scripts/powershell/poshqc/poshqc.testing.psm1 | 200/0 | 100.00 | 187/13 | 93.50 | PASS |
