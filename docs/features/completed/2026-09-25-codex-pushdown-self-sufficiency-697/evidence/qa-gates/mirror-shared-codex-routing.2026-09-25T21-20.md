# Mirror: Shared codex-routing Modules (Issue #697, AC-4.4)

Timestamp: 2026-09-25T21-20
Command: New-Item -ItemType Directory -Force -Path extensions/drm-copilot/resources/lib/codex-routing; Copy-Item -LiteralPath .claude/lib/codex-routing/<Module>.psm1 -Destination extensions/drm-copilot/resources/lib/codex-routing/<Module>.psm1 -Force (CodexTopology, CodexDeployment); Get-FileHash -Algorithm SHA256
EXIT_CODE: 0
Output Summary: each mirror hash equals its source hash.

| Path | SHA-256 |
| --- | --- |
| `.claude/lib/codex-routing/CodexTopology.psm1` | `F7458EE4C3F46DB9DFC2A4B38F333F1E61A6C5738C11B74D36AD587FBDC2AFFD` |
| `extensions/drm-copilot/resources/lib/codex-routing/CodexTopology.psm1` | `F7458EE4C3F46DB9DFC2A4B38F333F1E61A6C5738C11B74D36AD587FBDC2AFFD` |
| `.claude/lib/codex-routing/CodexDeployment.psm1` | `6D9A830D65116C344FF349365ECE29DE217CF5C46E2324D6A33A09FE7EF96BF5` |
| `extensions/drm-copilot/resources/lib/codex-routing/CodexDeployment.psm1` | `6D9A830D65116C344FF349365ECE29DE217CF5C46E2324D6A33A09FE7EF96BF5` |
