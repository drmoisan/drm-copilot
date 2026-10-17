# Python Pass-After Run, P10 Routing Suite (P3-T5)

Timestamp: 2026-10-02T04-44
Command: poetry run pytest tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py -q
EXIT_CODE: 0
Output Summary:
29 passed in 0.08s (18 test functions; test_ready_gate_emits_shared_literal_strings is parametrized over 12 literals)
Zero failures.
Node test_ready_gate_rejects_item_without_band_assessment_or_receipt recorded as PASSED (from a -rA run of the same file):
PASSED tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_item_without_band_assessment_or_receipt
Fail-before run of the same node: evidence/regression-testing/python-fail-before.2026-10-02T04-33.md (1 failed, validator returned no errors).
Superseded attempt: evidence/remediation-baseline/superseded/python-pass-after.2026-10-02T04-41.md (27 passed, before the DEV-8 change).
PLAN DEVIATION DEV-8 - the reused helpers _validate_complexity_assessments and _validate_model_routing_receipts test band, floor, and the receipt complexity_band by frozenset membership, which raised TypeError (unhashable type: 'list') for a list-valued field, contradicting the P3-T1 requirement that the routing module raises nothing. _parallel_planner_state_routing.py now passes the helpers a shallow copy in which a list- or object-valued band/floor/complexity_band is replaced by its str form (identical rendering in every helper message, never a valid band). Two list-valued cases were added to test_ready_gate_emits_shared_literal_strings and are mirrored in the TypeScript suite.
