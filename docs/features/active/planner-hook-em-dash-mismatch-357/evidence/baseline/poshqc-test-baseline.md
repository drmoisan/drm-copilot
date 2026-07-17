# PoshQC Test — Baseline (Issue #357)

Timestamp: 2026-07-17T10:18 (local, America/New_York; workstation clock)

Command: mcp__drm-copilot__run_poshqc_test (scan_folders: ["tests/scripts/claude-hooks/validate-planner-output.Tests.ps1"], using scripts/powershell/PoshQC/settings/pester.runsettings.psd1)

EXIT_CODE: 0

Output Summary: All 6 existing Pester tests in `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` passed (6/6, 0 failures, 0 errors) per `artifacts/pester/pester-junit.xml`. The shared `pester.runsettings.psd1` `CodeCoverage.Path` allowlist does not include `.claude/hooks/validate-planner-output.ps1` (it is scoped to a different, pre-curated set of hook/script files), so the MCP tool's aggregate JaCoCo coverage report (`artifacts/pester/powershell-coverage.xml`) reports 0% covered across the board for this narrow-scoped run and does not measure this file at all. Modifying `pester.runsettings.psd1` to add this file to the allowlist is out of scope for this plan's 2-file change budget, so it was not changed.

To obtain a real per-file baseline without editing any file outside the change budget, `Invoke-Pester` was run directly (ad hoc `PesterConfiguration`, no repo files modified) with `CodeCoverage.Path = '.claude/hooks/validate-planner-output.ps1'`:
- Tests: 6 passed, 0 failed, 0 errors (consistent with the MCP-tool run).
- Line/command coverage: 109 of 156 analyzed commands executed = **69.87%** line coverage (Pester's command-based coverage metric).
- Branch coverage: Pester 5.6.1's code-coverage engine does not emit a distinct `BRANCH` counter (confirmed no `BRANCH` counters in either the JaCoCo output of this ad hoc run or the repo's aggregate `artifacts/pester/powershell-coverage.xml`); branch coverage is not separately measurable by this toolchain for any file, not only this one.
- Baseline uncovered line numbers (pre-fix): 45, 46, 49, 50, 51, 53, 54, 57, 75, 78, 81, 137, 138, 162, 167, 176, 180, 184, 195, 196, 200, 209, 212, 217, 223, 244, 252, 261, 282, 283, 284, 285, 288.
- Line 121 (the `$phasePattern` regex assignment targeted for the fix) is already executed at baseline (unconditional assignment). Line 137 (the phase-heading error message targeted for the fix) is in the baseline-uncovered set — no existing fixture currently exercises the malformed-phase-heading branch.
