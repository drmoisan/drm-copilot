# p3t8-focused-lint

Timestamp: 2026-10-19T01-05
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/source_read_models.py packages/discovery-runtime/src/drm_copilot_discovery/source_reads.py tests/discovery_runtime/test_source_reads.py tests/discovery_runtime/test_source_read_limits.py
EXIT_CODE: 1
Output Summary: FAIL scoped P3-T8 stage 2; duration 1.187 seconds. Exact source hashes are in the paired JSON receipt.

```text
I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\test_source_read_limits.py:3:1
   |
 1 |   """Verify source authority, finite resource axes and immutable value boundaries."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | import json
 6 | | from hashlib import sha256
 7 | | from dataclasses import FrozenInstanceError, replace
 8 | | from typing import TYPE_CHECKING, cast
 9 | |
10 | | import pytest
11 | | from drm_copilot_discovery.path_models import PathPolicyError
12 | | from drm_copilot_discovery.profile_v2 import parse_profile_v2
13 | | from drm_copilot_discovery.repository_reader import RepositoryIdentity
14 | | from drm_copilot_discovery.source_read_models import (
15 | |     ReadCursor,
16 | |     ReadGrant,
17 | |     ReadSelection,
18 | |     SelectedManifest,
19 | |     SourceEvidence,
20 | |     SourceItem,
21 | |     SourceReadLimits,
22 | |     SourceReadRequest,
23 | |     SourceReadResult,
24 | |     SourceSpan,
25 | | )
26 | |
27 | | from tests.discovery_runtime.source_snapshot_test_support import (
28 | |     changed_header,
29 | |     unit_transport,
30 | | )
31 | | from tests.discovery_runtime.test_profile_v2 import profile_document
32 | | from tests.discovery_runtime.test_snapshot_io import MemoryStore
33 | | from tests.discovery_runtime.test_source_reads import (
34 | |     install_transport,
35 | |     make_reader,
36 | | )
37 | | from tests.discovery_runtime.test_source_reads import read_catalog as read_catalog
38 | | from tests.discovery_runtime.test_source_reads import read_profile as read_profile
39 | | from tests.schemas.discovery.v2_schema_test_support import as_object
   | |____________________________________________________________________^
40 |
41 |   if TYPE_CHECKING:
   |
help: Organize imports

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\test_source_read_limits.py:42:5
   |
41 |   if TYPE_CHECKING:
42 | /     from drm_copilot_discovery.path_models import PathKind
43 | |     from drm_copilot_discovery.catalog import SchemaCatalog
44 | |     from drm_copilot_discovery.profile_v2 import ProfileV2
   | |__________________________________________________________^
45 |
46 |   _EVIDENCE = SourceEvidence(
   |
help: Organize imports

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\test_source_reads.py:27:5
   |
26 |   if TYPE_CHECKING:
27 | /     from drm_copilot_discovery.source_read_models import ReadOperation
28 | |     from drm_copilot_discovery.snapshot_io import WorkspaceBytes
29 | |     from drm_copilot_discovery.transport_manifest import TransportRoute
   | |_______________________________________________________________________^
   |
help: Organize imports

Found 3 errors.
[*] 3 fixable with the `--fix` option.
```
