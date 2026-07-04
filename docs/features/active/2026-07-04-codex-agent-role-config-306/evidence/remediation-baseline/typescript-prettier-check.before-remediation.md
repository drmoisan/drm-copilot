Timestamp: 2026-07-04T14-49
Command: Push-Location extensions/drm-copilot; npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; Pop-Location
EXIT_CODE: 1
Output Summary:
- Baseline TypeScript Prettier check failed.
- Prettier reported formatting issues in 6 files:
  - src/lib/codex-native-converter/rewrites.ts
  - src/remove-worktrees.ts
  - src/workflow-command-arguments.ts
  - test/extension.potential-to-issue.test.ts
  - test/extension.push-down-claude-customizations.test.ts
  - test/mcp-repo-automation-tool-definitions.test.ts
