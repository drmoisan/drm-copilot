# Pytest Phase 0 Baseline (parallel gate) - issue 1114

Timestamp: 2026-11-07T19-28
Command: sh SCRATCH/issue-1114-pytest.sh baseline (in the item worktree: poetry run pytest -n auto -q -rfE -p no:cacheprovider --cov --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-1114-baseline-pytest-cov.json)
EXIT_CODE: 0
Output Summary:
- Result: 16204 passed, 6 skipped, 0 failed, 0 errors (233.52 s).
- Failing node IDs: none.
- Repo-wide coverage (JSON report totals; coverage source from pyproject `[tool.coverage.run]`): line 49.92% (16703 of 33459 statements), branch 45.96% (5772 of 12558 branches); combined terminal TOTAL 49%.
- Per-file coverage: N/A - no Python file in scope.
- Contract tests named in [P5-T4] (each collected in this tree, confirmed with `pytest --collect-only`, and none appears among failing node IDs, so each passed): `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`, `test_bundled_codex_files_are_listed_in_some_pack_manifest`, `test_codex_manifest_powershell_dependency_closure`, `test_brief_copies_are_byte_identical`, `test_brief_has_required_headings`, `test_brief_has_no_consuming_names`, `test_brief_has_no_g11_or_g12_findings`: all PASS.
