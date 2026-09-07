# TypeScript LCOV Module Inventory — [P2-T5]

Timestamp: 2026-09-07T12-00
Task: [P2-T5]

Command: `Select-String -LiteralPath extensions/drm-copilot/coverage/lcov.info -Pattern '^SF:.*orchestration-handoff-'`
EXIT_CODE: 0

## Matched lines (12 matches)

```
SF:src\lib\validate\orchestration-handoff-authority-service.ts
SF:src\lib\validate\orchestration-handoff-checkout-context.ts
SF:src\lib\validate\orchestration-handoff-contract-support.ts
SF:src\lib\validate\orchestration-handoff-contract.ts
SF:src\lib\validate\orchestration-handoff-materializer-production.ts
SF:src\lib\validate\orchestration-handoff-materializer-request.ts
SF:src\lib\validate\orchestration-handoff-materializer-support.ts
SF:src\lib\validate\orchestration-handoff-materializer.ts
SF:src\lib\validate\orchestration-handoff-path-boundary.ts
SF:src\lib\validate\orchestration-handoff-provider-adapters.ts
SF:src\lib\validate\orchestration-handoff-validation.ts
SF:src\mcp-handlers\orchestration-handoff-handlers.ts
```

## Comparison against [P0-T4]

| Source | Match count |
| --- | --- |
| [P0-T4] baseline | 12 |
| This run | 12 |

The counts are equal, and the twelve paths are identical to the baseline set.

## Why no changed file carries a coverage obligation

Every TypeScript file this plan changed is a test or test-support file under `extensions/drm-copilot/test/`:

- `test/lib/validate/orchestration-handoff-materializer-test-support.ts`
- `test/lib/validate/orchestration-handoff-materializer.test.ts`
- `test/lib/validate/orchestration-handoff-materializer-production.test.ts`
- `test/mcp-handlers/orchestration-handoff-handlers.test.ts`
- `test/mcp-server-test-service.ts`
- `test/mcp-server.test.ts`
- `test/repo-automation-orchestration-validation.test.ts`

`extensions/drm-copilot/jest.config.cjs` line 17 restricts measurement to `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]`. No path under `test/` matches that pattern, so no changed file carries an `SF:` record in `lcov.info` and none carries a changed-line coverage obligation. No production file was changed by this plan, so no production file's changed-line coverage is at issue either.

Output Summary: The inventory returns 12 `SF:` records, equal to the count recorded by [P0-T4], with an identical path set. Every changed TypeScript file is a test or test-support file under `extensions/drm-copilot/test/`, which `collectCoverageFrom` excludes from measurement, so no changed file carries an `SF:` record or a changed-line coverage obligation.
