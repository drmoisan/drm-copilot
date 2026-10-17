# TypeScript Feature-Receipt Suites (P5-T6)

Timestamp: 2026-10-16T00-59
Command: node run-jest.cjs test/lib/validate/epic-planner-state-feature-receipts.test.ts test/lib/validate/validate-orchestration-service-call.test.ts --reporters=default --verbose (in extensions/drm-copilot/)
EXIT_CODE: 0
Output Summary:
- Test Suites: 2 passed, 2 total
- Tests:       14 passed, 14 total (0 failed)
- Passing lines (verbatim, Windows console prefix √):
  - validateEpicPlannerStateText per-feature receipt key gate
  - √ skips the per-feature receipts when the keys are absent without a Codex flag
  - √ keeps the per-feature receipts unconditional under {"requireCodexModelRouting": true}
  - √ keeps the per-feature receipts unconditional under {"requireCodexTopology": true}
  - √ validates a present null model_routing_receipt without a Codex flag
  - √ validates a present null topology_receipt without a Codex flag
  - √ gates each per-feature receipt independently
  - √ preserves the feature index when receipts are skipped
  - √ threads the Codex flags into epic-planner-state
