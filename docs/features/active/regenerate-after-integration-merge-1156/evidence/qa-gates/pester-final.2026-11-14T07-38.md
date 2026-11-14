# Pester Final Gate — remediation cycle 2, [P2-T2]

Timestamp: 2026-11-14T07-38
Command: sh SCRATCH/issue-1156-pester-gate.sh (pwsh 7 from the item worktree root: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree root>; exit with the returned ExitCode); figures read by sh SCRATCH/issue-1156-results.sh from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary:
- One Invoke-PoshQCParallelTest run, workers=8, ExitCode 0, 913.3 s (07:23:25 to 07:38:38 UTC). Merged JUnit and coverage written 2026-11-14T07:38:38Z.
- artifacts/pester/pester-junit.xml: 24744 tests, 0 failures, 0 errors, 10 disabled (`Phase 0 baseline` 24724 tests, 0 failures). Named suites: `Invoke-RegenerationPath.ProcessStart.Tests.ps1` 33/0, `Invoke-RegenerationPath.Tests.ps1` 123/0, `regeneration-path-skill-contract.Tests.ps1` 56/0, `FileSizePolicy.RepoGate.Tests.ps1` 5/0, `enforcement-hooks-no-python-invocation.Tests.ps1` 35/0.
- Repo-wide line coverage: 95.94% (40928 covered, 1734 missed), not below the `Phase 0 baseline` 95.94% (`evidence/qa-gates/pester-gate.2026-11-14T06-14.md`).
- `.claude/lib/regeneration/Invoke-RegenerationPath.ps1`: 91.33% (295 covered, 28 missed), not below 91.28% and above 85%. New path-screen lines: the `if ($ResolvedPath -match ...)` line ci=1 and its `throw` line ci=2, both covered (0 missed instructions).
- Other regeneration files unchanged: `RegenerationClassifier.psm1` 100%, `RegenerationConfig.psm1` 98.00%, `RegenerationDelta.psm1` 100%.
