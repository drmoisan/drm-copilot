# Pester Gate (remediation cycle 2, P2-T3)

Timestamp: 2026-11-13T16-28
Command: sh SCRATCH/issue-1164-pester-gate.sh (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 from the branch; Invoke-PoshQCParallelTest -Root <worktree>; exit with the returned ExitCode)
EXIT_CODE: 0
Output Summary:
- Run on head 3b52240ff, 2026-11-13T16-17-08 to 16-27-54 UTC; "Invoke-PoshQCParallelTest: workers=8; wall-clock=645.32s; exit code=0"; returned ExitCode 0.
- artifacts/pester/pester-junit.xml (written 16-27-54): 21740 tests, 0 failures, 0 errors, 10 disabled, so 21730 passed, 0 failed (P0-T3: 21724 passed, 0 failed; +6 are the P1-T1 rows).
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml, written 16-27-54): 37704 / 39350 = 95.82% (P0-T3 95.82%; no drop).
- Per-file line coverage: .claude/lib/blast-radius/BlastRadiusAccess.psm1: 66 / 66 = 100.00% (P0-T3 64 / 64 = 100.00%; no drop; at least 85%).
- Named suites (tests, failures): BlastRadiusAccess.Tests.ps1 41, 0 (write-form rows 21 of 21 passed, including the six P1-T1 rows); Invoke-ParallelAdmission.PrecedenceGate.Tests.ps1 5, 0; parallel-scheduling-rule-wording.Tests.ps1 228, 0; FileSizePolicy.RepoGate.Tests.ps1 5, 0.
