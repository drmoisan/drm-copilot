# Issue #232 MCP Template Resolver Exposure Evidence

Timestamp: 2026-06-25T07-45

Command:

```powershell
npm --prefix extensions/drm-copilot run test:unit -- extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts extensions/drm-copilot/test/mcp-server.test.ts
```

EXIT_CODE: 0

Output Summary:

- `test/mcp-server.test.ts`: PASS.
- `test/mcp-repo-automation-tool-definitions.test.ts`: PASS.
- Test Suites: 2 passed, 2 total.
- Tests: 21 passed, 21 total.
- Snapshots: 0 total.
- The focused MCP unit tests verify that `resolve_policy_audit_template_asset` is exposed through the repo automation tool definitions and dispatched through the MCP server.
