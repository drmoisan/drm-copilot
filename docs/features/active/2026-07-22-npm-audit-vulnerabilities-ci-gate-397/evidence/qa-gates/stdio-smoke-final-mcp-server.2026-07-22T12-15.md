# [P6-T9] Final stdio Smoke Check — `packages/mcp-server/out/mcp-server.js` (rebuilt)

- **Timestamp:** 2026-07-22T12-15
- **Command:** started the rebuilt `out/mcp-server.js` (from P6-T8) as a child process with stdio pipes, wrote a single MCP `initialize` JSON-RPC request over stdin, read stdout for a matching JSON-RPC response, then terminated the process (`SIGTERM`).
- **EXIT_CODE:** process terminated via `SIGTERM` after receiving a valid response (script exit 0; child exit code `null`, signal `SIGTERM`, expected for a deliberately terminated stdio server process).

## Output Summary

- A well-formed JSON-RPC response was observed on stdout:
  `{"result":{"protocolVersion":"2024-11-05","capabilities":{"tools":{}},"serverInfo":{"name":"drmCopilotExtension","version":"1.0.17"}},"jsonrpc":"2.0","id":1}`
- Response correctly echoes `"id":1`, `"jsonrpc":"2.0"`, and includes `protocolVersion`, `capabilities`, and `serverInfo` — identical shape to the P0-T14 baseline response.
- Confirms the rebuilt bundle (post override + lock regeneration) starts correctly over stdio and answers `initialize` with no regression.
