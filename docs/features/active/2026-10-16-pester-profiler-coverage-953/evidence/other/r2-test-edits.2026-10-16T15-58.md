# r2 test edits verification (P1-T10)

Timestamp: 2026-10-16T15-58
Command: git diff --numstat 136d02fcb4ab6b87f87dc01479571f028262119b -- tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1 tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1 tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1; sh "SCRATCH/issue-953-r2-p1-t1.sh" ((Get-Content -LiteralPath <path>).Count, ParseFile error counts, and the P1-T1 to P1-T9 token counts)
EXIT_CODE: 0
Output Summary:
  numstat (exactly the four test files):
    21 3 tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1
    36 1 tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1
    42 0 tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1
    97 1 tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
  line counts (each at most 500, AC-15; 0 parse errors each):
    LINES: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 217
    LINES: tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1 172
    LINES: tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1 189
    LINES: tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1 157
  task acceptance counts: -ShardCount 3 = 0; $script:GetResultGateViolation = { = 1; WF01..WF05 = 1 each; SH01 = 1 and the new SH01 description = 1; SH10..SH12 = 1 each; the CR-8 METHOD literal = 1 and "are kept from the first report" = 0; the LINE/INSTRUCTION XPath on 2 lines; CM08 = 1; TS04..TS06 = 1 each.
