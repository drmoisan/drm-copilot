# P15-T21 — Execution-environment brief: shared-fixture bullet reworded

Task: [P15-T21] Reword the shared-fixture bullet of the execution-environment brief in all six copies.
Branch: feature/legacy-discovery-and-parity-980
Issue: #980

## Change

In `## Test Runtime` of `.github/skills/execution-environment/SKILL.md` the fourth
bullet now reads:

> Second, build an expensive immutable fixture once per session and hand each test
> its own copy wherever a test could mutate it, so test independence is unchanged.

The bytes were copied to the five other committed copies. The gitignored build
output under packages/mcp-server/resources/ was not edited. The token
`its own copy` is retained, so `test_brief_test_runtime_section_orders_diagnosis_before_parallelism`
and `test_brief_copies_are_byte_identical` are unchanged.

## SHA-256 of the six copies

Timestamp: 2026-10-30T00:19Z
Command: `sha256sum` over the six paths below (through SCRATCH/issue-980-p15-brief.sh)
EXIT_CODE: 0
Output Summary: all six values are equal.

| Copy | SHA-256 |
| --- | --- |
| .github/skills/execution-environment/SKILL.md | 372462e37d65440ef81cedf44b012ff574ee2b717ba09928d2e09ee4b7436072 |
| .claude/skills/execution-environment/SKILL.md | 372462e37d65440ef81cedf44b012ff574ee2b717ba09928d2e09ee4b7436072 |
| .agents/skills/execution-environment/SKILL.md | 372462e37d65440ef81cedf44b012ff574ee2b717ba09928d2e09ee4b7436072 |
| extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md | 372462e37d65440ef81cedf44b012ff574ee2b717ba09928d2e09ee4b7436072 |
| extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md | 372462e37d65440ef81cedf44b012ff574ee2b717ba09928d2e09ee4b7436072 |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md | 372462e37d65440ef81cedf44b012ff574ee2b717ba09928d2e09ee4b7436072 |

## Suites

Timestamp: 2026-10-30T00:19Z
Command: `poetry run pytest tests/scripts/dev_tools/test_execution_environment_brief_contracts.py tests/scripts/dev_tools/test_discovery_documentation_contracts.py tests/scripts/dev_tools/test_single_pass_preflight_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -p no:cacheprovider -q`
EXIT_CODE: 0
Output Summary: `108 passed in 2.04s`

## Generator check

Timestamp: 2026-10-30T00:19Z
Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`
EXIT_CODE: 0
Output Summary: empty output (no drift).

Result: PASS
