# Final QA — Test with Coverage (src/lib/validate/**)

Timestamp: 2026-06-25T23-14
Command: node run-jest.cjs --coverage --collectCoverageFrom="src/lib/validate/**/*.ts"
EXIT_CODE: 0
Output Summary:
- Test Suites: 51 passed, 51 total
- Tests: 619 passed, 619 total
- Coverage scoped to `src/lib/validate/**`:
  - All files: 95% Stmts, 88.73% Branch, 87.09% Funcs, 95% Lines
- Per-file (line% / branch%):
  - evidence-locations.ts: 100% / 100%
  - json-validator.ts: 89.13% / 85%
  - orchestration-artifacts.ts: 100% / 100%
  - orchestrator-state-completion.ts: 94.94% / 93.02%
  - orchestrator-state-core.ts: 98.11% / 93.75%
  - orchestrator-state-human-interaction.ts: 96.99% / 91.3%
  - orchestrator-state-remediation.ts: 100% / 100%
  - orchestrator-state-routing.ts: 91.34% / 81.69%
  - policy-audit-artifact.ts: 93.07% / 81.31%
  - review-artifacts.ts: 100% / 100%
- Aggregate line 95% >= 85% threshold; aggregate branch 88.73% >= 75% threshold.
  Every individual file also meets both thresholds (line >= 85%, branch >= 75%).
- Function coverage (87.09% aggregate; orchestrator-state-core.ts 45.45%) is
  informational only; repository policy gates line and branch coverage, not
  function coverage. The lower core function count reflects re-exported
  completion helpers that are exercised through orchestrator-state-completion.ts.
