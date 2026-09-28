# Phase 5 QA gate — surface contracts and push-down

Timestamp: 2026-09-07T17-50

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py -v`

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary: 55 passed, 1 failed. The single failure is the pre-existing
local-only failure covered by the C4 bounded exemption (issue #510). All five
acceptance-named tests passed. The permission-contract suite binds the skill's
prescribed commands to the agent's grants and passes with the four grants added
by [P5-T15] and the sub-steps added by [P5-T16].

## Acceptance-named tests

```text
tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_agent_tools_allowlist_excludes_pr_author_channel PASSED
tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_agent_body_contains_exactly_the_nine_required_headings PASSED
tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_orchestrate_skill_first_thirteen_headings_match_required_layout PASSED
tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_orchestrate_skill_section_states_its_required_obligations[merge-conflict-exhaustion-and-f8-handoff] PASSED
tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py::test_push_down_no_arguments_publishes_full_tree PASSED
```

## Failing node IDs with messages

Exactly one node failed:

```text
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

Assertion message (verbatim):

```text
E           AssertionError: Repo file missing from bundle: .claude\state\current-session-id
```

## C4 bounded exemption

All three C4 conditions hold on this run:

1. The failing node ID set is exactly the single node recorded by [P0-T7] in
   `<FEATURE>/evidence/baseline/python-pytest-coverage.2026-09-07T15-15.md`.
2. The run reports exactly one failure (`1 failed, 55 passed`).
3. The sole assertion message names a path under `.claude/state/`.

Because `list_scoped_files` sorts paths and `.claude/agents`, `.claude/lib`,
`.claude/rules`, and `.claude/skills` all sort before `.claude/state`, the three
new files under `.claude/lib/project-file-merge/` and the two edited files under
`.claude/agents/` and `.claude/skills/` would have surfaced ahead of the exempted
assertion had any of their mirrors been absent. They did not, which is
independently confirmed by the byte-identical-counterpart case of [P5-T11].

## Defect found and corrected during this task

The first run of this command also failed
`test_every_prescribed_command_invocation_has_a_persona_bash_grant`, reporting an
uncovered invocation `' and continue with step 1 below, including '`. The cause
was in the [P5-T16] insertion: a backticked command span had been wrapped across
a line break, which desynchronized the suite's line-oriented backtick-span
parser and made it read ordinary prose as a command. The sub-steps were rewritten
so every backticked command span sits on one line, the mirror was refreshed, and
the suite passes. No production behaviour was involved.
