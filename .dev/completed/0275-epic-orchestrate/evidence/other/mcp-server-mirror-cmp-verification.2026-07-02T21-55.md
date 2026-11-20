# MCP-Server Mirror `cmp` Verification (P5-T3)

- Timestamp: 2026-07-02T21-55

## Context

`packages/mcp-server/resources/` is gitignored and did not exist in this worktree
(`packages/mcp-server/.gitignore:3` ignores `resources/`; it is normally populated only by
`packages/mcp-server/prepack.cjs`'s `cpSync` at pack time). Per `spec.md`'s Bundled Mirror
Parity section, this mirror has no automated gate and is verified manually per file with
`cmp` as a pre-publish step. The directory tree and the 10 files listed in P5-T1 were
created manually in this worktree to perform that verification now, ahead of any npm
publish that includes this change.

## Per-File `cmp` Result

| File | Result |
|---|---|
| `.claude/agents/epic-orchestrator.md` | IDENTICAL |
| `.claude/skills/epic-orchestrate/SKILL.md` | IDENTICAL |
| `.claude/skills/orchestrate/SKILL.md` | IDENTICAL |
| `.claude/agents/orchestrator.md` | IDENTICAL |
| `.claude/hooks/validate-orchestrator-output.ps1` | IDENTICAL |
| `.claude/hooks/enforce-pr-author-skill.ps1` | IDENTICAL |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | IDENTICAL |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | IDENTICAL |
| `.claude/hooks/enforce-epic-wave-barrier.ps1` | IDENTICAL |
| `.claude/settings.json` | IDENTICAL |

All 10 files report zero differences via `cmp -s` between the repo-root `.claude/` copy
and `packages/mcp-server/resources/claude-customizations/.claude/` copy.

## Note

This mirror must be repeated (or re-verified) before any npm publish that includes this
change, per `spec.md`'s Bundled Mirror Parity section, since it is gitignored and not
covered by the per-commit toolchain loop.
