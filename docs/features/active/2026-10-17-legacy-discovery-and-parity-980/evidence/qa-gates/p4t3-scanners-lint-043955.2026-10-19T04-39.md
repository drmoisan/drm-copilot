# P4-T3 scanners lint

Timestamp: 2026-10-19T04-39
Command: `poetry run python -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/csharp_declarations.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/event_subscriptions.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dotnet_inventory.py tests/discovery_runtime/analyzer/test_csharp_declarations.py tests/discovery_runtime/analyzer/test_event_subscriptions.py tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py scripts/dev_tools/discovery/analyzer/dotnet_inventory.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\analyzer\test_event_subscriptions.py:3:1
   |
 1 |   """Keep possible handler assignments distinct from compiler/runtime event proof."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | from typing import TYPE_CHECKING, cast
 6 | |
 7 | | import pytest
 8 | | from drm_copilot_discovery.analyzer.dotnet_inventory import (
 9 | |     EventSubscriptionAnalyzer,
10 | |     classify_text,
11 | | )
12 | | from drm_copilot_discovery.analyzer.emitter import inventory_result
13 | | from drm_copilot_discovery.analyzer.findings import row
14 | | from drm_copilot_discovery.analyzer.event_subscriptions import subscription_candidates
15 | |
16 | | from tests.discovery_runtime.analyzer.test_dotnet_projects import capture, properties
17 | | from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog
   | |____________________________________________________________________________________^
18 |
19 |   if TYPE_CHECKING:
   |
help: Organize imports

Found 1 error.
[*] 1 fixable with the `--fix` option.

```
