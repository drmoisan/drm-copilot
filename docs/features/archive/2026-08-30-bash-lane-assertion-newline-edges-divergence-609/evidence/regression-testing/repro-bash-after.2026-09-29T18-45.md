# Bash-Lane Reproduction After the Fix (P3-T1)

Timestamp: 2026-10-01T23:40:00-04:00
Command: sh .claude/lib/bash/report-lane-assertion.sh --manifest tests/fixtures/parallel_manifest_payload/parallel.md --edges "999:998<real line break>101:202"   (NOT RUN locally; withheld by operator rule Option A, deviation D5)
EXIT_CODE: NOT-RUN (no local exit code observed; no value fabricated)
Output Summary: no local output. Expected per the plan: exit 0 and first stdout line `Lane assertion: 1 derived conflict component(s); 0 disagreement(s).`, identical to the Python line in `repro-python.2026-09-29T18-45.md`.

Operator-run blocker. Exact command, run in the worktree root at the current head:
sh .claude/lib/bash/report-lane-assertion.sh --manifest tests/fixtures/parallel_manifest_payload/parallel.md --edges "999:998
101:202"

Because this run is absent, AC-1 is not checked off (P4-T10 gap). CI job `shell-coverage` runs the new bats case `edges-parity: a newline-separated value matches the single-line control`, which asserts the same header through the entry point.
