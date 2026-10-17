# TypeScript Red Run (Remediation Cycle 3) [expect-fail]

Timestamp: 2026-10-16T06-25
Task: [P1-T6]
Working directory: extensions/drm-copilot/
Command: npx jest --config jest.config.cjs --verbose test/lib/validate/plan-gate-discrimination-literals.test.ts --reporters=default
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `Tests: 1 failed, 14 passed, 15 total`. The only failing case is `normalizes G6 tracked lines with the plan whitespace class`; every pre-existing case passed.

The jest diff shows exactly two differing elements, the second and fourth (the byte-order-mark cases); the first and third (NEL) already match:

- Hunk `@@ -6,11 +6,11 @@` (second element, `bom-only-line`):
  - Expected: `"[P2-T1] search literal `pinned items occupy` is absent from the tracked tree and is not quoted in the plan; ..."` (G5)
  - Received: `"[P2-T1] search literal `pinned items occupy` is present only across adjacent lines of a tracked file and matches no single line; ..."` (G6)
- Hunk `@@ -18,9 +18,9 @@` (fourth element, `bom-joined-line`):
  - Expected: `"[P2-T1] search literal `pinned items occupy` is present only across adjacent lines ..."` (G6)
  - Received: `"[P2-T1] search literal `pinned items occupy` is absent from the tracked tree ..."` (G5)

TypeScript treats the byte-order mark as whitespace before the change, so it drops the byte-order-mark-only line as blank and normalizes the joined byte-order mark to a space.

Grep counts from [P1-T4] (`extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-literals.test.ts`):

| Pattern | Count |
| --- | --- |
| `it\("normalizes G6 tracked lines with the plan whitespace class"` | 1 |
| `it\.each\|^\s*test\(` | 0 |
| line count `^` | 356 (314 before) |
| raw-character pattern | 0 |
