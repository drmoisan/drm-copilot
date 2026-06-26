# Baseline Toolchain — Remediation F8 (Issue #240)

Timestamp: 2026-06-26T05-25
Working directory: extensions/drm-copilot/

## Format

Command: `npx prettier --check "src/lib/new-active-feature-folder/**/*.ts" "test/lib/new-active-feature-folder/**/*.ts"`
EXIT_CODE: 0
Output Summary: All matched files use Prettier code style.

## Lint

Command: `npm run lint` (eslint --no-error-on-unmatched-pattern src test)
EXIT_CODE: 0
Output Summary: 0 lint errors.

## Type check

Command: `npm run typecheck` (tsc -p ./ --noEmit)
EXIT_CODE: 0
Output Summary: 0 type errors.

## Tests + Coverage

Command: `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"`
EXIT_CODE: 0
Output Summary:
- Test Suites: 85 passed, 85 total
- Tests: 999 passed, 999 total
- src/lib/** (All files): line 97.73%, branch 88.29%
- io.ts: line 98.89%, branch 88.88% (uncovered lines 66-67, 435-438)
- index.ts: line 100% (re-export surface)
- flow.ts: line 99.54%, branch 92.1%

## File size baseline

Command: `wc -l src/lib/new-active-feature-folder/io.ts`
EXIT_CODE: 0
Output Summary: io.ts = 542 lines (over the 500-line limit; this is finding R1).
