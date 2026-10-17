# Final QC: TypeScript Tests with Coverage (P7-T11)

Timestamp: 2026-10-07T22-28

## Command 1

Command: npm --prefix extensions/drm-copilot run test:coverage (cwd: worktree root)
EXIT_CODE: 0
Output Summary:
- `Test Suites: 253 passed, 253 total`
- `Tests:       3852 passed, 3852 total` (0 failed; P0-T15 baseline 3816 in 251 suites)
- text-summary: `Statements   : 97.11% ( 51037/52551 )`, `Branches     : 91.53% ( 7503/8197 )`, `Functions    : 91.56% ( 1531/1672 )`, `Lines        : 97.11% ( 51037/52551 )`
- The run exits 0 with the 14 new per-file `coverageThreshold` entries active, so no threshold failed.

### 14-module table (from `extensions/drm-copilot/coverage/lcov.info` `SF:` records; key = `SF:` path with `\` replaced by `/`, ending in `src/<module>`)

| Module | LH/LF | Line % | BRH/BRF | Branch % | >= 85 / 75 |
|---|---|---|---|---|---|
| `src/lib/validate/orchestration-handoff-authority-service.ts` | 386/390 | 98.97 | 64/71 | 90.14 | yes |
| `src/lib/validate/orchestration-handoff-checkout-context.ts` | 212/212 | 100.00 | 39/39 | 100.00 | yes |
| `src/lib/validate/orchestration-handoff-contract-support.ts` | 323/323 | 100.00 | 46/46 | 100.00 | yes |
| `src/lib/validate/orchestration-handoff-contract.ts` | 491/497 | 98.79 | 69/76 | 90.79 | yes |
| `src/lib/validate/orchestration-handoff-materializer-production.ts` | 139/139 | 100.00 | 39/40 | 97.50 | yes |
| `src/lib/validate/orchestration-handoff-materializer-request.ts` | 122/122 | 100.00 | 26/26 | 100.00 | yes |
| `src/lib/validate/orchestration-handoff-materializer-support.ts` | 77/77 | 100.00 | 20/21 | 95.24 | yes |
| `src/lib/validate/orchestration-handoff-materializer.ts` | 483/488 | 98.98 | 81/84 | 96.43 | yes |
| `src/lib/validate/orchestration-handoff-path-boundary.ts` | 218/221 | 98.64 | 50/59 | 84.75 | yes |
| `src/lib/validate/orchestration-handoff-provider-adapters.ts` | 271/273 | 99.27 | 22/23 | 95.65 | yes |
| `src/lib/validate/orchestration-handoff-validation.ts` | 246/248 | 99.19 | 25/27 | 92.59 | yes |
| `src/lib/validate/semantic-mcp-identity.ts` | 54/54 | 100.00 | 11/11 | 100.00 | yes |
| `src/mcp-handlers/orchestration-handoff-handlers.ts` | 310/310 | 100.00 | 68/68 | 100.00 | yes |
| `src/mcp-repo-automation-tool-definitions-handoff.ts` | 222/222 | 100.00 | 0/0 | no branch construct | yes |

## Command 2

Command: node run-jest.cjs test/packaging/mcp-server-prepack.test.ts (cwd: extensions/drm-copilot)
EXIT_CODE: 0
Output Summary: `Tests:       4 passed, 4 total` (verbatim; 0 failed; equals the P0-T15 second-command count 4).

## Command 3

Command: git diff --quiet 08ee030d9584bf15882fbb3654c8e38f34c7c359 -- extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts (cwd: worktree root; DEV-1 diff base)
EXIT_CODE: 0
Output Summary: the prepack test file is unchanged.

Result: PASS
