# Fail-Before: TypeScript Regression Test (Issue #543)

Timestamp: 2026-10-10T08-08
Task: [P1-T5] [expect-fail]
Command: cd extensions/drm-copilot && node run-jest.cjs test/lib/validate/epic-planner-state-core.test.ts -t "skips the planner topology receipt when the key is absent"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Production code state: pre-fix (`extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` unchanged from merge base 7bbd0b9b990737642b4eeded01a27b7c5c8348b3).
- `Test Suites: 1 failed, 1 total`
- `Tests:       1 failed, 22 skipped, 23 total` (the one selected title failed)
- `error TS` lines in the output: 0 (behavioural failure, not a compile failure).
- Jest received-value output: `- Expected  - 1` / `+ Received  + 3`, with the received array containing `"Epic planner topology_receipt must be an object.",`
- Paired pass-after artifact: produced by P3-T2 under `evidence/regression-testing/pass-after-typescript.<ts>.md`.
