# Fixture Run: PoshQC.TestingCommands.Tests.ps1 (P5-T13)

Timestamp: 2026-11-04T04-12
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=13 Passed=13 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1 tests=13 failed=0 (baseline: 1 failed, "Access to the path '/repo' is denied.")
- Changes: `preserves a custom KoverageOutputPath when ScanFolders narrow Run.Path and preserve coverage paths` mocks `New-Item -ModuleName PoshQC` with a ParameterFilter on `$ItemType -eq 'Directory'` and asserts one invocation (`-Times 1 -Exactly`) with `$Path` equal to `Join-Path '/repo' 'artifacts'`. The existing KoverageOutputPath assertion is unchanged.
- After the run, `/repo` does not exist on the host.
