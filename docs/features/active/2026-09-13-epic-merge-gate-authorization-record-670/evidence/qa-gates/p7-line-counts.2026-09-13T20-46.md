# Phase 7 Line Counts — Issue #670

Timestamp: 2026-09-17T08-56
Task: [P7-T3]
Command: foreach PATH in the sixteen paths below: @(Get-Content -LiteralPath 'PATH').Count
EXIT_CODE: 0

No automated test enforces the 500-line cap on `.claude/hooks/**`, so this enumerated count is the verification.

| # | Path | Lines | Verdict |
| --- | --- | --- | --- |
| 1 | `.claude/hooks/enforce-epic-merge-gate.ps1` | 483 | at most 500 |
| 2 | `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | 442 | at most 500 |
| 3 | `.codex/hooks/enforce-epic-merge-gate.ps1` | 378 | at most 500 |
| 4 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | 483 | at most 500 |
| 5 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | 442 | at most 500 |
| 6 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | 378 | at most 500 |
| 7 | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | 177 | at most 500 |
| 8 | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | 295 | at most 500 |
| 9 | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | 295 | at most 500 |
| 10 | `.claude/rules/orchestrator-state.md` | 159 | Markdown, exempt (Markdown-documentation exception, `.claude/rules/general-code-change.md`) |
| 11 | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` | 159 | Markdown, exempt |
| 12 | `.claude/skills/parallel-orchestrate/SKILL.md` | 1120 | Markdown, exempt (1089 in the base revision) |
| 13 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` | 1120 | Markdown, exempt (1089 in the base revision) |
| 14 | `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` | 168 | at most 500 |
| 15 | `tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1` | 203 | at most 500 |
| 16 | `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1` | 194 | at most 500 (138 before the [P7-T2] coverage remediation added 56 lines) |

## Addendum — recount after the Phase 8 pass-1 lint fixes (2026-09-17T08-56)

Only rows 2, 3, 5 and 6 changed (one added `[OutputType(...)]` line each): `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` 443, `.codex/hooks/enforce-epic-merge-gate.ps1` 379, and their bundled mirrors 443 and 379. The other twelve rows are unchanged. All `.ps1`, `.psd1` and `.json` rows remain at most 500.

Output Summary:
- Sixteen rows. Every `.ps1`, `.psd1` and `.json` row is at most 500 (largest: 483).
- The four Markdown rows (159, 159, 1120, 1120) are exempt under the Markdown-documentation exception.
