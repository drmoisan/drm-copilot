# Baseline Toolchain State — F2 Remediation

Timestamp: 2026-06-25T23-45
Working directory: `extensions/drm-copilot/`

## Service-File Line Count

Command: `wc -l src/repo-automation-service.ts`
EXIT_CODE: 0
Output Summary: 526 src/repo-automation-service.ts (exceeds the 500-line limit; baseline was 484).

## Format

Command: `npx prettier --check "src/**/*.ts" "test/**/*.ts"`
EXIT_CODE: 0
Output Summary: "All matched files use Prettier code style!" — clean pass.

## Lint

Command: `npm run lint` (`eslint --no-error-on-unmatched-pattern src test`)
EXIT_CODE: 0
Output Summary: 0 lint errors.

## Type-Check

Command: `npm run typecheck` (`tsc -p ./ --noEmit`)
EXIT_CODE: 0
Output Summary: 0 type errors.

## Test with Coverage (src/lib/validate/**)

Command: `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/validate/**/*.ts"`
EXIT_CODE: 0
Output Summary:
- Test Suites: 51 passed, 51 total
- Tests: 619 passed, 619 total
- Coverage (All files, src/lib/validate scope): % Stmts 95, % Branch 88.73, % Funcs 87.09, % Lines 95
- Line coverage 95% >= 85% threshold; Branch coverage 88.73% >= 75% threshold.
- `orchestration-artifacts.ts`: 100% lines / 100% branch.
