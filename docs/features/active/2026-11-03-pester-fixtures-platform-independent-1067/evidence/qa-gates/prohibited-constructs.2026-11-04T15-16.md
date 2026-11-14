# Prohibited Constructs and Test-Run Writes (P6-T14)

Timestamp: 2026-11-04T15-16
Command: sh SCRATCH/issue-1067-prohibited.sh (over the 17 suites listed in spec.md Scope: git grep -n -F for each of TestDrive, GetTempPath, New-TemporaryFile, env:TEMP, env:TMP, DanMoisan; git grep -n -E -e '-Skip([:[:space:]]|$)'; git grep -n -F "Should -Invoke -CommandName New-Item" in PoshQC.ScanFolders.Tests.ps1 and PoshQC.TestingCommands.Tests.ps1; git status --porcelain --untracked-files=all; git diff --name-only MB HEAD outside docs/features/)
EXIT_CODE: 0
Output Summary:
- FILES 17 (all present)
- TestDrive: 0 matches
- GetTempPath: 0 matches
- New-TemporaryFile: 0 matches
- env:TEMP: 0 matches
- env:TMP: 0 matches
- DanMoisan: 0 matches (AC11)
- Pester skip parameter (`-Skip` followed by a colon, whitespace, or line end): 0 matches
- P5-T12 and P5-T13 `New-Item` assertions present: `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1` (`Invoke-PoshQCTest scan-folder support` / `overrides run paths and preserves configured coverage paths when scan folders are supplied`) and `tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1` (`Invoke-PoshQCTest` / `preserves a custom KoverageOutputPath when ScanFolders narrow Run.Path and preserve coverage paths`), each `Should -Invoke -CommandName New-Item -Times 1 -Exactly` with the ParameterFilter `$ItemType -eq 'Directory' -and $Path -eq (Join-Path '/repo' 'artifacts')` (AC7).
- Porcelain status: empty.
- Adjusted evaluation (see `evidence/other/execution-deviations.2026-11-04T13-58.md`): the Phase 6 test changes are already committed (recovery commit and loop-fix commit), so they appear in `git diff --name-only MB HEAD` rather than in porcelain. The P6-T13 concurrent-shard run and the P6-T12 `tests/scripts` run both ran before the loop-fix commit; that commit staged only `tests/scripts/powershell/PoshQC` and the feature folder, and porcelain was empty immediately after it, so no test run wrote a file outside `<FEATURE>/evidence/` and the two intended test files. Porcelain is still empty now.
- `git diff --name-only MB HEAD` outside `docs/features/`: the 5 production files (`scripts/dev-tools/activate.ps1`, `scripts/dev-tools/HostBootstrapWorkspace.psm1`, `scripts/dev-tools/DrmCopilotPromptSupport.ps1`, `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1`, `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.ScanConfig.psm1`) and the 17 suites; no other path.
