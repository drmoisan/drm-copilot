# Pester Gate [P2-T4] — remediation cycle 1

Timestamp: 2026-11-20T20-18
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest run through sh SCRATCH/issue-1016-g-pester.sh, final QA loop pass 2, head 520617870, with the [P0-T3] clean layout in place)
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest workers=8, wall-clock 691.25 s, ExitCode 0. From artifacts/pester/pester-junit.xml: tests 29157, failures 0, errors 0, disabled 22 (0 failed). `Get-StageTimingReport.ps1 entry.STR-ENTRY-PRINTS-LABELS-AND-FIXTURE-MEDIANS` status Passed. From artifacts/pester/powershell-coverage.xml: repo-wide line coverage 96.84% (47286/48827), at least 85% and equal to the Phase 0 baseline figure 96.84% (47286/48827) in baseline-citation.2026-11-20T19-13.md. The moved-root directories were absent before and after the run. The integration lane is excluded by the launcher and runs in CI.
Note: the four gate suites ran in the order Jest extension, root Jest, pytest, Pester within one driver pass; the artifacts are written in plan order where the runs had finished.
