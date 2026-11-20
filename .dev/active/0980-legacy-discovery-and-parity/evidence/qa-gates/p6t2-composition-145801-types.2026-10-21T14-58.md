# P6-T2 CLI composition types

Timestamp: 2026-10-21T14-58

Command: `C:\Users\DanMoisan\AppData\Local\Programs\Python\Python313\python.exe -u -m pyright packages/discovery-runtime/src/drm_copilot_discovery/cli.py tests/discovery_runtime/test_cli_dry_run.py tests/discovery_runtime/cli_test_support.py tests/scripts/dev_tools/discovery/test_init_cli.py`

EXIT_CODE: 1

Output Summary: FAIL; 1.628 seconds; 0 passed nodes.

```text
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

WORKSPACE\tests\discovery_runtime\test_cli_dry_run.py
  WORKSPACE\tests\discovery_runtime\test_cli_dry_run.py:153:70 - error: Type of parameter "_" is unknown (reportUnknownLambdaType)
  WORKSPACE\tests\discovery_runtime\test_cli_dry_run.py:294:32 - error: "timezone" is not exported from module "drm_copilot_discovery.cli" (reportPrivateImportUsage)
  WORKSPACE\tests\discovery_runtime\test_cli_dry_run.py:298:29 - error: "Path" is not exported from module "drm_copilot_discovery.cli" (reportPrivateImportUsage)
  WORKSPACE\tests\discovery_runtime\test_cli_dry_run.py:299:29 - error: "Path" is not exported from module "drm_copilot_discovery.cli" (reportPrivateImportUsage)
  WORKSPACE\tests\discovery_runtime\test_cli_dry_run.py:299:45 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(path: Unknown) -> bool" (reportUnknownArgumentType)
  WORKSPACE\tests\discovery_runtime\test_cli_dry_run.py:299:52 - error: Type of parameter "path" is unknown (reportUnknownLambdaType)
6 errors, 0 warnings, 0 informations

```
