Timestamp: 2026-11-19T17-37
Task: [P3-T2]
Changed files:
- `scripts/harness-generation/sources/mcp-servers.json` (the #1028 generator source: both names after validate_orchestration_artifacts in `codex.enabled_tools`; no `tool_approval_modes` entry), from which `Invoke-HarnessGeneration.ps1 -Surface mcp` rendered `.codex/config.toml` and its bundle copy `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` (two lines each; no per-tool approval table).
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` (in place: both names appended to `EXPECTED_DRM_COPILOT_TOOLS` and to the exclusion set of `APPROVED_DRM_COPILOT_TOOLS`), so `test_codex_config_files_retain_full_drm_copilot_transport` asserts the new list.
- `.agents/skills/repo-automation-adapter/SKILL.md` and its bundle copy (both names after transition_prepared_orchestration in `## Published MCP Tool Surface`).
- `extensions/drm-copilot/README.md` (tool list, paragraph, input summary, result shape) and `extensions/drm-copilot/CHANGELOG.md` (Unreleased, Added).
- New `extensions/drm-copilot/test/packaging/push-down-integration-exposure.test.ts`.
- `.claude/settings.json` not edited.
Selection and rule: the new Jest test and the packaging tests; the named pytest files (the edited test file, `test_orchestration_guardrail_contracts.py`, the dependency-closure test) and the Pester `parallel-gate-wording.Tests.ps1` (ADAPTER-AGENTS rows) and harness-generation suites that read the changed paths (atomic-plan-contract Test Cadence).
Commands and exit codes:
- npx prettier --write / --check, npx eslint, npx tsc (both projects) on the new test: EXIT_CODE 0 each.
- sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension push-down-integration-exposure packaging: EXIT_CODE 0 (Test Suites: 4 passed, 4 total; Tests: 25 passed, 25 total).
- env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -q tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py: EXIT_CODE 0 (37 passed).
- env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check: EXIT_CODE 0.
- pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface all -Check: EXIT_CODE 0 (harness-generation: no drift).
- sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 tests/scripts/harness-generation: EXIT_CODE 0 (selection JUnit: 291 tests, 291 passed).
Rule tokens: S55 (positive and negative) in push-down-integration-exposure.test.ts.
EXIT_CODE: 0
Output Summary: task check passed.
