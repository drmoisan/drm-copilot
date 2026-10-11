# Regression: AC-tracking pin and mirror contracts pass after the edits ([P4-T10], AC-9)

Timestamp: 2026-10-09T21-21
Command: poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -v
EXIT_CODE: 0
Output Summary: 56 passed in 0.63s; 0 failed. All required PASSED node IDs are present (listed below; progress-percentage suffixes removed).

```
test_completion_gate_documentation_contracts.py::test_acceptance_criteria_tracking_skill_defines_ci_dependent_rule[claude] PASSED
test_completion_gate_documentation_contracts.py::test_acceptance_criteria_tracking_skill_defines_ci_dependent_rule[agents] PASSED
test_completion_gate_documentation_contracts.py::test_acceptance_criteria_tracking_skill_defines_ci_dependent_rule[github] PASSED
test_completion_gate_documentation_contracts.py::test_acceptance_criteria_tracking_skill_cross_references_ci_dependent_exception[claude] PASSED
test_completion_gate_documentation_contracts.py::test_acceptance_criteria_tracking_skill_cross_references_ci_dependent_exception[agents] PASSED
test_completion_gate_documentation_contracts.py::test_acceptance_criteria_tracking_skill_cross_references_ci_dependent_exception[github] PASSED
test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[claude-ac-tracking] PASSED
test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[agents-ac-tracking] PASSED
test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[github-ac-tracking] PASSED
test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts PASSED
============================= 56 passed in 0.63s ==============================
```

Acceptance (AC-9): exit 0; zero failed; all named PASSED lines present. Fail-before counterpart: ac-pin-fail-before.2026-10-09T09-00.md (3 failed). PASS.
