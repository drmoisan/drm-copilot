# Pester Phase 0 Baseline (P0-T4)

Timestamp: 2026-11-09T23-35
Command: sh SCRATCH/issue-1164-pester-gate.sh (pwsh: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 from the branch; Invoke-PoshQCParallelTest -Root <worktree>; exit with the returned ExitCode)
EXIT_CODE: 0
Output Summary:
- Run started 2026-11-09T23-23 (UTC), wall clock 666.96 s, 8 shard processes, every shard exit 0; merged reports written at 2026-11-09T23-34.
- Returned ExitCode: 0.
- Counts from artifacts/pester/pester-junit.xml: 21216 tests, 21206 passed, 0 failed, 0 errors, 10 skipped.
- Failing tests: none, so no failure classification is required.
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 37491 / 39137 = 95.79%.
- Per-file line coverage:
  - .claude/lib/blast-radius/BlastRadiusScheduling.psm1: 138 / 138 = 100.00%
  - .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1: 179 / 179 = 100.00%
  - .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1: 219 / 227 = 96.48%
  - .claude/lib/parallel-drift/ParallelDrift.psm1: 123 / 123 = 100.00%
