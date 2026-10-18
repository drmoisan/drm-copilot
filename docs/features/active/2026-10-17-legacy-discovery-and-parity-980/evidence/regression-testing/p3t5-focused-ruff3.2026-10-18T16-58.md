# p3t5-focused-ruff3

Timestamp: 2026-10-18T16-58
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py tests/discovery_runtime/test_evidence_linking.py tests/discovery_runtime/test_evidence_payloads.py tests/discovery_runtime/evidence_test_support.py
EXIT_CODE: 1
Output Summary: [1m[96mhelp[0m: [1mOrganize imports[0m; ; Found 2 errors.; [[36m*[0m] 2 fixable with the `--fix` option.

Working directory: .
Started: 2026-10-18T16:58:41.397238+00:00
Duration seconds: 0.768
Phase: P3-T5 evidence registration and linking; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`tests.discovery_runtime.test_references.immutable` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_evidence_linking.py:32:53
   [1m[94m|[0m
[1m[94m30 |[0m     mutation_catalog as mutation_catalog,
[1m[94m31 |[0m )
[1m[94m32 |[0m from tests.discovery_runtime.test_references import immutable
   [1m[94m|[0m                                                     [1m[91m^^^^^^^^^[0m
[1m[94m33 |[0m from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `tests.discovery_runtime.test_references.immutable`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_evidence_payloads.py:3:1
   [1m[94m|[0m
[1m[94m 1 |[0m   """Verify evidence bytes, immutable pins and delegated mutation safety boundaries."""
[1m[94m 2 |[0m
[1m[94m 3 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m 4 |[0m [1m[91m|[0m
[1m[94m 5 |[0m [1m[91m|[0m import json
[1m[94m 6 |[0m [1m[91m|[0m from dataclasses import replace
[1m[94m 7 |[0m [1m[91m|[0m from typing import TYPE_CHECKING, cast
[1m[94m 8 |[0m [1m[91m|[0m
[1m[94m 9 |[0m [1m[91m|[0m import pytest
[1m[94m10 |[0m [1m[91m|[0m from drm_copilot_discovery import evidence_linking
[1m[94m11 |[0m [1m[91m|[0m from drm_copilot_discovery.evidence_linking import (
[1m[94m12 |[0m [1m[91m|[0m     EvidencePayload,
[1m[94m13 |[0m [1m[91m|[0m     evidence_changes,
[1m[94m14 |[0m [1m[91m|[0m     plan_evidence_link,
[1m[94m15 |[0m [1m[91m|[0m )
[1m[94m16 |[0m [1m[91m|[0m from drm_copilot_discovery.models import to_plain_value
[1m[94m17 |[0m [1m[91m|[0m from drm_copilot_discovery.mutation_plan import MutationError
[1m[94m18 |[0m [1m[91m|[0m from drm_copilot_discovery.path_models import PathPolicyError
[1m[94m19 |[0m [1m[91m|[0m from drm_copilot_discovery.profile_v2 import ProfileV2
[1m[94m20 |[0m [1m[91m|[0m from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
[1m[94m21 |[0m [1m[91m|[0m from drm_copilot_discovery.snapshot import SnapshotFile
[1m[94m22 |[0m [1m[91m|[0m
[1m[94m23 |[0m [1m[91m|[0m from tests.discovery_runtime.mutation_test_support import constant, grants_for
[1m[94m24 |[0m [1m[91m|[0m from tests.discovery_runtime.mutation_test_support import (
[1m[94m25 |[0m [1m[91m|[0m     mutation_catalog as mutation_catalog,
[1m[94m26 |[0m [1m[91m|[0m )
[1m[94m27 |[0m [1m[91m|[0m from tests.discovery_runtime.evidence_test_support import CONTENT, request_for
[1m[94m28 |[0m [1m[91m|[0m from tests.discovery_runtime.test_evidence_linking import evidence_plan as evidence_plan
[1m[94m29 |[0m [1m[91m|[0m from tests.discovery_runtime.evidence_test_support import link_baseline as link_baseline
[1m[94m30 |[0m [1m[91m|[0m from tests.discovery_runtime.test_references import immutable
[1m[94m31 |[0m [1m[91m|[0m from tests.schemas.discovery.v2_schema_test_support import as_object
   [1m[94m|[0m [1m[91m|____________________________________________________________________^[0m
[1m[94m32 |[0m
[1m[94m33 |[0m   if TYPE_CHECKING:
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

Found 2 errors.
[[36m*[0m] 2 fixable with the `--fix` option.
```
