# P6-T1 renderer ruff

Timestamp: 2026-10-20T14-45

Command: `poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/service_contracts.py packages/discovery-runtime/src/drm_copilot_discovery/service_serialization.py packages/discovery-runtime/src/drm_copilot_discovery/service_request_rules.py tests/discovery_runtime/test_service_request_rules.py tests/discovery_runtime/test_service_failures.py tests/schemas/discovery/test_v2_service_result_failures.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 1.411 seconds.

```text
TC003 Move standard library import `datetime.datetime` into a type-checking block
 --> packages\discovery-runtime\src\drm_copilot_discovery\service_contracts.py:7:22
  |
5 | import re
6 | from dataclasses import dataclass
7 | from datetime import datetime
  |                      ^^^^^^^^
8 | from typing import TYPE_CHECKING, Literal, Protocol, TypeAlias, cast, get_args
  |
help: Move into type-checking block

TC001 Move application import `drm_copilot_discovery.models.JsonObject` into a type-checking block
 --> packages\discovery-runtime\src\drm_copilot_discovery\service_request_rules.py:7:42
  |
5 | from typing import cast
6 |
7 | from drm_copilot_discovery.models import JsonObject
  |                                          ^^^^^^^^^^
8 |
9 | _ROOT_MODES = ("structural", "discovery-complete", "parity-complete", "planning")
  |
help: Move into type-checking block

E501 Line too long (90 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\service_serialization.py:258:89
    |
256 |                 pointer="/",
257 |                 message="Request shape, operation or resource bounds are invalid.",
258 |                 next_action="Use the fixed service request schema and applicable inputs.",
    |                                                                                         ^^
259 |             ),
260 |         )
    |

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\test_service_failures.py:3:1
   |
 1 |   """Exercise bounded service carriers, fixed request rules and honest failures."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | import json
 6 | | from dataclasses import replace
 7 | | from typing import TYPE_CHECKING, cast
 8 | |
 9 | | import pytest
10 | | from drm_copilot_discovery import service_serialization
11 | | from drm_copilot_discovery.findings import Finding
12 | | from drm_copilot_discovery.models import JsonObject, ParseLimits
13 | | from drm_copilot_discovery.path_models import WriteGrant
14 | | from drm_copilot_discovery.report_models import ReportLimitError, bounded_object
15 | | from drm_copilot_discovery.service_contracts import (
16 | |     DiscoveryResult,
17 | |     Operation,
18 | |     RuntimeIdentity,
19 | |     ServiceArtifact,
20 | |     ServiceAuthority,
21 | |     ServiceRequestError,
22 | |     ServiceRuntimeError,
23 | |     parse_service_request,
24 | |     validate_service_result,
25 | | )
26 | | from drm_copilot_discovery.snapshot import InputManifest, SnapshotFile
27 | |
28 | | from tests.discovery_runtime.test_snapshot_io import (
29 | |     snapshot_catalog as snapshot_catalog,
30 | | )
31 | | from tests.discovery_runtime.test_service_request_rules import request_document
   | |_______________________________________________________________________________^
32 |
33 |   if TYPE_CHECKING:
   |
help: Organize imports

F401 [*] `drm_copilot_discovery.models.JsonObject` imported but unused
  --> tests\discovery_runtime\test_service_failures.py:12:42
   |
10 | from drm_copilot_discovery import service_serialization
11 | from drm_copilot_discovery.findings import Finding
12 | from drm_copilot_discovery.models import JsonObject, ParseLimits
   |                                          ^^^^^^^^^^
13 | from drm_copilot_discovery.path_models import WriteGrant
14 | from drm_copilot_discovery.report_models import ReportLimitError, bounded_object
   |
help: Remove unused import: `drm_copilot_discovery.models.JsonObject`

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_service_failures.py:226:89
    |
225 | def test_authority_is_explicit_typed_and_does_not_mint_grants() -> None:
226 |     """Return None after retaining exact provider objects and rejecting malformed data."""
    |                                                                                         ^^
227 |     grant = WriteGrant(
228 |         artifact_kind="validation-report", artifact_id="report", path="report.json"
    |

B010 [*] Do not call `setattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\discovery_runtime\test_service_request_rules.py:123:9
    |
121 |     assert isinstance(request.inputs, JsonObject)
122 |     with pytest.raises(FrozenInstanceError):
123 |         setattr(request, "id", "changed")
    |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    |
help: Replace `setattr` with assignment

Found 7 errors.
[*] 3 fixable with the `--fix` option (2 hidden fixes can be enabled with the `--unsafe-fixes` option).

```
