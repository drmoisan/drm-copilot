# Documentation Mirror Hash Baseline (P0-T23)

Timestamp: 2026-09-30T14-31
Command: Get-FileHash -Algorithm SHA256 -LiteralPath .agents/skills/orchestrator-workflow/SKILL.md,extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md,.claude/rules/orchestrator-state.md,extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md,.claude/skills/orchestrate/SKILL.md,extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md,.agents/skills/orchestrate/SKILL.md,extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md | Format-Table -HideTableHeaders Hash,Path
EXIT_CODE: 0
Output Summary: Eight hashes recorded; each repo copy's hash equals its bundle copy's hash (four equal pairs). No pre-existing drift.

Execution route: PowerShell execution route (scratchpad `.sh` file that changes to the worktree root and calls `pwsh -NoProfile -Command '<command text>'`, run with `sh`). `Get-FileHash` emits results in `-LiteralPath` input order; paths are rendered repository-relative below in that order.

| Hash | Path |
|---|---|
| 8E97C1DD08822A0FBF76ADC5BD05CE7E7CBB073EBF55534BF56B5926BC6C0CAE | `.agents/skills/orchestrator-workflow/SKILL.md` |
| 8E97C1DD08822A0FBF76ADC5BD05CE7E7CBB073EBF55534BF56B5926BC6C0CAE | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md` |
| AF54FF974A25C1256264D30C9B39E49B954ED0684154A6DB69BB9BBF95A6445A | `.claude/rules/orchestrator-state.md` |
| AF54FF974A25C1256264D30C9B39E49B954ED0684154A6DB69BB9BBF95A6445A | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` |
| B70D6B83BEDA0AE7AE73BFBB012A73D2BAC2C169B6A927B3A2643D41531838FB | `.claude/skills/orchestrate/SKILL.md` |
| B70D6B83BEDA0AE7AE73BFBB012A73D2BAC2C169B6A927B3A2643D41531838FB | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` |
| 06FE49844F87600EE0971BE4667E22571A131451307D3B215F2DC7BE1F37D4E8 | `.agents/skills/orchestrate/SKILL.md` |
| 06FE49844F87600EE0971BE4667E22571A131451307D3B215F2DC7BE1F37D4E8 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md` |
