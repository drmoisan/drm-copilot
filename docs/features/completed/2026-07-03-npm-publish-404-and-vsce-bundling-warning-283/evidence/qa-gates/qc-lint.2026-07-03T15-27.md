# QC — Post-Change Lint

Timestamp: 2026-07-03T15-27
Command: `npm --prefix extensions/drm-copilot run lint`
EXIT_CODE: 0

Output Summary: `eslint --no-error-on-unmatched-pattern src test` produced no output (0 errors, 0 warnings). Note: `esbuild-extension.cjs` and `esbuild-mcp-server.cjs` are `.cjs` scripts at the package root, not under `src`/`test`, so they are outside this lint glob's scope (consistent with baseline behavior for the pre-existing `esbuild-mcp-server.cjs`).
