# Pytest Final Gate (parallel) - issue 1114

Timestamp: 2026-11-07T19-50
Command: sh SCRATCH/issue-1114-pytest.sh final1 (in the item worktree: poetry run pytest -n auto -q -rfE -p no:cacheprovider --cov --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-1114-final1-pytest-cov.json)
EXIT_CODE: 0
Output Summary:
- Result: 16204 passed, 6 skipped, 0 failed, 0 errors (146.89 s). [P0-T5]: 16204 passed, 6 skipped, 0 failed.
- Failing node IDs absent from the [P0-T5] artifact: none (no failing node ID in either run).
- Repo-wide coverage (JSON report totals): line 49.92% (16703 of 33459 statements; [P0-T5] 49.92%), branch 45.97% (5773 of 12558 branches; [P0-T5] 45.96%). No drop.
- Per-file coverage: N/A - no Python file in scope.
- Contract tests (collected in this tree per [P0-T5]; none among failing node IDs, so each passed): `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` PASS, `test_bundled_codex_files_are_listed_in_some_pack_manifest` PASS, `test_codex_manifest_powershell_dependency_closure` PASS, `test_brief_copies_are_byte_identical` PASS, `test_brief_has_required_headings` PASS, `test_brief_has_no_consuming_names` PASS, `test_brief_has_no_g11_or_g12_findings` PASS.
