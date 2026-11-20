# Phase 0 — Pester Test & Coverage Baseline

Timestamp: 2026-06-24T17-40

Command: mcp__drm-copilot__run_poshqc_test (scan_folders: scripts, tests; coverage via scripts/powershell/PoshQC/settings/pester.runsettings.psd1)

EXIT_CODE: 0

Output Summary:
- Tool returned ok:true. Pester run completed with no reported test failures.
- Coverage report: coverage.xml (JaCoCo format) at repo root.
- Baseline line coverage (instrumented subset, report-level): LINE missed=5 covered=28 total=33 -> 84.85%.
- Branch coverage: BRANCH counters are NOT emitted by the bundled PoshQC JaCoCo report. The bundled coverage instruments only a fixed hook subset (package "hooks"); it does not produce branch counters. See agent-memory note "PowerShell coverage scope". Branch coverage is therefore unavailable as a numeric report-level value in this baseline.
- The instrumented scope is the bundled `hooks/` subset, not arbitrary scripts under scripts/orchestration/. New-script coverage for scripts/orchestration/Invoke-CiGateParser.ps1 is measured in Phase 3 via the new Pester test file driving that script directly.
