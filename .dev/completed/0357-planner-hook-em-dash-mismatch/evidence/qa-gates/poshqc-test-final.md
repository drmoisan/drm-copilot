# PoshQC Test — Final (Issue #357)

Timestamp: 2026-07-17T10:55 (local, America/New_York; workstation clock)

Command 1: mcp__drm-copilot__run_poshqc_test (scan_folders: ["tests/scripts/claude-hooks/validate-planner-output.Tests.ps1"], using scripts/powershell/PoshQC/settings/pester.runsettings.psd1)

EXIT_CODE: 0

Output Summary: All 7 tests passed (7/7, 0 errors, 0 failures) per `artifacts/pester/pester-junit.xml` (`tests="7" errors="0" failures="0"`), including the new em-dash regression test added in Phase 1. As at baseline (P0-T4), the shared `pester.runsettings.psd1` `CodeCoverage.Path` allowlist does not include `.claude/hooks/validate-planner-output.ps1`, so the MCP tool's aggregate coverage report does not measure this file; modifying that shared settings file is out of scope for this plan's 2-file change budget.

Command 2: `Invoke-Pester` (ad hoc `PesterConfiguration`, no repo files modified) with `Run.Path = 'tests/scripts/claude-hooks/validate-planner-output.Tests.ps1'` and `CodeCoverage.Path = '.claude/hooks/validate-planner-output.ps1'`, coverage enabled, to obtain a real per-file post-change coverage measurement consistent with the baseline methodology.

EXIT_CODE: 0

Output Summary: 7 of 7 tests passed, 0 failed. Line/command coverage: 109 of 156 analyzed commands executed = **69.87%** (unchanged from baseline). Branch coverage: not emitted by Pester 5.6.1's code-coverage engine (no `BRANCH` counter type produced), consistent with the baseline observation and with the repository's own aggregate coverage report. Post-change uncovered line numbers are identical to baseline: 45, 46, 49, 50, 51, 53, 54, 57, 75, 78, 81, 137, 138, 162, 167, 176, 180, 184, 195, 196, 200, 209, 212, 217, 223, 244, 252, 261, 282, 283, 284, 285, 288 (47 lines, matching the baseline count). No coverage regression.
