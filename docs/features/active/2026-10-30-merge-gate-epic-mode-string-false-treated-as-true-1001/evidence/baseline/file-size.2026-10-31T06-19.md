# Baseline File Size (issue #1001)

Timestamp: 2026-10-31T06-19
Command: sh SCRATCH/issue-1001-run.sh SCRATCH/issue-1001-static.ps1 (per file: @(Get-Content -LiteralPath <path>).Count); Grep of config/file-size-baseline.json for the three hook file names
EXIT_CODE: 0

| File | Logical lines |
|---|---|
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 476 |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 144 |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 349 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | 476 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 144 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt.ps1` | 349 |

Baseline-entry search: `config/file-size-baseline.json` searched for `enforce-epic-merge-gate.ps1`, `enforce-pr-author-skill.epic-base-branch`, and `enforce-model-routing-receipt.ps1`.
SearchResult: none

Output Summary: six counts recorded (476, 144, 349, and identical mirrors); all below the 500-line guidance tier; no baseline entry names any of the six files.
