# Mirror: CodexDeployment.psm1 into the Claude Bundle (Issue #697, rule 6)

Timestamp: 2026-09-25T21-18
Command: Copy-Item -LiteralPath .claude/lib/codex-routing/CodexDeployment.psm1 -Destination extensions/drm-copilot/resources/claude-customizations/.claude/lib/codex-routing/CodexDeployment.psm1 -Force; Get-FileHash -Algorithm SHA256 (both paths)
EXIT_CODE: 0
Output Summary: hashes equal.

| Path | SHA-256 |
| --- | --- |
| `.claude/lib/codex-routing/CodexDeployment.psm1` | `6D9A830D65116C344FF349365ECE29DE217CF5C46E2324D6A33A09FE7EF96BF5` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/codex-routing/CodexDeployment.psm1` | `6D9A830D65116C344FF349365ECE29DE217CF5C46E2324D6A33A09FE7EF96BF5` |
