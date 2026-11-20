# F2 Full Extension Jest Suite (Regression)

Timestamp: 2026-06-25T23-14
Command: npm test  (node run-jest.cjs)
EXIT_CODE: 0
Output Summary:
- Test Suites: 51 passed, 51 total
- Tests: 617 passed, 617 total
- Baseline (Phase 0) was 41 suites / 492 tests; F2 adds 10 new test suites and
  125 new tests under `test/lib/validate/**` plus the rewritten
  `repo-automation-orchestration-validation.test.ts`.
- New test files:
  - test/lib/validate/review-artifacts.test.ts
  - test/lib/validate/policy-audit-artifact.test.ts
  - test/lib/validate/evidence-locations.test.ts
  - test/lib/validate/orchestrator-state-human-interaction.test.ts
  - test/lib/validate/orchestrator-state-routing.test.ts
  - test/lib/validate/orchestrator-state-remediation.test.ts
  - test/lib/validate/orchestrator-state-core.test.ts
  - test/lib/validate/orchestrator-state-core.completion.test.ts
  - test/lib/validate/json-validator.test.ts
  - test/lib/validate/orchestration-artifacts.test.ts
- Rewritten: test/repo-automation-orchestration-validation.test.ts (now asserts
  the in-process call rather than a Python spawn; other service methods still
  spawn and remain unchanged).
- No pre-existing test regressed; all previously-passing suites still pass.
