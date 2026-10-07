# P3-T6 / P3-T7 Jest per-file threshold entry

Timestamp: 2026-09-30T07-38
Command: git grep -n -F -A2 -e "orchestrator-state-promotion-tools.ts" -- extensions/drm-copilot/jest.config.cjs
EXIT_CODE: 0
Output Summary:
Output quoted verbatim (three lines: key line, `lines: 85,`, `branches: 75,`):

```
extensions/drm-copilot/jest.config.cjs:80:    "./src/lib/validate/orchestrator-state-promotion-tools.ts": {
extensions/drm-copilot/jest.config.cjs-81-      lines: 85,
extensions/drm-copilot/jest.config.cjs-82-      branches: 75,
```

- No `exclude` or path-ignore entry was added. Threshold enforcement is performed by the full coverage run in P5-T4.
