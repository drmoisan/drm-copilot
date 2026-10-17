# Phase 1 format (#647)

Timestamp: 2026-10-01T23-18
Command: node extensions/drm-copilot/node_modules/prettier/bin/prettier.cjs --write <12 Phase 1 paths listed in evidence/other/phase-1-files.txt>; echo "EXIT=$?"
EXIT_CODE: 0

Final run output (ANSI color codes removed):
```
extensions/drm-copilot/src/lib/codex-native-converter/index.ts 24ms (unchanged)
extensions/drm-copilot/src/lib/codex-native-converter/models.ts 27ms (unchanged)
extensions/drm-copilot/test/lib/codex-native-converter/models.test.ts 17ms (unchanged)
extensions/drm-copilot/test/lib/codex-native-converter/parser.test.ts 17ms (unchanged)
extensions/drm-copilot/test/codex-native-converter-handlers.test.ts 3ms (unchanged)
extensions/drm-copilot/test/lib/collect-commit-context.test-helpers.ts 8ms (unchanged)
extensions/drm-copilot/test/lib/collect-commit-context.run-git.test.ts 5ms (unchanged)
extensions/drm-copilot/test/lib/collect-commit-context.test.ts 15ms (unchanged)
extensions/drm-copilot/test/lib/json-config.test.ts 12ms (unchanged)
extensions/drm-copilot/test/lib/markdown-label-formatter.test.ts 10ms (unchanged)
extensions/drm-copilot/test/lib/new-potential-bug-entry-service-call.test.ts 9ms (unchanged)
extensions/drm-copilot/test/lib/new-potential-bug-entry.test.ts 14ms (unchanged)
EXIT=0
```

Output Summary: all 12 lines end with `(unchanged)` on the first run; no file rewritten.
