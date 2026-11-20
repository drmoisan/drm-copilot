# TypeScript Test and Coverage Baseline (P0-T15)

Timestamp: 2026-10-07T21-53

## Command 1

Command: npm --prefix extensions/drm-copilot run test:coverage  (cwd: worktree root)
EXIT_CODE: 0
Output Summary:
- `Test Suites: 251 passed, 251 total`
- `Tests:       3816 passed, 3816 total` (0 failed)
- text-summary: `Statements   : 97.1% ( 50908/52428 )`, `Branches     : 91.44% ( 7462/8160 )`, `Functions    : 91.55% ( 1528/1669 )`, `Lines        : 97.1% ( 50908/52428 )`
- Line percent 97.1; branch percent 91.44.

### 14-module table (from `extensions/drm-copilot/coverage/lcov.info` `SF:` records; key = `SF:` path with `\` replaced by `/`, ending in `src/<module>`)

| Module | LH/LF | Line % | BRH/BRF | Branch % |
|---|---|---|---|---|
| `src/lib/validate/orchestration-handoff-authority-service.ts` | 371/377 | 98.41 | 61/69 | 88.41 |
| `src/lib/validate/orchestration-handoff-checkout-context.ts` | 212/212 | 100.00 | 39/39 | 100.00 |
| `src/lib/validate/orchestration-handoff-contract-support.ts` | 323/323 | 100.00 | 46/46 | 100.00 |
| `src/lib/validate/orchestration-handoff-contract.ts` | 491/497 | 98.79 | 69/76 | 90.79 |
| `src/lib/validate/orchestration-handoff-materializer-production.ts` | 136/136 | 100.00 | 36/37 | 97.30 |
| `src/lib/validate/orchestration-handoff-materializer-request.ts` | 84/84 | 100.00 | 11/11 | 100.00 |
| `src/lib/validate/orchestration-handoff-materializer-support.ts` | 77/77 | 100.00 | 18/20 | 90.00 |
| `src/lib/validate/orchestration-handoff-materializer.ts` | 437/444 | 98.42 | 74/78 | 94.87 |
| `src/lib/validate/orchestration-handoff-path-boundary.ts` | 200/205 | 97.56 | 43/53 | 81.13 |
| `src/lib/validate/orchestration-handoff-provider-adapters.ts` | 271/273 | 99.27 | 22/23 | 95.65 |
| `src/lib/validate/orchestration-handoff-validation.ts` | 246/248 | 99.19 | 25/27 | 92.59 |
| `src/lib/validate/semantic-mcp-identity.ts` | 54/54 | 100.00 | 11/11 | 100.00 |
| `src/mcp-handlers/orchestration-handoff-handlers.ts` | 304/304 | 100.00 | 64/64 | 100.00 |
| `src/mcp-repo-automation-tool-definitions-handoff.ts` | 220/220 | 100.00 | 0/0 | no branch construct |

## Command 2

Command: node run-jest.cjs test/packaging/mcp-server-prepack.test.ts  (cwd: extensions/drm-copilot)
EXIT_CODE: 0
Output Summary:
- `Test Suites: 1 passed, 1 total`
- `Tests:       4 passed, 4 total` (per-file prepack pass count used by P7-T11: 4)
