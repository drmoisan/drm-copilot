# Final Line Count — mcp-tool-inputs.ts and extracted sibling (Issue #401, AC-14)

Timestamp: 2026-07-22T20-17

Command: wc -l src/mcp-tool-inputs.ts src/mcp-tool-inputs-potential-to-issue.ts (from extensions/drm-copilot/)
EXIT_CODE: 0

Output Summary:
- Before P3-T9 change, mcp-tool-inputs.ts was 505 lines (over the 500-line production-file limit after the potential_path normalization was added).
- resolvePotentialToIssueToolInput was extracted into a new sibling module src/mcp-tool-inputs-potential-to-issue.ts (following the mcp-tool-inputs-push-down.ts precedent) and re-exported from mcp-tool-inputs.ts.
- Post-extraction line counts:
  - src/mcp-tool-inputs.ts: 477 lines (<= 500).
  - src/mcp-tool-inputs-potential-to-issue.ts: 60 lines (<= 500).
- `npm run typecheck` (tsc -p ./ --noEmit) exits 0 after the extraction, confirming the re-export and circular type import compile cleanly.
- AC-14 satisfied: no production file exceeds 500 lines.
