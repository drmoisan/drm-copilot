# Final QA: pytest parallel gate (P4-T5)

Timestamp: 2026-11-08T15-07
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1127-pytest-final.json --cov -q -rfE (from the item worktree root, through sh SCRATCH/issue-1127-pytest.sh final; run started 2026-11-08T14-59 UTC)
EXIT_CODE: 0
Output Summary:
- 16538 passed, 0 failed, 6 skipped in 344.12 s (baseline: 16537 passed, 0 failed, 6 skipped; the one added test is test_brief_worktree_python_environment_section_states_bootstrap)
- Failing node IDs: none (baseline failing set: empty), so no failing node ID is absent from the baseline set
- Repo-wide line coverage (JSON totals): 97.11% (34287 of 35308) vs baseline 97.11% (34287 of 35308): no drop
- Repo-wide branch coverage (JSON totals): 94.37% (12645 of 13400) vs baseline 94.37% (12645 of 13400): no drop
- Pinned contract tests named in P2-T5 and P2-T6 (push-down resource contracts, both pack-manifest completeness tests, dependency closure, test_codex_core_manifest_closure.py, and test_execution_environment_brief_contracts.py including test_brief_copies_are_byte_identical and test_brief_has_no_g11_or_g12_findings) ran in this gate and passed.
