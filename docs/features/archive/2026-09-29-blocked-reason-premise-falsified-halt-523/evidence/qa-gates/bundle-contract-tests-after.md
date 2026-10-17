# P6-T12 Bundle, Guardrail, and Skill-Bundle Contract Tests After the Documentation Edits

Timestamp: 2026-09-30T10-57
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py
EXIT_CODE: 0
Output Summary:
- Final line: `38 passed in 0.54s` (0 failed, 0 skipped). Pass count equals the P0-T12 value (38 passed, `evidence/baseline/bundle-contract-tests-before.md`).
- Named nodes, each reported `PASSED` in a companion run of the same command with `-rA` added for per-node reporting (also `38 passed`, exit 0):
  - `test_orchestration_guardrail_contracts.py::test_orchestration_skills_state_non_interpretable_guardrails`
  - `test_orchestration_guardrail_contracts.py::test_codex_only_orchestration_skills_match_published_bundle`
  - `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  - `test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`
  - `test_skill_bundle_contract_repo.py::test_every_skill_script_reference_is_bundled`
