# Defect reproduction, keys (P1-T3)

Timestamp: 2026-10-09T07-02
Command: sh .claude/lib/bash/compute-cohorts.sh --keys "1<LF>2"   (double-quoted argument with a real line break between 1 and 2)
EXIT_CODE: 0
Output Summary: stdout `[[1]]`; key 2 is silently dropped with no diagnostic. The control for `--keys "1 2"` is `[[1,2]]`.

stdout: [[1]]
