# p4t7-integration-focused2-lint

Timestamp: 2026-10-19T10-46
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependencies.py tests/discovery_runtime/analyzer/test_dependencies.py tests/discovery_runtime/analyzer/test_dependency_projection_limits.py
EXIT_CODE: 1
Output Summary: scoped lint; duration 1.167 seconds. Separate exact stdout/stderr hashes and SCRATCH-relative locations qualify sanitized presentation.

```text
E501 Line too long (96 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependencies.py:452:89
    |
450 |         try:
451 |             state = _Run(capture)
452 |             # Capture selection/exclusion remains authoritative; payloads cannot select parsers.
    |                                                                                         ^^^^^^^^
453 |             for item in capture.inputs:
454 |                 state.work -= len(item.path) + 1
    |

E501 Line too long (89 > 88)
 --> tests\discovery_runtime\analyzer\test_dependencies.py:1:89
  |
1 | """Verify dependency projection, provenance and aggregate budgets with captured bytes."""
  |                                                                                         ^
2 |
3 | from __future__ import annotations
  |

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\analyzer\test_dependencies.py:3:1
   |
 1 |   """Verify dependency projection, provenance and aggregate budgets with captured bytes."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | import hashlib
 6 | | from dataclasses import replace
 7 | | from typing import TYPE_CHECKING, cast
 8 | |
 9 | | import pytest
10 | |
11 | | from drm_copilot_discovery.analyzer import dependencies
12 | | from drm_copilot_discovery.analyzer.dependencies import DependencyAnalyzer
13 | | from drm_copilot_discovery.analyzer.dependency_inputs import (
14 | |     DependencyAnchor,
15 | |     DependencyCandidate,
16 | |     DependencyInputError,
17 | |     DependencyLimits,
18 | |     DependencyResult,
19 | |     DependencyValue,
20 | | )
21 | | from drm_copilot_discovery.analyzer.emitter import inventory_result
22 | | from drm_copilot_discovery.analyzer.findings import row
23 | | from drm_copilot_discovery.analyzer.models import (
24 | |     Analysis,
25 | |     InventoryCapture,
26 | |     InventoryInput,
27 | | )
28 | | from drm_copilot_discovery.models import JsonObject, canonical_json
29 | | from tests.discovery_runtime.analyzer.test_dotnet_projects import capture
30 | | from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog
31 | | from tests.discovery_runtime.analyzer.test_repository import inventory_profile
   | |______________________________________________________________________________^
32 |
33 |   if TYPE_CHECKING:
   |
help: Organize imports

B009 [*] Do not call `getattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\discovery_runtime\analyzer\test_dependencies.py:139:52
    |
137 |     No I/O, evaluation, mutation or expected exception occurs.
138 |     """
139 |     selector = cast("Callable[[str], str | None]", getattr(dependencies, "_format"))
    |                                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
140 |     assert selector(path) == expected
    |
help: Replace `getattr` with attribute access

B009 [*] Do not call `getattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\discovery_runtime\analyzer\test_dependencies.py:178:9
    |
176 |     dispatch = cast(
177 |         "Callable[[bytes, str, DependencyLimits], DependencyResult]",
178 |         getattr(dependencies, "_parse"),
    |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
179 |     )
180 |     assert dispatch(b"original", format, limits) == DependencyResult()
    |
help: Replace `getattr` with attribute access

E501 Line too long (106 > 88)
   --> tests\discovery_runtime\analyzer\test_dependencies.py:438:89
    |
436 |         (
437 |             "src/app.csproj",
438 |             b'<Project><ItemGroup><PackageReference Include="Delta" Version="2" /></ItemGroup></Project>',
    |                                                                                         ^^^^^^^^^^^^^^^^^^
439 |         ),
440 |     )
    |

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\analyzer\test_dependency_projection_limits.py:3:1
   |
 1 |   """Enforce aggregate dependency projection limits without filesystem or process use."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | from dataclasses import replace
 6 | | from typing import TYPE_CHECKING, Protocol, cast
 7 | |
 8 | | import pytest
 9 | | from drm_copilot_discovery.analyzer import dependencies
10 | | from drm_copilot_discovery.analyzer.dependencies import DependencyAnalyzer
11 | | from drm_copilot_discovery.analyzer.dependency_inputs import (
12 | |     DependencyAnchor,
13 | |     DependencyInputError,
14 | |     DependencyLimits,
15 | |     DependencyResult,
16 | | )
17 | | from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput
18 | | from drm_copilot_discovery.models import canonical_json
19 | | from tests.discovery_runtime.analyzer.test_dependencies import (
20 | |     codes,
21 | |     configured,
22 | |     item,
23 | |     stub,
24 | | )
25 | | from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog
   | |____________________________________________________________________________________^
26 |
27 |   if TYPE_CHECKING:
   |
help: Organize imports

B009 [*] Do not call `getattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\discovery_runtime\analyzer\test_dependency_projection_limits.py:214:54
    |
212 |         DependencyAnalyzer().analyze(cast("InventoryCapture", None))
213 |     factory = cast(
214 |         "Callable[[InventoryCapture], _Projection]", getattr(dependencies, "_Run")
    |                                                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
215 |     )
216 |     run = factory(configured(catalog))
    |
help: Replace `getattr` with attribute access

Found 8 errors.
[*] 5 fixable with the `--fix` option.
```
