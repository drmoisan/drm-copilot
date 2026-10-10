# Pester Fixture Suites After the Re-Pin (P4-T11)

Timestamp: 2026-10-09T04-00
Command: mcp__drm-copilot__run_poshqc_test scan_folders ["tests/scripts/claude-lib/blast-radius"]; then poetry run python (ElementTree) over artifacts/pester/pester-junit.xml, selecting BlastRadius.Parity.Tests.ps1 and BlastRadius.HistoricalRuns.Tests.ps1, and counting passed cases whose name contains derivation-file-shaped-tokens
EXIT_CODE: 0
Output Summary: substitute evidence. MCP result ok:true (654 tests folder-wide, 0 failures). Fixture suites: Passed=91 Failed=0 (P0-T18 baseline 89, plus the two derivation-file-shaped-tokens cases). Passed cases containing derivation-file-shaped-tokens: 2, so the PowerShell parity suite derived the same radius and findings as Python from the shared fixture.

## Deviation (PowerShell route denied)

The plan re-runs the P0-T18 `Invoke-Pester` command and a `$r.Passed` filter in the same session; both need the PowerShell tool or inline `pwsh`, which the worktree-isolation hook denies (denial text recorded in evidence/baseline/requirements-source.2026-10-09T02-51.md). Both values are read from the JUnit file written by the PoshQC MCP test run.

## Passed cases for the shared fixture

```text
Blast-radius derivation and validation parity.Derived radius.reproduces the expected radius for derivation-file-shaped-tokens
Blast-radius derivation and validation parity.Validation findings.reproduces the expected findings for derivation-file-shaped-tokens
```
