# P5-T2 graph ruff

Timestamp: 2026-10-20T07-02

Command: `poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/parity_report.py packages/discovery-runtime/src/drm_copilot_discovery/parity_metrics.py packages/discovery-runtime/src/drm_copilot_discovery/report_models.py tests/discovery_runtime/test_parity_report.py tests/discovery_runtime/test_parity_metrics.py tests/discovery_runtime/test_report_models.py tests/discovery_runtime/test_parity_axes.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 1.176 seconds.

```text
I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\test_parity_axes.py:3:1
   |
 1 |   """Verify authored axis states and bounded mode lookup without granting authority."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | from dataclasses import replace
 6 | | from typing import TYPE_CHECKING
 7 | |
 8 | | import pytest
 9 | | from drm_copilot_discovery.models import to_plain_value
10 | | from drm_copilot_discovery.report_models import ReportBudget, ReportLimitError
11 | |
12 | | from tests.discovery_runtime.parity_test_support import classification
13 | | from tests.discovery_runtime.test_parity_metrics import (
14 | |     axes,
15 | |     cast_rows,
16 | |     report_graph,
17 | |     report_profile as report_profile,
18 | |     summary,
19 | | )
20 | | from tests.discovery_runtime.test_parity_report import assessed_projection
21 | | from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
22 | | from tests.discovery_runtime.test_snapshot_io import (
23 | |     snapshot_catalog as snapshot_catalog,
24 | | )
25 | | from tests.discovery_runtime.validation_test_support import replace_document
26 | | from tests.schemas.discovery.v2_schema_test_support import as_object
   | |____________________________________________________________________^
27 |
28 |   if TYPE_CHECKING:
   |
help: Organize imports

Found 1 error.
[*] 1 fixable with the `--fix` option.
```
