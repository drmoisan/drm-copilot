# TypeScript Red Set — Issue #932

Timestamp: 2026-10-16T00-48
Task: [P1-T9] [expect-fail]
Working directory: extensions/drm-copilot/
Command: npx jest --config jest.config.cjs test/lib/validate/plan-gate-scratch.test.ts test/lib/validate/plan-gate-parity.test.ts test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary: `Test Suites: 3 failed, 3 total`; `Tests: 2 failed, 7 passed, 9 total`. All three failures match the expected signatures; no other failure occurred.

Failures (expected):
- `test/lib/validate/plan-gate-scratch.test.ts` — Test suite failed to run: `Cannot find module '../../../src/lib/validate/plan-gate-scratch' from 'test/lib/validate/plan-gate-scratch.test.ts'`.
- `plan acceptance-gate cross-runtime parity › renders offending values without pythonRepr formatting` — `ENOENT: no such file or directory, open '<repo>/extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts'`.
- `validateOrchestrationServiceCall plan acceptance gates › throws with the G10 message when a SCRATCH definition is not namespaced` — `Received function did not throw`.

Passing: the 7 other cases in `plan-gate-parity.test.ts` and `validate-orchestration-service-call-plan-gates.test.ts` passed.

TS_CASE_COUNT: 13

Case titles in `test/lib/validate/plan-gate-scratch.test.ts` (Grep `^\s*it\("`, verbatim):
1. declares G10_SEVERITY as the blocking channel
2. accepts every issue-namespaced definition
3. flags each unnamespaced definition exactly once at line 1
4. ignores non-definitions and fenced definitions
5. reports a wrapped definition at its first physical line
6. stops a logical line at a fence, a heading, and a task line
7. renders the frozen message for the apostrophe and tab fixtures
8. routes findings to the channel named by the severity argument
9. reports G10 on the blocking channel with and without a context
10. returns the G10 message as an error only for a bare definition
11. re-exports the G10 symbols from plan-gate-discrimination
12. names G10 in the evaluatePlanGates JSDoc
13. declares the jest coverage threshold for plan-gate-scratch.ts

[P1-T5] Grep counts: `describe\("plan-gate-scratch G10"` — 1; `it\.each|^\s*test\(` — 0.
