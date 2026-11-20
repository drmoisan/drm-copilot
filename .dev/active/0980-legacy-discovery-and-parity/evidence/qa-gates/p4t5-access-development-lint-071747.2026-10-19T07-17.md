# P4-T5 development lint

Timestamp: 2026-10-19T07-17
Command: `poetry run python -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/api_access.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/api_syntax.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/filesystem_access.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry_access.py tests/discovery_runtime/analyzer/test_filesystem_access.py tests/discovery_runtime/analyzer/test_registry_access.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
invalid-syntax: Cannot use `type` alias statement on Python 3.10 (syntax was added in Python 3.12)
  --> tests\discovery_runtime\analyzer\test_registry_access.py:42:5
   |
40 |     from drm_copilot_discovery.catalog import SchemaCatalog
41 |
42 |     type Projector = Callable[
   |     ^^^^
43 |         [InventoryCapture, InventoryInput, ApiSurface, tuple[AccessSite, ...], bool],
44 |         Analysis,
   |

Found 1 error.

```
