# Pester Gate Baseline (P0-T3, Phase 0 baseline)

Timestamp: 2026-11-16T01-17
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (launcher pester suite: Invoke-PoshQCParallelTest over config/poshqc-scan.json test.scanFolders with coverage, integration and golden lanes excluded), run through SCRATCH/issue-1025-pester-retry.sh; counts and coverage read by SCRATCH/issue-1025-pester-read.ps1
EXIT_CODE: 0
Output Summary: run 2026-11-16T01-04 to 2026-11-16T01-16 (8 workers, wall-clock 671.07 s); a first attempt at 2026-11-16T00-59 exited 75 (queue timeout: the machine test-suite lock was held by another worktree's pester suite) and was re-run after the holder finished; this is a queue timeout, not a failure. Returned ExitCode 0. Passed 27319, failed 0, skipped 18. Failing test files: none. Repo-wide line coverage 96.04% (44785 covered, 1846 missed). Coverage source: merged artifacts/pester/powershell-coverage.xml (run ExitCode 0). scripts/harness: absent (0 files).

Failing test files: (none)
