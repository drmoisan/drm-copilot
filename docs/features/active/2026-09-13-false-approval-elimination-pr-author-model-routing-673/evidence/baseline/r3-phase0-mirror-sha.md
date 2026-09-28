# Phase 0 Mirror SHA-256 Baseline (issue #673)

Timestamp: 2026-09-19T17-34

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-mirror-sha.ps1` (route `a`). The script resolves each repository-relative path against `(Get-Location).Path` and computes `Get-FileHash -Algorithm SHA256`, lowercasing the result.

EXIT_CODE: 0

Ten pairs. The mirror root for rows 1 to 9 is `extensions/drm-copilot/resources/claude-customizations/`; row 10's mirror root is `extensions/drm-copilot/resources/powershell/`.

| # | Source (repository-relative) | Source SHA-256 | Mirror SHA-256 | Verdict |
| --- | --- | --- | --- | --- |
| 1 | `.claude/hooks/enforce-pr-author-skill.ps1` | `479a2105575ea2d0d4a86ff654f63105cca30d9a7c9359e251c8c426753dd396` | `479a2105575ea2d0d4a86ff654f63105cca30d9a7c9359e251c8c426753dd396` | equal |
| 2 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | `5c05057a8105c52d37796bc58fbedc1dadc7f25dc3d2ed8b67eab2a9db39a3cc` | `5c05057a8105c52d37796bc58fbedc1dadc7f25dc3d2ed8b67eab2a9db39a3cc` | equal |
| 3 | `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | `d617f4b10f36d1ca58ea44a8863ae377ff784fc53a778ebbbb741d7d47feccfe` | `d617f4b10f36d1ca58ea44a8863ae377ff784fc53a778ebbbb741d7d47feccfe` | equal |
| 4 | `.claude/hooks/enforce-model-routing-receipt.ps1` | `7890f255f7ad6a06130d517c2fd5ee37a3262cedd3bdfeae521ad72de559c0b9` | `7890f255f7ad6a06130d517c2fd5ee37a3262cedd3bdfeae521ad72de559c0b9` | equal |
| 5 | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | `d87b0e0daa34023019630e22ad9c1c80059aef2bf5531b3162221b30b4080b32` | `d87b0e0daa34023019630e22ad9c1c80059aef2bf5531b3162221b30b4080b32` | equal |
| 6 | `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | `6529667b99d64205db53aa43a0d895bae164824c283e158012c6b027d82e123d` | `6529667b99d64205db53aa43a0d895bae164824c283e158012c6b027d82e123d` | equal |
| 7 | `.claude/skills/orchestrate/SKILL.md` | `152216aa5a6caaa31cd2083b9a2a8183dc797ce8cad95d5ab2cb91237d27bedb` | `152216aa5a6caaa31cd2083b9a2a8183dc797ce8cad95d5ab2cb91237d27bedb` | equal |
| 8 | `.claude/skills/parallel-orchestrate/SKILL.md` | `6a9743d8a85a234fde4e4a42633a028f3e5e55d5044b2a5b412387b629199ab1` | `6a9743d8a85a234fde4e4a42633a028f3e5e55d5044b2a5b412387b629199ab1` | equal |
| 9 | `.claude/skills/epic-orchestrate/SKILL.md` | `42cd106c1dc6982cfe4fb15fb3439bdde4eb1bbbc6a1a2db26a8739587ab4ca7` | `42cd106c1dc6982cfe4fb15fb3439bdde4eb1bbbc6a1a2db26a8739587ab4ca7` | equal |
| 10 | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `2ae0159bc145e209976cbcd1d3d8432b96ca08591048f2a8ac8e2dea1fac4cd2` | `2ae0159bc145e209976cbcd1d3d8432b96ca08591048f2a8ac8e2dea1fac4cd2` | equal |

ALL_PAIRS_EQUAL: True

Output Summary: Ten rows, twenty 64-hexadecimal hashes, every pair equal. Every file this plan will change is byte-identical to its bundled mirror at baseline, so any unequal pair recorded by a later mirror task or by `[P11-T7]` names a mirror this change set failed to update rather than a pre-existing divergence. Row 9's source hash, `42cd106c1dc6982cfe4fb15fb3439bdde4eb1bbbc6a1a2db26a8739587ab4ca7`, is additionally the value `[P8-T5]` must replace in the frozen-surface pin after `[P8-T4]` edits that skill; recording it here gives that task a verifiable before-value.
