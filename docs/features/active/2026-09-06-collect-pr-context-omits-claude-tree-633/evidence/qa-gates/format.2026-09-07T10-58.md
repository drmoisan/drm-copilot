Timestamp: 2026-09-07T10-58

Command: cd extensions/drm-copilot && git status --porcelain -- src test (before) ; npm run format ; git status --porcelain -- src test (after)

EXIT_CODE: 0

Before-snapshot (git status --porcelain -- src test):
```
 M extensions/drm-copilot/src/lib/pr-context/collector-core.ts
 M extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts
 M extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts
```

After-snapshot (git status --porcelain -- src test):
```
 M extensions/drm-copilot/src/lib/pr-context/collector-core.ts
 M extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts
 M extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts
```

Output Summary: `prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` reported
every file as `(unchanged)`, including the three files modified by this plan
(`src/lib/pr-context/collector-core.ts`, `test/lib/pr-context/collector-core.test.ts`,
`test/lib/pr-context/collector-output.test.ts`). The before- and after-snapshots are
identical, confirming the format step did not rewrite any tracked file. No loop restart
required.
