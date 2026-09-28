# Final Line Counts (Issue #697, AC-6.5)

Timestamp: 2026-09-26T00-12
Command: (Get-Content -LiteralPath <path>).Count for every production, test, and fixture file of section 3 (including bundle mirrors)
EXIT_CODE: 0
Output Summary: 40 files counted; every count is at or below 500 (maximum 428). The `.md` skill files and the JSON fixtures are included for completeness.

| Path | Lines | Result |
| --- | --- | --- |
| `.codex/hooks/enforce-epic-planning-only.ps1` | 365 | ok |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1` | 365 | ok |
| `.claude/lib/codex-routing/CodexDeployment.psm1` | 315 | ok |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/codex-routing/CodexDeployment.psm1` | 315 | ok |
| `extensions/drm-copilot/resources/lib/codex-routing/CodexTopology.psm1` | 394 | ok |
| `extensions/drm-copilot/resources/lib/codex-routing/CodexDeployment.psm1` | 315 | ok |
| `.codex/scripts/codex-routing-cli-common.ps1` | 370 | ok |
| `.codex/scripts/Resolve-CodexTopology.ps1` | 96 | ok |
| `.codex/scripts/Resolve-CodexDeployment.ps1` | 87 | ok |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/codex-routing-cli-common.ps1` | 370 | ok |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/Resolve-CodexTopology.ps1` | 96 | ok |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/Resolve-CodexDeployment.ps1` | 87 | ok |
| `scripts/dev_tools/push_down_codex_and_agents_customizations.py` | 428 | ok |
| `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts` | 355 | ok |
| `extensions/drm-copilot/jest.config.cjs` | 297 | ok |
| `packages/mcp-server/prepack.cjs` | 61 | ok |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | 314 | ok |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | 314 | ok |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml` | 99 | ok |
| `.agents/skills/codex-model-routing/SKILL.md` | 109 | ok |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/codex-model-routing/SKILL.md` | 109 | ok |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | 120 | ok |
| `tests/scripts/dev_tools/test_codex_agent_role_schema.py` | 275 | ok |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_virtual_paths.py` | 186 | ok |
| `tests/scripts/dev_tools/test_codex_routing_cli_corpus.py` | 155 | ok |
| `tests/scripts/dev_tools/test_codex_model_routing_skill.py` | 74 | ok |
| `tests/scripts/dev_tools/test_codex_core_manifest_closure.py` | 301 | ok |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` | 262 | ok |
| `tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1` | 261 | ok |
| `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` | 202 | ok |
| `tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1` | 286 | ok |
| `tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1` | 161 | ok |
| `tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1` | 216 | ok |
| `extensions/drm-copilot/test/lib/push-down/codex-agents-customizations.test.ts` | 413 | ok |
| `extensions/drm-copilot/test/lib/push-down/real-bundle-filesystem.test-helpers.ts` | 193 | ok |
| `extensions/drm-copilot/test/lib/push-down/codex-bundle-publish.integration.test.ts` | 123 | ok |
| `extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts` | 88 | ok |
| `tests/fixtures/codex_routing/topology.json` | 197 | ok |
| `tests/fixtures/codex_routing/deployment.json` | 140 | ok |
| `tests/fixtures/codex-hooks/invalid-orchestration-handoff-registry.json` | 1 | ok |
