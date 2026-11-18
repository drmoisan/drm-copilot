# Phase 0 baseline Pester gate (P0-T2)

Timestamp: 2026-11-18T03-56
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (launcher; one Invoke-PoshQCParallelTest run, 8 workers, integration and golden lanes excluded by the launcher)
EXIT_CODE: 0
Output Summary:
- Gate: `Invoke-PoshQCParallelTest: workers=8; wall-clock=706.59s; exit code=0`. A first launch exited 75 (queue timeout: machine test-suite lock held by another worktree's pester run); it was re-run unchanged and is recorded as a queue timeout, not a failure.
- Counts from `artifacts/pester/pester-junit.xml`: 27494 tests, 0 failures, 0 errors, 18 skipped (27476 passed).
- Repo-wide line coverage from `artifacts/pester/powershell-coverage.xml` (JaCoCo; a line is covered when its `ci` count is above 0): 44864 of 46711 lines = 96.05%.
- Per-file line coverage of the existing files under `scripts/ci/`:
  - scripts/ci/CiChangeScope.psm1: 132/141 = 93.62%
  - scripts/ci/CiRequiredGate.psm1: 90/90 = 100%
  - scripts/ci/FileSizeBaseline.psm1: 54/54 = 100%
  - scripts/ci/Invoke-CiChangeScope.ps1: 103/113 = 91.15%
  - scripts/ci/Invoke-CiRequiredGate.ps1: 27/30 = 90%
  - scripts/ci/New-FileSizeBaseline.ps1: 32/32 = 100%
  - scripts/ci/Select-PythonTestShard.ps1: 62/69 = 89.86%
- No pre-existing failing test. The per-file listing of all 461 measured files is kept in SCRATCH for the final comparison.
