# r2 projected shard balance (P4-T5, CR-10)

Timestamp: 2026-10-16T16-08
Command: sh "SCRATCH/issue-953-r2-p4-t5.sh" (the P4-T5 task PowerShell text verbatim: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; three Invoke-PoshQCTest calls with -ShardIndex 1..3 -ShardCount 3, an injected WriteShardFileList sink, and an injected InvokePester that does not run Pester; byte sums per shard for the LPT manifests and for a position round-robin of the 'all' list; Test-PoshQCShardCompleteness)
EXIT_CODE: 0
Output Summary:
  FILE_COUNT=388 TOTAL_BYTES=5182895 MAX_FILE_BYTES=42378
  RR_BYTES=1645771,1721565,1815559
  LPT_BYTES=1727855,1727374,1727666
  LPT_FILES=130,129,129
  LPT_SPREAD=481
  COMPLETE=True
  CI_RUN_38909263798_TEST_STEP_SECONDS: 214,340,603
  RR_BYTE_ORDER_MATCHES_CI_ORDER: YES (RR_BYTES rank shard 3 above shard 2 above shard 1, as the CI durations do)
  Checks: sum(LPT_BYTES) = 5182895 = TOTAL_BYTES; sum(RR_BYTES) = 5182895 = TOTAL_BYTES; every LPT_FILES value is at least 1; LPT_SPREAD 481 <= MAX_FILE_BYTES 42378.
  Byte counts depend on the local line-ending configuration and are a proxy for duration, not a measured duration. Reference task P8-T19 records the authoritative per-shard timings on the PR head.
