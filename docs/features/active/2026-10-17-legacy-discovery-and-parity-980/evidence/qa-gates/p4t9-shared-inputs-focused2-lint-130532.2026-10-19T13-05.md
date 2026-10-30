# P4-T9 Shared Inputs focused2 lint

Timestamp: 2026-10-19T13-05
Command: `poetry run python -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/extension_inputs.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/emitter.py tests/discovery_runtime/test_extension_inputs.py tests/discovery_runtime/test_extension_input_limits.py tests/discovery_runtime/analyzer/test_emitter_extensions.py`
EXIT_CODE: 1
Output Summary: Isolated development gate; exact input and raw-output bindings are in the paired JSON.

```text
E501 Line too long (89 > 88)
   --> tests\discovery_runtime\analyzer\test_emitter_extensions.py:376:89
    |
375 |     def identities() -> tuple[JsonObject, ...]:
376 |         """Return the isolated reserved descriptor without I/O or implementation imports.
    |                                                                                         ^
377 |
378 |         No parameters; returns tuple[JsonObject, ...]. No exceptions expected.
    |

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\test_extension_input_limits.py:3:1
   |
 1 |   """Verify finite projection resources and exact canonical serialization boundaries."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | import hashlib
 6 | | from dataclasses import replace
 7 | | from typing import TYPE_CHECKING, cast
 8 | |
 9 | | import pytest
10 | | from drm_copilot_discovery import extension_inputs as subject
11 | | from drm_copilot_discovery.analyzer.findings import row
12 | | from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput
13 | | from drm_copilot_discovery.models import (
14 | |     JsonObject,
15 | |     JsonValue,
16 | |     ParseLimits,
17 | |     canonical_json,
18 | | )
19 | | from drm_copilot_discovery.snapshot import SnapshotFile
20 | | from tests.discovery_runtime.analyzer.test_repository import (
21 | |     analyzer_catalog as analyzer_catalog,
22 | | )
23 | | from tests.discovery_runtime.analyzer.test_repository import inventory_profile
24 | | from tests.discovery_runtime.test_extension_inputs import capture_case
   | |______________________________________________________________________^
25 |
26 |   if TYPE_CHECKING:
   |
help: Organize imports

Found 2 errors.
[*] 1 fixable with the `--fix` option.

```
