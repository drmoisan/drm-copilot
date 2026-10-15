# Pester with Line Coverage, Final (P7-T5, AC-16)

Timestamp: 2026-10-09T04-30
Command: mcp__drm-copilot__run_poshqc_test scan_folders ["tests/scripts/claude-lib/blast-radius"]; then poetry run python (ElementTree) over the run's outputs artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml (JaCoCo)
EXIT_CODE: 0
Output Summary: substitute evidence derived from the files the PoshQC test run wrote. ok:true. Passed=653 Failed=0 (654 test cases, 1 disabled in BlastRadius.Regression452.Tests.ps1, unchanged from baseline).
  BlastRadiusExtraction.psm1 LineCovered=80 LineMissed=0 -> line 100.0% (>= 85)
  BlastRadiusTokenShape.psm1 LineCovered=31 LineMissed=0 -> line 100.0% (>= 85)
Uncovered line numbers: none in either module.
Coverage XML: docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/qa-gates/pester-coverage-final.xml (the two sourcefile elements, with per-line records and counters, copied from the run's JaCoCo report with the package name made repository-relative).

## Deviation (PowerShell route denied)

The P0-T17 `Invoke-Pester` configuration needs the PowerShell tool or inline `pwsh`; inline `pwsh` is denied by the worktree-isolation hook (denial text recorded in evidence/baseline/requirements-source.2026-10-09T02-51.md). The counts and coverage values are read from the JUnit and JaCoCo files written by the PoshQC MCP test run. Per operator constraint 3, AC-16 is reported PARTIAL pending CI evidence.
