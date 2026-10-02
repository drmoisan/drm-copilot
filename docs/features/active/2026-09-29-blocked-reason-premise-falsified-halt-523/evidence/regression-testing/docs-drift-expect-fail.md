# P6-T2 Documentation drift tests before the documentation edits [expect-fail]

Timestamp: 2026-09-30T10-53
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py -k test_docs_
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Final line: `19 failed, 13 passed, 22 deselected in 0.15s`.
- Failing (19): `test_docs_enumeration_lists_every_vocabulary_member` for the five new members (`awaiting_ci`, `external_dependency`, `human_decision_required`, `policy_hold`, `premise_falsified`); `test_docs_rules_section_lists_every_vocabulary_member` for all twelve members (the `## Blocked-Reason Vocabulary` section is absent); `test_docs_rules_section_declares_extension_point_for_484`; `test_docs_workflow_skill_carries_partition_paragraph`.
- Passing (13): `test_docs_enumeration_lists_every_vocabulary_member` for `none` and the six mechanical members (7), and `test_docs_enumeration_keeps_documentation_only_members` for all six documentation-only members (6).
- The failures are on the missing new members and the missing rules section; the documentation-only-members test passes, as the task requires.
