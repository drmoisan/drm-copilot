# Baseline: pytest (whole test tree, coverage)

Timestamp: 2026-11-18T08-04
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch --cov-report=term --cov-report=json:artifacts/python/issue-1029-base-coverage.json
EXIT_CODE: 0
Output Summary: One `pytest -n auto` run through the launcher (integration and golden lanes excluded): 17122 passed, 6 skipped, 0 failed in 188.11 s. Repo-wide coverage over the configured sources (`[tool.coverage.run]` `source`): combined 97% in the terminal `TOTAL` row (36079 statements, 720 missed, 13714 branches, 534 partial); from the JSON report, lines 98.00% (35359/36079) and branches 95.46% (13092/13714). In-scope Python production files: none (the plan edits only the test file `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`).
