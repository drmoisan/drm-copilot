# Fail-Before: TypeScript Regression Twin (P1-T4) [expect-fail]

Timestamp: 2026-10-16T00-42
Command: node run-jest.cjs test/lib/validate/epic-planner-state-feature-receipts.test.ts (in extensions/drm-copilot/)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Test Suites: 1 failed, 1 total
- Tests:       1 failed, 1 total
- "error TS" lines: 0 (behavioural failure, not a compile failure)
- Jest received-value output (verbatim):
  - Expected  - 0 / Received  + 4
  - +   "Epic planner checkpoint features[0].model_routing_receipt must be an object.",
  - +   "Epic planner checkpoint features[0].topology_receipt must be an object.",
  - +   "Epic planner checkpoint features[1].model_routing_receipt must be an object.",
  - +   "Epic planner checkpoint features[1].topology_receipt must be an object.",
- Test: "skips the per-feature receipts when the keys are absent without a Codex flag" on pre-fix production code.
