# p2t6-lint-pass2

Timestamp: 2026-10-18T09-24
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/coverage_rules.py packages/discovery-runtime/src/drm_copilot_discovery/coverage_scope_rules.py tests/discovery_runtime/test_coverage_rules.py tests/discovery_runtime/test_coverage_scope.py
EXIT_CODE: 1
Output Summary:     [1m[94m|[0m; ; Found 11 errors.; [[36m*[0m] 2 fixable with the `--fix` option.

Working directory: .
Started: 2026-10-18T09:24:06.456676+00:00
Duration seconds: 0.806
Phase: P2-T6 scope and coverage accounting; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\coverage_rules.py:59:89
   [1m[94m|[0m
[1m[94m57 |[0m         self, ledger: ArtifactRecord, pointer: str, features: tuple[ArtifactRecord, ...]
[1m[94m58 |[0m     ) -> None:
[1m[94m59 |[0m         """Require recorded characterization for each explicitly runtime-required feature."""
   [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m60 |[0m         for feature in features:
[1m[94m61 |[0m             supported = False
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\coverage_rules.py:62:89
   [1m[94m|[0m
[1m[94m60 |[0m         for feature in features:
[1m[94m61 |[0m             supported = False
[1m[94m62 |[0m             # A captured scenario is evidence of execution only when its claims validate.
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m63 |[0m             for scenario in self.context.index.records:
[1m[94m64 |[0m                 if (
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\coverage_rules.py:82:89
   [1m[94m|[0m
[1m[94m80 |[0m                     ledger,
[1m[94m81 |[0m                     pointer,
[1m[94m82 |[0m                     "Declared runtime need requires a valid observed or passed scenario.",
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m83 |[0m                 )
[1m[94m84 |[0m         if not features:
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\coverage_rules.py:129:89
    [1m[94m|[0m
[1m[94m127 |[0m         selection: CoverageScope,
[1m[94m128 |[0m     ) -> None:
[1m[94m129 |[0m         """Check provenance and claimed disposition independently of inspection state."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m130 |[0m         pointer = f"/components/{position}"
[1m[94m131 |[0m         identifier = row.get("component_id")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\coverage_rules.py:257:89
    [1m[94m|[0m
[1m[94m255 |[0m                     ledger,
[1m[94m256 |[0m                     pointer,
[1m[94m257 |[0m                     "Selected components require nonblocking inspection and disposition.",
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m258 |[0m                 )
[1m[94m259 |[0m             if gates.required("require_runtime_for_declared_features"):
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\coverage_scope_rules.py:227:89
    [1m[94m|[0m
[1m[94m225 |[0m                     "A selected scan input is unreadable or unjustifiably excluded.",
[1m[94m226 |[0m                 )
[1m[94m227 |[0m         # Global or selected-path failures cannot be hidden by a populated component list.
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m228 |[0m         for position, diagnostic in object_rows(document.get("diagnostics")):
[1m[94m229 |[0m             path = diagnostic.get("path")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\coverage_scope_rules.py:253:89
    [1m[94m|[0m
[1m[94m251 |[0m             if file.category in {"source", "test", "documentation"}
[1m[94m252 |[0m         }
[1m[94m253 |[0m         # Explicitly skipped paths need inventory exclusion records, not invented hashes.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m254 |[0m         for path in snapshot.excluded_paths:
[1m[94m255 |[0m             if not any(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_coverage_rules.py:396:89
    [1m[94m|[0m
[1m[94m394 |[0m     snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, case: str
[1m[94m395 |[0m ) -> None:
[1m[94m396 |[0m     """Detected tests establish relevance without claiming execution or measured coverage."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m397 |[0m     test = {
[1m[94m398 |[0m         "path": None if case == "invalid-path" else "tests/example.py",
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`drm_copilot_discovery.models.canonical_json` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_coverage_scope.py:16:42
   [1m[94m|[0m
[1m[94m14 |[0m     strings,
[1m[94m15 |[0m )
[1m[94m16 |[0m from drm_copilot_discovery.models import canonical_json, to_plain_value
   [1m[94m|[0m                                          [1m[91m^^^^^^^^^^^^^^[0m
[1m[94m17 |[0m from drm_copilot_discovery.profile_v2 import ProfileV2
[1m[94m18 |[0m from drm_copilot_discovery.repository_reader import RepositoryIdentity
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `drm_copilot_discovery.models.canonical_json`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`tests.discovery_runtime.test_references.artifact` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_coverage_scope.py:28:53
   [1m[94m|[0m
[1m[94m26 |[0m )
[1m[94m27 |[0m from tests.discovery_runtime.test_evidence_rules import CONTENT, PIN
[1m[94m28 |[0m from tests.discovery_runtime.test_references import artifact, immutable, reference
   [1m[94m|[0m                                                     [1m[91m^^^^^^^^[0m
[1m[94m29 |[0m from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
[1m[94m30 |[0m from tests.discovery_runtime.test_snapshot_io import (
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `tests.discovery_runtime.test_references.artifact`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_coverage_scope.py:216:89
    [1m[94m|[0m
[1m[94m214 |[0m     missing: bool,
[1m[94m215 |[0m ) -> None:
[1m[94m216 |[0m     """Root matching uses path segments; explicit and feature selectors remain additive."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m217 |[0m     snapshot = coverage_snapshot(
[1m[94m218 |[0m         snapshot_profile, snapshot_catalog, rows=[], scope_changes=selector
    [1m[94m|[0m

Found 11 errors.
[[36m*[0m] 2 fixable with the `--fix` option.
```
