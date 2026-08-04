Timestamp: 2026-08-04T10-33
Command: npm run test:unit -- --runInBand --testPathPatterns="orchestrator-state-core.test.ts|orchestrator-state-routing.test.ts|orchestrator-state-core.model-routing.test.ts"
EXIT_CODE: 1
Output Summary: Expected fail-before result: 3 test suites failed, 1 passed; 5 tests failed and 73 passed. State-core rejects object-form agents, routing reports every required agent missing, and legacy model-routing does not require a receipt for a mixed-object agent. TypeScript baseline line coverage is 96.34% (P0-T9); this plan-required focused unit command does not enable coverage.
