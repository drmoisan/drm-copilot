# Em-Dash Regression Test — Pass After Fix (Issue #357)

Timestamp: 2026-07-17T10:41 (local, America/New_York; workstation clock)

Command 1: `Invoke-Pester` (ad hoc `PesterConfiguration`, no repo files modified) with `Run.Path = 'tests/scripts/claude-hooks/validate-planner-output.Tests.ps1'` and `Filter.FullName = '*allows termination when phase headings use the canonical em dash*'`, scoping execution to only the single em-dash `It` case added in Phase 1, against the corrected `.claude/hooks/validate-planner-output.ps1`.

EXIT_CODE: 0

Output Summary: The scoped em-dash regression test now passes (1 selected, 1 passed, 0 failed). `Get-PlanStructureValidationReport`'s corrected `$phasePattern` (`^### Phase (?<Phase>\d+)\s+—\s+(?<Title>.+)$`, em dash U+2014) matches the em-dash fixture headings, and `Invoke-PlannerOutputValidation` returns `Ok = $true` with a null message.

Command 2: `mcp__drm-copilot__run_poshqc_test` scoped to `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` (full file run via the MCP toolchain wrapper, per `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`).

EXIT_CODE: 0

Output Summary: Full test file run: 7 of 7 tests passed, 0 errors, 0 failures (per `artifacts/pester/pester-junit.xml`: `tests="7" errors="0" failures="0"`). This includes the 6 pre-existing tests (now using em-dash fixtures per P2-T4) and the 1 new em-dash regression test added in Phase 1.
