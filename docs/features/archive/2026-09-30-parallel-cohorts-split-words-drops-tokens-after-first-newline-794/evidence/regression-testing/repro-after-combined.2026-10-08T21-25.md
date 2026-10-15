# Post-fix reproduction, combined keys and edges (P3-T3)

Timestamp: 2026-10-09T07-09
Command: sh .claude/lib/bash/compute-cohorts.sh --keys "1<LF>2<LF>3" --edges "1:2<LF>2:3"   (after P2-T3 and the mirror update)
EXIT_CODE: 0
Output Summary: stdout `[[2],[1,3]]`, equal to the P1-T2 control; the false membership error is resolved.

stdout: [[2],[1,3]]
