# pytest strictness decisions (#1048, P2-T11)

Timestamp: 2026-10-31T19-07
Command: decisions derived from `pytest-strictness-probes.2026-10-31T19-07.md`
EXIT_CODE: 0
Output Summary:
Rule applied: an option is adopted only when its probe failed zero tests or needs only trivial test edits; passing that bar is necessary, not sufficient, so an option with an unmeasured risk on the CI matrix is deferred with a follow-up.

| Option | Decision | Reason |
| --- | --- | --- |
| `--strict-markers` | ADOPT | Probe passed with 0 failures; every marker in use is registered, so the flag only turns a future misspelled marker into a collection error. Applied as an `addopts` token after the existing tokens (P2-T12). |
| `--strict-config` | ADOPT | Probe passed with 0 failures; the pytest configuration carries no unknown keys, and the flag turns a future unknown key into an error. Applied as an `addopts` token (P2-T12). |
| `xfail_strict` | ADOPT | Probe passed with 0 failures and no test uses `xfail`, so the setting changes no current outcome and makes a future unexpected pass fail. Applied as the key `xfail_strict = true` (P2-T12). |
| `filterwarnings = ["error"]` (probed as `-W error`) | DEFER | The probe passed with 0 failures on Python 3.13 only. The CI matrix also runs Python 3.10, 3.11, and 3.12, whose standard library and dependencies emit version-specific `DeprecationWarning`s that were not measured, so adopting it could fail the required `quality-checks7` legs on a warning unrelated to this item. Follow-up recorded. |
| `--import-mode=importlib` | DEFER | The probe failed 1 test: `tests/test_pytest_collection.py::test_repo_root_on_sys_path_allows_scripts_import`, which asserts that the repository root is on `sys.path` so `scripts.*` imports work; importlib mode does not insert the root. Adopting it needs a decision on the repository's import wiring (for example a `pythonpath` setting or packaging changes) and a rewrite of that regression test, which is not a trivial edit. Follow-up recorded. |

Deferrals are recorded in `follow-ups.2026-10-31T19-07.md`.

## Application (P2-T12, 2026-10-31T19-11)

- `[tool.pytest.ini_options]` in `pyproject.toml` now reads `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info --strict-markers --strict-config"` (the existing `-ra --cov-report=lcov:artifacts/python/lcov.info` tokens stay first) and carries the new key `xfail_strict = true`. No test edit was needed.
- Verification: `poetry run pytest -q -p no:cacheprovider` exited 0 with 15875 passed, 6 skipped in 177.32 s; `test_pyproject_addopts_carries_no_xdist_flag` passes (the workflow contract file: 9 passed).
