# P5-T5 renderer ruff

Timestamp: 2026-10-20T12-24

Command: `poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/gherkin.py tests/discovery_runtime/test_gherkin.py tests/discovery_runtime/test_acceptance_tags.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 1.409 seconds.

```text
E501 Line too long (90 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\gherkin.py:143:89
    |
142 |     def __init__(self, limits: ParseLimits) -> None:
143 |         """Initialize limits (ParseLimits); return None, raising ValueError if invalid."""
    |                                                                                         ^^
144 |         self.budget = ReportBudget(limits)
145 |         # Every physical LF is measured explicitly; no implicit JSON LF is needed.
    |

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\test_acceptance_tags.py:3:1
   |
 1 |   """Preserve generated tag spelling and configured applicability during rendering."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | from dataclasses import replace
 6 | | from typing import TYPE_CHECKING, cast
 7 | |
 8 | | import pytest
 9 | | from drm_copilot_discovery.acceptance_generation import generate_acceptance
10 | | from drm_copilot_discovery.acceptance_models import acceptance_tags
11 | | from drm_copilot_discovery.gherkin import render_acceptance
12 | | from drm_copilot_discovery.models import ParseLimits
13 | |
14 | | from tests.discovery_runtime.test_acceptance_decisions import policy_snapshot
15 | | from tests.discovery_runtime.test_acceptance_generation import (
16 | |     generation_snapshot,
17 | |     snapshot_catalog as snapshot_catalog,
18 | | )
19 | | from tests.discovery_runtime.test_acceptance_properties import (
20 | |     generation,
21 | |     identity,
22 | |     specification,
23 | | )
24 | | from tests.discovery_runtime.test_gherkin import blocks, changed, file_text
25 | | from tests.schemas.discovery.v2_schema_test_support import as_object
   | |____________________________________________________________________^
26 |
27 |   if TYPE_CHECKING:
   |
help: Organize imports

E501 Line too long (93 > 88)
  --> tests\discovery_runtime\test_acceptance_tags.py:44:89
   |
42 |     mode: str, mobile: bool
43 | ) -> None:
44 |     """Preserve mode/mobile-derived tags exactly; name substrings confer no applicability."""
   |                                                                                         ^^^^^
45 |     key = identity(mode_id=mode, feature_id="feat.a_b-c", client_id="mobile-named")
46 |     tags = acceptance_tags(key, limits=ParseLimits(), mobile_applicable=mobile)
   |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_acceptance_tags.py:111:89
    |
110 | def test_empty_tag_tuple_does_not_create_an_inferred_tag() -> None:
111 |     """Render structural empty tags without inventing applicability or semantic proof."""
    |                                                                                         ^
112 |     item = changed(specification(), tags=())
113 |     feature = file_text(render_acceptance(generation((item,), (item,))), ".feature")
    |

E501 Line too long (93 > 88)
   --> tests\discovery_runtime\test_acceptance_tags.py:121:89
    |
119 |     snapshot_catalog: SchemaCatalog,
120 | ) -> None:
121 |     """Compose approved captured target through generation and rendering; retain all refs."""
    |                                                                                         ^^^^^
122 |     result = generate_acceptance(
123 |         policy_snapshot(snapshot_catalog), kind="target-acceptance"
    |

E501 Line too long (96 > 88)
   --> tests\discovery_runtime\test_acceptance_tags.py:140:89
    |
138 |     snapshot_catalog: SchemaCatalog,
139 | ) -> None:
140 |     """Consume actual generator uncertainty; assert no executable fallback or synthetic Then."""
    |                                                                                         ^^^^^^^^
141 |     snapshot = generation_snapshot(snapshot_catalog)
142 |     # Missing captured evidence must not become a ready-looking renderer fixture.
    |

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\test_gherkin.py:3:1
   |
 1 |   """Check pure ready-only rendering and exact escaped traceability."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | import json
 6 | | import re
 7 | | from dataclasses import FrozenInstanceError, replace
 8 | | from typing import TYPE_CHECKING, cast
 9 | |
10 | | import pytest
11 | | from drm_copilot_discovery import gherkin
12 | | from drm_copilot_discovery.acceptance_generation import generate_acceptance
13 | | from drm_copilot_discovery.acceptance_models import (
14 | |     AcceptanceGeneration,
15 | |     AcceptanceSpecification,
16 | | )
17 | | from drm_copilot_discovery.findings import Finding
18 | | from drm_copilot_discovery.gherkin import (
19 | |     AcceptanceRenderBundle,
20 | |     AcceptanceRenderedFile,
21 | |     render_acceptance,
22 | | )
23 | | from drm_copilot_discovery.models import ParseLimits, to_plain_value
24 | | from drm_copilot_discovery.report_models import ReportLimitError, bounded_object
25 | | from drm_copilot_discovery.schema_validation import validate_document
26 | |
27 | | from tests.discovery_runtime.test_acceptance_generation import (
28 | |     generation_snapshot,
29 | |     imported_snapshot,
30 | |     snapshot_catalog as snapshot_catalog,
31 | | )
32 | | from tests.discovery_runtime.test_acceptance_properties import (
33 | |     generation,
34 | |     identity,
35 | |     specification,
36 | | )
37 | | from tests.schemas.discovery.v2_schema_test_support import as_object
   | |____________________________________________________________________^
38 |
39 |   if TYPE_CHECKING:
   |
help: Organize imports

TC002 Move third-party import `drm_copilot_discovery.acceptance_models.AcceptanceGeneration` into a type-checking block
  --> tests\discovery_runtime\test_gherkin.py:14:5
   |
12 | from drm_copilot_discovery.acceptance_generation import generate_acceptance
13 | from drm_copilot_discovery.acceptance_models import (
14 |     AcceptanceGeneration,
   |     ^^^^^^^^^^^^^^^^^^^^
15 |     AcceptanceSpecification,
16 | )
   |
help: Move into type-checking block

TC002 Move third-party import `drm_copilot_discovery.acceptance_models.AcceptanceSpecification` into a type-checking block
  --> tests\discovery_runtime\test_gherkin.py:15:5
   |
13 | from drm_copilot_discovery.acceptance_models import (
14 |     AcceptanceGeneration,
15 |     AcceptanceSpecification,
   |     ^^^^^^^^^^^^^^^^^^^^^^^
16 | )
17 | from drm_copilot_discovery.findings import Finding
   |
help: Move into type-checking block

E501 Line too long (96 > 88)
   --> tests\discovery_runtime\test_gherkin.py:246:89
    |
244 |     fields: dict[str, object],
245 | ) -> None:
246 |     """Reject fields (malformed steps/state) without inventing a fallback; expect ValueError."""
    |                                                                                         ^^^^^^^^
247 |     item = changed(specification(), **fields)
248 |     result = generation(
    |

B010 [*] Do not call `setattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\discovery_runtime\test_gherkin.py:269:9
    |
267 |     assert AcceptanceRenderBundle(files=()).files == ()
268 |     with pytest.raises(FrozenInstanceError):
269 |         setattr(alpha, "path", "changed")
    |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
270 |     with pytest.raises(ValueError, match="UTF-8"):
271 |         AcceptanceRenderedFile(path="a", content=b"\xff")
    |
help: Replace `setattr` with assignment

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_gherkin.py:302:89
    |
301 | def test_exact_aggregate_bytes_include_paths_and_all_files() -> None:
302 |     """Check exact ASCII bundle capacity and one-byte shortage, without partial output."""
    |                                                                                         ^^
303 |     item = specification()
304 |     original = generation((item,), (item,))
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\test_gherkin.py:323:89
    |
321 |     kind: str,
322 | ) -> None:
323 |     """Count serialization under kind (bytes/work) shortage; expect early ReportLimitError.
    |                                                                                         ^^^
324 |
325 |     monkeypatch replaces only the encoder after fixture construction. No I/O or
    |

E501 Line too long (93 > 88)
   --> tests\discovery_runtime\test_gherkin.py:353:89
    |
351 |     monkeypatch: pytest.MonkeyPatch,
352 | ) -> None:
353 |     """Lower literal hard ceilings via monkeypatch; assert file/count/aggregate rejection."""
    |                                                                                         ^^^^^
354 |     item = AcceptanceRenderedFile(path="a", content=b"1234")
355 |     monkeypatch.setattr(gherkin, "_MAX_BYTES", 4)
    |

Found 14 errors.
[*] 3 fixable with the `--fix` option (2 hidden fixes can be enabled with the `--unsafe-fixes` option).

```
