# TypeScript Coverage Artifact (Remediation Cycle 1, Issue #1006, RC1-R1 / policy-audit PA-1)

Timestamp: 2026-10-31T09-17
Command: npm --prefix extensions/drm-copilot run test:coverage (unmodified; runs node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary), launched from SCRATCH/issue-1006-tscov.sh
EXIT_CODE: 0
Output Summary: 324 of 324 suites and 5257 of 5257 tests passed, 0 failed, no coverageThreshold failure. extensions/drm-copilot/coverage/lcov.info exists. claude-blast-radius-overlay.ts 99.55% line (442/444), 96.00% branch (96/100). claude-blast-radius-overlay-demote.ts 100.00% line (157/157), 100.00% branch (27/27). Repo-wide (extension text-summary) Lines 97.05% (61650/63521), Branches 93.67% (9389/10023).

## Run context

- `git rev-parse HEAD`: `3c94c93c96b6d8d5560db077ee411362c3f1b115` (contains the P1 and P2 edits)
- Porcelain at run time (documentation only; no source change outstanding):

```
 M docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/remediation-plan.2026-10-31T08-57.md
?? docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/evidence/qa-gates/ts-lint.2026-10-31T09-17.md
?? docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/evidence/qa-gates/ts-prettier.2026-10-31T09-17.md
?? docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/evidence/qa-gates/ts-typecheck.2026-10-31T09-17.md
```

- `extensions/drm-copilot/coverage/lcov.info` was deleted before the run and exists after it (864264 bytes).

## Test counts

- Test Suites: 324 passed, 324 total
- Tests: 5257 passed, 5257 total
- Failures: 0; no `coverageThreshold` failure reported (Jest exit 0).

## Per-file figures (from `extensions/drm-copilot/coverage/lcov.info`)

| File | LH/LF | Line % | BRH/BRF | Branch % | Threshold (85 line / 75 branch) |
|---|---|---|---|---|---|
| `src/lib/push-down/claude-blast-radius-overlay.ts` | 442/444 | 99.55 | 96/100 | 96.00 | met |
| `src/lib/push-down/claude-blast-radius-overlay-demote.ts` | 157/157 | 100.00 | 27/27 | 100.00 | met |

The uncovered lines and branches of `claude-blast-radius-overlay.ts` are all pre-existing and outside this cycle's change (`relativeToPosix` lines and four branches in `parseObject`, `composeModules`, and `relativeToPosix`); they were also uncovered at baseline.

## Repo-wide figures (`text-summary` block, extension Jest project)

- Statements: 97.05% (61650/63521)
- Branches: 93.67% (9389/10023)
- Functions: 91.87% (1843/2006)
- Lines: 97.05% (61650/63521)

Repo-wide threshold status: PASS (Lines 97.05% >= 85%; Branches 93.67% >= 75%). No shortfall, so no merge-base comparison run is required.
