# Testing with coverage, final pass ([P5-T4])

Timestamp: 2026-10-08T18-31
Command: mcp__drm-copilot__run_poshqc_test (route step); then POSHQC_TEST_RUN: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root . -ScanFolders tests/scripts/claude-hooks,tests/scripts/codex-hooks'
EXIT_CODE: 2
Output Summary: route step disposition: error ("Command exited with code 2."; the stderr excerpt concerns publish verification of tag mcp-server-v0.0.2, a condition unrelated to the changed files; the MCP runner is not the measurement source per the plan). Self-hosted run: child exit code 2; the run printed `Tests Passed: 3538, Failed: 2`. Both failures are in the [P0-T12] baseline failure set (see p5-junit.md). Both result files under artifacts/pester/ exist afterwards. Baseline run printed Passed 3413, Failed 2; the difference of 125 equals the new tests (7 new suites hold 37+13+7+16+37+13+7 = 130) less the 5 transport rows removed.
