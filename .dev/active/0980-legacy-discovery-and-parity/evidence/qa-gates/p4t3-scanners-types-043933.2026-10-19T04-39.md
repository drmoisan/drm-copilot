# P4-T3 scanners types

Timestamp: 2026-10-19T04-39
Command: `poetry run python -m pyright packages/discovery-runtime/src/drm_copilot_discovery/analyzer/csharp_declarations.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/event_subscriptions.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dotnet_inventory.py tests/discovery_runtime/analyzer/test_csharp_declarations.py tests/discovery_runtime/analyzer/test_event_subscriptions.py tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py scripts/dev_tools/discovery/analyzer/dotnet_inventory.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
WORKSPACE\tests\discovery_runtime\analyzer\test_csharp_declarations.py
  WORKSPACE\tests\discovery_runtime\analyzer\test_csharp_declarations.py:200:5 - error: Type of "document" is unknown (reportUnknownVariableType)
  WORKSPACE\tests\discovery_runtime\analyzer\test_csharp_declarations.py:200:52 - error: Expected 2 positional arguments (reportCallIssue)
  WORKSPACE\tests\discovery_runtime\analyzer\test_csharp_declarations.py:201:12 - error: Type of "document" is unknown (reportUnknownMemberType)
  WORKSPACE\tests\discovery_runtime\analyzer\test_csharp_declarations.py:202:12 - error: Type of "ledger_components" is unknown (reportUnknownMemberType)
WORKSPACE\tests\discovery_runtime\analyzer\test_event_subscriptions.py
  WORKSPACE\tests\discovery_runtime\analyzer\test_event_subscriptions.py:117:9 - error: Type of "document" is unknown (reportUnknownMemberType)
  WORKSPACE\tests\discovery_runtime\analyzer\test_event_subscriptions.py:117:45 - error: Expected 2 positional arguments (reportCallIssue)
6 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
