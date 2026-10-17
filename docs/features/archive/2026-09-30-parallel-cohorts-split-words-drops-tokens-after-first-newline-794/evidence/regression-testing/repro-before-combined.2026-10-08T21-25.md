# Defect reproduction, combined keys and edges (P1-T5)

Timestamp: 2026-10-09T07-02
Command: sh .claude/lib/bash/compute-cohorts.sh --keys "1<LF>2<LF>3" --edges "1:2<LF>2:3"   (double-quoted arguments with real line breaks)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: exit 1 with the false membership error that the P2-T3 companion fix resolves.

stderr: Conflict edge (1, 2) names item key 1, which is not a member of item_keys; every edge endpoint must be a declared item key.
