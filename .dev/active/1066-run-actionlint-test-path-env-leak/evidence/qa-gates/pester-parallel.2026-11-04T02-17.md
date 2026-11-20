# Final QA: Concurrent-Shard Pester (P4-T5)

Timestamp: 2026-11-04T02-17
Command: pwsh -NoProfile -File SCRATCH/issue-1066-parallel.ps1 -Root <worktree> -Prefix final-parallel -ProfileOut SCRATCH/issue-1066-PP_final.json (Invoke-PoshQCParallelTest; each shard JUnit copied to RAW/final-parallel-shard-<i>.xml and each coverage file to RAW/final-parallel-shard-<i>-coverage.xml); comparison by SCRATCH/issue-1066-par-compare.ps1 against SCRATCH/issue-1066-PP_base.json
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary:
- ExitCode=1 WorkerCount=8 WallClockSeconds=408.76; no merged artifact, because shards 2 to 8 exited non-zero (pre-existing host failures, as in APPROVED P0-T8).
- Per-shard exit codes: 1=0, 2=4, 3=16, 4=6, 5=16, 6=255, 7=19, 8=14.
- Per-shard total/failed: 1: 439/0 (junit); 2: 1546/4 (junit); 3: 2189/16 (junit); 4: 1804/6 (junit); 5: 2046/16 (junit); 6: 2098/14 (summary line; its JUnit does not load as XML); 7: 2394/19 (junit); 8: 1398/14 (junit).
- Every shard directory holds pester-junit.xml and powershell-coverage.xml.
- Summed failed: 89, not greater than the APPROVED P0-T8 value of 90.
- Summed total: 13914 = 13910 (APPROVED P0-T8) + G (4), equal.
- Containers available in both runs other than GUARD: 360 compared, 0 outside their PP_base profile (holds). 72 containers of shard 6 are `unavailable` in this run; 72 containers of shard 5 were `unavailable` in the baseline.
- GUARD container (RCR 3): available from its shard JUnit; tests=4 failed=0 blocks=0 container=0, holds.
- Acceptance: met.
