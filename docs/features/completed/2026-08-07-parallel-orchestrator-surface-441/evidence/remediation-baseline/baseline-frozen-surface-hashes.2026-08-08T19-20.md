# Remediation Baseline — Frozen-Surface Immutability Pins

Timestamp: 2026-08-08T19-20

Command: `pwsh -NoProfile -Command "Get-FileHash -Algorithm SHA256 '.claude/agents/epic-orchestrator.md','.claude/skills/epic-orchestrate/SKILL.md','.claude/skills/orchestrate/SKILL.md'"`

Working directory: repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69`)

HEAD: `41633ad5e867070853e3e4501c3457b6641d1efc`

EXIT_CODE: 0

Output Summary — three path-to-hash pairs, each compared against its expected pin:

| Path | Measured SHA-256 | Expected SHA-256 | Match |
| --- | --- | --- | --- |
| `.claude/agents/epic-orchestrator.md` | `f4e3589ab53e6a61791f2d31e7506e7e6003ec63fe651f3cec323023d923f250` | `f4e3589ab53e6a61791f2d31e7506e7e6003ec63fe651f3cec323023d923f250` | yes |
| `.claude/skills/epic-orchestrate/SKILL.md` | `3c2e38bd5bdc5e2b7312437d47dc27aa282f2ff24fbaf01590b51e853e788d68` | `3c2e38bd5bdc5e2b7312437d47dc27aa282f2ff24fbaf01590b51e853e788d68` | yes |
| `.claude/skills/orchestrate/SKILL.md` | `b4e4c26fc5597af9499e43497ea013cf4780faaac14009e2bcf44946cde3402c` | `b4e4c26fc5597af9499e43497ea013cf4780faaac14009e2bcf44946cde3402c` | yes |

All three digests equal their expected values, so the cycle proceeds to Phase 1. No mismatch was
found, so the halt condition of `[P0-T8]` was not triggered. The first two digests are additionally
pinned in-process by `PINNED_FROZEN_SURFACE_HASHES` in
`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:81-90`.
