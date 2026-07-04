# TypeScript Test Baseline (P0-T12)

- Timestamp: 2026-07-02T19-50
- Command: `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`
  (run from `extensions/drm-copilot`).

  **Toolchain substitution note:** the repository's actual TypeScript test runner in
  `extensions/drm-copilot` is Jest (`node run-jest.cjs`, wired as the `test`/`test:unit`
  npm scripts), not Vitest; there is no `test:coverage` script and no `vitest` binary
  installed in this workspace (`.claude/rules/typescript.md`'s Vitest references do not
  match this package's actual toolchain). `npm run test:unit -- --coverage ...` is the
  repository-established equivalent coverage invocation, consistent with prior baseline
  evidence in this repository (for example
  `docs/features/archive/2026-03-21-bundle-sync-agents-113/evidence/baseline/typescript-test.2026-04-03T16-08.md`).
  This is a mechanical substitution to run the equivalent verification with the actual
  installed toolchain; it does not change what is being verified (pass/fail and coverage).
- EXIT_CODE: 0

## Output Summary

- Test Suites: 120 passed, 120 total.
- Tests: 1440 passed, 1440 total.
- Statements coverage: 96.88% (30868/31862).
- Branches coverage: 88.29% (3974/4501).
- Functions coverage: 88.11% (949/1077).
- Lines coverage: 96.88% (30868/31862).

Both the 85% line-coverage floor and the 75% branch-coverage floor are met at baseline.
This baseline is recorded for delta comparison in P6-T5.
