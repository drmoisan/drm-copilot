# r2 PoshQC.Testing.psm1 edit (P2-T7 to P2-T9)

Timestamp: 2026-10-16T16-03
Command: sh "SCRATCH/issue-953-r2-p2-t9.sh" (pwsh text: ParseFile error count; (Get-Content -LiteralPath scripts/powershell/PoshQC/PoshQC.Testing.psm1).Count; @(Select-String -LiteralPath scripts/powershell/PoshQC/PoshQC.Testing.psm1 -SimpleMatch -Pattern '<token>').Count for each token below)
EXIT_CODE: 0
Output Summary:
  PARSE_ERRORS=0
  LINES=479 (484 before; CR-17, AC-15)
  COUNT [5.99.99] = 1
  COUNT [-MaximumVersion $MaximumVersion] = 1
  COUNT [Set-Content -LiteralPath $Path -Value $Json -Encoding utf8] = 1 (default WriteShardFileList seam body intact)
  COUNT [size-balanced slice of the test files (Select-PoshQCShardTestFile)] = 1 (P2-T7)
  COUNT [Select-PoshQCShardTestFile -RootPath $Root] = 1 (P2-T8)
  COUNT [New-PoshQCShardManifest] = 0 (P2-T8)
  COUNT [round-robin] = 0
