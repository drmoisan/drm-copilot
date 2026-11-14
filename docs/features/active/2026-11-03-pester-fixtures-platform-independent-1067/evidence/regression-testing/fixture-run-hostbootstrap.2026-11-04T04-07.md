# Fixture Run: HostBootstrap.Tests.ps1 (P5-T2)

Timestamp: 2026-11-04T04-07
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools/HostBootstrap.Tests.ps1
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=28 Passed=28 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/HostBootstrap.Tests.ps1 tests=28 failed=0 (baseline: 1 failed, AC11-PIP-STREAMS)
- Changes: portable root `hostbootstrap-root`; in `AC11-PIP-STREAMS` the mocked `APPDATA` value, the mocked poetry directory, and the `Get-ChildItem` and `Add-DirectoryToUserPath` ParameterFilter expectations are built from the root with `Join-Path`. Other literals are opaque compared values and stay.
