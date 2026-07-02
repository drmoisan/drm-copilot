Timestamp: 2026-07-02T14-20
Command: $base = git merge-base HEAD origin/main; git diff --name-only --diff-filter=ACMRT "$base..HEAD" | measure changed non-test production TypeScript and Python script files
EXIT_CODE: 1
Output Summary:
- 179 lines: extensions/drm-copilot/src/lib/codex-native-converter/rewrites.ts
- 222 lines: extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts
- 199 lines: extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts
- 201 lines: extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts
- 501 lines: extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts
- 468 lines: extensions/drm-copilot/src/mcp-tool-definitions.ts
- 107 lines: extensions/drm-copilot/src/mcp-tool-inputs-push-down.ts
- 479 lines: extensions/drm-copilot/src/mcp-tool-inputs.ts
- 189 lines: extensions/drm-copilot/src/remove-worktrees.ts
- 407 lines: extensions/drm-copilot/src/repo-automation-command-registration-admin.ts
- 168 lines: extensions/drm-copilot/src/repo-automation-service-push-down.ts
- 497 lines: extensions/drm-copilot/src/repo-automation-service.ts
- 662 lines: extensions/drm-copilot/src/workflow-command-arguments.ts
- 275 lines: scripts/dev_tools/push_down_codex_and_agents_customizations.py
- 105 lines: scripts/dev_tools/push_down_codex_filesystem.py
- 178 lines: scripts/dev_tools/push_down_codex_pack_selection.py
- Files above 500 lines: extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts; extensions/drm-copilot/src/workflow-command-arguments.ts
