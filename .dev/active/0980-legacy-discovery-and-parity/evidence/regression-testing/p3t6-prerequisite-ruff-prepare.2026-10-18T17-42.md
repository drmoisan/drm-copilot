# p3t6-prerequisite-ruff-prepare

Timestamp: 2026-10-18T17-42
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py packages/discovery-runtime/src/drm_copilot_discovery/references.py packages/discovery-runtime/src/drm_copilot_discovery/transport_manifest.py tests/discovery_runtime/test_snapshot_export.py tests/discovery_runtime/test_snapshot_import.py
EXIT_CODE: 1
Output Summary: [1m[96mhelp[0m: [1mOrganize imports[0m; ; Found 4 errors.; [[36m*[0m] 3 fixable with the `--fix` option.

Working directory: .
Started: 2026-10-18T17:42:44.395969+00:00
Duration seconds: 0.917
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`drm_copilot_discovery.path_models.WriteGrant` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_export.py:17:64
   [1m[94m|[0m
[1m[94m15 |[0m     plan_mutation,
[1m[94m16 |[0m )
[1m[94m17 |[0m from drm_copilot_discovery.path_models import PathPolicyError, WriteGrant
   [1m[94m|[0m                                                                [1m[91m^^^^^^^^^^[0m
[1m[94m18 |[0m from drm_copilot_discovery.path_policy import PathPolicy
[1m[94m19 |[0m from drm_copilot_discovery.references import index_references
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `drm_copilot_discovery.path_models.WriteGrant`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_export.py:37:5
   [1m[94m|[0m
[1m[94m36 |[0m   if TYPE_CHECKING:
[1m[94m37 |[0m [1m[91m/[0m     from drm_copilot_discovery.catalog import SchemaCatalog
[1m[94m38 |[0m [1m[91m|[0m     from drm_copilot_discovery.mutation_plan import CapturedWorkspace
[1m[94m39 |[0m [1m[91m|[0m     from drm_copilot_discovery.transport_manifest import TransportRoute
[1m[94m40 |[0m [1m[91m|[0m     from tests.discovery_runtime.test_snapshot_io import MemoryStore
   [1m[94m|[0m [1m[91m|____________________________________________________________________^[0m
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_snapshot_export.py:226:89
    [1m[94m|[0m
[1m[94m224 |[0m     fault: str, mutation_catalog: SchemaCatalog
[1m[94m225 |[0m ) -> None:
[1m[94m226 |[0m     """The route cannot widen through aliases, conflicting identities or huge members."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m227 |[0m     route = unit_transport(mutation_catalog)
[1m[94m228 |[0m     document = as_object(json.loads(route.manifest.content))
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_import.py:31:5
   [1m[94m|[0m
[1m[94m30 |[0m   if TYPE_CHECKING:
[1m[94m31 |[0m [1m[91m/[0m     from contextlib import AbstractContextManager
[1m[94m32 |[0m [1m[91m|[0m     from drm_copilot_discovery.agent_output import InvocationContext
[1m[94m33 |[0m [1m[91m|[0m     from drm_copilot_discovery.catalog import SchemaCatalog
[1m[94m34 |[0m [1m[91m|[0m     from drm_copilot_discovery.mutation_plan import CapturedWorkspace
[1m[94m35 |[0m [1m[91m|[0m     from drm_copilot_discovery.path_models import ResolvedPath, WriteGrant
[1m[94m36 |[0m [1m[91m|[0m     from drm_copilot_discovery.transport_manifest import TransportRoute
   [1m[94m|[0m [1m[91m|_______________________________________________________________________^[0m
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

Found 4 errors.
[[36m*[0m] 3 fixable with the `--fix` option.
```
