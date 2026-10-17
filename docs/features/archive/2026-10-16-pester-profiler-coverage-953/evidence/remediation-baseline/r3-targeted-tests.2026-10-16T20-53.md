# r3 Shard-Suite Baseline (P0-T18)

Timestamp: 2026-10-16T20-53
Command: TARGETED_RUN(baseline-shard, R3_SHARD_SET) through the Tool route (SCRATCH/issue-953-r3-p0-t18.sh): export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $env:ISSUE953_PATHS = 'tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1;tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1'; $env:ISSUE953_JUNIT = Join-Path $S 'issue-953-r3-baseline-shard-junit.xml'; $start = [datetime]::UtcNow; pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.4.0 -MaximumVersion 5.99.99 -ErrorAction Stop; $c = New-PesterConfiguration; $c.Run.Path = @($env:ISSUE953_PATHS -split ';'); $c.Run.Exit = $true; $c.CodeCoverage.Enabled = $false; $c.TestResult.Enabled = $true; $c.TestResult.OutputFormat = 'JUnitXml'; $c.TestResult.OutputPath = $env:ISSUE953_JUNIT; $c.Output.Verbosity = 'Detailed'; Invoke-Pester -Configuration $c' *> (Join-Path $S 'issue-953-r3-baseline-shard.log'); "EXIT_CODE=$LASTEXITCODE START_UTC=..."' followed by the validity check and JRP over the JUnit file.
EXIT_CODE: 0
Output Summary:
- EXIT_CODE=0 START_UTC=2026-10-16T20:53:27.2690674Z; VALID=True (JUnit written after START_UTC)
- JRP tests=20 failures=0 errors=0
- Token checks (JRP step 4), each hits=1 PASS: SH01-SLICE-ROUND-ROBIN, SH02-SLICE-INVALID-INDEX-THROWS, SH03-MANIFEST-RELATIVE-PATHS, SH04-COMPLETENESS-PASS, SH05-COMPLETENESS-MISSING-FILE-THROWS, SH06-COMPLETENESS-OVERLAP-THROWS, SH07-COMPLETENESS-DIVERGENT-ALL-THROWS, SH08-TESTCOUNT-MISMATCH-THROWS, SH09-TESTCOUNT-MATCH-PASSES, SH10-SLICE-WEIGHTED-LPT, SH11-SLICE-EQUAL-WEIGHTS-ORDINAL-PATH-ORDER, SH12-SLICE-WEIGHT-COUNT-MISMATCH-THROWS, TS01-SHARD-RUNPATH-SELECTED, TS02-SHARD-FILELIST-WRITTEN-VIA-SEAM, TS03-NO-SHARD-RUNPATH-UNCHANGED, TS04-DEFAULT-FILELIST-SEAM-WRITES-UTF8-JSON, TS05-EMPTY-SHARD-SLICE-THROWS, TS06-SHARD-WEIGHTED-BY-FILE-SIZE
- Result: PASS.

R3_TARGETED_BASELINE_TESTS: 20
