# Mirror: enforce-epic-planning-only.ps1 (Issue #697, rule 6)

Timestamp: 2026-09-25T21-08
Command: Copy-Item -LiteralPath .codex/hooks/enforce-epic-planning-only.ps1 -Destination extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1 -Force; Get-FileHash -Algorithm SHA256 (both paths)
EXIT_CODE: 0
Output Summary: hashes equal.

| Path | SHA-256 |
| --- | --- |
| `.codex/hooks/enforce-epic-planning-only.ps1` | `B9FD4B9AF987DDC64F928F41A70F053647CA67F873FD8E7426E4DB305F430883` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1` | `B9FD4B9AF987DDC64F928F41A70F053647CA67F873FD8E7426E4DB305F430883` |
