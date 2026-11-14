# Pester Phase 0 Baseline (remediation cycle 2, P0-T3)

Timestamp: 2026-11-13T14-30
Command: sh SCRATCH/issue-1164-pester-gate.sh (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 from the branch; Invoke-PoshQCParallelTest -Root <item worktree>; exit with the returned ExitCode); figures read by SCRATCH/issue-1164-pester-figures.ps1
EXIT_CODE: 0
Output Summary:
- Run on head a876411d8; 2026-11-13T14-30-02 to 14-44-41 UTC; "Invoke-PoshQCParallelTest: workers=8; wall-clock=879.02s; exit code=0"; returned ExitCode 0; shards 1 to 8 exited 0. Merged reports written 2026-11-13T14-44-41, so they belong to this run.
- artifacts/pester/pester-junit.xml: 21734 tests, 0 failures, 0 errors, 10 disabled, so 21724 passed, 0 failed.
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 37702 / 39348 = 95.82%.
- Per-file line coverage: .claude/lib/blast-radius/BlastRadiusAccess.psm1: 64 / 64 = 100.00%.
- Named suites (tests, failures): BlastRadiusAccess.Tests.ps1 35, 0 (write-form rows 15 of 15 passed); Invoke-ParallelAdmission.PrecedenceGate.Tests.ps1 5, 0; parallel-scheduling-rule-wording.Tests.ps1 228, 0; FileSizePolicy.RepoGate.Tests.ps1 5, 0.
- No failing test, so no failure is classified under the Execution Terms.
