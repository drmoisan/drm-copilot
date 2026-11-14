# pytest Phase 0 Baseline (P0-T5)

Timestamp: 2026-11-14T07-18
Command: sh SCRATCH/issue-1173-pytest.sh baseline (from the worktree root: env -u VIRTUAL_ENV poetry run pytest tests -n auto -q --cov=docs_python_native.cli_argparse --cov=docs_python_native.cli --cov=docs_python_native.call_sites --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1173-pytest-baseline.json); per-module figures read from the JSON report by SCRATCH/issue-1173-covjson.ps1
EXIT_CODE: 1
Output Summary:
- One pytest -n auto run: 16721 passed, 1 failed, 6 skipped in 265.03 s.
- Failing test (pre-existing on the unmodified branch head, local environment): tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts, "Repo file missing from bundle: .claude/lib/docs/python/docs_python_native/__pycache__/__init__.cpython-313.pyc". The gitignored bytecode file was written during this same run (file time inside the run window) and the test's file enumeration (list_scoped_files plus filter_distributable_claude_paths) does not exclude `__pycache__`, so the result depends on whether another worker wrote the bytecode first. No tracked file differs; the defect is in the test enumeration.
- Coverage from the JSON report (line and branch):

| Module | Lines covered/total | Line % | Branches covered/total | Branch % |
|---|---|---|---|---|
| docs_python_native.call_sites | 91/91 | 100.00 | 38/38 | 100.00 |
| docs_python_native.cli_argparse | 159/159 | 100.00 | 83/86 | 96.51 |
| docs_python_native.cli | 105/106 | 99.06 | 45/46 | 97.83 |
| Total (three modules) | 355/356 | - | 166/170 | combined 99.05 |
