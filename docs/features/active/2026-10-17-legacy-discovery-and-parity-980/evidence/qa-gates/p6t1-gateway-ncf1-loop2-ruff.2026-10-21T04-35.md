Timestamp: 2026-10-21T04-35
Command: `.venv/Scripts/python.exe -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py tests/discovery_runtime/test_gateway_local.py tests/discovery_runtime/test_gateway_factory.py`
EXIT_CODE: 1
Output Summary: ncf1-loop2-ruff; 0 retained test IDs; elapsed 0.115 seconds.

```text
TC002 Move third-party import `drm_copilot_discovery.gateway_local.LocalServiceIO` into a type-checking block
  --> tests\discovery_runtime\test_gateway_factory.py:12:49
   |
10 | from drm_copilot_discovery import activation_store, gateway_local, mutation_filesystem
11 | from drm_copilot_discovery.activation_filesystem import NativeRegistry, RegistryLocation
12 | from drm_copilot_discovery.gateway_local import LocalServiceIO
   |                                                 ^^^^^^^^^^^^^^
13 | from drm_copilot_discovery.models import JsonObject
14 | from drm_copilot_discovery.service_contracts import ServiceRequest
   |
help: Move into type-checking block

Found 1 error.
No fixes available (1 hidden fix can be enabled with the `--unsafe-fixes` option).

```
