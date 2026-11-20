# Sharding Unit Tests: Invoke-PoshQCTest Shard Parameters (P8-T10)

Timestamp: 2026-10-16T13-29
Command: sh "SCRATCH/issue-953-p8-t10.sh" — TARGETED_RUN(`testing-shard`, `tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1`) through the Tool route: `$env:ISSUE953_PATHS = 'tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1'; $env:ISSUE953_JUNIT = Join-Path $S 'issue-953-testing-shard-junit.xml'; $start = [datetime]::UtcNow; pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.4.0 -MaximumVersion 5.99.99 -ErrorAction Stop; $c = New-PesterConfiguration; $c.Run.Path = @($env:ISSUE953_PATHS -split '';''); $c.Run.Exit = $true; $c.CodeCoverage.Enabled = $false; $c.TestResult.Enabled = $true; $c.TestResult.OutputFormat = ''JUnitXml''; $c.TestResult.OutputPath = $env:ISSUE953_JUNIT; $c.Output.Verbosity = ''Detailed''; Invoke-Pester -Configuration $c' *> (Join-Path $S 'issue-953-testing-shard.log'); "EXIT_CODE=$LASTEXITCODE START_UTC=$($start.ToString('o'))"`, followed in the same script by the JUnit freshness check and JRP (steps 1-4) on `SCRATCH/issue-953-testing-shard-junit.xml`.
EXIT_CODE: 0

Output Summary:
- Run valid: JUNIT_FRESH=True (JUnit LastWriteTimeUtc later than START_UTC 2026-10-16T13:29:08.6906828Z).
- JRP totals: tests=4, failures=0, errors=0.
- JRP token checks (all PASS, one hit each):
  - TS01-SHARD-RUNPATH-SELECTED: PASS
  - TS02-SHARD-FILELIST-WRITTEN-VIA-SEAM: PASS
  - TS03-NO-SHARD-RUNPATH-UNCHANGED: PASS
- The fourth test case (shard index outside 1..ShardCount throws before Pester runs) carries no token and passed.
- Seams injected in every case: EnsureModule (`{ }`), TestPathExists, LoadSettings, BuildConfiguration, ExpandRunPaths, EnsureResultPath, ExpandCoveragePaths, ResolveScanConfig, ResolveScanFolders, EnumerateTests, InvokePester, CopyCoverage, ResolveCoveragePopulation, Logger, and WriteShardFileList. No file is written.
- An earlier run of this script at 2026-10-16T13:28:29Z also passed (4 tests, 0 failures); the test file was then edited to clear two PSReviewUnusedParameter analyzer findings (parameters used only in closures), and this record is the re-run on the edited file.
