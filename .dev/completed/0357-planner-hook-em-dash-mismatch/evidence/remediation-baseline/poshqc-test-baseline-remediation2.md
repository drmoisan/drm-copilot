# PoshQC Test Baseline — Remediation Cycle 2

**Timestamp:** 2026-07-17T16-08
**Command:** `mcp__drm-copilot__run_poshqc_test` scoped to `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` (using the pre-fix, unmodified `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`)
**EXIT_CODE:** 0
**Output Summary:** `ok: true`. 7 tests, 0 failures (`artifacts/pester/pester-junit.xml`: `tests="7" errors="0" failures="0"`). `grep -n "sourcefilename=\"validate-planner-output" artifacts/pester/powershell-coverage.xml` returns no matches (grep exit code 1) — the canonical coverage artifact still contains zero entries for `.claude/hooks/validate-planner-output.ps1` at the start of this cycle, confirming the settings-file gap persists. This cycle's starting numeric coverage state for `.claude/hooks/validate-planner-output.ps1` is restated as 73.72% ad hoc line coverage (115/156 commands), carried forward from `evidence/qa-gates/coverage-delta-remediation1.md`, since the bundled settings copy consumed by this MCP tool does not yet include this file in `CodeCoverage.Path`.
