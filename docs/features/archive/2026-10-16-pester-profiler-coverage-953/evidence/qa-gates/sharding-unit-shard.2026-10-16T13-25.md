# Sharding Unit Tests: PoshQC.Shard (P8-T8)

Timestamp: 2026-10-16T13-25
Command: sh "SCRATCH/issue-953-p8-t8.sh" — TARGETED_RUN(`shard-unit`, `tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1`) through the Tool route: `$env:ISSUE953_PATHS = 'tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1'; $env:ISSUE953_JUNIT = Join-Path $S 'issue-953-shard-unit-junit.xml'; $start = [datetime]::UtcNow; pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.4.0 -MaximumVersion 5.99.99 -ErrorAction Stop; $c = New-PesterConfiguration; $c.Run.Path = @($env:ISSUE953_PATHS -split '';''); $c.Run.Exit = $true; $c.CodeCoverage.Enabled = $false; $c.TestResult.Enabled = $true; $c.TestResult.OutputFormat = ''JUnitXml''; $c.TestResult.OutputPath = $env:ISSUE953_JUNIT; $c.Output.Verbosity = ''Detailed''; Invoke-Pester -Configuration $c' *> (Join-Path $S 'issue-953-shard-unit.log'); "EXIT_CODE=$LASTEXITCODE START_UTC=$($start.ToString('o'))"`, followed in the same script by the JUnit freshness check and JRP (steps 1-4) on `SCRATCH/issue-953-shard-unit-junit.xml`.
EXIT_CODE: 0

Output Summary:
- Run valid: JUNIT_FRESH=True (JUnit LastWriteTimeUtc later than START_UTC 2026-10-16T13:25:02.3511084Z).
- JRP totals: tests=10, failures=0, errors=0.
- JRP token checks (all PASS, one hit each):
  - SH01-SLICE-ROUND-ROBIN: PASS
  - SH02-SLICE-INVALID-INDEX-THROWS: PASS
  - SH03-MANIFEST-RELATIVE-PATHS: PASS
  - SH04-COMPLETENESS-PASS: PASS
  - SH05-COMPLETENESS-MISSING-FILE-THROWS: PASS
  - SH06-COMPLETENESS-OVERLAP-THROWS: PASS
  - SH07-COMPLETENESS-DIVERGENT-ALL-THROWS: PASS
  - SH08-TESTCOUNT-MISMATCH-THROWS: PASS
  - SH09-TESTCOUNT-MATCH-PASSES: PASS
- The tenth test case ("keeps the forward-slash form of a path outside the root") carries no token and passed.
- The test file uses in-memory arrays and objects only and writes no file.
