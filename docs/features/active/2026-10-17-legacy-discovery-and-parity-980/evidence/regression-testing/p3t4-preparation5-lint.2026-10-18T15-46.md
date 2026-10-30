# p3t4-preparation5-lint

Timestamp: 2026-10-18T15-46
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py tests/discovery_runtime/test_draft_contracts.py tests/discovery_runtime/test_draft_scenarios.py tests/discovery_runtime/draft_test_support.py
EXIT_CODE: 1
Output Summary: [1m[96mhelp[0m: [1mOrganize imports[0m; ; Found 1 error.; [[36m*[0m] 1 fixable with the `--fix` option.

Working directory: .
Started: 2026-10-18T15:46:48.457610+00:00
Duration seconds: 0.850
Phase: P3-T4 contract and scenario drafting; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_draft_scenarios.py:3:1
   [1m[94m|[0m
[1m[94m 1 |[0m   """Verify unexecuted scenario proposals and linked uncertainty entirely in memory."""
[1m[94m 2 |[0m
[1m[94m 3 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m 4 |[0m [1m[91m|[0m
[1m[94m 5 |[0m [1m[91m|[0m import json
[1m[94m 6 |[0m [1m[91m|[0m from dataclasses import replace
[1m[94m 7 |[0m [1m[91m|[0m from typing import TYPE_CHECKING, cast
[1m[94m 8 |[0m [1m[91m|[0m
[1m[94m 9 |[0m [1m[91m|[0m import pytest
[1m[94m10 |[0m [1m[91m|[0m from drm_copilot_discovery.draft_scenarios import (
[1m[94m11 |[0m [1m[91m|[0m     ScenarioDraft,
[1m[94m12 |[0m [1m[91m|[0m     create_scenario,
[1m[94m13 |[0m [1m[91m|[0m     plan_scenario,
[1m[94m14 |[0m [1m[91m|[0m     scenario_changes,
[1m[94m15 |[0m [1m[91m|[0m )
[1m[94m16 |[0m [1m[91m|[0m from drm_copilot_discovery.models import JsonObject
[1m[94m17 |[0m [1m[91m|[0m from drm_copilot_discovery.mutation_plan import MutationError
[1m[94m18 |[0m [1m[91m|[0m from drm_copilot_discovery.schema_validation import validate_document
[1m[94m19 |[0m [1m[91m|[0m
[1m[94m20 |[0m [1m[91m|[0m from tests.discovery_runtime.mutation_test_support import capture, grants_for
[1m[94m21 |[0m [1m[91m|[0m from tests.discovery_runtime.mutation_test_support import (
[1m[94m22 |[0m [1m[91m|[0m     mutation_catalog as mutation_catalog,
[1m[94m23 |[0m [1m[91m|[0m )
[1m[94m24 |[0m [1m[91m|[0m from tests.discovery_runtime.draft_test_support import add_feature, draft_case
[1m[94m25 |[0m [1m[91m|[0m from tests.discovery_runtime.test_mutation_commit import MemoryWriter
[1m[94m26 |[0m [1m[91m|[0m from tests.discovery_runtime.test_references import immutable
[1m[94m27 |[0m [1m[91m|[0m from tests.schemas.discovery.v2_schema_test_support import as_object
   [1m[94m|[0m [1m[91m|____________________________________________________________________^[0m
[1m[94m28 |[0m
[1m[94m29 |[0m   if TYPE_CHECKING:
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

Found 1 error.
[[36m*[0m] 1 fixable with the `--fix` option.
```
