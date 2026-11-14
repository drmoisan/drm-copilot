# Fixture Run: HostBootstrap.Invoke.Tests.ps1 (P5-T1)

Timestamp: 2026-11-04T04-06
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=23 Passed=23 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 tests=23 failed=0 (baseline: 16 failed)
- Changes: portable root `hostbootstrap-invoke-root`; `$script:Ws`, `$script:Repo`, the `Get-Location` mock value, the mocked command sources, the clone target expectation, the `Set-BootstrapResumeRunOnce` arguments expectation, the manifest path and its error message, and the poetry message are built from the root. The opaque `C:\machine;C:\user` PATH value is never joined and stays. Every `Should -Invoke` keeps its count and ParameterFilter.
