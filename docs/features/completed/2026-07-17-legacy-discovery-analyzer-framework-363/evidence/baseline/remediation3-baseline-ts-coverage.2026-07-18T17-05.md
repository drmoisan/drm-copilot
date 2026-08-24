# Remediation Cycle 3 — TypeScript Test-and-Coverage Baseline (P0-T8) [expect-fail]

Timestamp: 2026-07-18T17-05

Command (canonical): `npm --prefix extensions/drm-copilot run test:coverage`

Command (as executed in this worktree): `npm --prefix extensions/drm-copilot run test:coverage -- --testMatch "**/test/**/*.test.ts"`

EXIT_CODE: 1

## Environment Note (test-discovery override, non-scope)

The `--testMatch "**/test/**/*.test.ts"` argument is required in this worktree because the branch is checked out under a `.claude` dot-directory, which mangles Jest's default `<rootDir>`-based `testMatch` glob (see `evidence/regression-testing/remediation3-fail-before-manifest-completeness.2026-07-18T17-05.md`). The override affects test discovery only, not coverage collection or thresholds.

## Output Summary

- Test counts: Test Suites 1 failed / 157 passed / 158 total; Tests 1 failed / 1885 passed / 1886 total. Matches CI run 29652993218 (1 failed, 1885 passed).
- Sole failure: `claude pack manifest completeness (real filesystem) › lists every bundled .claude agent, skill, and hook file in some pack manifest` (`test/lib/push-down/claude-pack-manifest-completeness.test.ts:137`), reporting the same four missing `.claude/agents/` paths. Confirmed this is the only failing test.
- Coverage summary (v8):
  - Lines: 96.74% (36133/37349)
  - Branches: 89.28% (5034/5638)
  - Functions: 89.14% (1051/1179)
  - Statements: 96.74% (36133/37349)
- Baseline line coverage 96.74% and branch coverage 89.28% are the pre-fix reference values for the P2-T11 delta check. Both exceed the mandatory thresholds (line >= 85%, branch >= 75%).
