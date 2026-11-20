# p3t2-correction-types4

Timestamp: 2026-10-18T13-22
Command: poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/init_flow.py packages/discovery-runtime/src/drm_copilot_discovery/init_io.py packages/discovery-runtime/src/drm_copilot_discovery/init_projection.py scripts/dev_tools/discovery/init_flow.py tests/discovery_runtime/test_initialization.py tests/discovery_runtime/test_initialization_conflicts.py tests/discovery_runtime/initialization_test_support.py tests/scripts/dev_tools/discovery/test_init_flow.py tests/scripts/dev_tools/discovery/test_init_cli.py tests/scripts/dev_tools/discovery/test_init_models.py tests/scripts/dev_tools/discovery/test_domain_neutrality.py
EXIT_CODE: 1
Output Summary:   EXTERNAL_PATH - error: "_directory" is protected and used outside of the class in which it is declared (reportPrivateUsage); 6 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T13:22:46.825987+00:00
Duration seconds: 1.902
Phase: P3-T2 safe draft initialization; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: "InitializationCapture" is not exported from module "drm_copilot_discovery.init_io"
    Import from "drm_copilot_discovery.init_projection" instead (reportPrivateImportUsage)
EXTERNAL_PATH
  EXTERNAL_PATH - error: "_ProposalInputs" is private and used outside of the module in which it is declared (reportPrivateUsage)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Class "_ProposalInputs" is not accessed (reportUnusedClass)
EXTERNAL_PATH
  EXTERNAL_PATH - error: "_ProposalInputs" is private and used outside of the module in which it is declared (reportPrivateUsage)
  EXTERNAL_PATH - error: "_directory" is protected and used outside of the class in which it is declared (reportPrivateUsage)
  EXTERNAL_PATH - error: "_directory" is protected and used outside of the class in which it is declared (reportPrivateUsage)
6 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
