# Fixture Run: PoshQC.ScanFolders.Tests.ps1 (P5-T12)

Timestamp: 2026-11-04T04-12
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=17 Passed=17 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1 tests=17 failed=0 (baseline: 1 failed, "Access to the path '/repo' is denied.")
- Changes: `overrides run paths and preserves configured coverage paths when scan folders are supplied` mocks `New-Item -ModuleName PoshQC` with a ParameterFilter on `$ItemType -eq 'Directory'` and asserts one invocation (`-Times 1 -Exactly`) with `$Path` equal to `Join-Path '/repo' 'artifacts'`. `/repo` stays as the fixture root.
- After the run, `/repo` does not exist on the host (no real directory was created).
