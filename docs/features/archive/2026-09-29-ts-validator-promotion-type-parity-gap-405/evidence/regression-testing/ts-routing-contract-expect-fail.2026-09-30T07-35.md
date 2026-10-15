# P2-T4 [expect-fail] TypeScript routing-contract regression test against the unfixed validator

Timestamp: 2026-09-30T07-35
Command: npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/orchestrator-state-routing.promotion-type.test.ts
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- `Tests:       2 failed, 2 passed, 4 total`; `Test Suites: 1 failed, 1 total`.
- The two failures:
  - validateRoutingContract promotion-type resolution > accepts a bug-type large-route checkpoint that declares and records new_potential_bug_entry
  - validateRoutingContract promotion-type resolution > rejects a bug-type large-route checkpoint that declares and records only new_potential_entry
- The feature-type acceptance test and the dead-skill-name test pass before the fix (intended no-regression baseline).
- P2-T3 file line count: `wc -l extensions/drm-copilot/test/lib/validate/orchestrator-state-routing.promotion-type.test.ts` printed 162 (below 500).
