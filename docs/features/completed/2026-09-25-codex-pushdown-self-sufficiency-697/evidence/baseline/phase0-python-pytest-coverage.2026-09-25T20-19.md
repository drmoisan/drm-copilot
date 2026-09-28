# Phase 0 Python Test and Coverage Baseline (Issue #697)

Timestamp: 2026-09-25T20-19
Command: poetry run pytest --cov=scripts.dev_tools --cov=src --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
EXIT_CODE: 1
Output Summary:
- Final summary line: `1 failed, 4418 passed, 5 skipped`
- Passed: 4418; Failed: 1; Skipped: 5
- Failing node IDs (rule 15, pre-existing):
  - `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` -- `AssertionError: Repo file missing from bundle: .claude\state\current-session-id` (issue #510; `.claude/state` files regenerate on disk)
- TOTAL row: `TOTAL  15803  1122  5754  579  91%` (statements, missed, branches, partial branches, cover)
- `scripts/dev_tools/push_down_codex_and_agents_customizations.py` from `artifacts/python/coverage.json` summary:
  - num_statements: 99
  - covered_lines: 97
  - num_branches: 14
  - covered_branches: 12
  - line percentage: 97.98
  - branch percentage: 85.71
  - missing_lines: [140, 325]
