Timestamp: 2026-08-04T10:48:00-04:00
Task: P6-T3

Installed MCP call: `mcp__drm-copilot__validate_orchestration_artifacts` with artifact type `orchestrator-state`, the canonical fixture path, target workspace root, and all four strict options set to `true`.

Installed-process result: failed because the registered 1.0.20 MCP process predates this feature. Its validation error was `Checkpoint delegation_receipts object contains unsupported key: agents`, followed by missing required agent receipts. That process cannot be authoritative for the source change under test.

Local package build command: `npm run build` in `extensions/drm-copilot`.
Build exit code: 0.

Local MCP invocation: JSON-RPC `initialize`, `notifications/initialized`, and `tools/call` requests piped to `node out/mcp-server.js`; the tool name was `validate_orchestration_artifacts`, with the same artifact path, workspace root, and all four strict options set to `true`.
Local MCP exit code: 0.
Local MCP result: `{ "ok": true, "tool": "validate_orchestration_artifacts", "summary": "Validated orchestrator-state artifact at 'docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/other/mixed-complete-checkpoint.2026-08-04T10-46.json'." }`.

Authority note: the locally bundled MCP server was built from this worktree's modified TypeScript source and exercised the same MCP JSON-RPC tool contract. It is the authoritative MCP validation surface for this uninstalled feature branch.
