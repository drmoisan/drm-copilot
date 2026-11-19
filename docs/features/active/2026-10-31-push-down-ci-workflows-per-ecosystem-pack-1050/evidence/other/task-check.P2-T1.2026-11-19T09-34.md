# Task Check P2-T1

Timestamp: 2026-11-19T09-34
Command: sh SCRATCH/issue-1050-tscheck.sh src/lib/push-down/push-down-ci-workflows.ts test/lib/push-down/push-down-ci-workflows.test.ts jest.config.cjs (npx prettier --write then --check; npx eslint on the .ts files; npm run typecheck); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension test/lib/push-down/push-down-ci-workflows.test.ts
EXIT_CODE: 0
Output Summary: Prettier check exit 0 (`All matched files use Prettier code style!`), ESLint exit 0, typecheck exit 0. Jest selection: 1 suite, 21 tests passed, 0 failed. The module imports neither `node:fs` nor `child_process` (grep count 0).

Changed files:
- `extensions/drm-copilot/src/lib/push-down/push-down-ci-workflows.ts` (new, 338 lines)
- `extensions/drm-copilot/test/lib/push-down/push-down-ci-workflows.test.ts` (new)
- `extensions/drm-copilot/jest.config.cjs` (entry `./src/lib/push-down/push-down-ci-workflows.ts` with lines 85 and branches 75 appended after the final entry; 632 lines)

Selection rule: the mirrored test file of the new production file; no other test imports the new module yet. `jest.config.cjs` is configuration read by every Jest run; its effect is exercised at the phase gate.

Informational: a selection run with coverage restricted to the module (`--collectCoverageFrom=src/lib/push-down/push-down-ci-workflows.ts`) reported 98.22% lines and 96.82% branches for the module; that run exited 1 only because Jest reported "Coverage data ... was not found" for the per-file threshold entries of every other file, which a coverage-restricted run cannot measure. Not a gate; the gate measures coverage at P2-T7 and P3-T2.

ESLint note: an ESLint call that included `jest.config.cjs` reported three pre-existing `@typescript-eslint/no-require-imports` errors on its `require()` lines, which this task did not touch; `npm run lint` lints only `src` and `test`, so the task check lints the `.ts` files.
