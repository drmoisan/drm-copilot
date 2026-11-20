# P5-T1 report-boundary2-lint

Timestamp: 2026-10-20T04-50

Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/coverage_scope_rules.py tests/discovery_runtime/test_coverage_report_contract.py

EXIT_CODE: 1

Output Summary: The exact completed command result is retained below; no inferred completion is claimed.

Duration seconds: 1.205

```text
I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\test_coverage_report_contract.py:3:1
   |
 1 |   """Verify public coverage-report rendering and authority boundaries in memory."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | import json
 6 | | from dataclasses import replace
 7 | | from typing import TYPE_CHECKING, cast
 8 | |
 9 | | import pytest
10 | | from drm_copilot_discovery.claim_rules import validate_claims
11 | | from drm_copilot_discovery.coverage_population import CoveragePopulation
12 | | from drm_copilot_discovery.coverage_report import (
13 | |     build_coverage_report,
14 | |     coverage_preflight,
15 | | )
16 | | from drm_copilot_discovery.evidence_rules import validate_evidence
17 | | from drm_copilot_discovery.models import to_plain_value
18 | | from drm_copilot_discovery.references import index_references
19 | | from drm_copilot_discovery.report_models import ReportLimitError
20 | | from drm_copilot_discovery.snapshot import SnapshotFile
21 | | from drm_copilot_discovery.snapshot_io import within_roots
22 | | from drm_copilot_discovery.snapshot_loading import load_snapshot
23 | | from drm_copilot_discovery.validation import report_input_digest
24 | |
25 | | from tests.discovery_runtime.test_coverage_report import change, summary
26 | | from tests.discovery_runtime.test_coverage_rules import (
27 | |     codes,
28 | |     coverage_snapshot,
29 | |     detection,
30 | | )
31 | | from tests.discovery_runtime.test_coverage_scope import profile_with
32 | | from tests.discovery_runtime.test_references import artifact, reference
33 | | from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
34 | | from tests.discovery_runtime.test_snapshot_io import (
35 | |     MemoryStore,
36 | |     snapshot_catalog as snapshot_catalog,
37 | | )
38 | | from tests.discovery_runtime.validation_test_support import (
39 | |     ROOT,
40 | |     captured,
41 | |     document_record,
42 | |     mode_profile,
43 | |     no_scope_snapshot,
44 | |     replace_document,
45 | | )
46 | | from tests.schemas.discovery.v2_schema_test_support import as_object
   | |____________________________________________________________________^
47 |
48 |   if TYPE_CHECKING:
   |
help: Organize imports

E501 Line too long (93 > 88)
   --> tests\discovery_runtime\test_coverage_report_contract.py:300:89
    |
298 |     snapshot_catalog: SchemaCatalog, folder: str, nested: str
299 | ) -> None:
300 |     """Configured output views stay out of scope while authored documents remain required."""
    |                                                                                         ^^^^^
301 |     profile = mode_profile(snapshot_catalog)
302 |     roots = as_object(to_plain_value(profile.document["artifacts"]))
    |

Found 2 errors.
[*] 1 fixable with the `--fix` option.

```
