# QC — PoshQC Format

Timestamp: 2026-08-19T08-58

Command: `mcp__drm-copilot__run_poshqc_format` (workspace_root=repo root) over scan folders `.claude/hooks`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks`, and `tests/scripts/claude-hooks`, covering:
- `.claude/hooks/enforce-epic-merge-gate.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`

EXIT_CODE: 0

Output Summary: PoshQC format completed successfully (`ok: true`). Idempotency verified: file md5 hashes were unchanged across two consecutive format runs (`md5sum -c` reported OK for all three files), confirming no pending formatting changes. The two hook copies remain byte-identical after formatting.
