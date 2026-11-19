# Phase 0 Baseline: Pester (P0-T4)

Timestamp: 2026-11-19T08-55
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest, 8 workers, integration and golden lanes excluded by the launcher); counts from artifacts/pester/pester-junit.xml, line coverage from artifacts/pester/powershell-coverage.xml (copies kept as SCRATCH/baseline-pester-junit.xml and SCRATCH/baseline-powershell-coverage.xml)
EXIT_CODE: 0
Output Summary: 29212 tests, 0 failures, 0 errors, 18 skipped; Invoke-PoshQCParallelTest exit code 0, wall-clock 697.75s. Repo-wide line coverage 96.77% (47184 covered, 1575 missed). In-scope file `scripts/ci/Set-CiRequiredChecks.ps1` does not exist yet (new file, judged against the 85% threshold at the final gate).

Queue timeout: the first launcher run exited 75 (`TEST_EXECUTION_QUEUE_TIMEOUT:`; the machine test-suite lock was held by a pester suite of another worktree). It was re-run after the holder finished; the run recorded above is the re-run.
