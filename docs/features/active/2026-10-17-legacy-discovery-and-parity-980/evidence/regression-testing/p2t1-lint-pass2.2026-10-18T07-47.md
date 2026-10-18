# p2t1-lint-pass2

Timestamp: 2026-10-18T07-47
Command: poetry run ruff check --fix packages/discovery-runtime/src/drm_copilot_discovery/snapshot.py packages/discovery-runtime/src/drm_copilot_discovery/snapshot_io.py packages/discovery-runtime/src/drm_copilot_discovery/repository_reader.py packages/discovery-runtime/src/drm_copilot_discovery/snapshot_loading.py tests/discovery_runtime/test_snapshot.py tests/discovery_runtime/test_snapshot_io.py tests/discovery_runtime/test_repository_reader.py tests/discovery_runtime/test_snapshot_loading.py tests/discovery_runtime/test_snapshot_imports.py
EXIT_CODE: 1
Output Summary:     1 × [1;31mF401[0m (unused-import); ; Found 19 errors (6 fixed, 13 remaining).; No fixes available (1 hidden fix can be enabled with the `--unsafe-fixes` option).

Working directory: .
Started: 2026-10-18T07:47:55.254981+00:00
Duration seconds: 0.783
Phase: P2-T1 immutable snapshots and injected read boundaries; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\snapshot_loading.py:365:89
    [1m[94m|[0m
[1m[94m363 |[0m                 )
[1m[94m364 |[0m             ):
[1m[94m365 |[0m                 # A referenced JSON/YAML payload is opaque unless it claims an artifact role.
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m366 |[0m                 del (
[1m[94m367 |[0m                     self.expected[path],
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot.py:84:89
   [1m[94m|[0m
[1m[94m82 |[0m     None
[1m[94m83 |[0m ):
[1m[94m84 |[0m     """A sorted manifest cannot hide duplicate, aliased or both-present-and-missing paths."""
   [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m85 |[0m     file = SnapshotFile(path="src/a", content=b"", category="source")
[1m[94m86 |[0m     with pytest.raises(PathPolicyError, match="PATH_COLLISION"):
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_snapshot.py:116:89
    [1m[94m|[0m
[1m[94m114 |[0m     snapshot_catalog: SchemaCatalog, snapshot_profile: ProfileV2
[1m[94m115 |[0m ) -> None:
[1m[94m116 |[0m     """Caller collection mutation cannot change captured files or transported identity."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m117 |[0m     file = SnapshotFile(path="docs/import/a.json", content=b"{}", category="artifact")
[1m[94m118 |[0m     identity = RepositoryIdentity(id="source", revision="a" * 40)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_imports.py:73:89
   [1m[94m|[0m
[1m[94m71 |[0m     path: str, snapshot_catalog: SchemaCatalog
[1m[94m72 |[0m ) -> None:
[1m[94m73 |[0m     """General readable source scope does not grant the stricter extension-schema read."""
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m74 |[0m     store, document = memory_workspace()
[1m[94m75 |[0m     document["extension_schemas"] = {
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_imports.py:90:89
   [1m[94m|[0m
[1m[94m88 |[0m     snapshot_catalog: SchemaCatalog,
[1m[94m89 |[0m ) -> None:
[1m[94m90 |[0m     """Extension pin mismatch cannot fall back to an unpinned or caller-supplied schema."""
   [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m91 |[0m     document, pinned = profile_extension_catalog()
[1m[94m92 |[0m     store = MemoryStore()
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_snapshot_imports.py:139:89
    [1m[94m|[0m
[1m[94m137 |[0m     snapshot_catalog: SchemaCatalog,
[1m[94m138 |[0m ) -> None:
[1m[94m139 |[0m     """Imported identities and origin paths survive without reading the source checkout."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m140 |[0m     store, document = memory_workspace()
[1m[94m141 |[0m     parent = "docs/migration/discovery/source-snapshots/imported"
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_io.py:79:89
   [1m[94m|[0m
[1m[94m77 |[0m     None
[1m[94m78 |[0m ):
[1m[94m79 |[0m     """Repeat captures return original bytes; freshness compares rather than replaces."""
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m80 |[0m     store = MemoryStore()
[1m[94m81 |[0m     store.put("src/a.py", b"exact\r\nbytes")
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mMove third-party import `drm_copilot_discovery.path_models.PathMetadata` into a type-checking block[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_loading.py:11:47
   [1m[94m|[0m
[1m[94m10 |[0m import pytest
[1m[94m11 |[0m from drm_copilot_discovery.path_models import PathMetadata
   [1m[94m|[0m                                               [1m[91m^^^^^^^^^^^^[0m
[1m[94m12 |[0m from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
[1m[94m13 |[0m from drm_copilot_discovery.snapshot_io import SnapshotIO
   [1m[94m|[0m
[1m[96mhelp[0m: [1mMove into type-checking block[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_loading.py:77:89
   [1m[94m|[0m
[1m[94m75 |[0m     snapshot_catalog: SchemaCatalog,
[1m[94m76 |[0m ) -> None:
[1m[94m77 |[0m     """All configured input categories retain exact bytes without rereading for hashes."""
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m78 |[0m     store, document = memory_workspace()
[1m[94m79 |[0m     store.put("src/a.py", b"new\r\n")
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_snapshot_loading.py:117:89
    [1m[94m|[0m
[1m[94m115 |[0m     extension: str, snapshot_catalog: SchemaCatalog
[1m[94m116 |[0m ) -> None:
[1m[94m117 |[0m     """A valid newly captured runtime payload is absent from the application's commit."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m118 |[0m     store, _ = memory_workspace()
[1m[94m119 |[0m     path = f"docs/migration/discovery/evidence/capture.{extension}"
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (95 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_snapshot_loading.py:258:89
    [1m[94m|[0m
[1m[94m256 |[0m     snapshot_catalog: SchemaCatalog,
[1m[94m257 |[0m ) -> None:
[1m[94m258 |[0m     """Recognized derived views remain inputs; authored ready fields are not evaluated here."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^[0m
[1m[94m259 |[0m     store, document = memory_workspace()
[1m[94m260 |[0m     roots = as_object(document["artifacts"])
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_snapshot_loading.py:276:89
    [1m[94m|[0m
[1m[94m274 |[0m     snapshot_catalog: SchemaCatalog,
[1m[94m275 |[0m ) -> None:
[1m[94m276 |[0m     """Source exclusions do not hide an unknown artifact even when the pattern matches."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m277 |[0m     store, document = memory_workspace()
[1m[94m278 |[0m     document["excluded_paths"] = [
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_snapshot_loading.py:297:89
    [1m[94m|[0m
[1m[94m295 |[0m     snapshot_catalog: SchemaCatalog,
[1m[94m296 |[0m ) -> None:
[1m[94m297 |[0m     """Historical immutable source bytes and current selected source bytes stay distinct."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m298 |[0m     store, _ = memory_workspace()
[1m[94m299 |[0m     store.put("src/a.py", b"working tree")
    [1m[94m|[0m


[1;32mFixed 6 errors:[0m
[36m-[0m [1mpackages\discovery-runtime\src\drm_copilot_discovery\snapshot_io.py[0m[36m:[0m
    1 × [1;31mI001[0m (unsorted-imports)
[36m-[0m [1mpackages\discovery-runtime\src\drm_copilot_discovery\snapshot_loading.py[0m[36m:[0m
    2 × [1;31mI001[0m (unsorted-imports)
[36m-[0m [1mtests\discovery_runtime\test_repository_reader.py[0m[36m:[0m
    1 × [1;31mB010[0m (set-attr-with-constant)
[36m-[0m [1mtests\discovery_runtime\test_snapshot.py[0m[36m:[0m
    1 × [1;31mB010[0m (set-attr-with-constant)
[36m-[0m [1mtests\discovery_runtime\test_snapshot_imports.py[0m[36m:[0m
    1 × [1;31mF401[0m (unused-import)

Found 19 errors (6 fixed, 13 remaining).
No fixes available (1 hidden fix can be enabled with the `--unsafe-fixes` option).
```
