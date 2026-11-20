# P3-T5 fixture support split

The approved plan, Governing contracts and ownership, permits splitting a new module within its named component when necessary for the 500-physical-line limit, with exact paths recorded and unchanged behavior/tests.

The formatted tests/discovery_runtime/test_evidence_linking.py is 497 physical lines before remaining intent documentation and coverage assertions. Authorize tests/discovery_runtime/evidence_test_support.py solely for the immutable link_baseline fixture and request_for, add_record, and memory_writer builders. Keep all behavioral assertions in the two prescribed suites. Production remains packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py.

The complete task file set is now:

- packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py
- tests/discovery_runtime/test_evidence_linking.py
- tests/discovery_runtime/test_evidence_payloads.py
- tests/discovery_runtime/evidence_test_support.py

This records the exact fixture-only split before the added path is created. It adds no task, production capability, requirement or quality exception. The executor will verify unchanged behavior ownership and all file-size gates.

An initial PowerShell document-write command was rejected before execution by the promotion hook with PROMOTION_MCP_ONLY_BLOCKED. That command contained no GitHub CLI invocation or promotion operation; no files were mutated. This record uses the normal structured patch tool. No hook configuration or enforcement was changed.
