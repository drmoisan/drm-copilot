# Remediation Baseline — Bundled-Mirror Parity Digests

Timestamp: 2026-08-08T19-20

Command: `pwsh -NoProfile -Command "foreach ($f in @('.claude/agents/parallel-orchestrator.md','.claude/skills/parallel-orchestrate/SKILL.md','.claude/skills/parallel-run/SKILL.md')) { Get-FileHash -Algorithm SHA256 $f; Get-FileHash -Algorithm SHA256 ('extensions/drm-copilot/resources/claude-customizations/' + $f) }"`

Working directory: repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69`)

HEAD: `41633ad5e867070853e3e4501c3457b6641d1efc`

EXIT_CODE: 0

Output Summary — six digests as three matching pairs:

| Pair | Path | SHA-256 |
| --- | --- | --- |
| 1 source | `.claude/agents/parallel-orchestrator.md` | `94f5f08bd318f72aed0971c1aefdb7b68ca5b8c694c229a682d68fc43a3318f4` |
| 1 mirror | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md` | `94f5f08bd318f72aed0971c1aefdb7b68ca5b8c694c229a682d68fc43a3318f4` |
| 2 source | `.claude/skills/parallel-orchestrate/SKILL.md` | `592d0054f078da98aa4e65f357720d6c251e26f7e7b14f4ff39f278964c3d137` |
| 2 mirror | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` | `592d0054f078da98aa4e65f357720d6c251e26f7e7b14f4ff39f278964c3d137` |
| 3 source | `.claude/skills/parallel-run/SKILL.md` | `9fc7fe3ad95df22d16081c0b2dae65956699a6001eddf10a9d66977166f56a90` |
| 3 mirror | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-run/SKILL.md` | `9fc7fe3ad95df22d16081c0b2dae65956699a6001eddf10a9d66977166f56a90` |

All three pairs match at cycle start (`MATCH True` for each). Pairs 1 and 2 are re-synced in Phase 4
after the Phase 2 and Phase 3 edits; pair 3 is not edited by this cycle and is re-verified unchanged.
