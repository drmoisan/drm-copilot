# TypeScript Red Run (Remediation Cycle 2)

Timestamp: 2026-10-16T04-20
Task: [P1-T7] [expect-fail]
Working directory: extensions/drm-copilot/
Command: npx jest --config jest.config.cjs --verbose test/lib/validate/plan-gate-scratch.test.ts test/lib/validate/plan-gate-discrimination-literals.test.ts --reporters=default
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `Test Suites: 1 failed, 1 passed, 2 total`; `Tests: 2 failed, 29 passed, 31 total`. The two failures are exactly the expected cases.

Failing cases (first differing element):

- `× decides continuation with the plan whitespace class`: the third element (`bom-led`, hunk `@@ -12,11 +12,11 @@`) differs. Expected `"- SCRATCH means the session scratchpad."`, received `"- SCRATCH means the session scratchpad. continued text"` (the JavaScript whitespace class continues a line led by the byte-order mark).
- `× normalizes whitespace with the plan whitespace class`: the `bom-inline` element differs. Expected the byte-order mark kept between `intro` and `SCRATCH`, received `"intro SCRATCH is the session scratchpad."`.

U-1 case verbose passing line:

```text
    √ treats a form feed or line separator in a tracked file as part of one line (1 ms)
```

All other cases in both files passed (16 pre-existing `plan-gate-scratch G10` cases and 13 pre-existing `evaluatePlanGates search literals` cases).

Grep counts recorded for [P1-T4] and [P1-T5]:

| Task | File | Pattern | Count |
| --- | --- | --- | --- |
| P1-T4 | `extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts` | `it\("decides continuation with the plan whitespace class"` | 1 |
| P1-T4 | same | `it\("normalizes whitespace with the plan whitespace class"` | 1 |
| P1-T4 | same | `it\.each|^\s*test\(` | 0 |
| P1-T4 | same | `PLAN_WHITESPACE_CLASS` | 0 |
| P1-T4 | same | `^` (line count; 385 before) | 431 |
| P1-T4 | same | raw-character zero-count pattern | 0 |
| P1-T5 | `extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-literals.test.ts` | `it\("treats a form feed or line separator in a tracked file as part of one line"` | 1 |
| P1-T5 | same | `it\.each|^\s*test\(` | 0 |
| P1-T5 | same | `^` (line count; 283 before) | 314 |
| P1-T5 | same | raw-character zero-count pattern | 0 |
