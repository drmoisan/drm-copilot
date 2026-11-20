# P6-T2 CLI composition lint

Timestamp: 2026-10-21T14-59

Command: `C:\Users\DanMoisan\AppData\Local\Programs\Python\Python313\python.exe -u -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/cli.py tests/discovery_runtime/test_cli_dry_run.py tests/discovery_runtime/cli_test_support.py tests/scripts/dev_tools/discovery/test_init_cli.py`

EXIT_CODE: 1

Output Summary: FAIL; 0.222 seconds; 0 passed nodes.

```text
E731 Do not assign a `lambda` expression, use a `def`
   --> tests\discovery_runtime\test_cli_dry_run.py:149:5
    |
148 |     ports = memory_ports(service_io, executor)
149 |     invalid_root: Callable[[str], str] = lambda selected: "relative"
    |     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
150 |     # Only root resolution/build errors are invocation failures; provider errors are 3.
151 |     if boundary in ("root", "canonical"):
    |
help: Rewrite `invalid_root` as a `def`

E731 Do not assign a `lambda` expression, use a `def`
   --> tests\discovery_runtime\test_cli_dry_run.py:298:5
    |
297 |     output, errors = io.StringIO(), io.StringIO()
298 |     is_directory: Callable[[Path], bool] = lambda path: directory
    |     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
299 |     monkeypatch.setattr(Path, "resolve", resolve)
300 |     monkeypatch.setattr(Path, "is_dir", is_directory)
    |
help: Rewrite `is_directory` as a `def`

Found 2 errors.
No fixes available (2 hidden fixes can be enabled with the `--unsafe-fixes` option).

```
