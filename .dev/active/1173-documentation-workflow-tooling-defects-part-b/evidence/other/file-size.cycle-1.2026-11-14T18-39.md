# File Sizes: Remediation Cycle 1 (P1-T4)

Timestamp: 2026-11-14T18-39
Command: wc -l <file> for each changed or new file; git -C <worktree> show HEAD:<file> | wc -l for the pre-change sizes
EXIT_CODE: 0
Output Summary:

| File | Before (HEAD) | After | Result |
|---|---|---|---|
| extensions/drm-copilot/src/mcp-tool-inputs-docs.ts | 508 | 407 | smaller than before (PASS) |
| extensions/drm-copilot/src/mcp-tool-inputs-docs-grammar.ts | new | 139 | below 500 (PASS) |
| extensions/drm-copilot/src/mcp-tool-inputs-docs-ledger-batch.ts | 206 | 206 | below 500 (PASS) |
| extensions/drm-copilot/test/mcp-tool-inputs-docs.import-graph.test.ts | new | 201 | below 500 (PASS) |
| extensions/drm-copilot/test/mcp-tool-inputs-docs-grammar.test.ts | new | 115 | below 500 (PASS) |
| extensions/drm-copilot/jest.docs-coverage.json | 8 | 9 | configuration; recorded for completeness |

- All files are below the 500-line guidance tier; no file is near the 800-line hard limit.
