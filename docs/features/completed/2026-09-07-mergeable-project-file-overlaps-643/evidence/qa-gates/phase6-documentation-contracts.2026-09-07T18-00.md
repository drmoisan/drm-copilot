# Phase 6 gate — documentation and surface contracts

Timestamp: 2026-09-07T18-00

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v`

EXIT_CODE: 1

## Output Summary

Result line, verbatim:

```text
1 failed, 78 passed in 0.47s
```

Required assertions of the task, observed verbatim in the run output:

```text
tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_agent_body_contains_exactly_the_nine_required_headings PASSED [ 11%]
tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_checkpoint_section_states_the_four_arrays_never_written PASSED [ 36%]
```

Both planner surface-contract modules, the rule-frontmatter module, and every push-down resource
contract other than the exempted node passed. The nine-heading and four-array contracts confirm that
the Phase 6 edits to `.claude/agents/parallel-orchestrator.md` and
`.claude/skills/parallel-orchestrate/SKILL.md` added no `##` heading and did not disturb the pinned
checkpoint prose (constraint C5).

## Failing node IDs

Exactly one:

```text
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
E           AssertionError: Repo file missing from bundle: .claude\state\current-session-id
```

## C4 bounded exemption

`EXIT_CODE: 1` is accepted under constraint C4. All three conditions hold and are checked against the
Phase 0 record `evidence/baseline/python-pytest-coverage.2026-09-07T15-15.md`:

1. The failing node ID set is exactly the set P0-T7 recorded — the single node
   `test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
2. The run reports exactly that many failures: `1 failed`.
3. The sole assertion message names a path under `.claude/state/`
   (`.claude/state/current-session-id`), the same path P0-T7 recorded.

Because `list_scoped_files` sorts paths and `.claude/agents`, `.claude/lib`, `.claude/rules`, and
`.claude/skills` all sort before `.claude/state`, a mirror defect introduced by this plan would have
surfaced before the exempted assertion. It did not.
