# Bats Cases Added (P1-T1)

Timestamp: 2026-10-01T23:20:00-04:00
Command: grep -c -F 'edges-parity:' tests/shell/parallel_lane_assertion.bats ; grep -c '^@test' tests/shell/parallel_lane_assertion.bats ; wc -l tests/shell/parallel_lane_assertion.bats ; git add tests/shell/parallel_lane_assertion.bats ; git status --porcelain -- tests/shell/parallel_lane_assertion.bats   (each run as a separate plain command)
EXIT_CODE: 0 for each command
Output Summary:
- `grep -c -F 'edges-parity:'` printed `6`.
- `grep -c '^@test'` printed `22` (16 existing plus 6 new).
- `wc -l` printed `495 tests/shell/parallel_lane_assertion.bats` (limit 500).
- `git status --porcelain` printed `M  tests/shell/parallel_lane_assertion.bats` (staged).
- Non-ASCII byte count in the file: 0 (`grep -c -P '[^\x00-\x7F]'` printed `0`).

The verbatim 12-line helper block (`EDGES_MERGED_HEADER`, `EDGES_SPLIT_HEADER`, comment, `edges_header_is`) was inserted directly after the case `the port drops an --edges endpoint outside the strict integer lexis`, followed by the six cases with the exact titles and ANSI-C inputs from the plan. Case (4) passes both of its values in one call. 4-space indentation used throughout.
