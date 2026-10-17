# Phase 7 line counts (#647)

Timestamp: 2026-10-01T23-18
Command: grep -c '' <each of the 12 Phase 7 paths>
EXIT_CODE: 0

| Path | Lines |
|---|---|
| extensions/drm-copilot/test/poshqc-folder-picker.test.ts | 243 |
| extensions/drm-copilot/test/push-down-claude-handler.test.ts | 142 |
| extensions/drm-copilot/test/remove-worktrees-runner.test.ts | 451 |
| extensions/drm-copilot/test/remove-worktrees.test.ts | 485 |
| extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts | 308 |
| extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts | 196 |
| extensions/drm-copilot/test/repo-automation-dispatch.test.ts | 499 |
| extensions/drm-copilot/test/repo-automation-execute-discovery.test.ts | 438 |
| extensions/drm-copilot/test/repo-automation-hard-lock-prompt.test.ts | 212 |
| extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts | 466 |
| extensions/drm-copilot/test/repo-automation-service.resolve-atomic-plan-prompt.test.ts | 120 |
| extensions/drm-copilot/test/subagent-tree-command.test.ts | 500 |

Output Summary: every count is at most 500 (repo-automation-dispatch.test.ts 499, net 0 after line recovery; subagent-tree-command.test.ts 500, matching the plan arithmetic).
