# Baseline: Python Contract Tests (Issue #973)

Timestamp: 2026-10-17T13-10
Command: sh SCRATCH/issue-973-pytest.sh <worktree> (per file: poetry run pytest tests/scripts/dev_tools/<file>.py -q --no-cov -p no:cacheprovider -rfE)
EXIT_CODE: 0

| File | Passed | Failed | Skipped | Exit |
|---|---|---|---|---|
| `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` | 18 | 0 | 0 | 0 |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | 14 | 0 | 0 | 0 |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` | 9 | 0 | 0 | 0 |
| `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py` | 12 | 0 | 0 | 0 |

Output Summary: 53 passed, 0 failed, 0 skipped across the four files; every file exits 0.
