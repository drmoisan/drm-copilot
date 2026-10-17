Timestamp: 2026-10-17T18:54:36Z
Command: pwsh -NoProfile -File scripts/powershell/Publish-DrmCopilotExtension.ps1 -Package; supported code-insiders --install-extension <local-vsix> --force; packaged-resource and installed-file verification
EXIT_CODE: 0
MCP_VALIDATION_OK: false (separate model/topology validation tool result)
Output Summary: Local package and installation succeeded. This running MCP provider continues requiring former model identifiers; authoritative readiness is not established.

- Package: artifacts/vsix/drm-copilot-1.1.20-20261017-145307.vsix
- SHA-256: 41d87af47111c0075c86f8663f8fc62c68b9b7544129ff3b57d9d8d9b849a8fa
- Size: 2,640,002 bytes; 685 ZIP entries.
- All 676 packaged resource files are byte-identical to branch resources.
- Compiled MCP contains gpt-6-luna, gpt-6.1-sol and gpt-6-astra and no former GPT-5.6 routing slug.
- Supported local installation reported success; installed out/mcp-server.js is byte-identical to the validated local build (1,333,907 bytes).
- No Marketplace publication, tag, app restart, workspace reload, or user-session interruption was performed.
- Immediate MCP recheck retained the legacy expectation shown below. Updating installed files did not refresh this already-running provider.
- No restart/reload capability was found among available drm-copilot MCP tools or extension commands inspected. A live-provider refresh remains required; no unsupported process restart was attempted.
- Historical requested-model/profile/hash launch receipts remain verbatim. Installation alone does not prove completed checkpoint validity.

~~~text
Validation failed for orchestrator-state artifact at 'artifacts/orchestration/orchestrator-state.json':
Checkpoint codex_model_routing_receipts[11].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[12].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[13].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[14].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[15].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[11].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[12].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[13].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[14].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[15].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
~~~
