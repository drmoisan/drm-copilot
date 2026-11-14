# Phase 0 baseline: Pester gate (P0-T2)

Timestamp: 2026-11-14T23-30
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (launcher `pester` suite, one Invoke-PoshQCParallelTest run, 8 workers, run from the worktree root)
EXIT_CODE: 0
Output Summary: tests=26852, failures=0, errors=0, disabled=22 (merged pester-junit.xml). Wall-clock 819.99 s.
Repo-wide line coverage (artifacts/pester/powershell-coverage.xml, JaCoCo LINE counter): covered=44274 missed=1840, 96.01%.
Per-file line coverage: scripts/powershell/PoshQC/PoshQC.Shard.psm1 138 covered, 0 missed, 100%; scripts/ci/Invoke-CiRequiredGate.ps1 27 covered, 3 missed, 90% (the guarded entry-call lines); scripts/ci/CiRequiredGate.psm1 90 covered, 0 missed, 100%.
New file scripts/ci/Select-PythonTestShard.ps1 has no pre-change run and is judged against the 85% threshold.
