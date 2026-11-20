# Final-QC TypeScript Jest Coverage Gate ([P4-T3])

Timestamp: 2026-11-20T07-45
Command: env -u VIRTUAL_ENV sh SCRATCH/issue-1016-jest-cov.sh (from the worktree root: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage --coverageReporters=lcov --coverageReporters=text-summary); cp extensions/drm-copilot/coverage/lcov.info SCRATCH/issue-1016-final-lcov.info
EXIT_CODE: 0
Output Summary:
- Test Suites: 412 passed, 412 total
- Tests: 6683 passed, 6683 total (0 failed); no `coverageThreshold` failure
- text-summary totals: Statements 97.58% (74498/76344); Branches 94.94% (11901/12535); Functions 93.31% (2246/2407); Lines 97.58% (74498/76344)
- Measured tree: the working tree at commit `049086840` plus the uncommitted [P4-T1] edit of `test/development-docs-migration-coverage-contracts.test.ts` (test file only).
- Integration stage: runs in CI (`CI Required Gate`); the launcher excludes the integration lane locally.

## Thirteen new files (lcov `LH/LF`, `BRH/BRF`)

| File | Lines | Line % | Branches | Branch % | At or above 85/75 |
| --- | --- | --- | --- | --- | --- |
| `src/lib/development-docs-migration/folder-rename-plan.ts` | 217/217 | 100.00 | 30/35 | 85.71 | yes |
| `src/lib/development-docs-migration/layout-map.ts` | 156/156 | 100.00 | 21/21 | 100.00 | yes |
| `src/lib/development-docs-migration/migrate-development-docs-service-call.ts` | 212/212 | 100.00 | 33/34 | 97.06 | yes |
| `src/lib/development-docs-migration/migration-apply.ts` | 106/106 | 100.00 | 12/12 | 100.00 | yes |
| `src/lib/development-docs-migration/migration-decisions.ts` | 346/346 | 100.00 | 75/76 | 98.68 | yes |
| `src/lib/development-docs-migration/migration-git.ts` | 85/85 | 100.00 | 11/11 | 100.00 | yes |
| `src/lib/development-docs-migration/migration-plan.ts` | 587/587 | 100.00 | 145/148 | 97.97 | yes |
| `src/lib/development-docs-migration/migration-report.ts` | 222/222 | 100.00 | 25/25 | 100.00 | yes |
| `src/lib/development-docs-migration/reference-rewrite.ts` | 333/333 | 100.00 | 65/65 | 100.00 | yes |
| `src/mcp-development-docs-tool-definitions.ts` | 42/42 | 100.00 | 0/0 | 100.00 | yes |
| `src/mcp-handlers/development-docs-migration-handler.ts` | 30/30 | 100.00 | 4/4 | 100.00 | yes |
| `src/mcp-tool-inputs-development-docs.ts` | 72/72 | 100.00 | 18/18 | 100.00 | yes |
| `src/migrate-development-docs-cli.ts` | 138/143 | 96.50 | 39/41 | 95.12 | yes |

## Seven changed files

| File | Lines | Line % | Branches | Branch % | Zero DA | Zero BRDA (line x count) |
| --- | --- | --- | --- | --- | --- | --- |
| `src/mcp-tools.ts` | 480/495 | 96.97 | 99/106 | 93.40 | 131 132 228 229 260 261 262 263 276 277 278 279 316 317 318 | 130x1 155x1 194x1 227x1 259x1 275x1 315x1 |
| `src/mcp-tool-definitions.ts` | 475/475 | 100.00 | 0/0 | 100.00 | none | none |
| `src/mcp-repo-automation-tool-definitions.ts` | 438/438 | 100.00 | 0/0 | 100.00 | none | none |
| `src/repo-automation-service.ts` | 528/528 | 100.00 | 48/51 | 94.12 | none | 271x1 288x1 416x1 |
| `src/repo-automation-tool-names.ts` | 56/56 | 100.00 | 0/0 | 100.00 | none | none |
| `src/mcp-server.ts` | 146/172 | 84.88 | 12/16 | 75.00 | 74 75 76 77 98 99 100 101 102 103 104 105 106 107 133 134 135 136 137 166 167 168 169 170 171 172 | 43x1 73x1 97x1 165x1 |
| `src/lib/subprocess-runner.ts` | 147/149 | 98.66 | 21/22 | 95.45 | 105 106 | 104x1 |
