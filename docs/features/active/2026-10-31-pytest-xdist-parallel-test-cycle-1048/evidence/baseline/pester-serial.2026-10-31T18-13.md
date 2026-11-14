# Serial Pester baseline (#1048)

Timestamp: 2026-10-31T18-13
Command: pwsh -NoLogo -NoProfile -NonInteractive -Command "Import-Module '<worktree root>/scripts/powershell/PoshQC/PoshQC.psd1'; Invoke-PoshQCTest -Root '<worktree root>'" (launched from SCRATCH/issue-1048-pester-serial.ps1 through the brief's sh-launched PowerShell 7 route); then artifacts/pester/pester-junit.xml copied to SCRATCH/issue-1048-pester-serial-baseline.xml
EXIT_CODE: 0
Output Summary:
- JUnit root (`testsuites`): tests=13611, failures=0, errors=0, disabled=10, time=1164.488 s; `testsuite` element count = 481.
- Pester console summary: Passed 13601, Failed 0, Skipped 10, Inconclusive 0, NotRun 0; "Covered 92.76%, 34,165 analyzed Commands in 257 Files".
- Launcher wall-clock (process start to exit, including coverage processing and report writing): 1471 s.
- Coverage report LINE totals (artifacts/pester/powershell-coverage.xml): covered 20926, missed 1445.
- Per-file line coverage: `scripts/powershell/PoshQC/PoshQC.Testing.psm1` 190 covered / 13 missed = 93.60%; `scripts/powershell/PoshQC/PoshQC.Shard.psm1` 95 covered / 0 missed = 100.00%.
