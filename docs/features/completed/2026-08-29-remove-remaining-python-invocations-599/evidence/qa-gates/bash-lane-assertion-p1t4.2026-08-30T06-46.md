# [P1-T4] pla_derive_components bats gate

Timestamp: 2026-08-30T06-46

Command: `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "derive_components"'`

EXIT_CODE: 0

Output Summary: TAP plan line `1..1`; one `ok` line; zero lines beginning
`not ok`. Verbatim output:

```
1..1
ok 1 derive_components partitions declared keys deterministically
```

Acceptance: met. Exit code 0 with 0 failures.

Inputs the case covers, matching the task enumeration: an isolated vertex
(`104`), a self-loop (`103:103`), an undeclared endpoint (`101:999`,
`999:101`), and reversed plus duplicated edges (`102:101` with `101:102`). The
case additionally pins component ordering by lowest member, a two-hop chain, and
the empty partition.

Ordering note: components are produced already ordered by lowest member because
breadth-first search starts from each unvisited root in ascending key order, so
a component's first root is necessarily its smallest member. No second sort over
components is performed; the Python reference's `sorted(..., key=members[0])` is
a no-op on the same sequence.
