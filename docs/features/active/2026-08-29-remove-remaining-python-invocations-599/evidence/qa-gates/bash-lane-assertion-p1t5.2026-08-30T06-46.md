# [P1-T5] pla_compare bats gate

Timestamp: 2026-08-30T06-46

Command: `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "compare emits findings"'`

EXIT_CODE: 0

Output Summary: TAP plan line `1..1`; one `ok` line; zero lines beginning
`not ok`. Verbatim output:

```
1..1
ok 1 compare emits findings in the fixed class order
```

Acceptance: met. Exit code 0 with 0 failures.

The case covers one finding of each of the four classes and a key repeated
across two asserted lanes (`106` in `dup-a` and `dup-b`), asserting that the
expected index resolves it to the later lane (`5`) and that no finding is
emitted for the repetition.

## Supporting cross-check against the Python reference

Command: `cd C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && poetry run python -m scripts.dev_tools.parallel_lane_assertion --manifest <scratch>/four-class.md --edges "101:102"`

EXIT_CODE: 0

Output Summary: the reference emits the same four findings, in the same class
order, with byte-identical kind tokens and detail text, over the same manifest
the bats case builds inline:

```
Lane assertion: 5 derived conflict component(s); 3 disagreement(s).
ADVISORY [expected_together_derived_apart] expected component 'split-lane' was derived apart: its members occupy 2 distinct conflict components.
ADVISORY [expected_apart_derived_together] derived conflict component [101, 102] spans 2 expected components that were asserted apart.
ADVISORY [member_names_no_item] expected member 999 names no manifest item.
ADVISORY [item_covered_by_no_component] manifest item 105 is covered by no expected component.
Advisory only: this diagnostic never blocks, never modifies a derived edge, never feeds compute_cohorts, and never influences scheduling.
```

This cross-check is a de-risking observation for the Phase 3 parity corpus, not
an acceptance condition of this task. The manifest was written outside the
repository, under the session scratchpad, so no temporary file was created in
the tree and no fixture was added ahead of Phase 3.
