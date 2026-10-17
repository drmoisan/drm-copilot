# r3 CI Manifest Validation (P0-T17)

Timestamp: 2026-10-16T20-52
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $m = Get-Content -Raw -LiteralPath (Join-Path $S 'issue-953-ci3-shard1/shard-files.json') | ConvertFrom-Json; $sel = @($m.selected | ForEach-Object { [string] $_ }); "SHARD=..."; "MISSING_IN_PREFIX=..."; Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $captured = @{}; $sink = { param([string] $Path, [string] $Json) $captured[$Path] = $Json }.GetNewClosure(); Invoke-PoshQCTest -Root (Get-Location).Path -ShardIndex 1 -ShardCount 3 -ShardFileListPath 'shard-1' -WriteShardFileList $sink -InvokePester { param($Config) $null = $Config } -DisableKoverageCopy *> $null; $local = ...; "LOCAL_SHARD1_EQUALS_CI=..."' (SCRATCH/issue-953-r3-p0-t17.sh; the plan's P0-T17 text verbatim)
EXIT_CODE: 0
Output Summary:
- SHARD=1/3 SELECTED=130 INDEX_850=40
- MISSING_IN_PREFIX=0
- LOCAL_SHARD1_EQUALS_CI=True (observation only; does not gate the task)
- Result: PASS.
