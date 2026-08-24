# Codex Pair Byte Parity — Issue #516

Timestamp: 2026-08-24T10-45

Command: `pwsh -NoProfile -Command "Get-FileHash -Algorithm SHA256 -Path '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1','extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'"`

EXIT_CODE: 0

Output Summary:

| Copy | SHA-256 |
| --- | --- |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `7A16D7EABFC274DA0C176846541C778739C1494B6A086544D3989C46C82743D7` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `7A16D7EABFC274DA0C176846541C778739C1494B6A086544D3989C46C82743D7` |

The two hashes are identical; the copy-2/copy-4 byte-parity relation holds. The expected hash is also the value the pre-existing suite `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:115` asserts against the bundle copy.
