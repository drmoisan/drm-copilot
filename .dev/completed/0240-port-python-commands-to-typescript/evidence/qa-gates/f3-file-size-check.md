# F3 File-Size Verification (<= 500 lines)

Timestamp: 2026-06-26T01-39
Command: wc -l src/lib/push-down/*.ts src/repo-automation-service.ts src/repo-automation-service-push-down.ts
EXIT_CODE: 0
Output Summary (line counts; all <= 500):
- src/lib/push-down/claude-customizations.ts          244
- src/lib/push-down/claude-filesystem-adapter.ts      303
- src/lib/push-down/claude-memory-scope.ts            136
- src/lib/push-down/claude-pack-selection.ts          308
- src/lib/push-down/codex-agents-customizations.ts     80
- src/lib/push-down/copilot-customizations.ts         102
- src/lib/push-down/copilot-customizations-engine.ts  448
- src/lib/push-down/filesystem-adapter.ts             204
- src/lib/push-down/push-down-service-call.ts         180
- src/lib/push-down/reference-rewrites.ts             243
- src/repo-automation-service.ts                      500
- src/repo-automation-service-push-down.ts            135

All listed files are <= 500 lines. `repo-automation-service.ts` is exactly 500.
Test files touched: test/lib/push-down/*.test.ts (all new),
test/repo-automation-service.push-down-claude.test.ts (rewritten),
test/extension.push-down-claude-customizations.test.ts (rewritten),
test/extension.integration.test.ts (now 493 lines after removing the two
push-down spawn case blocks), test/extension-test-harness.ts (added statSync/
readdirSync mock support for the in-process push-down filesystem).
