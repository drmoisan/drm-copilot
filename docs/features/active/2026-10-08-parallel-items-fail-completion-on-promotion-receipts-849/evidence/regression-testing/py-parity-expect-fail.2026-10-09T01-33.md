# Python Parity Fail-Before Evidence (P2-T1, Issue #849)

Timestamp: 2026-10-10T10-18
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py
ExpectedExitCode: 1
EXIT_CODE: 1
State: before the validator change (Phase 3 not started); corpus at 34 fixtures with the five P1 fixtures; `MINIMUM_CORPUS_COUNT = 34`.

## Summary line (verbatim)

```text
======================== 3 failed, 34 passed in 0.13s =========================
```

## Failed node IDs (verbatim)

```text
FAILED tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py::test_corpus_document_reproduces_the_expected_routing_errors[valid-bug-large-filed-before-orchestration-without-record]
FAILED tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py::test_corpus_document_reproduces_the_expected_routing_errors[valid-bug-preparation-filed-before-orchestration-without-record]
FAILED tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py::test_corpus_document_reproduces_the_expected_routing_errors[valid-large-transferred-waives-feature-entry-tool-without-record]
```

The failed set is exactly the parametrized cases for the D1 (`valid-bug-preparation-filed-before-orchestration-without-record`), D2 (`valid-bug-large-filed-before-orchestration-without-record`), and D3 (`valid-large-transferred-waives-feature-entry-tool-without-record`) stems. The D4 and D5 cases pass.

## D1 failure output (verbatim)

```text
E       AssertionError: Corpus case valid-bug-preparation-filed-before-orchestration-without-record produced routing errors ['Checkpoint missing successful MCP receipt: new_potential_bug_entry.', 'Checkpoint missing successful MCP receipt: potential_to_issue.', 'Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving new_potential_bug_entry.'] that differ from its expected_errors block [].
E       assert ['Checkpoint ...l_bug_entry.'] == []
E         
E         Left contains 3 more items, first extra item: 'Checkpoint missing successful MCP receipt: new_potential_bug_entry.'
E         Use -v to get more diff
```

The D1 output contains the token `when waiving new_potential_bug_entry` (rule 9) and both missing-receipt errors (`new_potential_bug_entry` and `potential_to_issue`): AC-7 fail-before.

## D2 and D3 failure messages (verbatim)

```text
E       AssertionError: Corpus case valid-bug-large-filed-before-orchestration-without-record produced routing errors ['Checkpoint missing successful MCP receipt: new_potential_bug_entry.', 'Checkpoint missing successful MCP receipt: potential_to_issue.', 'Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving new_potential_bug_entry.'] that differ from its expected_errors block [].
E       AssertionError: Corpus case valid-large-transferred-waives-feature-entry-tool-without-record produced routing errors ['Checkpoint missing successful MCP receipt: new_potential_entry.', 'Checkpoint missing successful MCP receipt: potential_to_issue.', 'Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving new_potential_entry.'] that differ from its expected_errors block [].
```

Output Summary: EXIT_CODE 1 equals ExpectedExitCode 1. 3 failed, 34 passed. Failures are exactly the D1, D2, and D3 corpus cases; each reports two missing-receipt errors plus the rule-9 potential_record error, showing the resolver waives nothing when origin is transferred or filed_before_orchestration and the record is absent.
