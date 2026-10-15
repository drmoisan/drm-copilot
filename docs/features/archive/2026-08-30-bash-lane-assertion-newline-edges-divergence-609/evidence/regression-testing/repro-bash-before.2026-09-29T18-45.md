# Bash-Lane Reproduction Before the Fix (P1-T5)

Timestamp: 2026-10-01T23:25:30-04:00
Command: sh .claude/lib/bash/report-lane-assertion.sh --manifest tests/fixtures/parallel_manifest_payload/parallel.md --edges "999:998<real line break>101:202"   (NOT RUN locally; withheld by operator rule Option A, deviation D5)
EXIT_CODE: NOT-RUN (no local exit code observed; no value fabricated)
Output Summary: no local output. The command text contains a shell-entry word the worktree isolation guard policy refuses, and Option A forbids routing around it. Expected result per the plan: exit 0 and first stdout line `Lane assertion: 2 derived conflict component(s); 0 disagreement(s).` (the truncated result).

Operator-run blocker. Exact command for the operator, run in the worktree root before the fix commit (parent of the Phase 2 commit; check out the Phase 1 commit or run before the fix is applied):
sh .claude/lib/bash/report-lane-assertion.sh --manifest tests/fixtures/parallel_manifest_payload/parallel.md --edges "999:998
101:202"
(the value is the double-quoted text `999:998`, a real line break, then `101:202`).

Authority: the CI job `shell-coverage` on the pushed head covers the fixed behavior through the six new bats cases (cases 1, 3, 4, and 6 fail on the unmodified library).
