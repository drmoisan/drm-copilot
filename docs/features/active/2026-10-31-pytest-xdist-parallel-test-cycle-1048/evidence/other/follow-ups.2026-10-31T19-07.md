# Follow-ups recorded by #1048

Timestamp: 2026-10-31T19-07
Command: follow-up register written by P2-T11 and extended by P7-T6
EXIT_CODE: 0
Output Summary:
Each entry is a candidate follow-up for promotion; none is filed by this item.

## FU-1: adopt warnings-as-errors for pytest after a CI-matrix probe

- Source: P2-T11 (`filterwarnings = ["error"]` deferred).
- Evidence: `-W error` passed the full suite locally on Python 3.13 (15875 passed, 0 failed); the 3.10, 3.11, and 3.12 CI legs were not probed.
- Proposed work: run the `quality-checks7` matrix once with `-W error` (for example on a throwaway branch), fix or filter each version-specific warning at its source, then add `filterwarnings = ["error"]` to `[tool.pytest.ini_options]`.

## FU-2: evaluate `--import-mode=importlib`

- Source: P2-T11 (`--import-mode=importlib` deferred).
- Evidence: one failure, `tests/test_pytest_collection.py::test_repo_root_on_sys_path_allows_scripts_import`, which asserts that the repository root is on `sys.path`.
- Proposed work: decide how `scripts.*` and `tests.*` imports resolve without prepend mode (for example a `pythonpath = ["."]` setting), update that regression test to assert the chosen wiring, and re-run the full suite with `--import-mode=importlib`.
