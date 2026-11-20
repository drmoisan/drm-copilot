# TypeScript Jest Coverage Baseline ([P0-T4], Phase 0 baseline)

Timestamp: 2026-11-20T06-54
Command: env -u VIRTUAL_ENV sh SCRATCH/issue-1016-jest-cov.sh (from the worktree root: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage --coverageReporters=lcov --coverageReporters=text-summary); then cp extensions/drm-copilot/coverage/lcov.info SCRATCH/issue-1016-baseline-lcov.info
EXIT_CODE: 0
HEAD: 5f8a76ef9c2dded22bd9128d4f9337fabc6cf6c3
Output Summary:
- Test Suites: 394 passed, 394 total
- Tests: 6450 passed, 6450 total (0 failed)
- text-summary totals: Statements 97.51% (71883/73715); Branches 94.83% (11414/12036); Functions 93.15% (2178/2338); Lines 97.51% (71883/73715)
- The launcher excludes the integration lane (`*.integration.test.ts`); integration runs in CI.

## Seven changed files (from extensions/drm-copilot/coverage/lcov.info)

| File | Lines LH/LF | Line % | Branches BRH/BRF | Branch % |
| --- | --- | --- | --- | --- |
| `src/mcp-tools.ts` | 473/488 | 96.93 | 97/104 | 93.27 |
| `src/mcp-tool-definitions.ts` | 473/473 | 100.00 | 0/0 | 100.00 |
| `src/mcp-repo-automation-tool-definitions.ts` | 436/436 | 100.00 | 0/0 | 100.00 |
| `src/repo-automation-service.ts` | 513/513 | 100.00 | 47/50 | 94.00 |
| `src/repo-automation-tool-names.ts` | 55/55 | 100.00 | 0/0 | 100.00 |
| `src/mcp-server.ts` | 111/136 | 81.62 | 8/12 | 66.67 |
| `src/lib/subprocess-runner.ts` | 140/142 | 98.59 | 19/20 | 95.00 |

`src/mcp-server.ts` is below the 85/75 thresholds at baseline (pre-existing; its uncovered lines are the stdio entry and `main`). The plan compares changed files by gained zero-count records ([P4-T4]).

## Zero-count records per file (durable baseline for [P4-T4])

Zero-count `DA` lines; zero-count `BRDA` records per line written `line x count` (count `0` or `-`).

- `src/mcp-tools.ts`
  - zero DA: 130 131 227 228 259 260 261 262 275 276 277 278 315 316 317
  - zero BRDA: 129x1 154x1 193x1 226x1 258x1 274x1 314x1
- `src/mcp-tool-definitions.ts`
  - zero DA: none
  - zero BRDA: none
- `src/mcp-repo-automation-tool-definitions.ts`
  - zero DA: none
  - zero BRDA: none
- `src/repo-automation-service.ts`
  - zero DA: none
  - zero BRDA: 266x1 283x1 411x1
- `src/repo-automation-tool-names.ts`
  - zero DA: none
  - zero BRDA: none
- `src/mcp-server.ts`
  - zero DA: 70 71 72 73 94 95 96 97 98 99 100 101 102 103 124 125 126 127 130 131 132 133 134 135 136
  - zero BRDA: 39x1 69x1 93x1 129x1
- `src/lib/subprocess-runner.ts`
  - zero DA: 102 103
  - zero BRDA: 101x1
