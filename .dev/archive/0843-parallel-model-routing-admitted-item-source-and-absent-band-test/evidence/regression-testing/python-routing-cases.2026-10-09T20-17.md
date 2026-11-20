# Python routing cases (P1-T19)

Timestamp: 2026-10-09T20-17
Command: poetry run pytest tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py -v
EXIT_CODE: 0
Output Summary:
Result line: ============================= 31 passed in 0.09s =============================
BaselineRoutingTestCount (P0-T14): 29; passed count 31 equals 29 plus 2.

Node lines (all PASSED; file prefix tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py:: omitted except for the two new nodes):

- test_ready_gate_rejects_item_without_band_assessment_or_receipt PASSED
- test_ready_gate_accepts_item_with_valid_routing_record PASSED
- test_gate_off_accepts_item_without_routing_fields PASSED
- test_ready_gate_rejects_floor_that_disagrees_with_signals PASSED
- test_ready_gate_rejects_band_below_floor PASSED
- test_ready_gate_rejects_receipt_model_that_disagrees_with_resolver PASSED
- test_ready_gate_rejects_disabled_policy_fable_model PASSED
- test_ready_gate_rejects_assessment_band_mismatch PASSED
- test_ready_gate_rejects_receipt_band_mismatch PASSED
- test_ready_gate_rejects_non_orchestrator_agent PASSED
- test_ready_gate_rejects_unknown_fable_policy PASSED
- test_ready_gate_rejects_non_object_assessment_and_receipt PASSED
- test_ready_gate_rejects_missing_assessed_at PASSED
- test_band_mismatch_reported_when_item_band_invalid PASSED
- test_p10_errors_follow_p7_errors_for_same_item PASSED
- test_routing_helper_reuses_claude_helpers_only PASSED
- test_ready_gate_emits_shared_literal_strings (12 parametrized cases) PASSED
- test_required_item_keys_unchanged PASSED
- tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_absent_item_band_with_assessment_and_receipt_present PASSED
- tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_absent_receipt_band_with_item_band_present PASSED
