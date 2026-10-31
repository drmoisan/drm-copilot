# TypeScript Coverage Baseline (Remediation Cycle 1, Issue #1006)

Timestamp: 2026-10-31T09-12
Command: npm --prefix extensions/drm-copilot run test:coverage (unmodified; runs node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary), launched from SCRATCH/issue-1006-tscov.sh
EXIT_CODE: 0
Output Summary: 324 of 324 suites and 5257 of 5257 tests passed, 0 failed, no coverageThreshold failure. Repo-wide (extension) Lines 97.05% (61640/63511), Branches 93.67% (9392/10026). claude-blast-radius-overlay.ts 99.57% line (463/465), 96.15% branch (100/104). claude-blast-radius-overlay-demote.ts 100% line (126/126), 100% branch (26/26).

## Run context

- HEAD: `4fdb1848ab48cb161d46725c3115892fb1067000` (before any cycle edit)
- Porcelain at run time: only untracked `FEATURE/` paths (the plan, the preflight-fix record, and `evidence/remediation-baseline/`).
- `extensions/drm-copilot/coverage/lcov.info` was deleted before the run and exists after it.

## Test counts

- Test Suites: 324 passed, 324 total
- Tests: 5257 passed, 5257 total
- Failing tests: none

## Per-file figures (from `extensions/drm-copilot/coverage/lcov.info`)

| File | LH/LF | Line % | BRH/BRF | Branch % |
|---|---|---|---|---|
| `src/lib/push-down/claude-blast-radius-overlay.ts` | 463/465 | 99.57 | 100/104 | 96.15 |
| `src/lib/push-down/claude-blast-radius-overlay-demote.ts` | 126/126 | 100.00 | 26/26 | 100.00 |

## Repo-wide figures (`text-summary` block)

- Statements: 97.05% (61640/63511)
- Branches: 93.67% (9392/10026)
- Functions: 91.87% (1843/2006)
- Lines: 97.05% (61640/63511)
