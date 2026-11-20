# pytest strictness probes (#1048, P2-T10)

Timestamp: 2026-10-31T19-07
Command: one full serial run per option: poetry run pytest -p no:cacheprovider <option> (SCRATCH/issue-1048-run-probes.sh)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
Four options pass with zero failures; `--import-mode=importlib` fails one test. The artifact's `EXIT_CODE` is the last probe's exit code, which is expected.

| Option | Command | EXIT_CODE | Failures | Result | First failing node id |
| --- | --- | --- | --- | --- | --- |
| `--strict-markers` | `poetry run pytest -p no:cacheprovider --strict-markers` | 0 | 0 | 15875 passed, 6 skipped in 192.05 s | none |
| `--strict-config` | `poetry run pytest -p no:cacheprovider --strict-config` | 0 | 0 | 15875 passed, 6 skipped in 193.76 s | none |
| `xfail_strict` | `poetry run pytest -p no:cacheprovider -o xfail_strict=true` | 0 | 0 | 15875 passed, 6 skipped in 193.34 s (no test in `tests/` uses `xfail`) | none |
| `filterwarnings = ["error"]` | `poetry run pytest -p no:cacheprovider -W error` | 0 | 0 | 15875 passed, 6 skipped in 190.72 s | none |
| `--import-mode=importlib` | `poetry run pytest -p no:cacheprovider --import-mode=importlib` | 1 | 1 | 1 failed, 15874 passed, 6 skipped in 195.32 s | `tests/test_pytest_collection.py::test_repo_root_on_sys_path_allows_scripts_import` |
