# D4 Pass-After (P4-T5)

Timestamp: 2026-11-04T04-05
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 -Report 'throws an error naming the file for an absolute-path entry','throws an error naming the file for a POSIX-rooted entry','throws an error naming the file for a backslash-rooted entry' ; git hash-object scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1 extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.ScanConfig.psm1
EXIT_CODE: 0
Output Summary:
- State: `Get-PoshQCScanConfigFolder` rejects an entry matching `^(?:[A-Za-z]:|[\\/])` with the unchanged error text ("... must be a workspace-relative path, not an absolute path."); the `$ConfigRelativePath` resolution is unchanged.
- TOTAL Tests=14 Passed=14 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 tests=14 failed=0
- RESULT Get-PoshQCScanConfigFolder.throws an error naming the file for an absolute-path entry Passed
- RESULT Get-PoshQCScanConfigFolder.throws an error naming the file for a POSIX-rooted entry Passed
- RESULT Get-PoshQCScanConfigFolder.throws an error naming the file for a backslash-rooted entry Passed
- git hash-object, source: f3723438e1c3f69451c670a465c0ca0f2439b3b1
- git hash-object, bundle mirror: f3723438e1c3f69451c670a465c0ca0f2439b3b1 (byte-identical, AC6)
- Supporting check: the three mirror contract pytest modules report `24 passed`.
