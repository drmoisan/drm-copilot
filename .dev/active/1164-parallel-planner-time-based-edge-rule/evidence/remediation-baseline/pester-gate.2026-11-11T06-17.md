# Pester Phase 0 Baseline (remediation cycle 1, P0-T4)

Timestamp: 2026-11-11T05-56
Command: sh SCRATCH/issue-1164-pester-gate.sh baseline (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 from the branch; Invoke-PoshQCParallelTest -Root <item worktree>; exit with the returned ExitCode); figures read by sh SCRATCH/issue-1164-pester-extract.sh
EXIT_CODE: 0
Output Summary:
- Run 2026-11-11T05-56 to 06-17 UTC; "Invoke-PoshQCParallelTest: workers=8; wall-clock=1244.08s; exit code=0"; returned ExitCode 0; shards 1 to 8 exited 0. Merged reports written 2026-11-11T06-17, so they belong to this run.
- artifacts/pester/pester-junit.xml: 21581 tests, 0 failures, 0 errors, 10 disabled, so 21571 passed, 0 failed. No failing test to classify.
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 37690 / 39337 = 95.81%.
- Per-file line coverage:
  - .claude/lib/blast-radius/BlastRadiusAccess.psm1: 53 / 53 = 100.00%
  - .claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1: 41 / 42 = 97.62% (missed: the final return of Get-PrecedenceGateItemBand)
- Named suites (tests, failures): BlastRadiusAccess.Tests.ps1 19, 0; ParallelAdmissionPrecedenceGate.Tests.ps1 9, 0; parallel-scheduling-rule-wording.Tests.ps1 228, 0; FileSizePolicy.RepoGate.Tests.ps1 5, 0.
