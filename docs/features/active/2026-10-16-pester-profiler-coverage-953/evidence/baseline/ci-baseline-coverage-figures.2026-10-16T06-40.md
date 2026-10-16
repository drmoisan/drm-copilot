# CI Baseline Coverage Figures (P0-T5)

Timestamp: 2026-10-16T06-40
Command: sh SCRATCH/issue-953-crp.sh SCRATCH/issue-953-baseline-artifact/powershell-coverage.xml SCRATCH/issue-953-baseline-artifact/pester-junit.xml (pwsh -NoProfile -Command applying the plan CRP steps 1-7 and JRP step 2 verbatim: report-level LINE counter, anchor-derived root prefix, per-file map with duplicate and sum cross-checks, line lookup L(key, nr))
EXIT_CODE: 0
Output Summary: Every CRP step passed (one aggregate LINE counter; one anchor package; no duplicate key; per-file sums equal the aggregate). Repo-wide LINE 16417/18154 = 90.43% (85% threshold PASS). JUnit 10407 tests, 0 failures, 0 errors. scripts/powershell/poshqc/poshqc.psm1 covered 40, missed 20.

LINE_COVERED: 16417
LINE_MISSED: 1737
LINE_TOTAL: 18154
LINE_PERCENT: 90.43
SOURCEFILE_COUNT: 203
JUNIT_TESTS: 10407
JUNIT_FAILURES: 0
L('.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', 41): ci=0 mi=1
L('.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1', 206): ci=0 mi=1
L('.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1', 207): ci=0 mi=1
POSHQC_PSM1_BASELINE: covered=40 missed=20
