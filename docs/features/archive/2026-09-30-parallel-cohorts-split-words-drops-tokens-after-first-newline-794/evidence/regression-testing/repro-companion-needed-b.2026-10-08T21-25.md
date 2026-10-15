# Companion-fix observation b (P2-T2)

Timestamp: 2026-10-09T07-08
Command: sh .claude/lib/bash/compute-cohorts.sh --keys "1<LF>2<LF>3" --edges "1:2<LF>2:3"   (library modified by P2-T1 only)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: exit 1 with `Conflict edge (1, 2) names item key 1`; the tokenizer fix alone does not make multi-line keys and edges work, so P2-T3 is required.

stderr: Conflict edge (1, 2) names item key 1, which is not a member of item_keys; every edge endpoint must be a declared item key.
