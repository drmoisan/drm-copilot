# Fixture Run: Test-DiscoveryHostCapability.Entry.Tests.ps1 (P5-T10)

Timestamp: 2026-11-04T04-11
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=4 Passed=4 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 tests=4 failed=0 (baseline: 3 failed in the tests/scripts run, 4 in the two-tree run)
- Changes: the no-probe `It` passes a local portable root (`test-discoveryhostcapability-entry-root`) with `Test-Path` mocked to `$false` under a ParameterFilter limited to that root, and asserts the mock was invoked once. The probe `It` (three hosts) uses `$script:GateRunningHostEnvironment`, which matches the host the suite runs on; on Windows it is the same value as the former `$script:GateHostEnvironment`. `DiscoveryGate.TestSupport.ps1` is unchanged.
- Baseline cause (C7): "AUTHORITY_PATH_NOT_CANONICAL: Workspace root must be an absolute path" from the fixed `windows` platform shape against the real Linux checkout.
