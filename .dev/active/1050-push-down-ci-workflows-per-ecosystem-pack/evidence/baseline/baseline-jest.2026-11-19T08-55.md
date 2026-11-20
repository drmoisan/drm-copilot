# Phase 0 Baseline: Jest (P0-T4)

Timestamp: 2026-11-19T08-55
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage (node run-jest.cjs in extensions/drm-copilot through the launcher; integration lane excluded by the launcher); per-file figures read from extensions/drm-copilot/coverage/lcov.info (copy kept as SCRATCH/baseline-lcov.info)
EXIT_CODE: 0
Output Summary: Test Suites 369 passed of 369; Tests 6119 passed, 0 failed. Repo-wide (Jest coverage summary): lines 97.42% (68431/70241), branches 94.63% (10597/11198), statements 97.42%, functions 92.79%.

## Per-File Coverage of Existing TypeScript Files This Plan Edits (lcov.info)

| File | Lines | Branches |
| --- | --- | --- |
| `src/lib/push-down/push-down-layer.ts` | 100.00% (126/126) | 100.00% (1/1) |
| `src/lib/push-down/push-down-pipeline.ts` | 99.21% (504/508) | 97.65% (83/85) |
| `src/lib/push-down/push-down-harness.ts` | 100.00% (225/225) | 96.00% (48/50) |
| `src/lib/push-down/push-down-service-call.ts` | 100.00% (202/202) | 100.00% (20/20) |
| `src/mcp-push-down-schema-properties.ts` | 100.00% (91/91) | no branches |
| `src/mcp-tool-inputs-push-down.ts` | 100.00% (180/180) | 100.00% (51/51) |
| `src/repo-automation-service-contract.ts` | 0.00% (0/325) | 0.00% (0/1) |
| `src/repo-automation-service-push-down.ts` | 100.00% (227/227) | 100.00% (20/20) |

`src/repo-automation-service-contract.ts` reports 0% before any edit: it holds type declarations only, which the coverage policy allows to report 0% executable coverage.
