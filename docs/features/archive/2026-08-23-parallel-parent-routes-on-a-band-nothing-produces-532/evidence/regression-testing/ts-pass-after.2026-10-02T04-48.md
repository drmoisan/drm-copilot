# TypeScript Pass-After Run, Routing, Core, and Tolerated-Edge Suites (P4-T5)

Timestamp: 2026-10-02T04-48
Command: npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/parallel-planner-state-routing.test.ts test/lib/validate/parallel-planner-state-core.test.ts test/lib/validate/parallel-state-tolerated-edge-fields.test.ts
EXIT_CODE: 0
Output Summary:
Test Suites: 3 passed, 3 total
Tests:       110 passed, 110 total
Zero failures. The routing suite holds 22 cases (fail-before, valid record, gate off, C9 band, non-object fields, P7-before-P10 ordering, 12 shared-literal cases, a direct call on a valid record, and 3 divergence pins).
- npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/parallel-planner-state-routing.test.ts -t "(fail-before)" exited 0
Tests:       21 skipped, 1 passed, 22 total
The passed case is "rejects an item without band, assessment, or receipt under the ready gate (fail-before)". The repository Jest wrapper prints only the summary lines, so the per-case pass is recorded through the name-filtered run above.
Fail-before run of the same case: evidence/regression-testing/ts-fail-before.2026-10-02T04-35.md (1 failed; result lacked the check-1, check-2, and check-6 literals).
PLAN DEVIATION DEV-8 - two list-valued shared-literal cases (assessment band ["C3"], receipt complexity_band ["C3"]) mirror the cases added to the Python test_ready_gate_emits_shared_literal_strings; see evidence/regression-testing/python-pass-after.2026-10-02T04-44.md.
