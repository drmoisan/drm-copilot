# Phase 0 — SHA-256 Baseline of the Eight Hook Files in Scope (issue #554)

Timestamp: 2026-08-26T10-18

Command:

```powershell
$paths = @(
 '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1',
 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1',
 '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1',
 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1',
 '.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1',
 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1',
 '.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1',
 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1'
)
foreach ($p in $paths) { $h = (Get-FileHash -Algorithm SHA256 -LiteralPath $p).Hash; '{0}  {1}' -f $h.ToLower(), $p }
```

EXIT_CODE: 0

Output Summary:

Eight path-and-hash rows, in the order emitted:

| # | Path | SHA-256 |
| --- | --- | --- |
| 1 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `bf3fe18d0de06f871e80a3962fc69bf1551e4015f4351e98979f087ebe911ca9` |
| 2 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `bf3fe18d0de06f871e80a3962fc69bf1551e4015f4351e98979f087ebe911ca9` |
| 3 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `db69f084eea38ef30f273b95c07a994a17e1f4b6b4963eb39388f4021533f350` |
| 4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `db69f084eea38ef30f273b95c07a994a17e1f4b6b4963eb39388f4021533f350` |
| 5 | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `45c339fd4b4b1702230518b6fcdeb863a08bcb7a7540f46c5f7851c730765c0b` |
| 6 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `45c339fd4b4b1702230518b6fcdeb863a08bcb7a7540f46c5f7851c730765c0b` |
| 7 | `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `45c339fd4b4b1702230518b6fcdeb863a08bcb7a7540f46c5f7851c730765c0b` |
| 8 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `45c339fd4b4b1702230518b6fcdeb863a08bcb7a7540f46c5f7851c730765c0b` |

## Per-Surface Self-Hosted / Bundled-Mirror Agreement

| Surface | File | Self-hosted vs bundled mirror |
| --- | --- | --- |
| Claude | main gate hook (rows 1, 2) | **AGREE** |
| Codex | main gate hook (rows 3, 4) | **AGREE** |
| Claude | `-helpers.ps1` (rows 5, 6) | **AGREE** |
| Codex | `-helpers.ps1` (rows 7, 8) | **AGREE** |

All four mirror pairs are byte-identical at the branch point.

Additionally, all four `-helpers.ps1` copies share the single hash
`45c339fd4b4b1702230518b6fcdeb863a08bcb7a7540f46c5f7851c730765c0b` across both surfaces. That single
value is the byte-identity baseline the Phase 5 verification (P5-T1) compares against to prove the
issue #539 orchestration-bookkeeping staging exemption is behaviourally unchanged. None of the four
`-helpers.ps1` copies is written by this feature.

These measured values agree exactly with the context values recorded in the plan's "Known Operational
Conditions" section.
