# [P0-T14] Manual stdio Smoke Check Baseline — `packages/mcp-server/out/mcp-server.js`

- **Timestamp:** 2026-07-22T12-15
- **Command:** started the built `out/mcp-server.js` as a child process with stdio pipes, wrote a single MCP `initialize` JSON-RPC request (`{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"stdio-smoke-check","version":"0.0.0"}}}\n`) to stdin, read stdout for a matching JSON-RPC response, then terminated the process (`SIGTERM`).
- **EXIT_CODE:** process terminated via `SIGTERM` after receiving a valid response (script exit 0; child exit code `null`, signal `SIGTERM`, which is the expected termination signal for a deliberately killed long-running stdio server process).

## Output Summary

- A well-formed JSON-RPC response was observed on stdout:
  `{"result":{"protocolVersion":"2024-11-05","capabilities":{"tools":{}},"serverInfo":{"name":"drmCopilotExtension","version":"1.0.17"}},"jsonrpc":"2.0","id":1}`
- Response correctly echoes `"id":1` and includes `jsonrpc":"2.0"`, `protocolVersion`, `capabilities`, and `serverInfo` — confirms the pre-fix build starts correctly over stdio and answers `initialize`.
- Process was cleanly terminated after the response was confirmed.
