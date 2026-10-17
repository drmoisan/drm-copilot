# Pre-Existing Tests Unchanged

Timestamp: 2026-10-10T08-17
Task: [P1-T7]
Command: poetry run pytest tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py -k "not first_line_of_shell_fence and not first_line_of_python_fence and not split_across_lines and not compute_cohorts_under_bash_fence and not invokes_bundled_remove_script"
EXIT_CODE: 0

Output Summary:
- `26 passed, 10 deselected in 0.33s`; 0 failed.
- The 10 deselected cases are exactly the ten new cases from [P1-T1] through [P1-T5].
- The 26 passing tests equal the pre-existing count of these two files at baseline (21 in `test_skill_bundle_contract.py`, 5 in `test_skill_bundle_contract_repo.py`; see `evidence/baseline/python-pytest-coverage.2026-10-10T08-05.md`).
- Additional checks on the two edited test files: `poetry run black` (2 files left unchanged), `poetry run ruff check` (All checks passed!), `poetry run pyright` (0 errors, 0 warnings, 0 informations). Line counts: 340 and 186 (both under 500).
