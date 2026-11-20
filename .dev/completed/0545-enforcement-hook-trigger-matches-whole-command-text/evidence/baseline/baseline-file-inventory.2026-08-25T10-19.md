# Phase 0 — Pre-change production file inventory (issue #545)

Timestamp: 2026-08-25T10-19

Task: [P0-T4]

Command: `wc -l` over each of the sixteen in-scope production PowerShell copies, with an
existence test per path (`[ -f "$f" ]`) so the four not-yet-existing scanner locations are
recorded as absent rather than as zero.

EXIT_CODE: 0

## Inventory

| # | Path | Line count |
| --- | --- | --- |
| 1 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 381 |
| 2 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 382 |
| 3 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 381 |
| 4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 382 |
| 5 | `.claude/hooks/enforce-promotion-mcp-only.ps1` | 274 |
| 6 | `.codex/hooks/enforce-promotion-mcp-only.ps1` | 261 |
| 7 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1` | 274 |
| 8 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1` | 261 |
| 9 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 228 |
| 10 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 228 |
| 11 | `.claude/hooks/enforce-pr-author-skill.ps1` | 311 |
| 12 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` | 311 |
| 13 | `.claude/hooks/hook-command-scanner.ps1` | ABSENT — created by [P4-T1] |
| 14 | `.codex/hooks/hook-command-scanner.ps1` | ABSENT — created by [P4-T2] |
| 15 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1` | ABSENT — created by [P5-T1] |
| 16 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1` | ABSENT — created by [P5-T2] |

## Output Summary

Twelve of the sixteen paths exist at baseline and carry a numeric line count; the four
`hook-command-scanner.ps1` locations are absent, as this plan expects. Each existing copy is
under the 500-line cap, and the per-pair line counts agree exactly (381/381 for the Claude
preimplementation-gate pair, 382/382 for the Codex pair, 274/274 and 261/261 for the two
promotion pairs, 228/228 and 311/311 for the two pr-author pairs). The Claude and Codex
preimplementation-gate pairs differ by one line (381 versus 382), which is consistent with D9's
statement that the two pairs are deliberately divergent and that equal line counts across pairs
would be incidental. The Claude and Codex promotion copies differ by thirteen lines (274 versus
261), which is likewise a cross-pair difference and is not a parity defect.
