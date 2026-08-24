# Codex Hook Pair Byte-Identity — issue #535

Timestamp: 2026-08-23T21-58

Command:
`pwsh -NoProfile -Command "$a = Get-FileHash -Algorithm SHA256 -LiteralPath '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'; $b = Get-FileHash -Algorithm SHA256 -LiteralPath 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'; ..."`

EXIT_CODE: 0

Output Summary:

- canonical `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
  SHA256 = `E8A2DFC7F7F47219B19F957EBF473489C02B4F0C3CFDB745889B4E08AD1D4F37`
- bundle `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
  SHA256 = `E8A2DFC7F7F47219B19F957EBF473489C02B4F0C3CFDB745889B4E08AD1D4F37`
- Hashes are equal: byte-identity holds, which the hash-binding contract test in
  `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` asserts.
- Line count: 336 lines in both copies. Under the 500-line limit.
- Method note: the bundle copy was byte-identical to the pre-edit canonical
  (both SHA256 `2ec3bc90c078f39e2b747296bf0a6ed485ecd1bfa12d5591e11ab36d1bbe881d`),
  so the same three edit hunks were applied to it rather than performing a file copy.
  The equal post-edit hashes above confirm the result. Both copies land in the same
  commit (P3-T7).
