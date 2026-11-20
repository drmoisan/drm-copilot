# Phase 5 line counts (#647)

Timestamp: 2026-10-01T23-18
Command: grep -c '' <each Phase 5 path except test/extension.workflow-commands.test.ts> ; git diff --numstat 1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9 -- extensions/drm-copilot/test/extension.workflow-commands.test.ts
EXIT_CODE: 0

| Path | Lines |
|---|---|
| extensions/drm-copilot/test/extension-test-harness.ts | 479 |
| extensions/drm-copilot/test/codex-worktree-session-command.test.ts | 389 |
| extensions/drm-copilot/test/extension.discovery-commands.test.ts | 282 |
| extensions/drm-copilot/test/extension.new-potential-bug-entry-inprocess.test.ts | 258 |
| extensions/drm-copilot/test/extension.resolve-policy-audit-template.test.ts | 107 |
| extensions/drm-copilot/test/extension.run-poshqc-commands.test.ts | 254 |
| extensions/drm-copilot/test/extension.run-poshqc-suite.test.ts | 112 |
| extensions/drm-copilot/test/extension.test.ts | 390 |

`git diff --numstat BASE_SHA -- extensions/drm-copilot/test/extension.workflow-commands.test.ts`: (empty output; file not modified)

Output Summary: every count is at most 500 (maximum 479); the workflow-commands numstat is empty, so the line-neutral condition holds.
