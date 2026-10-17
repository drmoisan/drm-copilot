# Acceptance Criteria Check-Off (P2-T9)

Timestamp: 2026-10-12T15-19

Source: `docs/features/active/2026-10-11-argumentless-sort-ordering-and-comparator-coverage-gaps-889/issue.md`, section `## Acceptance Criteria` (minor-audit). Only `- [ ]` was changed to `- [x]`; no criterion text changed. All paths below are relative to FEATURE.

| AC | Evidence (on disk) | Checked |
|---|---|---|
| AC-1 | `evidence/regression-testing/sort-site-zero-match.2026-10-12T15-03.md` (0 matches, exit 1); `evidence/regression-testing/sort-site-comparator-imports.2026-10-12T15-03.md` (19 converted lines in 12 files; 12 target imports + 7 pre-existing) | yes |
| AC-2 | `evidence/regression-testing/cp-order-green.2026-10-12T15-03.md` and `cp-order-green.2026-10-12T15-17.md` (14 passed); `evidence/other/observable-site-test-map.2026-10-12T15-17.md` | yes |
| AC-3 | `evidence/regression-testing/cp-order-red.2026-10-12T15-03.md` (14 failed against unconverted sources, with per-test default-order output); `evidence/other/observable-site-test-map.2026-10-12T15-17.md` | yes |
| AC-4 | `evidence/other/non-observable-sites.2026-10-12T15-19.md` | yes |
| AC-5 | `evidence/regression-testing/null-arm-and-target-role.2026-10-12T15-03.md` and `.2026-10-12T15-17.md` (7 passed). Grep tool confirmed the literal `on both operands and asserts the order decided by the target path` on the AC-5 line (issue.md:65). | yes |
| AC-6 | `evidence/regression-testing/null-arm-and-target-role.2026-10-12T15-03.md` (target-role test passes); `evidence/regression-testing/target-role-mutation-red.2026-10-12T15-03.md` (1 failed with line 241 returning 0); `evidence/regression-testing/target-role-mutation-restored.2026-10-12T15-03.md` (1 passed after restore; anchored diff empty) | yes |
| AC-7 | `evidence/qa-gates/ts-prettier-check.2026-10-12T15-19.md`, `ts-lint.2026-10-12T15-19.md`, `ts-typecheck-src.2026-10-12T15-19.md`, `ts-typecheck-test.2026-10-12T15-19.md`, `ts-test-coverage.2026-10-12T15-19.md` (all exit 0, single pass) | yes |
| AC-8 | `evidence/qa-gates/ts-coverage-per-file.2026-10-12T15-19.md`; `evidence/qa-gates/coverage-delta.2026-10-12T15-19.md` | yes |
| AC-9 | `evidence/qa-gates/changed-files-scope.2026-10-12T15-19.md` (max 492 lines; mirrored test paths); `evidence/qa-gates/temp-file-search.2026-10-12T15-19.md` (0 matches); `evidence/qa-gates/ts-test-coverage.2026-10-12T15-19.md` | yes |
| AC-10 | `evidence/qa-gates/changed-files-scope.2026-10-12T15-19.md` (no Python, PowerShell, or tests/fixtures path); `evidence/qa-gates/temp-file-search.2026-10-12T15-19.md`; `evidence/qa-gates/ts-test-coverage.2026-10-12T15-19.md` (full suite including parity and corpus suites, 270/270 suites passed) | yes |

AC-7 npm-script-to-command mapping (from `extensions/drm-copilot/package.json:208-213` and `extensions/drm-copilot/run-jest.cjs:9-28`; the executor allowlist covers `npx` and `git`, not `npm run`):
- Format check `npx prettier --check "src/**/*.ts" "test/**/*.ts"` -> P2-T1 `cd extensions/drm-copilot && npx prettier --check "src/**/*.ts" "test/**/*.ts"` (`ts-prettier-check.2026-10-12T15-19.md`)
- `npm run lint` -> P2-T2 `cd extensions/drm-copilot && npx eslint --no-error-on-unmatched-pattern src test` (`ts-lint.2026-10-12T15-19.md`)
- `npm run typecheck` -> P2-T3 `cd extensions/drm-copilot && npx tsc -p ./ --noEmit` (`ts-typecheck-src.2026-10-12T15-19.md`) followed by `cd extensions/drm-copilot && npx tsc -p tsconfig.jest.json --noEmit` (`ts-typecheck-test.2026-10-12T15-19.md`, the `typecheck:test` script)
- `npm run test:coverage` -> P2-T4 `cd extensions/drm-copilot && npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` (`ts-test-coverage.2026-10-12T15-19.md`)

Evidence Checklist items checked: baseline (`evidence/baseline/`), targeted verification (`evidence/regression-testing/`), end-state (`evidence/qa-gates/`).
