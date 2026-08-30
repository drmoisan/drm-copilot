# [P1-T2] pla_parse_edges bats gate

Timestamp: 2026-08-30T06-46

Command: `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "parse_edges"'`

EXIT_CODE: 0

Output Summary: TAP plan line `1..1`; one `ok` line; zero lines beginning
`not ok`, which is the "0 failures" assertion in TAP form. Verbatim output:

```
1..1
ok 1 parse_edges keeps input order and drops malformed tokens
```

Acceptance: met. Exit code 0 with 0 failures.

Coverage of the five inputs the task enumerates: empty value, whitespace-only
value, token with no colon (`909`), token with two colons (`1:2:3`), token with
a non-integer endpoint (`40:x`, `y:50`). The case additionally pins input-order
preservation and the strict-lexis exclusions (`007:1`, `+5:6`, `1_0:2`).
