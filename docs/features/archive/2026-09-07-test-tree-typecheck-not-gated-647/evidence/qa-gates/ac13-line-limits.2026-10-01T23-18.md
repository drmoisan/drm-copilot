# AC-13 line limits (#647)

Timestamp: 2026-10-01T23-18
Command: git diff --numstat 1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9 -- extensions/drm-copilot/test/extension.workflow-commands.test.ts ; git diff --name-only --diff-filter=AM 1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9 -- extensions/drm-copilot ; git status --porcelain -- extensions/drm-copilot ; grep -c '' <each .ts path in the union, excluding extension.workflow-commands.test.ts>
EXIT_CODE: 0

workflow-commands numstat: (empty; file unchanged)
Name list (AM): 65 paths, of which 64 are `.ts` (the other is package.json). Porcelain: empty.

Largest counts among the 64 `.ts` files:
- test/mcp-server.test.ts: 482
- test/remove-worktrees.test.ts: 485
- test/lib/push-down/claude-config-carriage.test.ts: 494
- test/extension.collect-pr-context.test.ts: 497
- test/extension.integration.test.ts: 498
- test/repo-automation-dispatch.test.ts: 499
- test/lib/validate/orchestration-handoff-authority-service.test.ts: 500
- test/subagent-tree-command.test.ts: 500
Files over 500 lines: none.

Output Summary: workflow-commands numstat is empty (line-neutral); every changed or added `.ts` file is at most 500 lines (`grep -c ''` equals `(Get-Content <path>).Count` for these files).
