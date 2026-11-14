# Fixture Run: SideloadedExtensionPublish.Tests.ps1 (P5-T8)

Timestamp: 2026-11-04T04-10
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=27 Passed=27 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 tests=27 failed=0 (baseline: 4 failed)
- Changes: portable root `sideloadedextensionpublish-root`; the `AC06-PUBLISH-FORCE-CLEANUP` working directory and its `Remove-Item` filter, and the three `Invoke-ProjectCompile` roots and the compile `$WorkingDirectory` filter, are built from the root. The `Invoke-ExternalCommand` `cmd.exe /c` tests and the other opaque `C:\fixture\ext` working-directory values (never joined) stay.
