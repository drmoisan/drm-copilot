# Phase 6 Mirror Hashes — Issue #670

Timestamp: 2026-09-17T08-47
Tasks: [P6-T4], [P6-T6], [P6-T7] (accumulating artifact)
Command: foreach pair: (Get-FileHash -LiteralPath 'REPO_PATH' -Algorithm SHA256).Hash ; (Get-FileHash -LiteralPath 'BUNDLE_PATH' -Algorithm SHA256).Hash
EXIT_CODE: 0

Each bundled file was produced by a byte copy (`cp REPO_PATH BUNDLE_PATH`), which preserves line endings, so both the text-mode parity assertion and a byte comparison hold.

## [P6-T4] Claude hooks

| Repository path | Bundle path | Repository SHA256 | Bundle SHA256 | Result |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | 77C30E88590188AE426ABD8A71825BBEB9EDED4E07E9E95AA1093F71CDE4E24D | 77C30E88590188AE426ABD8A71825BBEB9EDED4E07E9E95AA1093F71CDE4E24D | match |
| `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | 55337C886E3E4199D9EB7E0110BFCFDB4441D51273DE9AFE0641CA993DA88FC0 | 55337C886E3E4199D9EB7E0110BFCFDB4441D51273DE9AFE0641CA993DA88FC0 | match |

## [P6-T6] Rules and skill files

| Repository path | Bundle path | Repository SHA256 | Bundle SHA256 | Result |
| --- | --- | --- | --- | --- |
| `.claude/rules/orchestrator-state.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` | 0085540BBEC5BE02ACA785547B9F4C361ED3AE83C7EE9FD2AECE7F73A374C892 | 0085540BBEC5BE02ACA785547B9F4C361ED3AE83C7EE9FD2AECE7F73A374C892 | match |
| `.claude/skills/parallel-orchestrate/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` | 6A9743D8A85A234FDE4E4A42633A028F3E5E55D5044B2A5B412387B629199AB1 | 6A9743D8A85A234FDE4E4A42633A028F3E5E55D5044B2A5B412387B629199AB1 | match |

## [P6-T7] Codex hook

| Repository path | Bundle path | Repository SHA256 | Bundle SHA256 | Result |
| --- | --- | --- | --- | --- |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | 7AB10E92305EE55BB6899F04CAF94C5E08C654866F17667A494C763BAD6427A5 | 7AB10E92305EE55BB6899F04CAF94C5E08C654866F17667A494C763BAD6427A5 | match |

Output Summary:
- [P6-T4]: 2 of 2 pairs match.
- [P6-T6]: 2 of 2 pairs match.
- [P6-T7]: 1 of 1 pair matches.
- The four mirrored `.claude/**` files (two hooks, the rules file, the skill file) all have matching SHA256 pairs; this is the durable substitute cited by [P6-T8] for the issue #510 condition.
