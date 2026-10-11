# Pester Fixture Suites After the Classifier Change, Before Re-Pin (P4-T2)

Timestamp: 2026-10-09T03-50
Command: mcp__drm-copilot__run_poshqc_test scan_folders ["tests/scripts/claude-lib/blast-radius"] (the P3-T4 run; no source changed since); then poetry run python (ElementTree) over artifacts/pester/pester-junit.xml, selecting BlastRadius.Parity.Tests.ps1 and BlastRadius.HistoricalRuns.Tests.ps1
EXIT_CODE: 1
Output Summary: substitute evidence. Passed=90 Failed=1 (Parity 82 tests, 0 failures; HistoricalRuns 9 tests, 1 failure). The failing name belongs to the historical-runs AFTER Its. No verification-integrity case failed. Two parity cases naming derivation-file-shaped-tokens passed. The observed PowerShell value for edge 588-622 is cost 160, the same value Python observed at P4-T1.

## Deviation (PowerShell route denied)

The plan re-runs the P0-T18 `Invoke-Pester` command, which needs the PowerShell tool or inline `pwsh`; inline `pwsh` is denied by the worktree-isolation hook (denial text recorded in evidence/baseline/requirements-source.2026-10-09T02-51.md). Counts are read from the JUnit file written by the PoshQC MCP test run.

## Failed names

```text
Blast-radius historical runs.reproduces the pinned AFTER edges and tolerated overlaps for backlog-2026-09-26
  Expected @('528-588|path_overlap|False|8|2', '588-622|path_overlap|False|152|4'), because backlog-2026-09-26, but got @('528-588|path_overlap|False|8|2', '588-622|path_overlap|False|160|4').
```
