# P4-T3 scanners lint

Timestamp: 2026-10-19T04-39
Command: `poetry run python -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/csharp_declarations.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/event_subscriptions.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dotnet_inventory.py tests/discovery_runtime/analyzer/test_csharp_declarations.py tests/discovery_runtime/analyzer/test_event_subscriptions.py tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py scripts/dev_tools/discovery/analyzer/dotnet_inventory.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
E501 Line too long (89 > 88)
  --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\csharp_declarations.py:23:89
   |
21 |     (
22 |         "public private protected internal static sealed abstract partial readonly "
23 |         "ref unsafe new virtual override file extern async required const volatile fixed"
   |                                                                                         ^
24 |     ).split()
25 | )
   |

Found 1 error.

```
