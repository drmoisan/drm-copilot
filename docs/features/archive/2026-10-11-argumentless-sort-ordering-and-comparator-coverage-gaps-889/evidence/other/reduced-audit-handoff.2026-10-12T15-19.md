# Reduced-Audit Handoff (P2-T10)

Timestamp: 2026-10-12T15-19

Feature folder: `docs/features/active/2026-10-11-argumentless-sort-ordering-and-comparator-coverage-gaps-889` (FEATURE). Work mode: minor-audit. AC source: `FEATURE/issue.md` `## Acceptance Criteria`. Plan: `FEATURE/plan.2026-10-11T08-31.md`. All paths below are relative to FEATURE.

## Phase 0 artifacts (evidence/baseline/)
- `evidence/baseline/mode-and-requirements-check.2026-10-12T15-03.md` (P0-T1)
- `evidence/baseline/phase0-instructions-read.md` (P0-T2)
- `evidence/baseline/git-state.2026-10-12T15-03.md` (P0-T3)
- `evidence/baseline/ts-dependency-install.2026-10-12T15-03.md` (P0-T3)
- `evidence/baseline/sort-site-inventory.2026-10-12T15-03.md` (P0-T4)
- `evidence/baseline/ts-prettier-check.2026-10-12T15-03.md` (P0-T5)
- `evidence/baseline/ts-lint.2026-10-12T15-03.md` (P0-T6)
- `evidence/baseline/ts-typecheck-src.2026-10-12T15-03.md` (P0-T7)
- `evidence/baseline/ts-typecheck-test.2026-10-12T15-03.md` (P0-T7)
- `evidence/baseline/ts-coverage.2026-10-12T15-03.md` (P0-T8)

## Phase 1 artifacts
- `evidence/other/p1-execution-order.2026-10-12T15-03.md` (P1-T1)
- `evidence/regression-testing/pre-red-src-diff.2026-10-12T15-03.md` (P1-T16 step 1)
- `evidence/regression-testing/cp-order-red.2026-10-12T15-03.md` (P1-T16 step 2, expect-fail)
- `evidence/regression-testing/sort-site-zero-match.2026-10-12T15-03.md` (P1-T26 step 1)
- `evidence/regression-testing/sort-site-comparator-imports.2026-10-12T15-03.md` (P1-T26 step 2)
- `evidence/regression-testing/cp-order-green.2026-10-12T15-03.md` (P1-T27)
- `evidence/regression-testing/null-arm-and-target-role.2026-10-12T15-03.md` (P1-T33)
- `evidence/regression-testing/target-role-mutation-red.2026-10-12T15-03.md` (P1-T34, expect-fail)
- `evidence/regression-testing/target-role-mutation-restored.2026-10-12T15-03.md` (P1-T34)
- `evidence/other/phase1-format.2026-10-12T15-17.md` (P1-T35)
- `evidence/regression-testing/cp-order-green.2026-10-12T15-17.md` (P1-T35 rerun of P1-T27)
- `evidence/regression-testing/null-arm-and-target-role.2026-10-12T15-17.md` (P1-T35 rerun of P1-T33)
- `evidence/other/observable-site-test-map.2026-10-12T15-17.md` (P1-T36)

## Phase 2 artifacts
- `evidence/qa-gates/ts-prettier-check.2026-10-12T15-19.md` (P2-T1)
- `evidence/qa-gates/ts-lint.2026-10-12T15-19.md` (P2-T2)
- `evidence/qa-gates/ts-typecheck-src.2026-10-12T15-19.md` (P2-T3)
- `evidence/qa-gates/ts-typecheck-test.2026-10-12T15-19.md` (P2-T3)
- `evidence/qa-gates/ts-test-coverage.2026-10-12T15-19.md` (P2-T4)
- `evidence/qa-gates/ts-coverage-per-file.2026-10-12T15-19.md` (P2-T5)
- `evidence/qa-gates/coverage-delta.2026-10-12T15-19.md` (P2-T6)
- `evidence/other/non-observable-sites.2026-10-12T15-19.md` (P2-T7)
- `evidence/qa-gates/changed-files-scope.2026-10-12T15-19.md` (P2-T8 step 1)
- `evidence/qa-gates/temp-file-search.2026-10-12T15-19.md` (P2-T8 step 2)
- `evidence/other/ac-checkoff.2026-10-12T15-19.md` (P2-T9)
- `evidence/other/reduced-audit-handoff.2026-10-12T15-19.md` (P2-T10, this file)

The Phase 2 loop (P2-T1 to P2-T5) completed in one pass; Pass-start and Pass-end diffs were both empty. No superseded Phase 2 artifacts exist.

## AC-7 npm-script-to-npx-command mapping

Derived from `extensions/drm-copilot/package.json:208-213` and `extensions/drm-copilot/run-jest.cjs:9-28` (the plan "Terms" > "Command equivalence" entry). `run-jest.cjs` spawns `jest --config jest.config.cjs <args>`, rejects only `--passWithNoTests`, `--onlyChanged`, and `--lastCommit`, and rewrites only `--testPathPattern`; none is used here.
- `npm run lint` = `cd extensions/drm-copilot && npx eslint --no-error-on-unmatched-pattern src test` (P2-T2 artifact `evidence/qa-gates/ts-lint.2026-10-12T15-19.md`)
- `npm run typecheck` = `cd extensions/drm-copilot && npx tsc -p ./ --noEmit` followed by `cd extensions/drm-copilot && npx tsc -p tsconfig.jest.json --noEmit` (the `typecheck:test` script) (P2-T3 artifacts `evidence/qa-gates/ts-typecheck-src.2026-10-12T15-19.md` and `evidence/qa-gates/ts-typecheck-test.2026-10-12T15-19.md`)
- `npm run test:coverage` = `cd extensions/drm-copilot && npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` (P2-T4 artifact `evidence/qa-gates/ts-test-coverage.2026-10-12T15-19.md`)
- `node run-jest.cjs <args>` = `cd extensions/drm-copilot && npx jest --config jest.config.cjs <args>`
