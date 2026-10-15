# baseline-locked-versions

Timestamp: 2026-10-08T18-58
Command: git grep -nF -A1 "node_modules/handlebars" -- package-lock.json extensions/drm-copilot/package-lock.json packages/mcp-server/package-lock.json
EXIT_CODE: 0
Output Summary: package-lock.json and extensions/drm-copilot/package-lock.json each lock handlebars at 4.7.9; packages/mcp-server/package-lock.json has no match.

```text
extensions/drm-copilot/package-lock.json:4512:    "node_modules/handlebars": {
extensions/drm-copilot/package-lock.json-4513-      "version": "4.7.9",
--
package-lock.json:4474:    "node_modules/handlebars": {
package-lock.json-4475-      "version": "4.7.9",
```
