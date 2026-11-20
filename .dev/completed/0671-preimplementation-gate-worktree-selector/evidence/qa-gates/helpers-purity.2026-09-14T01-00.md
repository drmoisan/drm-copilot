# Helpers Module Purity (issue #671)

Timestamp: 2026-09-17T08-20
Task: [P5-T7]
Command: pwsh -NoProfile -NonInteractive -File <scratchpad>/f671/literals.ps1 — for each literal and each of the four helpers copies, `@(Select-String -SimpleMatch -Pattern <literal> -LiteralPath <path>).Count` (worktree root, via a scratchpad `sh` wrapper)
EXIT_CODE: 0

Output Summary:
- The declared-purity sentence occurs exactly once in each of the four copies (line 5).
- `git worktree`, `Test-Path`, `Start-Process`, `Resolve-Path`, `Invoke-Expression`, `env:`, and `Import-Module` each have 0 matches in every copy. `Select-String -SimpleMatch` is case-insensitive, so these counts also exclude case variants.

| Literal | `.claude/hooks/...-helpers.ps1` | `.codex/hooks/...-helpers.ps1` | `extensions/.../claude-customizations/.claude/hooks/...-helpers.ps1` | `extensions/.../codex-and-agents-customizations/.codex/hooks/...-helpers.ps1` |
| --- | --- | --- | --- | --- |
| `Pure string logic only: no disk, process, network, or environment access` | 1 | 1 | 1 | 1 |
| `git worktree` | 0 | 0 | 0 | 0 |
| `Test-Path` | 0 | 0 | 0 | 0 |
| `Start-Process` | 0 | 0 | 0 | 0 |
| `Resolve-Path` | 0 | 0 | 0 | 0 |
| `Invoke-Expression` | 0 | 0 | 0 | 0 |
| `env:` | 0 | 0 | 0 | 0 |
| `Import-Module` | 0 | 0 | 0 | 0 |

(`...-helpers.ps1` = `enforce-orchestration-preimplementation-gate-helpers.ps1`; `extensions/...` = `extensions/drm-copilot/resources`)
