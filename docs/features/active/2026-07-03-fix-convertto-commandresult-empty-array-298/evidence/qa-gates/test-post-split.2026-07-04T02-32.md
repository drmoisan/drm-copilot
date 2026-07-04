Timestamp: 2026-07-04T02-32
Command: mcp__drm-copilot__run_poshqc_test (scan_folders: ["tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1", "tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1"], unmodified scripts/powershell/PoshQC/settings/pester.runsettings.psd1)
EXIT_CODE: 0
Output Summary: Pester JUnit report (`artifacts/pester/pester-junit.xml`) reports aggregate `tests="26" errors="0" failures="0"`, split as `Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` tests="11" errors="0" failures="0" and `Invoke-FullReleaseFlow.Tests.ps1` tests="15" errors="0" failures="0" (11 + 15 = 26). This confirms the split moved the 11 additional-failure-path tests to the new sibling file without removing, weakening, or skipping any of the original 26 tests.
