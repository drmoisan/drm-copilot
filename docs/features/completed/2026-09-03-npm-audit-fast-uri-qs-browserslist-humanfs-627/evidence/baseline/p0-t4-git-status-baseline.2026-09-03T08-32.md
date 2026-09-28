# P0-T4 — Git Baseline Capture

- Timestamp: 2026-09-03T08-32
- Command: `git rev-parse HEAD`
- EXIT_CODE: 0
- Command: `git status --porcelain -- package.json package-lock.json extensions/drm-copilot/package.json extensions/drm-copilot/package-lock.json packages/mcp-server/package.json packages/mcp-server/package-lock.json`
- EXIT_CODE: 0
- Output Summary: HEAD SHA is `cb51d46ea2f1bb04cb14b3536b438c39dcd81481`. `git status --porcelain` output for the six in-scope manifest files (root `package.json`/`package-lock.json`, `extensions/drm-copilot/package.json`/`package-lock.json`, `packages/mcp-server/package.json`/`package-lock.json`) was empty, confirming all six files are clean/unmodified prior to Phase 1.
