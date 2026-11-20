# File-Size Check (<= 500 lines)

Timestamp: 2026-07-09T09-59
Command: wc -l on every touched production and test file (from repo root / extensions/drm-copilot).
EXIT_CODE: 0
Output Summary: every listed file is <= 500 lines.

## Production files
| Lines | File |
|---|---|
| 133 | extensions/drm-copilot/src/lib/subagent-tree/quick-pick-labels.ts |
| 364 | extensions/drm-copilot/src/lib/file-system.ts |
| 211 | extensions/drm-copilot/src/subagent-tree-command.ts |
| 78 | extensions/drm-copilot/src/lib/subagent-tree/session-transcript-resolver.ts |
| 25 | extensions/drm-copilot/src/repo-automation-tool-names.ts |
| 470 | extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts |
| 43 | extensions/drm-copilot/src/mcp-tool-inputs-subagent-tree.ts |
| 487 | extensions/drm-copilot/src/repo-automation-service.ts |
| 63 | extensions/drm-copilot/src/repo-automation-service-subagent-tree.ts |
| 71 | extensions/drm-copilot/src/repo-automation-execute-script.ts |
| 136 | extensions/drm-copilot/src/repo-automation-service-support.ts |
| 21 | extensions/drm-copilot/src/mcp-handlers/render-subagent-tree-handler.ts |
| 269 | extensions/drm-copilot/src/mcp-tools.ts |
| 153 | .claude/hooks/persist-session-id.ps1 |

## Test files
| Lines | File |
|---|---|
| 206 | extensions/drm-copilot/test/lib/subagent-tree/quick-pick-labels.test.ts |
| 499 | extensions/drm-copilot/test/subagent-tree-command.test.ts |
| 147 | extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts |
| 220 | extensions/drm-copilot/test/repo-automation-render-subagent-tree.test.ts |
| 185 | extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts |
| 500 | extensions/drm-copilot/test/mcp-server.test.ts |
| 200 | tests/scripts/claude-hooks/persist-session-id.Tests.ps1 |

Note: test/subagent-tree-command.test.ts was trimmed from 502 to 499 lines (redundant comment lines
removed) to satisfy the limit; test/mcp-server.test.ts is exactly 500 (limit is "may not exceed 500").
