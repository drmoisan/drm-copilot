# r2 Shard and CoverageMerge module edits (P2-T6)

Timestamp: 2026-10-16T16-02
Command: sh "SCRATCH/issue-953-r2-p2-t6.sh" (pwsh text: for each of scripts/powershell/PoshQC/PoshQC.Shard.psm1 and scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1, $errors = $null; [void][System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path <path>).Path, [ref]$null, [ref]$errors); $errors.Count and (Get-Content -LiteralPath <path>).Count; count of lines starting with "function <name> " for the five Shard functions; Select-String -SimpleMatch counts of the P2-T1 to P2-T5 literals)
EXIT_CODE: 0
Output Summary:
  FILE scripts/powershell/PoshQC/PoshQC.Shard.psm1 PARSE_ERRORS=0 LINES=256
  FILE scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1 PARSE_ERRORS=0 LINES=163
  FUNCTION_DEFS Get-PoshQCShardSlice = 1; New-PoshQCShardManifest = 1; Test-PoshQCShardCompleteness = 1; Test-PoshQCShardTestCount = 1; Select-PoshQCShardTestFile = 1
  P2-T1: "[System.Array]::Sort($order, $heaviestFirst)" = 1; "Weight lists $($Weight.Count) values" = 1
  P2-T2: "$sliceArguments['Weight'] = $Weight" = 1; "-TestFile $TestFile -ShardIndex $ShardIndex -ShardCount $ShardCount)" = 0
  P2-T3: "function Select-PoshQCShardTestFile {" = 1; "selects no test file; $($paths.Count) test files cannot fill" = 1; "[OutputType([string[]])]" = 1
  P2-T4: "cannot be recomputed from merged line hits (CR-8)" = 1; lines containing both throw and percent = 0
  P2-T5: "[void] $staleNode.ParentNode.RemoveChild($staleNode)" = 1
