# Baseline — Test and Coverage

- Timestamp: 2026-07-19T00-40
- Command: `cd extensions/drm-copilot && npm run test:coverage` (i.e. `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`)
- EXIT_CODE: 0

## Environment Note (jest + Windows + `.claude/` dot-directory)

This feature worktree is checked out under `...\.claude\worktrees\agent-a55939ec61e0aa828\...`. Jest 30 on Windows cannot discover its test files at this location: `jest-util`'s `replacePathSepForGlob` (`path.replaceAll(/\\(?![$()+.?^{}])/g, '/')`) preserves the `\.` before `.claude`, and picomatch then treats the glob's `\.` as an escaped dot while the candidate path's `\` is literal data, so `testMatch` yields 0 matches (`350 files checked, testMatch 0 matches`). `npm run format`, `npm run lint`, and `npm run typecheck` are unaffected and run directly in the worktree.

To obtain the numeric coverage the plan requires, the identical jest invocation is executed against a non-dotted mirror of the extension: `src/` and `test/` (plus `jest.config.cjs`, `package.json`, `tsconfig*.json`, `run-jest.cjs`) are copied to `C:\Users\DanMoisan\AppData\Local\Temp\drm370\extensions\drm-copilot`, and `node_modules/` and `resources/` are directory junctions back to the worktree. The jest config, coverage collection set (`src/**/*.ts`), and per-file thresholds are byte-identical to the worktree. No source is modified by the mirror; edits continue to be made in the worktree and re-synced before each run.

## Output Summary

- Test Suites: 158 passed, 158 total
- Tests: 1886 passed, 1886 total
- Coverage (text-summary reporter, whole extension):
  - Statements: 96.74% (36133/37349)
  - Branches: 89.28% (5034/5638)
  - Lines: 96.74% (36133/37349)
  - Functions: 89.14% (1051/1179)

Baseline test and coverage state is clean (all suites/tests pass; coverage well above the 85% line / 75% branch policy floor).
