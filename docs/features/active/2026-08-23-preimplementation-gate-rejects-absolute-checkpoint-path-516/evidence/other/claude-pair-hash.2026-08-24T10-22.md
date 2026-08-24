# Claude Pair Byte Parity — Issue #516

Timestamp: 2026-08-24T10-22

Command: `pwsh -NoProfile -Command "Get-FileHash -Algorithm SHA256 -Path '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1','extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1'"`

EXIT_CODE: 0

Output Summary:

| Copy | SHA-256 |
| --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `4BDFE6FF84DDD363D59C3AA4C96F33DB3BB96E4B2113E29BA1110080DA2F2A43` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `4BDFE6FF84DDD363D59C3AA4C96F33DB3BB96E4B2113E29BA1110080DA2F2A43` |

The two hashes are identical; the copy-1/copy-3 byte-parity relation holds.
