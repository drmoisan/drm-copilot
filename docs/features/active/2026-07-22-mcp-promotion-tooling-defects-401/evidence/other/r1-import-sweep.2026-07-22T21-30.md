# R1 Import Sweep (Cycle 1, Issue #401)

Timestamp: 2026-07-22T21-30

Command:
- grep -rn "run_poshqc" extensions/drm-copilot/src extensions/drm-copilot/test
- grep -rn "mcp-repo-automation-tool-definitions" extensions/drm-copilot/src extensions/drm-copilot/test
- npx tsc -p ./ --noEmit (from extensions/drm-copilot/)

EXIT_CODE: 0 (tsc)

Output Summary:
- Consumers of the base module import `REPO_AUTOMATION_TOOL_DEFINITIONS` (test/mcp-tools.push-down-claude.test.ts, test/mcp-epic-validation-definitions.test.ts, test/mcp-repo-automation-tool-definitions.test.ts, src/mcp-tools.ts) or the `ToolDefinition` type (src/mcp-discovery-tool-definitions.ts). All of these remain exported from the base module unchanged.
- The `run_poshqc` matches in src/repo-automation-tool-names.ts, src/repo-automation-service.ts, src/repo-automation-service-support.ts, src/repo-automation-args.ts, src/mcp-tools.ts, src/lib/codex-native-converter/rewrites-rules.ts are string tool-name references, not imports of the moved definitions; no change required.
- Import updates made: NONE (as predicted; the public import surface is preserved by the re-export).
- tsc exited 0 with no diagnostics after the split.
