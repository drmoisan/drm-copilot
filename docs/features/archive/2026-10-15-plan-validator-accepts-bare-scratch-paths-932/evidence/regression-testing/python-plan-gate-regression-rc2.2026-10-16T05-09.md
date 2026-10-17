# Python Plan-Gate Regression (Remediation Cycle 2), rerun after the [P2-T6] remediation

Timestamp: 2026-10-16T05-09
Task: [P2-T5]
Command: poetry run pytest tests/scripts/dev_tools/test_plan_gate_discrimination_context.py tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `1 failed, 80 passed in 0.89s`. The single failing node is `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_states_g10_whitespace_alignment` (rule file lacks the three alignment tokens), expected until Phase 4 changes the rule file. No other failure.
