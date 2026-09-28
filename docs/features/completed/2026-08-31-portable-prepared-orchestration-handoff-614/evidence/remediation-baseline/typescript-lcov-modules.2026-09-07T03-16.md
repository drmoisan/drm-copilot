# TypeScript LCOV Handoff-Module Inventory — [P0-T4]

Timestamp: 2026-09-07T10-58
Task: [P0-T4]

Command: `Select-String -LiteralPath extensions/drm-copilot/coverage/lcov.info -Pattern '^SF:.*orchestration-handoff-'`
EXIT_CODE: 0

## Matched lines (verbatim, 12 matches)

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

Match count: 12

Output Summary: The inventory records 12 `SF:` records matching `orchestration-handoff-`, which satisfies the stated floor of at least 11. Eleven are the `src/lib/validate/orchestration-handoff-*.ts` modules; the twelfth is `src/mcp-handlers/orchestration-handoff-handlers.ts`. The observed path-separator spelling in the `SF:` records is the Windows backslash (`src\lib\validate\...`), and every recorded path is relative to the `extensions/drm-copilot` project root rather than to the repository root. The recorded count of 12 is the floor for [P2-T5]. Because the `SF:` records depend on the Windows path separator, [P2-T5] must compare counts rather than exact path strings if run on a different platform; this pass is Windows-only, so the spelling is stable across the two observations.
