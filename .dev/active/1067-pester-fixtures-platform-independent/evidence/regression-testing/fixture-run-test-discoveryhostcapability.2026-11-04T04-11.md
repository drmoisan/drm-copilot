# Fixture Run: Test-DiscoveryHostCapability.Tests.ps1 (P5-T11)

Timestamp: 2026-11-04T04-11
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=6 Passed=6 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1 tests=6 failed=0 (baseline: 1 failed in the two-tree run; passed in the tests/scripts run order)
- Changes: `exits 2 with an unsupported document when the host has no installed probe` uses the portable root `test-discoveryhostcapability-root` with `Test-Path` mocked to `$false` under a ParameterFilter limited to that root, and asserts the mock was invoked once. The `C:/Users/Example/...` workspace literal is removed, so the outcome no longer depends on the host or on run order.
