# Pass-After — Guard Fix (FU-763-5)

Timestamp: 2026-10-10T08-21
Task: [P2-T3]
Command: poetry run pytest "tests/scripts/dev_tools/test_skill_bundle_contract.py::test_extract_reads_invocation_on_first_line_of_shell_fence" "tests/scripts/dev_tools/test_skill_bundle_contract.py::test_extract_reads_python_invocation_on_first_line_of_python_fence" "tests/scripts/dev_tools/test_skill_bundle_contract.py::test_extract_ignores_verb_and_path_split_across_lines" "tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_parallel_plan_extracts_compute_cohorts_under_bash_fence"
EXIT_CODE: 0

Output Summary:
- `9 passed in 0.09s`; 0 failed.
- The nine cases are the six shell-fence cases, the python-fence case, the split-line case, and the parallel-plan case that failed in `fail-before.2026-10-10T08-16.md`.
- `test_parallel_remove_invokes_bundled_remove_script` is deliberately excluded; it passes only after Phase 5.
- Edited module checks: `poetry run black --check scripts/dev_tools/skill_bundle_contract.py` (1 file would be left unchanged), `poetry run ruff check` (All checks passed!), `poetry run pyright` (0 errors, 0 warnings, 0 informations).
