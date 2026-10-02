# Python Parity Tests Before the Fix (P2-T5, expect-fail)

Timestamp: 2026-10-01T21-41
Task: P2-T5
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_remediation_loop_parity.py -v
EXIT_CODE: 1
ExpectedExitCode: 1

Key lines:

```
tests/scripts/dev_tools/test_orchestrator_state_remediation_loop_parity.py::test_corpus_case_reproduces_expected_errors[r5_candidate_applied_string] FAILED [ 69%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_loop_parity.py::test_corpus_case_reproduces_expected_errors[verdict_pass_valid] PASSED [ 97%]
======================== 30 failed, 55 passed in 0.22s ========================
```

Failing set (30, all `test_corpus_case_reproduces_expected_errors[...]`): combined_legacy_and_new_errors_order, r10_awaiting_ci_with_policy_hold, r10_halt_with_empty_findings, r10_pass_with_autonomous_finding, r11_opened_by_awaiting_ci_outcome, r11_opened_by_halt_outcome, r11_opened_by_review_negative, r11_opened_by_review_null, r11_opened_by_review_out_of_range, r11_opened_by_review_without_review_outcomes, r5_candidate_applied_integer, r5_candidate_applied_string, r6_candidate_applied_true_execution_failed, r7a_completed_attempts_negative, r7a_completed_attempts_null, r7a_completed_attempts_string, r7b_completed_attempts_mismatch, r7b_completed_attempts_positive_without_cycles, r8a_review_outcomes_string, r8b_review_outcome_integer, r9a_verdict_case_variant_pass, r9a_verdict_integer, r9a_verdict_lowercase_halt, r9a_verdict_null, r9b_findings_missing, r9c_finding_non_object, r9d_remediability_case_variant_autonomous, r9d_remediability_integer, r9d_remediability_null, r9d_remediability_verdict_literal_as_class.

Output Summary: EXIT_CODE 1; 30 failed, 55 passed. The 30 failures are exactly the corpus cases whose `expected_errors` list is non-empty (the unmodified validator emits no R5-R11 message; `combined_legacy_and_new_errors_order` emits only its legacy plan_path message). The 11 cases with empty expectations, the 41 name-equals-stem cases, the two count tests, and `test_corpus_covers_every_new_message` pass. A `FAILED` line names `r5_candidate_applied_string`; a `PASSED` line names `verdict_pass_valid`. This is the expected pre-fix failure.
