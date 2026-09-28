# Baseline bats Suite State

Timestamp: 2026-09-07T15-00
Task: [P0-T6]

Command: `npx --yes bats --tap tests/shell`
EXIT_CODE: 0

The TAP stream was redirected to a scratch file outside the repository and then measured. The
measurements taken were the first line of the stream, the count of lines beginning `ok `, and the
count of lines beginning `not ok`.

## Observations

```
first line of stream : 1..308
count of lines beginning "ok "     : 308
count of lines beginning "not ok"  : 0
```

Output Summary: the TAP plan count is 308. The suite exited 0, 308 `ok` lines were printed, and no
output line begins with `not ok`. This is the baseline case count against which Phase 1 (unchanged,
308), Phase 3 (314), and Phase 6 (321) are read.
