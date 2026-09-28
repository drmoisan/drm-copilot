# [P1-T6] pla_format_report bats gate

Timestamp: 2026-08-30T06-46

Command: `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "format_report"'`

EXIT_CODE: 0

Output Summary: TAP plan line `1..1`; one `ok` line; zero lines beginning
`not ok`. Verbatim output:

```
1..1
ok 1 format_report renders the header, findings, and closing line
```

Acceptance: met. Exit code 0 with 0 failures.

The case covers an absent name (renders `component[0]`), an empty-string name
(renders `''`), and a two-member derived component (renders `[105, 106]`). It
additionally asserts the full report string for a findings-bearing manifest and
for an agreeing manifest that renders only the header and the closing line, and
asserts that the disagreement count is 3 while the finding count is 4, which
pins the informational class out of the header count.

## Supporting cross-check against the Python reference

Command: `cd C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && poetry run python -m scripts.dev_tools.parallel_lane_assertion --manifest <scratch>/rendering.md --edges "105:106"`

EXIT_CODE: 0

Output Summary: the reference produces a report byte-identical to the value the
port places in `PLA_REPORT`, including both label forms and the list form:

```
Lane assertion: 6 derived conflict component(s); 3 disagreement(s).
ADVISORY [expected_together_derived_apart] expected component component[0] was derived apart: its members occupy 2 distinct conflict components.
ADVISORY [expected_together_derived_apart] expected component '' was derived apart: its members occupy 2 distinct conflict components.
ADVISORY [expected_apart_derived_together] derived conflict component [105, 106] spans 2 expected components that were asserted apart.
ADVISORY [item_covered_by_no_component] manifest item 107 is covered by no expected component.
Advisory only: this diagnostic never blocks, never modifies a derived edge, never feeds compute_cohorts, and never influences scheduling.
```

This cross-check is a de-risking observation for the Phase 3 parity corpus, not
an acceptance condition of this task. The manifest was written outside the
repository, under the session scratchpad.
