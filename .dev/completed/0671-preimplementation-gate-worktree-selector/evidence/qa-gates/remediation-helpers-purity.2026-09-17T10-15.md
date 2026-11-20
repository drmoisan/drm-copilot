# Remediation Helpers Purity (issue #671, R1)

Timestamp: 2026-09-17T10-00
Task: [P5-T5]
Command: `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/purity4.ps1` — `@(Select-String -LiteralPath <copy> -SimpleMatch -Pattern <literal>).Count` for nine literals over each of the four helpers copies (36 counts).
EXIT_CODE: 0

| Literal | `.claude/hooks` | `.codex/hooks` | Claude bundle | Codex bundle |
| --- | --- | --- | --- | --- |
| `git worktree` | 0 | 0 | 0 | 0 |
| `Test-Path` | 0 | 0 | 0 | 0 |
| `Start-Process` | 0 | 0 | 0 | 0 |
| `Resolve-Path` | 0 | 0 | 0 | 0 |
| `Invoke-Expression` | 0 | 0 | 0 | 0 |
| `env:` | 0 | 0 | 0 | 0 |
| `Import-Module` | 0 | 0 | 0 | 0 |
| `Pure string logic only: no disk, process, network, or environment access` | 1 | 1 | 1 | 1 |
| `Accepted widening` | 1 | 1 | 1 | 1 |

Copy paths: `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`; `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`; `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`. All four hash to `AAD0BAAF088BAA3227E42D6E0B4171352C4F51BA611DBF7BD145024C6F958989` at capture.

Output Summary: each of the seven prohibited literals counts 0 in every copy; the purity sentence counts 1 in every copy; `Accepted widening` counts 1 in every copy. The fail-closed guard introduced none of the prohibited literals. PASS.
