# Baseline — Four-Copy SHA256 Parity (issue #516)

Timestamp: 2026-08-24T15-30
Command: `Get-FileHash -Algorithm SHA256` over the four hook copies, before any edit
EXIT_CODE: 0

## Baseline Hashes

| # | File | SHA256 |
| --- | --- | --- |
| 1 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `F57FAE11FB5E98DC3D06214922A1B1CA4AE200D014873CADF03312042537493C` |
| 2 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `F57FAE11FB5E98DC3D06214922A1B1CA4AE200D014873CADF03312042537493C` |
| 3 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `E8A2DFC7F7F47219B19F957EBF473489C02B4F0C3CFDB745889B4E08AD1D4F37` |
| 4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `E8A2DFC7F7F47219B19F957EBF473489C02B4F0C3CFDB745889B4E08AD1D4F37` |

## Pairwise Equality — acceptance condition

- **Claude family (1 == 2):** `F57FAE11...37493C` equals `F57FAE11...37493C`. **EQUAL.**
- **Codex family (3 == 4):** `E8A2DFC7...1D4F37` equals `E8A2DFC7...1D4F37`. **EQUAL.**
- **Families distinct (1 != 3):** the two family hashes differ, which is expected and required. The families differ in payload plumbing, in `apply_patch` handling, and in malformed-input behavior; the spec states none of those differences is reconciled by this item.

Output Summary: All four hook copies hashed before any edit. The two Claude copies are byte-identical to each other (`F57FAE11FB5E98DC3D06214922A1B1CA4AE200D014873CADF03312042537493C`) and the two Codex copies are byte-identical to each other (`E8A2DFC7F7F47219B19F957EBF473489C02B4F0C3CFDB745889B4E08AD1D4F37`). Both pairwise equalities hold at baseline, so the [P4-T9] post-change comparison measures this item's edits against a known-parity starting point. The two families are correctly distinct from each other.
