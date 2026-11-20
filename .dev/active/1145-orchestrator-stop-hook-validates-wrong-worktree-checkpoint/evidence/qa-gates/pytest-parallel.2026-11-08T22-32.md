# Final pytest Gate (issue #1145, [P4-T4])

Timestamp: 2026-11-08T22-26
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/pytest-final.json --junitxml=SCRATCH/pytest-final.json.junit.xml
EXIT_CODE: 0
Output Summary:
- Run: one `pytest -n auto` gate on the branch head after the P4-T1 merge; finished 2026-11-08T22-32 (311.66 s).
- Counts: 16590 passed, 0 failed, 0 errors, 6 skipped (P0-T3: 16560 passed, 6 skipped; the increase comes from the suites merged from `origin/main`).
- Named tests, all passing (read from the JUnit report): `test_push_down_claude_resource_contracts.py` (14 testcases), `test_push_down_claude_pack_manifest_completeness.py` (2), `test_push_down_pack_manifest_dependency_closure.py` (18), and `test_execution_environment_brief_contracts.py::test_brief_copies_are_byte_identical`.
- Totals from the JSON report: line 97.11% (34334 of 35355; P0-T3 97.11%, 34296 of 35317); branch 94.37% (12668 of 13424; P0-T3 94.37%, 12649 of 13404). Neither total is below P0-T3 (unrounded: line 0.971121 vs 0.971090; branch 0.943683 vs 0.943673).
- No Python file is changed by this branch.
