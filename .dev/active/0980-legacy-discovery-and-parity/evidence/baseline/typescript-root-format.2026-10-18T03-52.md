# typescript-root-format

Timestamp: 2026-10-18T03-52
Command: npm.cmd run format:check
EXIT_CODE: 1
Output Summary:   ]; }; ; Node.js v24.14.0

Working directory: .
Started: 2026-10-18T03:52:11.089535+00:00
Duration seconds: 0.280
Phase: P0 baseline; no implementation repair is performed by this command.

## Captured output

```text

> drm-copilot@1.0.0 format:check
> node run-node-tool.cjs prettier/bin/prettier.cjs --no-error-on-unmatched-pattern --check "src/**/*.{ts,tsx,js,mjs,cjs,json}" "tests/**/*.{ts,tsx,js,mjs,cjs,json}" "eslint.config.mjs" "jest.config.cjs" "tsconfig*.json" "run-*.cjs"

.\run-node-tool.cjs:67
      throw error;
      ^

Error: Cannot find module 'prettier/bin/prettier.cjs'
Require stack:
- .\run-node-tool.cjs
    at Module._resolveFilename (node:internal/modules/cjs/loader:1456:15)
    at require.resolve (node:internal/modules/helpers:163:19)
    at resolveTool (.\run-node-tool.cjs:62:20)
    at runNodeTool (.\run-node-tool.cjs:109:6)
    at Object.<anonymous> (.\run-node-tool.cjs:132:16)
    at Module._compile (node:internal/modules/cjs/loader:1812:14)
    at Object..js (node:internal/modules/cjs/loader:1943:10)
    at Module.load (node:internal/modules/cjs/loader:1533:32)
    at Module._load (node:internal/modules/cjs/loader:1335:12)
    at wrapModuleLoad (node:internal/modules/cjs/loader:255:19) {
  code: 'MODULE_NOT_FOUND',
  requireStack: [
    'EXTERNAL_PATH'
  ]
}

Node.js v24.14.0
```
