# QA Gate — File-Size Audit (500-line cap)

- Timestamp: 2026-07-19T02-10
- Issue: #370
- Policy: `.claude/rules/general-code-change.md` — no production/test file may exceed 500 lines.

## Production files (new and modified)

| Lines | File | Status |
|---|---|---|
| 283 | `src/runtime-detection.ts` | OK |
| 454 | `src/repo-automation-execute-discovery.ts` | OK |
| 175 | `src/repo-automation-service-contract.ts` | OK |
| 439 | `src/repo-automation-service.ts` | OK |
| 246 | `src/mcp-tool-inputs-discovery.ts` | OK |
| 69 | `src/mcp-handlers/discovery-handlers.ts` | OK |
| 32 | `src/repo-automation-tool-names.ts` | OK |
| 318 | `src/mcp-tools.ts` | OK |
| 210 | `src/mcp-discovery-tool-definitions.ts` | OK |
| 490 | `src/mcp-repo-automation-tool-definitions.ts` | OK |
| 437 | `src/mcp-tool-definitions.ts` | OK |
| 364 | `src/discovery-command-registration.ts` | OK |
| 496 | `src/extension.ts` | OK |

## Test files (new and modified)

| Lines | File | Status |
|---|---|---|
| 153 | `test/runtime-detection.test.ts` | OK |
| 432 | `test/repo-automation-execute-discovery.test.ts` | OK |
| 155 | `test/repo-automation-service.discovery.test.ts` | OK |
| 275 | `test/mcp-tool-inputs-discovery.test.ts` | OK |
| 288 | `test/mcp-tools.discovery.test.ts` | OK |
| 282 | `test/extension.discovery-commands.test.ts` | OK |
| 306 | `test/mcp-repo-automation-tool-definitions.test.ts` | OK |
| 493 | `test/mcp-server.test.ts` | OK |
| 303 | `test/mcp-server.discovery.test.ts` | OK |
| 131 | `test/mcp-server-epic-validation.test.ts` | OK |
| 82 | `test/mcp-tools.codex-native-converter.test.ts` | OK |
| 208 | `test/mcp-tools.push-down-claude.test.ts` | OK |

## Note

`test/mcp-server.test.ts` reached 716 lines while the seven discovery MCP round-trip tests were added inline per plan task P5-T6. Because the 500-line cap is a non-negotiable repository policy, the round-trip suite (dispatch round-trips over `InMemoryTransport`, invalid-enum rejections, discovery no-terminal invariant) was extracted into a new sibling file `test/mcp-server.discovery.test.ts` (303 lines). The `listTools` exact-array expectation (extended with the seven discovery tool names) remains in `test/mcp-server.test.ts` (493 lines). Both files pass and satisfy the cap.

## Result: PASS

Every production and test file touched by this feature is at or under the 500-line cap.
