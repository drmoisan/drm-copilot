# Phase 0 Line Counts (Issue #697, AC-6.5 baseline)

Timestamp: 2026-09-25T20-14
Command: (Get-Content -LiteralPath <path>).Count for each section 3 inventory file (pwsh -NoProfile -File <SCRATCHPAD>/lc.ps1)
EXIT_CODE: 0
Output Summary: 18 existing inventory files counted; 6 inventory files do not exist yet (created by this plan). test_push_down_codex_and_agents_customizations.py = 416; enforce-epic-planning-only.ps1 = 355. No existing file exceeds 500 lines.

| Path | Lines |
| --- | --- |
| `.codex/hooks/enforce-epic-planning-only.ps1` | 355 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1` | 355 |
| `.claude/lib/codex-routing/CodexDeployment.psm1` | 314 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/codex-routing/CodexDeployment.psm1` | 314 |
| `.claude/lib/codex-routing/CodexTopology.psm1` | 394 |
| `extensions/drm-copilot/resources/lib/codex-routing/CodexTopology.psm1` | absent (created by this plan) |
| `extensions/drm-copilot/resources/lib/codex-routing/CodexDeployment.psm1` | absent (created by this plan) |
| `.codex/scripts/codex-routing-cli-common.ps1` | absent (created by this plan) |
| `.codex/scripts/Resolve-CodexTopology.ps1` | absent (created by this plan) |
| `.codex/scripts/Resolve-CodexDeployment.ps1` | absent (created by this plan) |
| `scripts/dev_tools/push_down_codex_and_agents_customizations.py` | 357 |
| `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts` | 296 |
| `extensions/drm-copilot/jest.config.cjs` | 290 |
| `packages/mcp-server/prepack.cjs` | 55 |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | 308 |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | 308 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml` | 98 |
| `.agents/skills/codex-model-routing/SKILL.md` | 110 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/codex-model-routing/SKILL.md` | 110 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | 103 |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` | 275 |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` | 416 |
| `tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1` | 269 |
| `extensions/drm-copilot/test/lib/push-down/codex-agents-customizations.test.ts` | 289 |
