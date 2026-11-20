# p2t9-prepare2-ruff

Timestamp: 2026-10-18T10-36
Command: poetry run ruff check --fix packages/discovery-runtime/src/drm_copilot_discovery/validation.py packages/discovery-runtime/src/drm_copilot_discovery/validation_inputs.py packages/discovery-runtime/src/drm_copilot_discovery/completion_rules.py packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py tests/discovery_runtime/test_validation_modes.py tests/discovery_runtime/test_completion_rules.py tests/discovery_runtime/test_agent_output.py tests/discovery_runtime/validation_test_support.py
EXIT_CODE: 1
Output Summary: [36m-[0m [1mtests\discovery_runtime\test_agent_output.py[0m[36m:[0m;     1 × [1;31mI001[0m (unsorted-imports); ; Found 12 errors (1 fixed, 11 remaining).

Working directory: .
Started: 2026-10-18T10:36:54.827409+00:00
Duration seconds: 0.860
Phase: P2-T9 validation composition and role outputs; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\agent_output.py:128:89
    [1m[94m|[0m
[1m[94m126 |[0m         self, snapshot: DiscoverySnapshot, invocation: InvocationContext
[1m[94m127 |[0m     ) -> None:
[1m[94m128 |[0m         """Retain immutable inputs and map captured files for deterministic comparison."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m129 |[0m         self.snapshot, self.invocation = snapshot, invocation
[1m[94m130 |[0m         self.collector = FindingCollector(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\agent_output.py:138:89
    [1m[94m|[0m
[1m[94m137 |[0m     def add(self, code: str, message: str, path: str | None = None) -> None:
[1m[94m138 |[0m         """Append an actionable output-contract diagnostic with optional captured path."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m139 |[0m         self.collector.add(
[1m[94m140 |[0m             Finding(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\agent_output.py:315:89
    [1m[94m|[0m
[1m[94m313 |[0m         self, rows: tuple[tuple[int, JsonObject], ...], index: ReferenceIndex
[1m[94m314 |[0m     ) -> None:
[1m[94m315 |[0m         """Limit changed paths and preserve protected decision and collection content."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m316 |[0m         paths = tuple(str(row.get("path")) for _, row in rows)
[1m[94m317 |[0m         if len(paths) != len(set(paths)):
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\agent_output.py:386:89
    [1m[94m|[0m
[1m[94m384 |[0m     snapshot: DiscoverySnapshot, *, invocation: InvocationContext, index: ReferenceIndex
[1m[94m385 |[0m ) -> OutputValidation:
[1m[94m386 |[0m     """Validate exact output data against caller context; never issue native authority."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m387 |[0m     rules = _OutputRules(snapshot, invocation)
[1m[94m388 |[0m     if rules.manifest():
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
 [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\validation.py:1:89
  [1m[94m|[0m
[1m[94m1 |[0m """Compose explicit graph-validation modes; results carry data, never native authority."""
  [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m2 |[0m
[1m[94m3 |[0m from __future__ import annotations
  [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\validation.py:82:89
   [1m[94m|[0m
[1m[94m80 |[0m     @property
[1m[94m81 |[0m     def ok(self) -> bool:
[1m[94m82 |[0m         """Return selected-mode success; a valid failing review can finish its output."""
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m83 |[0m         return (
[1m[94m84 |[0m             self.output_valid is True
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_completion_rules.py:213:89
    [1m[94m|[0m
[1m[94m211 |[0m     snapshot_catalog: SchemaCatalog, state: str, dimensions: list[str], blocked: bool
[1m[94m212 |[0m ) -> None:
[1m[94m213 |[0m     """Unrelated dimensions and historical resolved questions do not broaden the gate."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m214 |[0m     profile = policy_profile(
[1m[94m215 |[0m         snapshot_catalog, block_on_unresolved_required_behavior=True
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_validation_modes.py:110:89
    [1m[94m|[0m
[1m[94m108 |[0m     snapshot_catalog: SchemaCatalog, case: str
[1m[94m109 |[0m ) -> None:
[1m[94m110 |[0m     """Malformed or unrepresented inputs cannot be hidden by otherwise valid artifacts."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m111 |[0m     snapshot = no_scope_snapshot(snapshot_catalog)
[1m[94m112 |[0m     files, records = snapshot.manifest.files, snapshot.artifacts
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_validation_modes.py:285:89
    [1m[94m|[0m
[1m[94m283 |[0m     snapshot_catalog: SchemaCatalog,
[1m[94m284 |[0m ) -> None:
[1m[94m285 |[0m     """Excluding report/control outputs cannot exclude actual inspected source changes."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m286 |[0m     snapshot = no_scope_snapshot(snapshot_catalog)
[1m[94m287 |[0m     file = SnapshotFile(path="src/addition.cs", content=b"source", category="source")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\validation_test_support.py:138:89
    [1m[94m|[0m
[1m[94m136 |[0m         required_coverage={"feature_refs": [], "client_ids": [], "modes": []},
[1m[94m137 |[0m         disposition="no-scope",
[1m[94m138 |[0m         no_scope_rationale="No migration behavior exists in the inspected source selection.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m139 |[0m     )
[1m[94m140 |[0m     as_object(scope["confirmed_by"])["evidence_refs"] = [
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\validation_test_support.py:182:89
    [1m[94m|[0m
[1m[94m180 |[0m     snapshot: DiscoverySnapshot, path: str, value: dict[str, object]
[1m[94m181 |[0m ) -> DiscoverySnapshot:
[1m[94m182 |[0m     """Update one prospective document and its bytes together without shared mutation."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m183 |[0m     document = immutable(value)
[1m[94m184 |[0m     return replace(
    [1m[94m|[0m


[1;32mFixed 1 error:[0m
[36m-[0m [1mtests\discovery_runtime\test_agent_output.py[0m[36m:[0m
    1 × [1;31mI001[0m (unsorted-imports)

Found 12 errors (1 fixed, 11 remaining).
```
