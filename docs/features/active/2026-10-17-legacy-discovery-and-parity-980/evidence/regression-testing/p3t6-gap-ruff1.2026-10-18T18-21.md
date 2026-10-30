# p3t6-gap-ruff1

Timestamp: 2026-10-18T18-21
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/source_snapshots.py tests/discovery_runtime/test_snapshot_export.py tests/discovery_runtime/test_snapshot_import.py tests/discovery_runtime/source_snapshot_test_support.py
EXIT_CODE: 1
Output Summary:     [1m[94m|[0m; ; Found 2 errors.; [[36m*[0m] 1 fixable with the `--fix` option.

Working directory: .
Started: 2026-10-18T18:21:52.542080+00:00
Duration seconds: 0.859
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_import.py:3:1
   [1m[94m|[0m
[1m[94m 1 |[0m   """Keep transport mutation forwarding and guarded validation isolated in memory."""
[1m[94m 2 |[0m
[1m[94m 3 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m 4 |[0m [1m[91m|[0m
[1m[94m 5 |[0m [1m[91m|[0m import json
[1m[94m 6 |[0m [1m[91m|[0m from dataclasses import replace
[1m[94m 7 |[0m [1m[91m|[0m from typing import TYPE_CHECKING, cast
[1m[94m 8 |[0m [1m[91m|[0m
[1m[94m 9 |[0m [1m[91m|[0m import pytest
[1m[94m10 |[0m [1m[91m|[0m from drm_copilot_discovery import mutation_io, source_snapshots
[1m[94m11 |[0m [1m[91m|[0m from drm_copilot_discovery.models import ParseLimits, to_plain_value
[1m[94m12 |[0m [1m[91m|[0m from drm_copilot_discovery.mutation_io import (
[1m[94m13 |[0m [1m[91m|[0m     GuardedMutationWriter,
[1m[94m14 |[0m [1m[91m|[0m     MutationResult,
[1m[94m15 |[0m [1m[91m|[0m     commit_mutation,
[1m[94m16 |[0m [1m[91m|[0m )
[1m[94m17 |[0m [1m[91m|[0m from drm_copilot_discovery.mutation_plan import (
[1m[94m18 |[0m [1m[91m|[0m     MutationChange,
[1m[94m19 |[0m [1m[91m|[0m     MutationError,
[1m[94m20 |[0m [1m[91m|[0m     MutationPlan,
[1m[94m21 |[0m [1m[91m|[0m     PlannedWrite,
[1m[94m22 |[0m [1m[91m|[0m     plan_mutation,
[1m[94m23 |[0m [1m[91m|[0m )
[1m[94m24 |[0m [1m[91m|[0m from drm_copilot_discovery.snapshot import SnapshotFile
[1m[94m25 |[0m [1m[91m|[0m from drm_copilot_discovery.source_snapshots import prepare_snapshot_import
[1m[94m26 |[0m [1m[91m|[0m from drm_copilot_discovery.transport_manifest import transport_digest
[1m[94m27 |[0m [1m[91m|[0m
[1m[94m28 |[0m [1m[91m|[0m from tests.discovery_runtime.mutation_test_support import grants_for
[1m[94m29 |[0m [1m[91m|[0m from tests.discovery_runtime.mutation_test_support import (
[1m[94m30 |[0m [1m[91m|[0m     mutation_catalog as mutation_catalog,
[1m[94m31 |[0m [1m[91m|[0m )
[1m[94m32 |[0m [1m[91m|[0m from tests.discovery_runtime.source_snapshot_test_support import (
[1m[94m33 |[0m [1m[91m|[0m     RecordingPrimitives,
[1m[94m34 |[0m [1m[91m|[0m     export_request,
[1m[94m35 |[0m [1m[91m|[0m     import_case,
[1m[94m36 |[0m [1m[91m|[0m     isolated_plan,
[1m[94m37 |[0m [1m[91m|[0m     retained_fault,
[1m[94m38 |[0m [1m[91m|[0m     with_files,
[1m[94m39 |[0m [1m[91m|[0m )
[1m[94m40 |[0m [1m[91m|[0m from tests.discovery_runtime.source_snapshot_test_support import (
[1m[94m41 |[0m [1m[91m|[0m     retained_target as retained_target,
[1m[94m42 |[0m [1m[91m|[0m     source_capture as source_capture,
[1m[94m43 |[0m [1m[91m|[0m )
[1m[94m44 |[0m [1m[91m|[0m from tests.discovery_runtime.source_snapshot_test_support import (
[1m[94m45 |[0m [1m[91m|[0m     target_capture as target_capture,
[1m[94m46 |[0m [1m[91m|[0m )
[1m[94m47 |[0m [1m[91m|[0m from tests.schemas.discovery.v2_schema_test_support import as_object
   [1m[94m|[0m [1m[91m|____________________________________________________________________^[0m
[1m[94m48 |[0m
[1m[94m49 |[0m   if TYPE_CHECKING:
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_snapshot_import.py:459:89
    [1m[94m|[0m
[1m[94m457 |[0m     fault: str | None,
[1m[94m458 |[0m ) -> None:
[1m[94m459 |[0m     """A repeat retains original verification bytes; conflicting identities cannot win."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m460 |[0m     baseline, request = retained_target
[1m[94m461 |[0m     if fault:
    [1m[94m|[0m

Found 2 errors.
[[36m*[0m] 1 fixable with the `--fix` option.
```
