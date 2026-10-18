# typescript-extension-build

Timestamp: 2026-10-18T04-00
Command: npm.cmd run build
EXIT_CODE: 0
Output Summary: ; ; > drm-copilot@1.1.21 bundle:mcp-server; > node esbuild-mcp-server.cjs

Working directory: extensions/drm-copilot
Started: 2026-10-18T04:00:12.376632+00:00
Duration seconds: 2.042
Phase: P0 baseline; no implementation repair is performed by this command.

## Captured output

```text

> drm-copilot@1.1.21 build
> tsc -p ./ --noEmit && npm run bundle:extension && npm run bundle:mcp-server


> drm-copilot@1.1.21 bundle:extension
> node esbuild-extension.cjs


> drm-copilot@1.1.21 bundle:mcp-server
> node esbuild-mcp-server.cjs
```
