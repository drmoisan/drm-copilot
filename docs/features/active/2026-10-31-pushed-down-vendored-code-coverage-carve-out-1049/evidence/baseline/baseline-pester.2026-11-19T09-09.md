# Baseline - Pester Phase 0 baseline - [P0-T6]

Timestamp: 2026-11-19T09-09
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (Invoke-PesterSuite.ps1 imports scripts/powershell/PoshQC/PoshQC.psd1 and runs one branch-current Invoke-PoshQCParallelTest -Root . with coverage, integration and golden lanes excluded); counts and coverage read by sh SCRATCH/issue-1049-pester-report.sh from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 714.09s); source MERGED. JUnit: 857 suites, 29212 tests, 29194 passed, 0 failed, 0 errors, 18 skipped. Pre-existing failing set: empty. Repo-wide line coverage 96.77% (47184 covered, 1575 missed). Per-file line coverage below.

## Per-file line coverage (Phase 0 baseline)

| File | Covered | Missed | Line % | Uncovered lines |
| --- | --- | --- | --- | --- |
| scripts/powershell/PoshQC/PoshQC.Coverage.psm1 | 104 | 6 | 94.55 | 75, 96, 163, 256, 257, 258 |
| scripts/powershell/PoshQC/PoshQC.Testing.psm1 | 210 | 13 | 94.17 | 94, 95, 98, 99, 103, 104, 105, 275, 284, 322, 323, 324, 326 |
| scripts/powershell/PoshQC/PoshQC.psm1 | 54 | 7 | 88.52 | 20, 21, 22, 23, 24, 25, 136 |
| scripts/powershell/PoshQC/PoshQC.VendoredCoverage.psm1 | - | - | - | not present (new file; judged against the threshold) |
