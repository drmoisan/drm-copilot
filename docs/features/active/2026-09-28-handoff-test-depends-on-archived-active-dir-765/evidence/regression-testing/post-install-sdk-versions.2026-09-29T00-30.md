Timestamp: 2026-09-28T20-05
Command: git grep -nF -A1 "node_modules/@modelcontextprotocol/sdk" -- package-lock.json extensions/drm-copilot/package-lock.json packages/mcp-server/package-lock.json
EXIT_CODE: 0
Output Summary: (last 25 lines of output below)
```text
extensions/drm-copilot/package-lock.json:1852:    "node_modules/@modelcontextprotocol/sdk": {
extensions/drm-copilot/package-lock.json-1853-      "version": "1.30.1",
--
package-lock.json:1368:    "node_modules/@modelcontextprotocol/sdk": {
package-lock.json-1369-      "version": "1.30.1",
--
package-lock.json:1408:    "node_modules/@modelcontextprotocol/sdk/node_modules/ajv": {
package-lock.json-1409-      "version": "8.18.0",
--
package-lock.json:1424:    "node_modules/@modelcontextprotocol/sdk/node_modules/json-schema-traverse": {
package-lock.json-1425-      "version": "1.0.0",
--
packages/mcp-server/package-lock.json:478:    "node_modules/@modelcontextprotocol/sdk": {
packages/mcp-server/package-lock.json-479-      "version": "1.30.1",
```

Note: per-lockfile comparison with P0-T5 (1.30.1 in each):
- package-lock.json: @modelcontextprotocol/sdk 1.30.1 - unchanged
- extensions/drm-copilot/package-lock.json: 1.30.1 - unchanged
- packages/mcp-server/package-lock.json: 1.30.1 - unchanged
No sdk movement; no package.json sdk range edited.
