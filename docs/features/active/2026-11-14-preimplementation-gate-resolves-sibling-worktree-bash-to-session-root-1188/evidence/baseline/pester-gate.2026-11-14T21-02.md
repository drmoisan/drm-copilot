# Pester gate - Phase 0 baseline (P0-T2)

Timestamp: 2026-11-14T20-49
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest, 8 workers, wall-clock 754.98 s, ExitCode 0. JUnit (artifacts/pester/pester-junit.xml): 26522 tests, 0 failures, 0 errors, 22 disabled/skipped. Repo-wide line coverage 95.96% (43686 covered, 1839 missed). Per-file line coverage: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 97.73% (129/132); .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 98.01% (148/151).

Queue timeout (recorded, not a failure): the first attempt at 2026-11-14T20-46 exited 75 with `TEST_EXECUTION_QUEUE_TIMEOUT:` because the machine test-suite lock was held by the `pester` suite of the concurrent #1187 worktree. The gate was re-run after the holder finished; the run above is the re-run.

Readers: counts from the merged `artifacts/pester/pester-junit.xml`; coverage from the merged `artifacts/pester/powershell-coverage.xml` (JaCoCo `LINE` counters), read with SCRATCH/issue-1188-read-gate.ps1. A copy of both files is kept under SCRATCH for the P4-T4 comparison.

Per-shard summaries (shard logs under artifacts/pester/parallel/): shard 1 596 passed; shard 2 2553 passed, 2 skipped; shard 3 4436 passed, 2 skipped, 1 not run; shard 4 3605 passed; shard 6 4222 passed, 8 skipped, 3 not run; shard 7 3142 passed; shard 8 3270 passed; every shard exited 0 with 0 failed.
