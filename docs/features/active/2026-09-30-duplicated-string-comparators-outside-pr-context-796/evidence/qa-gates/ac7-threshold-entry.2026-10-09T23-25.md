# QA gate: AC-7 coverage threshold entry (P4-T13, pass 2)

Timestamp: 2026-10-09T23-25
Command: git grep --untracked -n -A 3 -F '"./src/lib/string-ordering.ts": {' -- extensions/drm-copilot/jest.config.cjs
EXIT_CODE: 0
Output Summary:
- extensions/drm-copilot/jest.config.cjs:90:    "./src/lib/string-ordering.ts": {
- extensions/drm-copilot/jest.config.cjs-91-      lines: 85,
- extensions/drm-copilot/jest.config.cjs-92-      branches: 75,
- extensions/drm-copilot/jest.config.cjs-93-    },
- The key line appears exactly once, followed by `lines: 85,` and `branches: 75,`.
- Result: PASS.
