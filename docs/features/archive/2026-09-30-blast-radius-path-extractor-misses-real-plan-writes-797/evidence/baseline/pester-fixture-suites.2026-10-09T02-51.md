# Baseline Pester Fixture Suites (P0-T18, AC-1)

Timestamp: 2026-10-09T02-51
Command: mcp__drm-copilot__run_poshqc_test scan_folders ["tests/scripts/claude-lib/blast-radius"]; then poetry run python (ElementTree) over artifacts/pester/pester-junit.xml, selecting the testsuites BlastRadius.Parity.Tests.ps1 and BlastRadius.HistoricalRuns.Tests.ps1
EXIT_CODE: 0
Output Summary: substitute evidence. Passed=89 Failed=0 (Parity 80, HistoricalRuns 9; the verification-integrity Describe is inside the parity file). Comparison value for P4-T11: 89.

## Deviation (PowerShell route denied)

The plan's `Invoke-Pester -Path <two files>` needs the PowerShell tool or inline `pwsh`; inline `pwsh` is denied by the worktree-isolation hook (denial text recorded in requirements-source.2026-10-09T02-51.md). The counts are read from the JUnit result file written by the PoshQC MCP test run over the folder that contains both files.
