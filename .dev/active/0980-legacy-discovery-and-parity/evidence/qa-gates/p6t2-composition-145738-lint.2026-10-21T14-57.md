# P6-T2 CLI composition lint

Timestamp: 2026-10-21T14-57

Command: `C:\Users\DanMoisan\AppData\Local\Programs\Python\Python313\python.exe -u -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/cli.py tests/discovery_runtime/test_cli_dry_run.py tests/discovery_runtime/cli_test_support.py tests/scripts/dev_tools/discovery/test_init_cli.py`

EXIT_CODE: 1

Output Summary: FAIL; 0.626 seconds; 0 passed nodes.

```text
E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_cli_dry_run.py:271:89
    |
270 |     def resolve(path: Path, *, strict: bool) -> Path:
271 |         """Record path (Path)/strict (bool); return memory root without filesystem I/O."""
    |                                                                                         ^^
272 |         assert strict
273 |         roots.append(str(path))
    |

Found 1 error.

```
