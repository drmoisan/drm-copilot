# Baseline Pester with Line Coverage (P0-T17)

Timestamp: 2026-10-09T02-51
Command: mcp__drm-copilot__run_poshqc_test scan_folders ["tests/scripts/claude-lib/blast-radius"]; then poetry run python (ElementTree) over the run's own outputs artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml (JaCoCo)
EXIT_CODE: 0
Output Summary: substitute evidence derived from the files the PoshQC test run wrote. Passed=610 Failed=0 (611 test cases, 1 disabled/skipped in BlastRadius.Regression452.Tests.ps1). Failing tests: none.
  BlastRadiusExtraction.psm1 LineCovered=86 LineMissed=0 -> line 100.0%
  BlastRadiusTokenShape.psm1 LineCovered=20 LineMissed=0 -> line 100.0%
Coverage XML: docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/pester-coverage-baseline.xml (the two sourcefile elements and their counters, copied from the run's JaCoCo report with the package name made repository-relative; the full report is not copied because it carries absolute paths).

## Deviation (PowerShell route denied)

The plan's `Invoke-Pester` configuration needs the PowerShell tool or inline `pwsh`; inline `pwsh` is denied by the worktree-isolation hook (denial text recorded in requirements-source.2026-10-09T02-51.md). The PoshQC MCP test tool ran Pester over the same folder and wrote a JUnit result file and a JaCoCo coverage report under the gitignored artifacts tree; the counts and coverage values above are read from those files, not from the MCP return value.

## Per-file test counts (from the JUnit file)

```text
Total 611 Failures 0 Errors 0 Disabled 1
BlastRadius.HistoricalRuns.Tests.ps1 tests=9 failures=0
BlastRadius.Parity.Tests.ps1 tests=80 failures=0
BlastRadiusExtraction.Path.Tests.ps1 tests=61 failures=0
BlastRadiusTokenShape.Tests.ps1 tests=16 failures=0
BlastRadiusWriteIntent.Tests.ps1 tests=28 failures=0
(17 further files, all failures=0)
```
