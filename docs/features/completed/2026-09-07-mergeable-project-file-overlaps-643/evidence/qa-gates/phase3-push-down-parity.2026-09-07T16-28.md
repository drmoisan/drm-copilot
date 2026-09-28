# Phase 3 QA Gate — push-down resource contracts and pack publication (issue #643)

Timestamp: 2026-09-07T16-28

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py -v`

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary:

`1 failed, 32 passed in 0.34s`. The single failure is the pre-existing
local-only failure covered by the C4 bounded exemption; the C4 conditions are
re-checked below and all three hold.

The two node IDs the task requires are reported as passed:

```
tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py::test_push_down_no_arguments_publishes_full_tree PASSED
tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py::test_push_down_claude_repeated_generation_is_deterministic PASSED
```

## Failing node IDs, with messages

```text
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

```text
E           AssertionError: Repo file missing from bundle: .claude\state\current-session-id
E           assert WindowsPath('.claude/state/current-session-id') in [WindowsPath('.claude/agent-memory/epic-orchestrator/feedback_commit_push_memory_before_pr.md'), ...]
```

## C4 bounded-exemption check

1. The failing node ID set is exactly the set recorded by [P0-T7] in
   `evidence/baseline/python-pytest-coverage.2026-09-07T15-15.md`: the single
   node `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
2. The run reports exactly that many failures: `1 failed`.
3. The sole assertion message names a path under `.claude/state/`
   (`.claude/state/current-session-id`).

All three conditions hold, so the run satisfies the acceptance condition under
the C4 exemption. This failure is issue #510 and is green in CI.

The C4 masking argument holds on this run as stated in the plan: `list_scoped_files`
sorts its paths, and `.claude/agents`, `.claude/lib`, `.claude/rules`, and
`.claude/skills` all sort before `.claude/state`, so a mirror defect introduced by
this plan would have surfaced ahead of the exempted assertion. The mirror added by
[P3-T5] (`.claude/lib/blast-radius/BlastRadiusConflict.psm1`) did not raise an
assertion, which is the positive signal that the bundled counterpart is present.
