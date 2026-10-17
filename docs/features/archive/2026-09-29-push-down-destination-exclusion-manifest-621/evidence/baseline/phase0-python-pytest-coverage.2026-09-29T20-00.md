# Phase 0 Python Test and Coverage Baseline — Issue #621

Task: [P0-T9]
Branch: feature/push-down-destination-exclusion-manifest-exec-621

Timestamp: 2026-09-29T20-00
Command: poetry run pytest --cov=scripts.dev_tools --cov=src --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
EXIT_CODE: 0
Output Summary:
- Final summary line: `5526 passed, 6 skipped in 102.58s (0:01:42)`. Passed 5526, failed 0, skipped 6, errors 0.
- Failing or erroring node IDs (rule 13): none. `grep -c -e FAILED -e 'ERROR '` over the captured output returned 0. The issue #510 node `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passed in this worktree.
- Skipped cases are all in `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231` (fixtures that declare no accessor expectation).
- `TOTAL` row (Stmts, Miss, Branch, BrPart, Cover): `TOTAL 16717 1125 6048 583 91%`.
- `artifacts/python/coverage.json` totals: covered_lines 15592 / num_statements 16717; covered_branches 5213 / num_branches 6048; percent_covered 91.39.
- `scripts/dev_tools/push_down_claude_customizations.py` (from `files[...].summary`): num_statements 69, covered_lines 64, num_branches 8, covered_branches 6; line 92.75%, branch 75.00%. Term-missing row: `69 5 8 0 91% 100-109`.
