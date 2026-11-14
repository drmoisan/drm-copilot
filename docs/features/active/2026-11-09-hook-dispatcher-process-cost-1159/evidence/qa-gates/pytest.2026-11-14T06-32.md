# Final pytest gate ([P7-T5])

Timestamp: 2026-11-14T06-32
Command: sh SCRATCH/issue-1159-pytest.sh (in the worktree: env -u VIRTUAL_ENV poetry run pytest -n auto -p no:cacheprovider --cov --cov-branch --cov-report=term:skip-covered --cov-report=json:artifacts/python/coverage-final.json -rf -q; totals read from the JSON report), started 2026-11-14T06-27
EXIT_CODE: 0
Output Summary: 16723 passed, 6 skipped, 0 failed in 248.84s (pytest-xdist, -n auto). Repo-wide line coverage 97.13% (34574 of 35595 statements) against 97.11% (34334 of 35355) at the [P0-T6] baseline; branch coverage 94.42% (12785 of 13540 branches; 555 partial) against 94.37% (12668 of 13424). No line or branch drop. Combined term TOTAL 96% (baseline 96%).

## Push-down contract tests named in the execution-environment brief (all inside this run, all passed)
- tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
- tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py
- tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py
- tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py
- tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py
The three [P4-T4] files (test_push_down_pack_manifest_dependency_closure.py, test_codex_core_manifest_closure.py, test_discovery_publication_contracts.py) are in the run with 0 failures; -rf listed no failure.
