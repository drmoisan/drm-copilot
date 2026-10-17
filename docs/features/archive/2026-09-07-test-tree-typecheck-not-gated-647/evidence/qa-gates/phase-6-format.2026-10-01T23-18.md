# Phase 6 format (#647)

Timestamp: 2026-10-01T23-18
Command: node extensions/drm-copilot/node_modules/prettier/bin/prettier.cjs --write <10 Phase 6 paths listed in evidence/other/phase-6-files.txt>
EXIT_CODE: 0

Run 1 rewrote `test/extension-command-helpers.test.ts`, `test/extension.collect-pr-context.test.ts` (the `writeFileSync` callback collapsed onto one line), and `test/extension.integration.test.ts`. Final run (run 2) output, ANSI codes removed:
```
extensions/drm-copilot/test/extension-command-helpers.test.ts 57ms (unchanged)
extensions/drm-copilot/test/extension.collect-commit-context.integration.test.ts 18ms (unchanged)
extensions/drm-copilot/test/extension.collect-pr-context-gh-resolution.test.ts 12ms (unchanged)
extensions/drm-copilot/test/extension.collect-pr-context.test.ts 20ms (unchanged)
extensions/drm-copilot/test/extension.integration.test.ts 20ms (unchanged)
extensions/drm-copilot/test/extension.new-active-feature-folder-inprocess.test.ts 9ms (unchanged)
extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts 8ms (unchanged)
extensions/drm-copilot/test/extension.potential-to-issue.test.ts 11ms (unchanged)
extensions/drm-copilot/test/extension.resolve-atomic-plan-prompt.test.ts 6ms (unchanged)
extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts 7ms (unchanged)
```

Output Summary: final run prints `(unchanged)` for all 10 files.
