# Final QC — Test and Coverage

- Timestamp: 2026-07-19T02-20
- Command: `cd extensions/drm-copilot && npm run test:coverage` (i.e. `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`)
- EXIT_CODE: 0

## Environment Note

Executed against the non-dotted mirror of the extension (`node_modules`/`resources` junctioned back to the worktree; `src`/`test`/config copied) because jest-on-Windows cannot glob test files under the `.claude/worktrees/...` checkout. See `evidence/baseline/baseline-test-coverage.2026-07-19T00-40.md` for the full explanation. The jest config, coverage collection set, and per-file thresholds are byte-identical to the worktree.

## Output Summary

- Test Suites: 165 passed, 165 total
- Tests: 2006 passed, 2006 total
- Coverage (text-summary reporter, whole extension):
  - Statements: 96.30% (37511/38949)
  - Branches: 89.22% (5198/5826)
  - Lines: 96.30% (37511/38949)
  - Functions: 89.48% (1098/1227)
- All per-file `coverageThreshold` gates satisfied (EXIT_CODE 0). New production files:
  - `src/repo-automation-execute-discovery.ts`: lines 97.13%, branches 83.87%
  - `src/mcp-tool-inputs-discovery.ts`: lines 100%, branches 96.87%
  - `src/mcp-handlers/discovery-handlers.ts`: lines 100%, branches 100%
  - `src/mcp-discovery-tool-definitions.ts`: lines 100%, branches 100%
  - `src/discovery-command-registration.ts`: lines 90.65%, branches 78.18%
  - `src/repo-automation-service-contract.ts`: type/interface-only (omitted from the per-file gate per policy)
- Modified production files under gate:
  - `src/mcp-tools.ts`: lines 92.76%, branches 83.33%
  - `src/runtime-detection.ts`: lines 95.05%, branches 84.74%
