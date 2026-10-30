# P7-T3 native conversion and first generation record

Timestamp: 2026-10-22T10-18
Command: poetry run python -I SCRATCH/issue-980-p7t3-generate-native.py (then poetry run python -m scripts.dev_tools.generate_codex_agent_variants, then the same conversion script again)
EXIT_CODE: 0
Output Summary: Deterministic conversion of exactly twenty canonical sources: four .github/agents/<role>.agent.md contracts and sixteen .github/skills/<name>/SKILL.md workflows/aliases. First run: 56 files created, 31 changed. Generator write run: 4 base aliases re-pinned plus 20 variants in two surfaces and 24 Codex core.json rows. Repeat conversion run after generation: 0 created, 0 changed, 91 same (idempotent). Generator --check: 0 drift.

## Mapping applied

| Source | Claude target | Codex target | Rewrite |
| --- | --- | --- | --- |
| .github/agents/<role>.agent.md (4) | .claude/agents/<role>.md, replacing the four pre-#980 personas; mirrored to the Claude bundle | .codex/agents/<role>.toml base in the established converted-subagent shape; generator variants follow | Frontmatter tool `drmcopilotextension/<op>` becomes `"mcp__drm-copilot__<op>"`; body verbatim; superseded `model: sonnet` and `Write(discovery/**)` removed; Codex body embeds the Claude persona with `.claude/skills/` rewritten to `.agents/skills/` (no occurrence, so `Applied rewrites: - None`) |
| .github/skills/<workflow>/SKILL.md (9) | .claude/skills/<workflow>/SKILL.md (new); mirrored to the Claude bundle and added to its core.json | .agents/skills/<workflow>/SKILL.md (new); mirrored to the Codex bundle and added to its core.json | Role link `](../../agents/<role>.agent.md)` becomes `](../../../.claude/agents/<role>.md)` or `](../../../.codex/agents/<role>.toml)`; body otherwise verbatim |
| .github/skills/discovery-*/SKILL.md (7 aliases) | .claude/skills/discovery-*/SKILL.md replaced (old duplicated procedure, `allowed-tools`, v1 schema paths, `dev.discovery.*` commands and fan-in flags removed) | .agents/skills/discovery-*/SKILL.md (new) | Same role-link rewrite; aliases carry dispatch only |
| .claude/lib/codex-routing/{CodexTopology,CodexDeployment,CodexDiscoveryRouting}.psm1 | mirrored to extensions/drm-copilot/resources/lib/codex-routing and the Claude bundle .claude/lib/codex-routing; CodexDiscoveryRouting added to the Claude core.json | published through the explicit VIRTUAL_RESOURCE_PAIRS row `.codex/lib/codex-routing/CodexDiscoveryRouting.psm1` -> `lib/codex-routing/CodexDiscoveryRouting.psm1` in the Python and TypeScript publishers; destination added to the Codex core.json | byte copy; no physical `.codex/lib` directory is created |
| .codex/scripts/Resolve-CodexTopology.ps1 | n/a | byte copy to the Codex bundle `.codex/scripts` | selector/skill argument parsing and forwarding (`--invocation-kind`, `--skill-id`) |
| config/orchestration-routing.json | byte copy to extensions/drm-copilot/resources/config and the Claude bundle config | consumed through the shared virtual config | discovery_operations block and four generated families |

## Checks

- Both core pack manifests round-trip through json.dumps(indent=2) so the structural insertion preserved formatting; new skill rows were inserted in ordinal order inside their blocks and the helper rows after the CodexTopology rows.
- Frozen shared baseline comparison (407 bindings): 249 unchanged, 53 changed, 102 created, 0 removed, 3 still absent; 0 pre-existing Codex profiles changed. The only changed binding outside this task's file set is packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py, which was committed by the accepted P6/P7 work after the baseline was taken and is not modified in this working tree.
- The `tests/scripts/dev_tools/test_codex_full_migration_inventory.py` wrapper contract (Canonical migration source, migration contract fragments, `.github/agents/` reference) holds for the four new Codex bases, and `test_codex_agent_role_schema.py` now pins 98 routed role files per set.
- Enforceability: the Claude tool lists are narrowed to drm-copilot MCP identifiers; the Codex bases carry the same list as prose only (degraded, as recorded in p7t3-native-translation-plan.2026-10-21T18-33.md). No settings.json, config.toml, hook or permission entry changed; P8/P9 own native enforcement and P10-T1 regenerates the bundles after it.
- The Copilot customizations bundle under extensions/drm-copilot/resources/customizations was not changed; it is regenerated with all three bundles in P10-T1.
