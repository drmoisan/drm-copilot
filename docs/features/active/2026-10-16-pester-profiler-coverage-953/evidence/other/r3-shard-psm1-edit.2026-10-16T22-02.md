# r3 PoshQC.Shard.psm1 Edit Verification (P4-T1, P4-T2, P4-T3, P4-T4)

Timestamp: 2026-10-16T22-02
Command: git diff --numstat 7558c7e42ec8c8955cb5f9997cca41afc6e3b797 -- scripts/powershell/PoshQC/PoshQC.Shard.psm1; export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $f = 'scripts/powershell/PoshQC/PoshQC.Shard.psm1'; ParseFile error count; (Get-Content -LiteralPath $f).Count; count of lines matching ^function <name>\s*\{ for each of the six functions; Select-String -SimpleMatch counts of the literals created by P4-T1 to P4-T3 and of "[long] $_.Length"' (SCRATCH/issue-953-r3-p4-t4.sh)
EXIT_CODE: 0
Output Summary:
- numstat: `45	5	scripts/powershell/PoshQC/PoshQC.Shard.psm1` (45 added, 5 deleted)
- PARSE_ERRORS=0
- LINES=296 (256 + 5 + 35; AC-15)
- Function definitions, each exactly 1: Get-PoshQCShardSlice, New-PoshQCShardManifest, Test-PoshQCShardCompleteness, Test-PoshQCShardTestCount, Select-PoshQCShardTestFile, Get-PoshQCShardTestFileWeight
- P4-T1 literals: `Weight must not be negative;` 1; `or a weight is negative (CR-18).` 1
- P4-T2 literals: `$weights = [long[]] @(Get-PoshQCShardTestFileWeight -TestFile $TestFile)` 1; `[long] $_.Length` 0
- P4-T3 literals: `function Get-PoshQCShardTestFileWeight {` 1; `$weights.Add([System.Text.Encoding]::UTF8.GetByteCount($text.Replace(` 1
- Batch budget: this is the only production PowerShell file written with the Edit tool in this cycle; the hook did not deny any write.
- Result: PASS.
