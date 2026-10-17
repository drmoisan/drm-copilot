# Sharding Unit Tests: PoshQC.CoverageMerge (P8-T9)

Timestamp: 2026-10-16T13-27
Command: sh "SCRATCH/issue-953-p8-t9.sh" — TARGETED_RUN(`merge-unit`, `tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1`) through the Tool route: `$env:ISSUE953_PATHS = 'tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1'; $env:ISSUE953_JUNIT = Join-Path $S 'issue-953-merge-unit-junit.xml'; $start = [datetime]::UtcNow; pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.4.0 -MaximumVersion 5.99.99 -ErrorAction Stop; $c = New-PesterConfiguration; $c.Run.Path = @($env:ISSUE953_PATHS -split '';''); $c.Run.Exit = $true; $c.CodeCoverage.Enabled = $false; $c.TestResult.Enabled = $true; $c.TestResult.OutputFormat = ''JUnitXml''; $c.TestResult.OutputPath = $env:ISSUE953_JUNIT; $c.Output.Verbosity = ''Detailed''; Invoke-Pester -Configuration $c' *> (Join-Path $S 'issue-953-merge-unit.log'); "EXIT_CODE=$LASTEXITCODE START_UTC=$($start.ToString('o'))"`, followed in the same script by the JUnit freshness check and JRP (steps 1-4) on `SCRATCH/issue-953-merge-unit-junit.xml`.
EXIT_CODE: 0

Output Summary:
- Run valid: JUNIT_FRESH=True (JUnit LastWriteTimeUtc later than START_UTC 2026-10-16T13:26:51.9764272Z).
- JRP totals: tests=8, failures=0, errors=0.
- JRP token checks (all PASS, one hit each):
  - CM01-MERGE-MAX-CI: PASS
  - CM02-MERGE-RECOMPUTES-LINE-COUNTERS: PASS
  - CM03-MERGE-PRESERVES-DENOMINATOR: PASS
  - CM04-MERGE-MISMATCHED-LINES-THROWS: PASS
  - CM05-MERGE-SINGLE-REPORT-IDENTITY: PASS
  - CM06-MERGE-EMPTY-INPUT-THROWS: PASS
  - CM07-SUMMARY-REPORT-LINE: PASS
- The eighth test case (summary percent 0 for an empty report; throw when the report LINE counter is absent) carries no token and passed.
- Every report is an in-memory XML string; the test file reads and writes no file.
