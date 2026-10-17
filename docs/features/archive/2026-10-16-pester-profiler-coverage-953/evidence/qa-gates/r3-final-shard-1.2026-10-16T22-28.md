# r3 Final Shard 1 of 3 (P5-T5)

Timestamp: 2026-10-16T22-28
Command: SHARD_RUN(final, 1) through the Tool route in the background (SCRATCH/issue-953-r3-p5-t5.sh): export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $env:ISSUE953_SHARD = '1'; $env:ISSUE953_JUNIT = Join-Path $S 'issue-953-r3-final-shard-1-junit.xml'; $env:ISSUE953_LIST = Join-Path $S 'issue-953-r3-final-shard-1.json'; $start = [datetime]::UtcNow; pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $build = { param($Settings) $c = New-PesterConfiguration -Hashtable $Settings; $c.CodeCoverage.Enabled = $false; $c.TestResult.OutputPath = $env:ISSUE953_JUNIT; $c }; Invoke-PoshQCTest -Root (Get-Location).Path -ShardIndex ([int] $env:ISSUE953_SHARD) -ShardCount 3 -ShardFileListPath $env:ISSUE953_LIST -BuildConfiguration $build -DisableKoverageCopy' *> (Join-Path $S 'issue-953-r3-final-shard-1.log'); $code = $LASTEXITCODE; ...' followed by the validity checks, the selected-file count, and JRP.
EXIT_CODE: 0
Output Summary:
- Printed: EXIT_CODE=0 SECONDS=150 START_UTC=2026-10-16T22:26:09.7405917Z
- Validity: JUnit and manifest written after START_UTC (True); `Code coverage population: source=config` lines in the log: 0 (coverage stayed off). Run valid.
- Selected files (SCRATCH/issue-953-r3-final-shard-1.json): 129
- JRP (SCRATCH/issue-953-r3-final-shard-1-junit.xml): tests=3541 failures=0 errors=0
- Wall seconds: 150
- Result: PASS.
