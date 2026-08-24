# Push-Down Byte-Parity Relations — Issue #516

Timestamp: 2026-08-24T17-31

Command: `pwsh -NoProfile -Command "Get-FileHash -Algorithm SHA256 -Path '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1','.codex/hooks/enforce-orchestration-preimplementation-gate.ps1','extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1','extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1' | Format-List Path,Hash"`

EXIT_CODE: 0

Output Summary:

| Copy | Path | SHA-256 |
| --- | --- | --- |
| 1 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `4BDFE6FF84DDD363D59C3AA4C96F33DB3BB96E4B2113E29BA1110080DA2F2A43` |
| 2 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `7A16D7EABFC274DA0C176846541C778739C1494B6A086544D3989C46C82743D7` |
| 3 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `4BDFE6FF84DDD363D59C3AA4C96F33DB3BB96E4B2113E29BA1110080DA2F2A43` |
| 4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `7A16D7EABFC274DA0C176846541C778739C1494B6A086544D3989C46C82743D7` |

Both required relations hold:

- hash(copy 1) == hash(copy 3) — `4BDFE6FF...2A43`.
- hash(copy 2) == hash(copy 4) — `7A16D7EA...43D7`.

The two pairs differ from each other, as expected: the Claude and Codex variants are distinct files (420 and 425 lines respectively), and only the Codex variant carries the `Test-ImplementationCommand` hunk-path normalization.
