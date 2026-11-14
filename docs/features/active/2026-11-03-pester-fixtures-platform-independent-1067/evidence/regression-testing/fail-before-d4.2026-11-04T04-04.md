# D4 Fail-Before (P4-T2)

Timestamp: 2026-11-04T04-04
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 -Report 'throws an error naming the file for an absolute-path entry'
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- State: P4-T1 tests added; `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` unchanged (`[IO.Path]::IsPathRooted` entry check).
- TOTAL Tests=14 Passed=12 Failed=2 Skipped=0 NotRun=0
- FILE tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 tests=14 failed=2
- RESULT Get-PoshQCScanConfigFolder.throws an error naming the file for an absolute-path entry Failed
- Message: "Expected an exception with message like '*config/poshqc-scan.json*absolute*' to be thrown, but no exception was thrown." (`C:/absolute/path` is not rooted on Linux).
- The new backslash-rooted case (`\absolute\path`) also fails before the change for the same reason; the new POSIX-rooted case (`/absolute/path`) already passes on Linux.
