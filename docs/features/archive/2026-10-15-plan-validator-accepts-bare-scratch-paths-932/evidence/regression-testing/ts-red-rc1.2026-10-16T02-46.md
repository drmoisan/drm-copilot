# TypeScript Red Run (Remediation Cycle 1)

Timestamp: 2026-10-16T02-46
Task: [P1-T7] [expect-fail]
Working directory: extensions/drm-copilot/
Command: npx jest --config jest.config.cjs --verbose test/lib/validate/plan-gate-commands.test.ts test/lib/validate/plan-gate-scratch.test.ts
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:

- `Test Suites: 1 failed, 1 passed, 2 total`; `Tests: 1 failed, 28 passed, 29 total`.
- Failing suite: `test/lib/validate/plan-gate-commands.test.ts`. Failing case `splitPlanLines › splits only on CR LF, LF, and CR terminators`; first error line `TypeError: (0 , plan_gate_commands_1.splitPlanLines) is not a function`. This is the expected `TypeError` signature.
- In the same suite, `reports line numbers that ignore a form feed and a line separator` passes, because the TypeScript extractor already splits on CR LF, LF, and CR only.
- `test/lib/validate/plan-gate-scratch.test.ts` passes in full (15 cases). Verbose passing lines of the three new or retitled `plan-gate-scratch G10` cases:

```text
    √ stops a logical line at an indented fence and at a column-0 heading or task line
    √ absorbs an indented heading or task line into the logical line
    √ does not end a physical line at a form feed or a line separator
```

Execution note: Jest 30 selects its agent reporter when the `CLAUDECODE` environment variable is set, which suppresses the `--verbose` per-case lines. The command was therefore run with `--reporters=default` appended after the test paths so that the verbose lines could be read; the test selection and configuration are otherwise identical to the plan command.

## Grep counts from [P1-T4] and [P1-T5]

[P1-T4] `extensions/drm-copilot/test/lib/validate/plan-gate-commands.test.ts`:

- `describe\("splitPlanLines"`: 1
- `it\("splits only on CR LF, LF, and CR terminators"`: 1
- `it\("reports line numbers that ignore a form feed and a line separator"`: 1
- `it\.each|^\s*test\(`: 0
- `[\x{2028}\x0c]`: 0
- Line count: 279 (at most 500)

[P1-T5] `extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts`:

- `stops a logical line at a fence, a heading, and a task line`: 0
- `it\("stops a logical line at an indented fence and at a column-0 heading or task line"`: 1
- `it\("absorbs an indented heading or task line into the logical line"`: 1
- `it\("does not end a physical line at a form feed or a line separator"`: 1
- `it\.each|^\s*test\(`: 0
- `[\x{2028}\x0c]`: 0
- Line count: 385 (at most 500)
