# P4-T4 repair-2 types

Timestamp: 2026-10-19T06-23
Command: `poetry run python -m pyright packages/discovery-runtime/src/drm_copilot_discovery/analyzer/configuration.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/configuration_input.py tests/discovery_runtime/analyzer/test_configuration.py tests/discovery_runtime/analyzer/test_configuration_input.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\configuration.py
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\configuration.py:192:15 - error: Argument of type "str | None" cannot be assigned to parameter "obj" of type "Sized" in function "len"
    Type "str | None" is not assignable to type "Sized"
      "None" is incompatible with protocol "Sized"
        "__len__" is not present (reportArgumentType)
WORKSPACE\tests\discovery_runtime\analyzer\test_configuration.py
  WORKSPACE\tests\discovery_runtime\analyzer\test_configuration.py:402:37 - error: "_project" is private and used outside of the module in which it is declared (reportPrivateUsage)
WORKSPACE\tests\discovery_runtime\analyzer\test_configuration_input.py
  WORKSPACE\tests\discovery_runtime\analyzer\test_configuration_input.py:185:29 - error: "child_pointer" is not exported from module "drm_copilot_discovery.analyzer.configuration_input" (reportPrivateImportUsage)
  WORKSPACE\tests\discovery_runtime\analyzer\test_configuration_input.py:218:29 - error: "child_pointer" is not exported from module "drm_copilot_discovery.analyzer.configuration_input" (reportPrivateImportUsage)
  WORKSPACE\tests\discovery_runtime\analyzer\test_configuration_input.py:295:29 - error: "_IniParser" is private and used outside of the module in which it is declared (reportPrivateUsage)
  WORKSPACE\tests\discovery_runtime\analyzer\test_configuration_input.py:312:38 - error: "_IniParser" is private and used outside of the module in which it is declared (reportPrivateUsage)
6 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
