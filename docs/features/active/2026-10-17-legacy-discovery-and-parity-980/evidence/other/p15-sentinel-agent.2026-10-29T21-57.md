# P15-T9 — capability sentinel agent on every host surface

Timestamp: 2026-10-29T21-57
Command: poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check; poetry run pytest -q --no-cov tests/scripts/dev_tools -k "agent or codex or claude or push_down"; sh SCRATCH/issue-980-pester.sh tests/scripts/claude-runtime tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1
EXIT_CODE: 0
Output Summary:
- Generator check: exit 0, no drift.
- Python: 2254 passed (the named suites test_discovery_agent_contracts, test_claude_rules_frontmatter, test_generate_codex_agent_variants, test_resolve_codex_topology and test_resolve_codex_deployment are included, together with the push-down resource, manifest and closure contracts and the Codex wrapper inventory).
- Pester: tests/scripts/claude-runtime 810 of 810 passed (includes claude-settings, legacy-discovery-agent-roles and claude-architecture-doc). CodexDeployment.Parity is included in the 60-of-60 run of the four named Pester suites.

## Files added

- .claude/agents/discovery-capability-sentinel.md (tools `mcp__drm-copilot__discovery_capability_sentinel` and `Bash`; no memory).
- .github/agents/discovery-capability-sentinel.agent.md (Copilot shape: `drmcopilotextension/discovery_capability_sentinel` and `execute/runInTerminal`).
- .codex/agents/discovery-capability-sentinel.toml.
- Bundle copies of all three under extensions/drm-copilot/resources; core pack manifest entries for the Claude agent and the Codex wrapper. The Copilot customizations tree has no manifest.

## Execution decision

`generate_codex_agent_variants` renders only the model-routed families (`GENERATED_AGENT_FAMILIES`). It wrote nothing for the sentinel, which has no complexity variants. The Codex surface is therefore a hand-authored base wrapper in the same shape as the discovery-role wrappers, carrying the `WRAPPER_REQUIRED_FRAGMENTS` that test_codex_full_migration_inventory.py requires. The generator `--check` is still the acceptance proof that no generated file drifted.

## Matchers (confirmed, not edited)

- .claude/settings.json: the PreToolUse group running enforce-discovery-artifact-gate.ps1 has matcher `Bash|Write|Edit|MultiEdit|NotebookEdit|Agent|Task|WebFetch|WebSearch|mcp__.*`, which admits `mcp__drm-copilot__discovery_capability_sentinel`.
- .codex/config.toml: the enforce-discovery-artifact-gate matcher `^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$` admits it.
- No SubagentStart or SubagentStop matcher names the sentinel; the four-role matchers and the fifteen-agent stop group are unchanged.

## Suite updates (only suites that enumerate agents or matchers)

- tests/scripts/claude-runtime/claude-settings.Tests.ps1: the gate-matcher assertion now includes the sentinel tool name, and a new assertion checks that no SubagentStart or SubagentStop matcher names the sentinel agent.
- docs/engineering/claude-code-architecture.md: added the sentinel row to the Copilot-to-Claude agent mapping table.
- No other suite needed a change. legacy-discovery-agent-roles.Tests.ps1 and test_discovery_agent_contracts.py are unchanged, as Set P states.
