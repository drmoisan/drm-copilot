# Skill Contract Fail-Before Evidence (P2-T3, Issue #849)

Timestamp: 2026-10-10T10-20
Command: poetry run pytest tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py
ExpectedExitCode: 1
EXIT_CODE: 1
State: before any skill or rule-document edit (Phase 4 not started).

## Summary line (verbatim)

```text
========================= 8 failed, 3 passed in 0.13s =========================
```

## Failed node IDs (verbatim)

```text
FAILED tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py::test_parallel_plan_item_intake_declares_issue_number_items_adopted
FAILED tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py::test_parallel_plan_fan_out_carries_issue_adoption_prompt_line
FAILED tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py::test_parallel_plan_issue_adoption_line_carries_no_mode_marker
FAILED tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py::test_parallel_orchestrate_element_four_carries_issue_adoption
FAILED tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py::test_added_skill_text_does_not_match_hook_issue_number_pattern[parallel-plan-adoption-line]
FAILED tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py::test_rule_doc_states_origin_conditional_potential_record
FAILED tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py::test_skill_states_origin_conditional_potential_record[feature-promotion-lifecycle]
FAILED tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py::test_skill_states_origin_conditional_potential_record[orchestrate]
```

## Passing cases

The three passing cases are `test_parallel_plan_kickoff_line_is_unchanged`, `test_parallel_orchestrate_kickoff_keeps_five_elements`, and `test_added_skill_text_does_not_match_hook_issue_number_pattern[parallel-orchestrate-element-four]` (the 11 collected cases minus the 8 failed node IDs above).

## Failure messages (verbatim, in order)

```text
E       AssertionError: Item Intake lacks the adoption statement
E           AssertionError: expected exactly one line starting '> `Issue adoption:' in ## Preparation Fan-Out, found 0
E           AssertionError: expected exactly one line starting '> `Issue adoption:' in ## Preparation Fan-Out, found 0
E       AssertionError: element 4 does not name issue_adoption
E           AssertionError: expected exactly one line starting '> `Issue adoption:' in ## Preparation Fan-Out, found 0
E           AssertionError: rule document lacks: required when `origin` is `epic_decomposition`
E           AssertionError: feature-promotion-lifecycle skill lacks: required when `origin` is `epic_decomposition`
E           AssertionError: orchestrate skill lacks: required when `origin` is `epic_decomposition`
```

Output Summary: EXIT_CODE 1 equals ExpectedExitCode 1. 8 failed, 3 passed. Passing cases are the kickoff-line guard, the five-element guard, and the parallel-orchestrate-element-four hook-pattern guard. Every failure is a missing-text assertion against the unedited skill and rule documents (AC-10 fail-before).
