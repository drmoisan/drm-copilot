# Contract Tests After Final QA (Issue #1026, P9-T5)

Timestamp: 2026-11-03T18-39
Command: sh SCRATCH/issue-1026-contract.sh (poetry run pytest -p no:cacheprovider -q --no-cov over the eight tests/scripts/dev_tools contract modules below, then poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check)
EXIT_CODE: 0
Output Summary: pytest 176 passed, 0 failed (PYTEST_EXIT=0) under the project addopts, which now carry --strict-markers and --strict-config; generator --check exit 0 with no stale-file output (GENERATOR_EXIT=0). Counts equal the P0-T7 baseline and the P8-T9 run (176 passed).

Host: GitHub Codespace, Linux (differs from the plan-time host). Branch HEAD at run time: the branch tip after the merge of origin/main (0 behind origin/main).

Modules run (all under `tests/scripts/dev_tools/`):

- `test_push_down_claude_resource_contracts.py`
- `test_push_down_codex_and_agents_resource_contracts.py`
- `test_push_down_claude_pack_manifest_completeness.py`
- `test_push_down_codex_and_agents_pack_manifest_completeness.py`
- `test_push_down_pack_manifest_dependency_closure.py`
- `test_push_down_issue_824_follow_ups.py`
- `test_execution_environment_brief_contracts.py`
- `test_completion_gate_documentation_contracts.py`

| Step | Passed | Failed | Exit code |
|---|---|---|---|
| pytest contract modules | 176 | 0 | 0 |
| generator `--check` | n/a | n/a | 0 |
