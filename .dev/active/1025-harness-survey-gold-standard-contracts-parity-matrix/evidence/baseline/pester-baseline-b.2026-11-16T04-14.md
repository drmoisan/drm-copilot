# Pester Gate Baseline, Plan B (P0-T2, Phase 0 baseline)

Timestamp: 2026-11-16T04-14
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (launcher pester suite: Invoke-PoshQCParallelTest over config/poshqc-scan.json test.scanFolders with coverage, integration and golden lanes excluded), run through SCRATCH/issue-1025-pester-retry.sh; counts and coverage read by SCRATCH/issue-1025-pester-read.ps1
EXIT_CODE: 0
Output Summary: run started 2026-11-16T04-02 and ended 2026-11-16T04-14 (8 workers, wall-clock 655.85 s); two earlier attempts exited 75 (queue timeout: the machine test-suite lock was held by another suite) and were re-run after the holder finished; these are queue timeouts, not failures. Returned ExitCode 0. Passed 27468, failed 0, skipped 18. Failing test files: none. Repo-wide line coverage 96.07% (45204 covered, 1847 missed). Coverage source: merged artifacts/pester/powershell-coverage.xml (run ExitCode 0). Line coverage: scripts/harness/HarnessInventory.psm1 100.00%, scripts/harness/HarnessParityMatrix.psm1 99.25%, scripts/harness/HarnessSkillContract.psm1 100.00%. The It `reports zero ratchet violations against config/file-size-baseline.json` passed.

Passed: 27468
Failed: 0
Skipped: 18
Failing test files: (none)
RepoLineCoverage: 96.07
CoverageSource: merged artifacts/pester/powershell-coverage.xml (run ExitCode 0)
scripts/harness/HarnessInventory.psm1: 100.00
scripts/harness/HarnessParityMatrix.psm1: 99.25
scripts/harness/HarnessSkillContract.psm1: 100.00
