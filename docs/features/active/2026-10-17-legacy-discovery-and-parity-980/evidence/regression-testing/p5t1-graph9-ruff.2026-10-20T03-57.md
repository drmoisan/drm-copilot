# P5-T1 graph9-ruff

Timestamp: 2026-10-20T03-57
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/coverage_report.py packages/discovery-runtime/src/drm_copilot_discovery/coverage_population.py tests/discovery_runtime/test_coverage_report.py tests/discovery_runtime/test_coverage_report_contract.py
EXIT_CODE: 1

Duration seconds: 1.183

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
16 | | from drm_copilot_discovery.models import to_plain_value
17 | | from drm_copilot_discovery.evidence_rules import validate_evidence
18 | | from drm_copilot_discovery.references import index_references
19 | | from drm_copilot_discovery.report_models import ReportLimitError
20 | | from drm_copilot_discovery.snapshot_io import within_roots
21 | | from drm_copilot_discovery.validation import report_input_digest
22 | |
23 | | from tests.discovery_runtime.test_coverage_report import change, summary
24 | | from tests.discovery_runtime.test_coverage_rules import coverage_snapshot, detection
25 | | from tests.discovery_runtime.test_coverage_scope import profile_with
26 | | from tests.discovery_runtime.test_references import artifact, reference
27 | | from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
28 | | from tests.discovery_runtime.test_snapshot_io import (
29 | |     snapshot_catalog as snapshot_catalog,
30 | | )
31 | | from tests.discovery_runtime.validation_test_support import (
32 | |     ROOT,
33 | |     captured,
34 | |     document_record,
35 | |     mode_profile,
36 | |     no_scope_snapshot,
37 | |     replace_document,
38 | | )
39 | | from tests.schemas.discovery.v2_schema_test_support import as_object
   | |____________________________________________________________________^
40 |
41 |   if TYPE_CHECKING:
   |
help: Organize imports

Found 1 error.
[*] 1 fixable with the `--fix` option.

```
