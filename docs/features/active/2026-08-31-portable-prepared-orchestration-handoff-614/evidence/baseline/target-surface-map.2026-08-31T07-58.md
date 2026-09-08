Timestamp: 2026-08-31T11-22
Command: `rg -n -e 'scripts/dev_tools|extensions/drm-copilot|\.codex/hooks|\.agents/skills|\.claude/skills|config/orchestration|tests/' 'docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/research/20260831-portable-prepared-orchestration-handoff-implementation-research.md'`
EXIT_CODE: 0
Output Summary:
- Contract/config: `config/orchestration-handoff.schema.json` and `config/orchestration-handoff-registry.json`.
- Python authority: `scripts/dev_tools/orchestration_handoff_contract.py`, `scripts/dev_tools/orchestration_handoff_adapters.py`, and `scripts/dev_tools/validate_orchestrator_state.py`.
- Python tests/fixtures: `tests/scripts/dev_tools/test_orchestration_handoff_*.py`, `tests/scripts/dev_tools/test_validate_orchestrator_state.py`, and `tests/fixtures/orchestration-handoff/`.
- TypeScript authority: `extensions/drm-copilot/src/lib/validate/orchestration-handoff-*.ts` and `semantic-mcp-identity.ts`.
- MCP dispatch: `repo-automation-tool-names.ts`, `mcp-repo-automation-tool-definitions.ts`, `repo-automation-service-contract.ts`, `repo-automation-service.ts`, and `mcp-tools.ts`.
- TypeScript tests: `extensions/drm-copilot/test/lib/validate/orchestration-handoff-*.test.ts`, `mcp-server.test.ts`, and `repo-automation-orchestration-validation.test.ts`.
- Hook/tests: `.codex/hooks/enforce-epic-planning-only.ps1`, its published bundle copy, and `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1`.
- Provider skills: `.agents/skills/{orchestrate,orchestrator-state}/SKILL.md` and the corresponding Claude ordinary orchestration/state-machine skills.
- Publication: both customization push-down scripts, bundled config/runtime files, `pack-manifests/core.json`, and applicable variant manifests.
- Installed-consumer parity: `test_push_down_codex_and_agents_customizations.py` and `test_push_down_claude_resource_contracts.py`.
- Scope is limited to #614. No #467 scheduler implementation or #543 epic-ready-gate change is included.
