# p3t6-api-ruff-prepare

Timestamp: 2026-10-18T18-03
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/source_snapshots.py tests/discovery_runtime/source_snapshot_test_support.py tests/discovery_runtime/test_snapshot_export.py tests/discovery_runtime/test_snapshot_import.py
EXIT_CODE: 1
Output Summary: [1m[96mhelp[0m: [1mRemove unused import: `tests.discovery_runtime.test_snapshot_io.MemoryStore`[0m; ; Found 14 errors.; [[36m*[0m] 13 fixable with the `--fix` option.

Working directory: .
Started: 2026-10-18T18:03:32.894801+00:00
Duration seconds: 0.832
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`drm_copilot_discovery.snapshot.SnapshotFile` imported but unused[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\source_snapshots.py:26:44
   [1m[94m|[0m
[1m[94m24 |[0m from drm_copilot_discovery.repository_reader import RepositoryIdentity, full_revision
[1m[94m25 |[0m from drm_copilot_discovery.revision_rules import RevisionInputs
[1m[94m26 |[0m from drm_copilot_discovery.snapshot import SnapshotFile, repository_pins
   [1m[94m|[0m                                            [1m[91m^^^^^^^^^^^^[0m
[1m[94m27 |[0m from drm_copilot_discovery.transport_manifest import bind_transport, transport_digest
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `drm_copilot_discovery.snapshot.SnapshotFile`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\source_snapshots.py:377:89
    [1m[94m|[0m
[1m[94m375 |[0m     invocation: InvocationContext | None = None,
[1m[94m376 |[0m ) -> MutationPlan:
[1m[94m377 |[0m     """Validate the complete export graph with exact external grants and root context."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m378 |[0m     proposal = prepare_snapshot_export(baseline, request)
[1m[94m379 |[0m     return plan_mutation(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`typing.cast` imported but unused[0m
 [1m[94m-->[0m tests\discovery_runtime\source_snapshot_test_support.py:7:35
  [1m[94m|[0m
[1m[94m5 |[0m import json
[1m[94m6 |[0m from hashlib import sha256
[1m[94m7 |[0m from typing import TYPE_CHECKING, cast
  [1m[94m|[0m                                   [1m[91m^^^^[0m
[1m[94m8 |[0m
[1m[94m9 |[0m from drm_copilot_discovery.models import ParseLimits, canonical_json
  [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `typing.cast`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\source_snapshot_test_support.py:19:5
   [1m[94m|[0m
[1m[94m18 |[0m   if TYPE_CHECKING:
[1m[94m19 |[0m [1m[91m/[0m     from drm_copilot_discovery.catalog import SchemaCatalog
[1m[94m20 |[0m [1m[91m|[0m     from drm_copilot_discovery.mutation_plan import CapturedWorkspace
[1m[94m21 |[0m [1m[91m|[0m     from drm_copilot_discovery.transport_manifest import TransportRoute
[1m[94m22 |[0m [1m[91m|[0m     from tests.discovery_runtime.test_snapshot_io import MemoryStore
   [1m[94m|[0m [1m[91m|____________________________________________________________________^[0m
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_export.py:3:1
   [1m[94m|[0m
[1m[94m 1 |[0m   """Verify exact transport manifests, immutable export routes and replica identity."""
[1m[94m 2 |[0m
[1m[94m 3 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m 4 |[0m [1m[91m|[0m
[1m[94m 5 |[0m [1m[91m|[0m import json
[1m[94m 6 |[0m [1m[91m|[0m from dataclasses import replace
[1m[94m 7 |[0m [1m[91m|[0m from hashlib import sha256
[1m[94m 8 |[0m [1m[91m|[0m from typing import TYPE_CHECKING, cast
[1m[94m 9 |[0m [1m[91m|[0m
[1m[94m10 |[0m [1m[91m|[0m import pytest
[1m[94m11 |[0m [1m[91m|[0m from drm_copilot_discovery.claim_rules import ClaimContext
[1m[94m12 |[0m [1m[91m|[0m from drm_copilot_discovery.evidence_linking import evidence_changes
[1m[94m13 |[0m [1m[91m|[0m from drm_copilot_discovery.evidence_rules import EvidenceValidation
[1m[94m14 |[0m [1m[91m|[0m from drm_copilot_discovery.models import ParseLimits, canonical_json
[1m[94m15 |[0m [1m[91m|[0m from drm_copilot_discovery.mutation_plan import (
[1m[94m16 |[0m [1m[91m|[0m     MutationChange,
[1m[94m17 |[0m [1m[91m|[0m     MutationError,
[1m[94m18 |[0m [1m[91m|[0m     plan_mutation,
[1m[94m19 |[0m [1m[91m|[0m )
[1m[94m20 |[0m [1m[91m|[0m from drm_copilot_discovery.path_models import PathPolicyError
[1m[94m21 |[0m [1m[91m|[0m from drm_copilot_discovery.path_policy import PathPolicy
[1m[94m22 |[0m [1m[91m|[0m from drm_copilot_discovery.references import index_references
[1m[94m23 |[0m [1m[91m|[0m from drm_copilot_discovery.snapshot import SnapshotFile
[1m[94m24 |[0m [1m[91m|[0m from drm_copilot_discovery.transport_manifest import (
[1m[94m25 |[0m [1m[91m|[0m     bind_transport,
[1m[94m26 |[0m [1m[91m|[0m     replica_aliases,
[1m[94m27 |[0m [1m[91m|[0m     transport_digest,
[1m[94m28 |[0m [1m[91m|[0m )
[1m[94m29 |[0m [1m[91m|[0m
[1m[94m30 |[0m [1m[91m|[0m from tests.discovery_runtime.draft_test_support import add_feature, draft_case
[1m[94m31 |[0m [1m[91m|[0m from tests.discovery_runtime.evidence_test_support import request_for
[1m[94m32 |[0m [1m[91m|[0m from tests.discovery_runtime.mutation_test_support import capture, grants_for
[1m[94m33 |[0m [1m[91m|[0m from tests.discovery_runtime.mutation_test_support import (
[1m[94m34 |[0m [1m[91m|[0m     mutation_catalog as mutation_catalog,
[1m[94m35 |[0m [1m[91m|[0m )
[1m[94m36 |[0m [1m[91m|[0m from tests.discovery_runtime.source_snapshot_test_support import (
[1m[94m37 |[0m [1m[91m|[0m     changed_header, transport_case, unit_transport,
[1m[94m38 |[0m [1m[91m|[0m )
[1m[94m39 |[0m [1m[91m|[0m from tests.discovery_runtime.test_references import immutable
[1m[94m40 |[0m [1m[91m|[0m from tests.discovery_runtime.test_snapshot_io import PROFILE_PATH
[1m[94m41 |[0m [1m[91m|[0m from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture
   [1m[94m|[0m [1m[91m|__________________________________________________________________________________^[0m
[1m[94m42 |[0m
[1m[94m43 |[0m   if TYPE_CHECKING:
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`hashlib.sha256` imported but unused[0m
 [1m[94m-->[0m tests\discovery_runtime\test_snapshot_export.py:7:21
  [1m[94m|[0m
[1m[94m5 |[0m import json
[1m[94m6 |[0m from dataclasses import replace
[1m[94m7 |[0m from hashlib import sha256
  [1m[94m|[0m                     [1m[91m^^^^^^[0m
[1m[94m8 |[0m from typing import TYPE_CHECKING, cast
  [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `hashlib.sha256`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`drm_copilot_discovery.mutation_plan.MutationChange` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_export.py:16:5
   [1m[94m|[0m
[1m[94m14 |[0m from drm_copilot_discovery.models import ParseLimits, canonical_json
[1m[94m15 |[0m from drm_copilot_discovery.mutation_plan import (
[1m[94m16 |[0m     MutationChange,
   [1m[94m|[0m     [1m[91m^^^^^^^^^^^^^^[0m
[1m[94m17 |[0m     MutationError,
[1m[94m18 |[0m     plan_mutation,
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `drm_copilot_discovery.mutation_plan.MutationChange`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`tests.discovery_runtime.draft_test_support.add_feature` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_export.py:30:56
   [1m[94m|[0m
[1m[94m28 |[0m )
[1m[94m29 |[0m
[1m[94m30 |[0m from tests.discovery_runtime.draft_test_support import add_feature, draft_case
   [1m[94m|[0m                                                        [1m[91m^^^^^^^^^^^[0m
[1m[94m31 |[0m from tests.discovery_runtime.evidence_test_support import request_for
[1m[94m32 |[0m from tests.discovery_runtime.mutation_test_support import capture, grants_for
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`tests.discovery_runtime.draft_test_support.draft_case` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_export.py:30:69
   [1m[94m|[0m
[1m[94m28 |[0m )
[1m[94m29 |[0m
[1m[94m30 |[0m from tests.discovery_runtime.draft_test_support import add_feature, draft_case
   [1m[94m|[0m                                                                     [1m[91m^^^^^^^^^^[0m
[1m[94m31 |[0m from tests.discovery_runtime.evidence_test_support import request_for
[1m[94m32 |[0m from tests.discovery_runtime.mutation_test_support import capture, grants_for
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`tests.discovery_runtime.test_snapshot_io.PROFILE_PATH` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_export.py:40:54
   [1m[94m|[0m
[1m[94m38 |[0m )
[1m[94m39 |[0m from tests.discovery_runtime.test_references import immutable
[1m[94m40 |[0m from tests.discovery_runtime.test_snapshot_io import PROFILE_PATH
   [1m[94m|[0m                                                      [1m[91m^^^^^^^^^^^^[0m
[1m[94m41 |[0m from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `tests.discovery_runtime.test_snapshot_io.PROFILE_PATH`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`tests.schemas.discovery.v2_schema_test_support.load_fixture` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_export.py:41:71
   [1m[94m|[0m
[1m[94m39 |[0m from tests.discovery_runtime.test_references import immutable
[1m[94m40 |[0m from tests.discovery_runtime.test_snapshot_io import PROFILE_PATH
[1m[94m41 |[0m from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture
   [1m[94m|[0m                                                                       [1m[91m^^^^^^^^^^^^[0m
[1m[94m42 |[0m
[1m[94m43 |[0m if TYPE_CHECKING:
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `tests.schemas.discovery.v2_schema_test_support.load_fixture`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`drm_copilot_discovery.mutation_plan.CapturedWorkspace` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_export.py:45:53
   [1m[94m|[0m
[1m[94m43 |[0m if TYPE_CHECKING:
[1m[94m44 |[0m     from drm_copilot_discovery.catalog import SchemaCatalog
[1m[94m45 |[0m     from drm_copilot_discovery.mutation_plan import CapturedWorkspace
   [1m[94m|[0m                                                     [1m[91m^^^^^^^^^^^^^^^^^[0m
[1m[94m46 |[0m     from drm_copilot_discovery.transport_manifest import TransportRoute
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `drm_copilot_discovery.mutation_plan.CapturedWorkspace`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`drm_copilot_discovery.transport_manifest.TransportRoute` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_export.py:46:58
   [1m[94m|[0m
[1m[94m44 |[0m     from drm_copilot_discovery.catalog import SchemaCatalog
[1m[94m45 |[0m     from drm_copilot_discovery.mutation_plan import CapturedWorkspace
[1m[94m46 |[0m     from drm_copilot_discovery.transport_manifest import TransportRoute
   [1m[94m|[0m                                                          [1m[91m^^^^^^^^^^^^^^[0m
[1m[94m47 |[0m
[1m[94m48 |[0m     from tests.discovery_runtime.test_snapshot_io import MemoryStore
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `drm_copilot_discovery.transport_manifest.TransportRoute`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`tests.discovery_runtime.test_snapshot_io.MemoryStore` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_export.py:48:58
   [1m[94m|[0m
[1m[94m46 |[0m     from drm_copilot_discovery.transport_manifest import TransportRoute
[1m[94m47 |[0m
[1m[94m48 |[0m     from tests.discovery_runtime.test_snapshot_io import MemoryStore
   [1m[94m|[0m                                                          [1m[91m^^^^^^^^^^^[0m
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `tests.discovery_runtime.test_snapshot_io.MemoryStore`[0m

Found 14 errors.
[[36m*[0m] 13 fixable with the `--fix` option.
```
