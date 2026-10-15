# TypeScript Fail-Before Regression Run (P2-T6) [expect-fail]

Timestamp: 2026-10-02T04-35
Command: npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/parallel-planner-state-routing.test.ts
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
FAIL test/lib/validate/parallel-planner-state-routing.test.ts
Failing case - parallel planner ready gate P10 routing record > rejects an item without band, assessment, or receipt under the ready gate (fail-before)
expect(received).toEqual(expected) // deep equality
Expected - ArrayContaining ["Parallel planner checkpoint items[0] complexity_band must be one of C1, C2, C3, C4; found: None.", "Parallel planner checkpoint items[0] complexity_assessment must be an object.", "Parallel planner checkpoint items[0] model_routing_receipt must be an object."]
Received - []
at test/lib/validate/parallel-planner-state-routing.test.ts line 41 column 20
The expectation failed because the validator result lacked the check-1 (band absent), check-2, and check-6 literals; no error was thrown.
Test Suites: 1 failed, 1 total
Tests:       1 failed, 1 total
- git diff --stat 74e1d674 -- extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts exited 0
(no output: the TypeScript core validator is unmodified)
PLAN DEVIATION DEV-1 - the plan's diff anchor b7b4a2dc is replaced by the merge-base 74e1d674 (see evidence/baseline/git-baseline.2026-10-02T04-29.md). The orchestrator verified that main did not change the TypeScript core between b7b4a2dc and 74e1d674.
