Timestamp: 2026-04-11T23:54:10-04:00
Command: refreshed-from-P0-T3-with-P1-T1-structural-line-exclusions
EXIT_CODE: 0
Output Summary:
- Preserved all executable changed lines from the original `P0-T3` proof inventory.
- Excluded only the line ranges classified as `non-instrumented structural line` in `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/other/ts-coverage-proof-basis.2026-04-11T23-23.md`.
- No executable changed-line range was removed from scope.

Excluded Structural Ranges:
- `extensions/drm-copilot/src/mcp-tool-inputs.ts` lines `240-245`
  - Rationale: declaration and wrapped entry-call lines remain zero-hit while adjacent executable body lines `246-267` are covered in the file-specific `lcov.info` section
  - Basis: `ts-coverage-proof-basis.2026-04-11T23-23.md`, item 1
- `extensions/drm-copilot/src/mcp-tools.ts` lines `525-531`
  - Rationale: absent from the file-specific `lcov.info` line map for `src\mcp-tools.ts`
  - Basis: `ts-coverage-proof-basis.2026-04-11T23-23.md`, item 2
- `extensions/drm-copilot/src/workflow-command-arguments.ts` line `75`
  - Rationale: blank separator line with no executable statement text
  - Basis: `ts-coverage-proof-basis.2026-04-11T23-23.md`, item 3
- `extensions/drm-copilot/src/workflow-command-arguments.ts` lines `164-167`
  - Rationale: wrapped argument lines for an already-covered return expression
  - Basis: `ts-coverage-proof-basis.2026-04-11T23-23.md`, item 4
- `extensions/drm-copilot/src/workflow-command-arguments.ts` lines `254-257`
  - Rationale: helper declaration and separator lines while the covered caller body starts at line `258`
  - Basis: `ts-coverage-proof-basis.2026-04-11T23-23.md`, item 5
- `extensions/drm-copilot/src/workflow-command-arguments.ts` lines `571-598`
  - Rationale: absent from the file-specific `lcov.info` line map for `src\workflow-command-arguments.ts`
  - Basis: `ts-coverage-proof-basis.2026-04-11T23-23.md`, item 6

Changed Line Inventory:
```json
[
  {
    "file": "extensions/drm-copilot/src/extension.ts",
    "changed_line_ranges": ["7", "18", "225-233", "410-416", "437"]
  },
  {
    "file": "extensions/drm-copilot/src/mcp-tool-inputs.ts",
    "changed_line_ranges": ["2", "8", "11", "41-45", "246-268"]
  },
  {
    "file": "extensions/drm-copilot/src/mcp-tools.ts",
    "changed_line_ranges": ["14", "16", "40-42", "303-326", "404-410"]
  },
  {
    "file": "extensions/drm-copilot/src/repo-automation-service.ts",
    "changed_line_ranges": ["7-17", "36", "48-50", "112-117", "323", "330", "337", "344", "351", "354-370", "372-374", "376-386", "403-440", "466"]
  },
  {
    "file": "extensions/drm-copilot/src/workflow-command-arguments.ts",
    "changed_line_ranges": ["1-2", "34-37", "41-42", "71-74", "159-163", "168-169", "258-269"]
  }
]
```
