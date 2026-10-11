# Fail-Before — Issue #791 Regression Tests

Timestamp: 2026-10-10T08-16
Task: [P1-T6] [expect-fail]
Command: poetry run pytest "tests/scripts/dev_tools/test_skill_bundle_contract.py::test_extract_reads_invocation_on_first_line_of_shell_fence" "tests/scripts/dev_tools/test_skill_bundle_contract.py::test_extract_reads_python_invocation_on_first_line_of_python_fence" "tests/scripts/dev_tools/test_skill_bundle_contract.py::test_extract_ignores_verb_and_path_split_across_lines" "tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_parallel_plan_extracts_compute_cohorts_under_bash_fence" "tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_parallel_remove_invokes_bundled_remove_script"
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:
- `collected 10 items`; `10 failed in 0.15s`; 0 passed.
- Failures and the defect each reproduces:
  - `test_extract_reads_invocation_on_first_line_of_shell_fence[bash-bash]`, `[bash-sh]`, `[sh-bash]`, `[sh-sh]`, `[source-bash]`, `[source-sh]`: `AssertionError: fence=<fence> verb=<verb>: got ()` — the `\s+` separator lets the fence info string consume the next line's verb, so the path is not extracted (FU-763-5).
  - `test_extract_reads_python_invocation_on_first_line_of_python_fence`: `AssertionError: Got ()` — same defect in `_PYTHON_PATH_PATTERN`.
  - `test_extract_ignores_verb_and_path_split_across_lines`: `AssertionError: Expected no references, got ('scripts/tools/example.sh',)` — a line-final verb pairs with the next line's path.
  - `test_parallel_plan_extracts_compute_cohorts_under_bash_fence`: `AssertionError: compute-cohorts.sh not extracted from parallel-plan; got ('.claude/lib/bash/compute-concurrency-batches.sh', '.claude/lib/bash/report-lane-assertion.sh', '.claude/lib/bash/validate-parallel-manifest.sh', '.claude/lib/blast-radius/BlastRadius.psm1')` — the real `.claude/skills/parallel-plan/SKILL.md` line 322-323 bash fence invocation is missed.
  - `test_parallel_remove_invokes_bundled_remove_script`: `AssertionError: remove-parallel-item.sh not extracted from parallel-remove; got ('.claude/lib/bash/abandon-parallel-item.sh',)` — the skill still calls the Python engine (FU-763-3; passes only after Phase 5).
- Count check: 6 shell-fence + 1 python-fence + 1 split-line + 1 parallel-plan + 1 parallel-remove = 10. Matches the acceptance condition.
