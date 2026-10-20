# p5t2-projection-draft2-lint

Timestamp: 2026-10-20T05-52
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/validation.py tests/discovery_runtime/test_parity_report_projection.py tests/discovery_runtime/test_validation_modes.py
EXIT_CODE: 1
Output Summary: lint, 1.622s; exact raw streams separately bound.

```text
S101 Use of `assert` detected
   --> packages\discovery-runtime\src\drm_copilot_discovery\validation.py:315:17
    |
313 |                 )
314 |             else:
315 |                 assert (
    |                 ^^^^^^
316 |                     self.complete_parity is not None
317 |                     and self._complete_source is not None
    |

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\test_parity_report_projection.py:3:1
   |
 1 |   """Check parity report composition, recomputation and authority entirely in memory."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | from dataclasses import replace
 6 | | from functools import partial
 7 | | from typing import TYPE_CHECKING, cast
 8 | |
 9 | | import pytest
10 | | from drm_copilot_discovery import validation
11 | | from drm_copilot_discovery.findings import Finding
12 | | from drm_copilot_discovery.models import to_plain_value
13 | | from drm_copilot_discovery.parity_report import build_parity_report
14 | | from drm_copilot_discovery.report_models import ReportLimitError
15 | | from drm_copilot_discovery.validation import (
16 | |     report_input_digest,
17 | |     report_projection,
18 | |     validate_snapshot,
19 | | )
20 | |
21 | | from tests.discovery_runtime.test_snapshot_io import (
22 | |     snapshot_catalog as snapshot_catalog,
23 | | )
24 | | from tests.discovery_runtime.test_coverage_scope import profile_with
25 | | from tests.discovery_runtime.validation_test_support import (
26 | |     ROOT,
27 | |     captured,
28 | |     document_record,
29 | |     mode_profile,
30 | |     no_scope_snapshot,
31 | |     output_context,
32 | |     replace_document,
33 | | )
34 | | from tests.schemas.discovery.v2_schema_test_support import as_object
   | |____________________________________________________________________^
35 |
36 |   if TYPE_CHECKING:
   |
help: Organize imports

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_parity_report_projection.py:141:89
    |
139 |     snapshot_catalog: SchemaCatalog, field: str
140 | ) -> None:
141 |     """For field (str), reject forged output despite an otherwise exact role manifest."""
    |                                                                                         ^
142 |     baseline = no_scope_snapshot(snapshot_catalog)
143 |     report = build_parity_report(baseline).to_dict()
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_parity_report_projection.py:198:89
    |
196 |         name: str, target: Callable[..., object], *args: object, **kwargs: object
197 |     ) -> object:
198 |         """Forward args/kwargs to target, counting complete name calls; return object."""
    |                                                                                         ^
199 |         if name == "parity_summary":
200 |             carriers.append(kwargs["parity"])
    |

Found 4 errors.
[*] 1 fixable with the `--fix` option.
```
