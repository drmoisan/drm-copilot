# Baseline: npm ci (P0-T10)

Timestamp: 2026-10-09T21-11
Command: Glob extensions/drm-copilot/node_modules/jest/package.json (no file); cd extensions/drm-copilot && npm ci --no-audit --no-fund; git status --porcelain -- extensions/drm-copilot/package.json extensions/drm-copilot/package-lock.json
EXIT_CODE: 0
Output Summary:
- Pre-install Glob: no file (node_modules absent).
- npm ci: exit 0; "added 452 packages in 5s" (deprecation warnings only, e.g. glob@10.5.0).
- Post-install: extensions/drm-copilot/node_modules/jest/package.json exists.
- git status on package.json and package-lock.json: empty output (manifest and lockfile unchanged).
