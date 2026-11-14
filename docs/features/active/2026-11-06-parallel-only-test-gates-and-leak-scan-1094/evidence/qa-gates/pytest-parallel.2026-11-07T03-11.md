# Pytest Parallel Gate

Timestamp: 2026-11-07T03-11
Command: poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov --cov-report=json:SCRATCH/pytest-coverage.json --junitxml=SCRATCH/pytest-junit.xml
EXIT_CODE: 0
Output Summary: 16103 passed, 6 skipped, 0 failures, 0 errors in 157.29 s (JUnit: 16109 tests). Each of test_execution_environment_fact_is_unchanged_across_copies, test_codex_orchestrator_workflow_requires_large_path_evidence_gates, test_validate_policy_audit_text_accepts_no_pre_change_run_record, test_comparison_line_baseline_label_reaches_later_percentage, test_brief_test_isolation_states_parallel_gates, test_brief_copies_carry_no_removed_run_tokens, test_brief_passages_state_parallel_gate_facts, and test_contract_premortem_test_isolation_states_parallel_gates appears once and passed. JSON totals: line 49.52% (16522 of 33367 statements), branch 45.29% (5669 of 12516 branches). The item worktree shares a virtual environment whose path entry names the main checkout, which likely accounts for the low totals; this cause was not verified. No production file changed, so no per-file coverage gate applies.
