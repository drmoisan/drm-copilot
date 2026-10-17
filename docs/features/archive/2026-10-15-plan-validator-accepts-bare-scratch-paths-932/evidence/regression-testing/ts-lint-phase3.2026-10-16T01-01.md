# TypeScript Lint Check (Phase 3) — Issue #932

Timestamp: 2026-10-16T01-01
Task: [P3-T6]
Working directory: extensions/drm-copilot/
Command: npx eslint src/lib/validate/plan-gate-scratch.ts src/lib/validate/plan-gate-discrimination.ts test/lib/validate/plan-gate-scratch.test.ts test/lib/validate/plan-gate-parity.test.ts test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts test/lib/validate/plan-gate-observability-boundaries.test.ts jest.config.cjs
EXIT_CODE: 1

Output Summary: `1 problem (1 error, 0 warnings)`: `jest.config.cjs 2:1 error 'module' is not defined no-undef`. The six TypeScript files report no problems.

Acceptance status: NOT MET (the task requires `EXIT_CODE: 0`). The task is left unchecked in the plan.

Pre-existing-condition proof:
- Line 2 of `extensions/drm-copilot/jest.config.cjs` is `module.exports = {`, which this item does not change (the item's only edit is the six-line `plan-gate-scratch.ts` threshold entry).
- Command: `git show <MERGE_BASE>:extensions/drm-copilot/jest.config.cjs` written to SCRATCH/jest.config.base.cjs, then `npx eslint --stdin --stdin-filename jest.config.cjs < SCRATCH/jest.config.base.cjs` (working directory `extensions/drm-copilot/`). EXIT_CODE: 1, identical diagnostic `2:1 error 'module' is not defined no-undef`. MERGE_BASE: adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99.
- `extensions/drm-copilot/eslint.config.mjs` declares no Node globals for `.cjs` files; the repository lint script (`npx eslint --no-error-on-unmatched-pattern src test`, used by [P0-T12] and [P6-T8]) does not lint `jest.config.cjs`, so the condition does not appear in the project's own lint gate.

Why it is not fixed here: a fix needs either a globals declaration in `jest.config.cjs` beyond the threshold entry the plan names (the operator restricted this item's edit to that entry because a concurrent item reads the file) or an `eslint.config.mjs` change, which is outside this plan's WRITES list. Recorded as a remediation candidate for the caller.
