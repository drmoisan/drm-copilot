# Fixture Run: SideloadedExtensionPublish.Invoke.Tests.ps1 (P5-T7)

Timestamp: 2026-11-04T04-09
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=13 Passed=13 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 tests=13 failed=0 (baseline: 12 failed)
- Changes: portable root `sideloadedextensionpublish-invoke-root`; `$script:publishArgs`, the `Resolve-ExtensionProjectRoot` mock value, every `$WorkingDirectory` ParameterFilter, the output-directory `Test-Path` and `New-Item` filters, the VSIX path expectation, and the `RepoRoot does not exist` message are built from the root. Counts and ParameterFilters are kept.
