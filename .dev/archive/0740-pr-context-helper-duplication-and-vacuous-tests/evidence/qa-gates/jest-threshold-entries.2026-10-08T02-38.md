# Jest Threshold Entries (P2-T13, AC-13)

Timestamp: 2026-10-08T02-38
Command: git grep -n -E "\./src/lib/pr-context/(models|collector-core|render|gh-client-details|render-pr-helpers|verification-evidence|render-feature-excerpts|feature-docs-parsers)\.ts\"" -- extensions/drm-copilot/jest.config.cjs
EXIT_CODE: 0
Output Summary: PASS (loop pass 3). Exactly 8 output lines, one per PROD-FILE.

```
extensions/drm-copilot/jest.config.cjs:33:    "./src/lib/pr-context/collector-core.ts": {
extensions/drm-copilot/jest.config.cjs:51:    "./src/lib/pr-context/models.ts": {
extensions/drm-copilot/jest.config.cjs:55:    "./src/lib/pr-context/feature-docs-parsers.ts": {
extensions/drm-copilot/jest.config.cjs:59:    "./src/lib/pr-context/render-feature-excerpts.ts": {
extensions/drm-copilot/jest.config.cjs:63:    "./src/lib/pr-context/render-pr-helpers.ts": {
extensions/drm-copilot/jest.config.cjs:70:    "./src/lib/pr-context/render.ts": {
extensions/drm-copilot/jest.config.cjs:74:    "./src/lib/pr-context/gh-client-details.ts": {
extensions/drm-copilot/jest.config.cjs:78:    "./src/lib/pr-context/verification-evidence.ts": {
```
