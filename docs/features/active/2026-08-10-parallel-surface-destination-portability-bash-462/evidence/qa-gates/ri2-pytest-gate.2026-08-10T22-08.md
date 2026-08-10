# QA Gate — RI-2 Pytest Contract Verification

Timestamp: 2026-08-10T22-08
Issue: #462
Task: [P5-T4]
Head under test: `f8d82e1e1794b3beda66787c526ffe6da2b4a962` (the P5-T3 dispatch head)

This is the executable verification gate for the RI-2 allowlist narrowing. It is a required gate
expected to pass — a missing verification gate being added, not an expected-failure task. It carries
no `[expect-fail]` tag.

## Command

```
poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
```

EXIT_CODE: 0

## Output Summary

```
collected 61 items

tests\scripts\dev_tools\test_parallel_orchestrator_permission_contracts.py .    [  1%]
..                                                                              [  4%]
tests\scripts\dev_tools\test_parallel_orchestrator_surface_contracts.py .       [  6%]
...................................                                             [ 63%]
tests\scripts\dev_tools\test_parallel_planner_surface_contracts.py .....        [ 72%]
..........                                                                      [ 88%]
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py ....        [ 95%]
...                                                                             [100%]

============================= 61 passed in 0.23s ==============================
```

| Metric | Value |
| --- | --- |
| Collected | 61 |
| Passed | **61** |
| Failed | 0 |
| Errored | 0 |
| Skipped | 0 |
| xfailed / xpassed | 0 |
| Duration | 0.23s |

## Why These Files Constitute the RI-2 Gate

Two of the four modules read the RI-2 target files at run time, so they exercise the narrowed grants
directly rather than asserting against a fixture copy:

- `test_parallel_orchestrator_permission_contracts.py` parses the `Bash(...)` grants from the
  `tools:` frontmatter of `.claude/agents/parallel-orchestrator.md` and asserts that **every command
  invocation prescribed in `.claude/skills/parallel-orchestrate/SKILL.md` is covered by a grant**.
  This is the seam that a too-narrow grant would break: if any prescribed bash invocation fell
  outside the three entry-point-specific patterns, the uncovered-invocation assertion would fail.
  It passes, so the narrowed grant set still covers the full prescribed invocation surface
  (uncovered = 0).
- `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  asserts byte-identical text parity for every repo `.claude/**` file against its bundled
  counterpart. This is the executable form of the P3-T4 mirror contract, covering all three edited
  pairs plus every other payload file.

The two surface-contract modules
(`test_parallel_orchestrator_surface_contracts.py`, `test_parallel_planner_surface_contracts.py`)
assert the broader structural contract of the two agent definitions whose frontmatter and prose were
edited, confirming the RI-2 edits did not disturb any other declared contract.

No remediation of the RI-2 edits was required, so no re-dispatch of P5-T3 is triggered by this gate
(the plan's contingency clause does not apply). No production file changed after the P5-T3 dispatch
head `f8d82e1e`.

Output Summary: All 61 tests passed with exit code 0. The permission-contract seam reports full
grant coverage of the prescribed invocation surface under the three narrowed entry-point-specific
grants, and repo/bundle byte parity holds for the entire `.claude/**` payload. RI-2 is verified
executably.
