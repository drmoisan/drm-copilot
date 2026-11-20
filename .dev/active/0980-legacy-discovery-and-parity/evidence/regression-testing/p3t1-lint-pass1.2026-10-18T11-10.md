# p3t1-lint-pass1

Timestamp: 2026-10-18T11-10
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py tests/discovery_runtime/test_mutation_plan.py tests/discovery_runtime/test_mutation_commit.py
EXIT_CODE: 1
Output Summary: [1m[96mhelp[0m: [1mReplace `setattr` with assignment[0m; ; Found 16 errors.; [[36m*[0m] 5 fixable with the `--fix` option.

Working directory: .
Started: 2026-10-18T11:10:07.594240+00:00
Duration seconds: 0.812
Phase: P3-T1 planned mutations and guarded commits; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_io.py:106:89
    [1m[94m|[0m
[1m[94m104 |[0m @dataclass(frozen=True, kw_only=True)
[1m[94m105 |[0m class MutationArtifact:
[1m[94m106 |[0m     """Report one exact output and its observed operation disposition, never authority."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m107 |[0m
[1m[94m108 |[0m     path: str
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_io.py:284:89
    [1m[94m|[0m
[1m[94m282 |[0m         )
[1m[94m283 |[0m     except (OSError, ValueError) as error:
[1m[94m284 |[0m         # Stale state invalidates old authority too; a failed revocation remains visible.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m285 |[0m         if not dry_run and not revoked:
[1m[94m286 |[0m             try:
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (110 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_io.py:311:89
    [1m[94m|[0m
[1m[94m309 |[0m             code="MUTATION_FAILED",
[1m[94m310 |[0m             message=str(error),
[1m[94m311 |[0m             next_action="Reload all inputs, inspect partial/uncertain paths, and revalidate before retrying.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^^^^^^^^^^^[0m
[1m[94m312 |[0m         )
[1m[94m313 |[0m         return MutationResult(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_mutation_commit.py:26:5
   [1m[94m|[0m
[1m[94m25 |[0m   if TYPE_CHECKING:
[1m[94m26 |[0m [1m[91m/[0m     from collections.abc import Callable
[1m[94m27 |[0m [1m[91m|[0m
[1m[94m28 |[0m [1m[91m|[0m     from drm_copilot_discovery.catalog import SchemaCatalog
[1m[94m29 |[0m [1m[91m|[0m     from drm_copilot_discovery.mutation_plan import CapturedWorkspace, PlannedWrite
[1m[94m30 |[0m [1m[91m|[0m     from tests.discovery_runtime.test_snapshot_io import MemoryStore
   [1m[94m|[0m [1m[91m|____________________________________________________________________^[0m
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_commit.py:198:89
    [1m[94m|[0m
[1m[94m196 |[0m     mutation_catalog: SchemaCatalog,
[1m[94m197 |[0m ) -> None:
[1m[94m198 |[0m     """A concurrently created destination is preserved when the atomic guard rejects it."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m199 |[0m     store, baseline = mutation_case(mutation_catalog)
[1m[94m200 |[0m     change = collection_change(baseline)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_commit.py:215:89
    [1m[94m|[0m
[1m[94m213 |[0m     after: bool, mutation_catalog: SchemaCatalog
[1m[94m214 |[0m ) -> None:
[1m[94m215 |[0m     """Earlier successful writes and the failed attempt remain explicit without rollback."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m216 |[0m     store, baseline = mutation_case(mutation_catalog)
[1m[94m217 |[0m     changes = (collection_change(baseline), collection_change(baseline, decisions=True))
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_commit.py:234:89
    [1m[94m|[0m
[1m[94m232 |[0m     effect: str, mutation_catalog: SchemaCatalog
[1m[94m233 |[0m ) -> None:
[1m[94m234 |[0m     """Postchecks detect both changed unrelated content and same-byte identity changes."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m235 |[0m     store, _ = mutation_case(mutation_catalog)
[1m[94m236 |[0m     store.put("src/a.py", b"original")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_commit.py:261:89
    [1m[94m|[0m
[1m[94m259 |[0m     mutation_catalog: SchemaCatalog,
[1m[94m260 |[0m ) -> None:
[1m[94m261 |[0m     """A protected-store failure is explicit and cannot leave an apparently revoked state."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m262 |[0m     store, baseline = mutation_case(mutation_catalog)
[1m[94m263 |[0m     change = collection_change(baseline)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_commit.py:278:89
    [1m[94m|[0m
[1m[94m276 |[0m     mutation_catalog: SchemaCatalog,
[1m[94m277 |[0m ) -> None:
[1m[94m278 |[0m     """Internal immutable plan values are reconstructed instead of trusting success fields."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m279 |[0m     store, baseline = mutation_case(mutation_catalog)
[1m[94m280 |[0m     change = collection_change(baseline)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`drm_copilot_discovery.models.canonical_json` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_mutation_plan.py:13:42
   [1m[94m|[0m
[1m[94m11 |[0m from drm_copilot_discovery.agent_output import required_output_digest
[1m[94m12 |[0m from drm_copilot_discovery.catalog import load_catalog
[1m[94m13 |[0m from drm_copilot_discovery.models import canonical_json, to_plain_value
   [1m[94m|[0m                                          [1m[91m^^^^^^^^^^^^^^[0m
[1m[94m14 |[0m from drm_copilot_discovery.mutation_io import capture_workspace
[1m[94m15 |[0m from drm_copilot_discovery.mutation_plan import (
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `drm_copilot_discovery.models.canonical_json`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_mutation_plan.py:30:5
   [1m[94m|[0m
[1m[94m29 |[0m   if TYPE_CHECKING:
[1m[94m30 |[0m [1m[91m/[0m     from drm_copilot_discovery.agent_output import InvocationContext
[1m[94m31 |[0m [1m[91m|[0m     from drm_copilot_discovery.catalog import SchemaCatalog
[1m[94m32 |[0m [1m[91m|[0m     from drm_copilot_discovery.mutation_plan import MutationPlan
[1m[94m33 |[0m [1m[91m|[0m     from tests.discovery_runtime.test_snapshot_io import MemoryStore
   [1m[94m|[0m [1m[91m|____________________________________________________________________^[0m
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`drm_copilot_discovery.mutation_plan.MutationPlan` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_mutation_plan.py:32:53
   [1m[94m|[0m
[1m[94m30 |[0m     from drm_copilot_discovery.agent_output import InvocationContext
[1m[94m31 |[0m     from drm_copilot_discovery.catalog import SchemaCatalog
[1m[94m32 |[0m     from drm_copilot_discovery.mutation_plan import MutationPlan
   [1m[94m|[0m                                                     [1m[91m^^^^^^^^^^^^[0m
[1m[94m33 |[0m     from tests.discovery_runtime.test_snapshot_io import MemoryStore
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `drm_copilot_discovery.mutation_plan.MutationPlan`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_plan.py:159:89
    [1m[94m|[0m
[1m[94m157 |[0m     mutation_catalog: SchemaCatalog,
[1m[94m158 |[0m ) -> None:
[1m[94m159 |[0m     """Every proposal/grant order yields the same canonical plan and prospective hash."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m160 |[0m     _, baseline = mutation_case(mutation_catalog)
[1m[94m161 |[0m     changes = (collection_change(baseline), collection_change(baseline, decisions=True))
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_plan.py:179:89
    [1m[94m|[0m
[1m[94m177 |[0m     error: str, mutation_catalog: SchemaCatalog
[1m[94m178 |[0m ) -> None:
[1m[94m179 |[0m     """Invalid requested bytes/identity/preconditions cannot validate the old document."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m180 |[0m     store, initial = mutation_case(mutation_catalog)
[1m[94m181 |[0m     first = collection_change(initial)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_plan.py:235:89
    [1m[94m|[0m
[1m[94m233 |[0m     role: str, mutation_catalog: SchemaCatalog
[1m[94m234 |[0m ) -> None:
[1m[94m235 |[0m     """Selected draft questions are allowed only through an exact role output manifest."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m236 |[0m     _, baseline = mutation_case(mutation_catalog)
[1m[94m237 |[0m     changes, context = role_plan(baseline, role=role)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mDo not call `setattr` with a constant attribute value. It is not any safer than normal property access.[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_plan.py:334:9
    [1m[94m|[0m
[1m[94m332 |[0m         replace(change, content=cast("bytes", bytearray()))
[1m[94m333 |[0m     with pytest.raises(FrozenInstanceError):
[1m[94m334 |[0m         setattr(change, "path", "other")
    [1m[94m|[0m         [1m[91m^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^[0m
[1m[94m335 |[0m     with pytest.raises(ValueError, match="unique"):
[1m[94m336 |[0m         replace(baseline, metadata=baseline.metadata + (baseline.metadata[0],))
    [1m[94m|[0m
[1m[96mhelp[0m: [1mReplace `setattr` with assignment[0m

Found 16 errors.
[[36m*[0m] 5 fixable with the `--fix` option.
```
