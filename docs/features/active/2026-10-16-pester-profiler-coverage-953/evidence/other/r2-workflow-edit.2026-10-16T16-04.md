# r2 workflow edit verification (P2-T10 to P2-T13)

Timestamp: 2026-10-16T16-04
Command: git diff --numstat 136d02fcb4ab6b87f87dc01479571f028262119b -- .github/workflows/_poshqc.yml; git show 136d02fcb4ab6b87f87dc01479571f028262119b:.github/workflows/_poshqc.yml (saved to SCRATCH/issue-953-r2-head-poshqc.yml); sh "SCRATCH/issue-953-r2-p2-t13.sh" ((Get-Content -LiteralPath .github/workflows/_poshqc.yml).Count; @(Select-String -LiteralPath .github/workflows/_poshqc.yml -SimpleMatch -Pattern 'if: always()').Count; @(Select-String -LiteralPath .github/workflows/_poshqc.yml -SimpleMatch -Pattern 'cancelled()').Count; lines 1-5 comparison; poshqc-linux-hooks block comparison); sh "SCRATCH/issue-953-r2-p2-t12.sh" (Select-String -SimpleMatch counts of the P2-T10 to P2-T12 literals)
EXIT_CODE: 0
Output Summary:
  numstat: 6 added, 5 deleted (.github/workflows/_poshqc.yml)
  LINES=186 (head 185)
  IF_ALWAYS_COUNT=3 at lines 65,79,181 of the edited file (head lines 65,79,180; the job-level line 79 is kept under D17)
  CANCELLED_COUNT=0
  LINES_1_5_IDENTICAL=True (on: block unchanged)
  poshqc-linux-hooks block (37 lines) IDENTICAL=True
  P2-T10: round-robin = 0
  P2-T11: "-ShardCount ${{ strategy.job-total }}" = 1; "-ShardCount 3" = 0
  P2-T12: "1..3" = 0; "1..$shardCount" = 2 lines
