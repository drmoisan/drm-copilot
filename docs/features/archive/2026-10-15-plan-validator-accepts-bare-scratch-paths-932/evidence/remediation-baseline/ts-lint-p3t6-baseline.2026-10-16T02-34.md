# RF-1 Reproduction: Original [P3-T6] Command (Remediation Cycle 1)

Timestamp: 2026-10-16T02-34
Task: [P0-T5]
Working directory: extensions/drm-copilot/
Command: npx eslint src/lib/validate/plan-gate-scratch.ts src/lib/validate/plan-gate-discrimination.ts test/lib/validate/plan-gate-scratch.test.ts test/lib/validate/plan-gate-parity.test.ts test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts test/lib/validate/plan-gate-observability-boundaries.test.ts jest.config.cjs
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:

```text
extensions/drm-copilot/jest.config.cjs
  2:1  error  'module' is not defined  no-undef

✖ 1 problem (1 error, 0 warnings)
```

The sole reported problem is `'module' is not defined` with rule `no-undef` in `jest.config.cjs`, which reproduces RF-1. No problem is reported for the six TypeScript files.
