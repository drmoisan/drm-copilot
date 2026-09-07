# R1 Fixtures-Only Suite Run

Timestamp: 2026-09-07T15-00
Task: [P1-T5]

Command: `npx --yes bats --tap tests/shell`
EXIT_CODE: 0

Tree state at the time of the run: the four R1 fixture directories created by [P1-T1] through
[P1-T4] exist (`detached_content_neutral`, `detached_equivalent`, `detached_unique_residuals`,
`detached_equivalent_residual`). No test file and no source file has been modified.

## Observations

```
first line of stream : 1..308
count of lines beginning "ok "     : 308
count of lines beginning "not ok"  : 0
```

Output Summary: the TAP plan count is 308, equal to the [P0-T6] baseline of 308, and no output line
begins with `not ok`. Adding fixture data alone changed no behavior and added no case, which is the
expected result for a phase that adds only checked-in scenario directories that no test yet names.
