# Defect reproduction, edges (P1-T4)

Timestamp: 2026-10-09T07-02
Command: sh .claude/lib/bash/compute-cohorts.sh --keys "1 2 3" --edges "1:2<LF>2:3"   (double-quoted argument with a real line break between 1:2 and 2:3)
EXIT_CODE: 0
Output Summary: stdout `[[1,3],[2]]`; edge 2:3 is silently dropped. The P1-T2 control is `[[2],[1,3]]`.

stdout: [[1,3],[2]]
