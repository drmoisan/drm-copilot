# Remediation Helpers Surface Parity (issue #671, R1)

Timestamp: 2026-09-17T09-53
Task: [P2-T9] (also the recorded acceptance for [P2-T5], [P2-T6], and [P2-T8])
Command: `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/hashes7.ps1` (`(Get-FileHash -LiteralPath <p>).Hash` and `@(Get-Content -LiteralPath <p>).Count` per path), run after the three mirror scripts:
- [P2-T5] `copy-codex.ps1` at 2026-09-17T09-52-34: `Copy-Item -LiteralPath .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 -Destination .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 -Force`
- [P2-T6] `copy-claude-bundle.ps1` at 2026-09-17T09-52-36: same source, destination `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
- [P2-T7] scheduled batch-budget reset at 2026-09-17T09-52-43
- [P2-T8] `copy-codex-bundle.ps1` at 2026-09-17T09-52-58: same source, destination `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
EXIT_CODE: 0

| Path | SHA256 | Lines |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | AAD0BAAF088BAA3227E42D6E0B4171352C4F51BA611DBF7BD145024C6F958989 | 441 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | AAD0BAAF088BAA3227E42D6E0B4171352C4F51BA611DBF7BD145024C6F958989 | 441 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | AAD0BAAF088BAA3227E42D6E0B4171352C4F51BA611DBF7BD145024C6F958989 | 441 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | AAD0BAAF088BAA3227E42D6E0B4171352C4F51BA611DBF7BD145024C6F958989 | 441 |

Output Summary: the four hashes collapse to exactly one distinct value (`AAD0BAAF…8989`); that value differs from the [P0-T4] helpers hash (`5C906A2A…13B1`); each copy counts 441 lines (cap 500). [P2-T5], [P2-T6], and [P2-T8] each produced a destination whose hash equals the canonical hash. None of the three mirrors was written with the Write or Edit tool.
