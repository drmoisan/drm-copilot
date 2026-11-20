# p2t9-prepare-ruff

Timestamp: 2026-10-18T10-35
Command: poetry run ruff check --fix packages/discovery-runtime/src/drm_copilot_discovery/validation.py packages/discovery-runtime/src/drm_copilot_discovery/validation_inputs.py packages/discovery-runtime/src/drm_copilot_discovery/completion_rules.py packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py tests/discovery_runtime/test_validation_modes.py tests/discovery_runtime/test_completion_rules.py tests/discovery_runtime/test_agent_output.py tests/discovery_runtime/validation_test_support.py
EXIT_CODE: 1
Output Summary: [36m-[0m [1mtests\discovery_runtime\validation_test_support.py[0m[36m:[0m;      1 × [1;31mI001[0m (unsorted-imports); ; Found 49 errors (20 fixed, 29 remaining).

Working directory: .
Started: 2026-10-18T10:35:36.068040+00:00
Duration seconds: 0.817
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

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\agent_output.py:144:89
    [1m[94m|[0m
[1m[94m142 |[0m                 message=message,
[1m[94m143 |[0m                 artifact_path=path,
[1m[94m144 |[0m                 next_action="Restore the invocation's exact allowed outputs and revalidate.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m145 |[0m             )
[1m[94m146 |[0m         )
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

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\agent_output.py:365:89
    [1m[94m|[0m
[1m[94m363 |[0m             if record.kind == "product-decision"
[1m[94m364 |[0m         }
[1m[94m365 |[0m         # These roles may propose decisions; approval and historical statuses stay fixed.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m366 |[0m         for key in old_decisions.keys() | new_decisions.keys():
[1m[94m367 |[0m             old, new = old_decisions.get(key), new_decisions.get(key)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\agent_output.py:385:89
    [1m[94m|[0m
[1m[94m383 |[0m     snapshot: DiscoverySnapshot, *, invocation: InvocationContext, index: ReferenceIndex
[1m[94m384 |[0m ) -> OutputValidation:
[1m[94m385 |[0m     """Validate exact output data against caller context; never issue native authority."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m386 |[0m     rules = _OutputRules(snapshot, invocation)
[1m[94m387 |[0m     if rules.manifest():
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\completion_rules.py:63:89
   [1m[94m|[0m
[1m[94m61 |[0m                     code="COMPLETION_PROFILE",
[1m[94m62 |[0m                     message="Completion requires a configured profile.",
[1m[94m63 |[0m                     next_action="Complete the profile and capture its immutable inputs.",
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m64 |[0m                 )
[1m[94m65 |[0m             )
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\completion_rules.py:103:89
    [1m[94m|[0m
[1m[94m101 |[0m                             code="COMPLETION_INPUT",
[1m[94m102 |[0m                             message=f"Source {source.id} lacks required {kind}.",
[1m[94m103 |[0m                             next_action="Capture the configured source discovery artifacts.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m104 |[0m                         )
[1m[94m105 |[0m                     )
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\completion_rules.py:131:89
    [1m[94m|[0m
[1m[94m130 |[0m     def feature(self, obligation: FeatureObligation) -> None:
[1m[94m131 |[0m         """Keep required evidence and unresolved legacy questions independent of policy."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m132 |[0m         if not obligation.required:
[1m[94m133 |[0m             return
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\completion_rules.py:158:89
    [1m[94m|[0m
[1m[94m156 |[0m             )
[1m[94m157 |[0m         if self.gates.required("block_on_unresolved_required_behavior"):
[1m[94m158 |[0m             # A resolved target policy question cannot close separate legacy uncertainty.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m159 |[0m             for question in self.context.questions(feature, None):
[1m[94m160 |[0m                 dimensions = strings(question.document.get("dimensions"))
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\completion_rules.py:168:89
    [1m[94m|[0m
[1m[94m166 |[0m                         question,
[1m[94m167 |[0m                         "/status",
[1m[94m168 |[0m                         "Required legacy behavior remains an open observation question.",
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m169 |[0m                     )
[1m[94m170 |[0m         if self.gates.required("require_approved_deviations"):
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

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\validation.py:358:89
    [1m[94m|[0m
[1m[94m356 |[0m             _problem(
[1m[94m357 |[0m                 "VALIDATION_CONTEXT",
[1m[94m358 |[0m                 "Role invocation context cannot select a root completion or planning mode.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m359 |[0m             )
[1m[94m360 |[0m         )
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\validation_inputs.py:37:89
   [1m[94m|[0m
[1m[94m35 |[0m         message=message,
[1m[94m36 |[0m         artifact_path=path,
[1m[94m37 |[0m         next_action="Correct the complete inputs and validate the exact requested mode.",
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m38 |[0m     )
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_agent_output.py:337:89
    [1m[94m|[0m
[1m[94m335 |[0m     snapshot_catalog: SchemaCatalog,
[1m[94m336 |[0m ) -> None:
[1m[94m337 |[0m     """Neither missing caller context nor an empty review manifest satisfies output duties."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m338 |[0m     baseline = no_scope_snapshot(snapshot_catalog)
[1m[94m339 |[0m     assert not validate_snapshot(baseline, mode="agent-output").ok
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_completion_rules.py:65:89
   [1m[94m|[0m
[1m[94m64 |[0m def completion_codes(snapshot: DiscoverySnapshot, *, parity: bool = False) -> set[str]:
[1m[94m65 |[0m     """Compose the accepted pure assessments exactly once for this isolated policy test."""
   [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m66 |[0m     index = index_references(snapshot)
[1m[94m67 |[0m     evidence_result = validate_evidence(snapshot, index=index)
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_completion_rules.py:177:89
    [1m[94m|[0m
[1m[94m175 |[0m     snapshot_catalog: SchemaCatalog, case: str, expected: bool
[1m[94m176 |[0m ) -> None:
[1m[94m177 |[0m     """Only qualifying retained source evidence satisfies this configurable prerequisite."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m178 |[0m     profile = policy_profile(
[1m[94m179 |[0m         snapshot_catalog, require_feature_evidence=case != "disabled"
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_completion_rules.py:209:89
    [1m[94m|[0m
[1m[94m207 |[0m     snapshot_catalog: SchemaCatalog, state: str, dimensions: list[str], blocked: bool
[1m[94m208 |[0m ) -> None:
[1m[94m209 |[0m     """Unrelated dimensions and historical resolved questions do not broaden the gate."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m210 |[0m     profile = policy_profile(
[1m[94m211 |[0m         snapshot_catalog, block_on_unresolved_required_behavior=True
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (96 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_completion_rules.py:267:89
    [1m[94m|[0m
[1m[94m265 |[0m     snapshot_catalog: SchemaCatalog, case: str, blocked: bool
[1m[94m266 |[0m ) -> None:
[1m[94m267 |[0m     """Target identity, missing captures or a planned run cannot supply source runtime proof."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^[0m
[1m[94m268 |[0m     profile = policy_profile(
[1m[94m269 |[0m         snapshot_catalog, require_runtime_for_declared_features=case != "disabled"
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (97 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_completion_rules.py:298:89
    [1m[94m|[0m
[1m[94m296 |[0m     snapshot_catalog: SchemaCatalog,
[1m[94m297 |[0m ) -> None:
[1m[94m298 |[0m     """Approval can resolve target policy while completion still reports unknown source facts."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^[0m
[1m[94m299 |[0m     profile = policy_profile(
[1m[94m300 |[0m         snapshot_catalog, block_on_unresolved_required_behavior=True
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_validation_modes.py:73:89
   [1m[94m|[0m
[1m[94m71 |[0m     snapshot_catalog: SchemaCatalog, prerequisite: str, passed: bool
[1m[94m72 |[0m ) -> None:
[1m[94m73 |[0m     """Structural success only permits planning when the configured prerequisite is none."""
   [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m74 |[0m     snapshot = captured(
[1m[94m75 |[0m         mode_profile(snapshot_catalog, draft=True, planning=prerequisite),
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_validation_modes.py:108:89
    [1m[94m|[0m
[1m[94m106 |[0m     snapshot_catalog: SchemaCatalog, case: str
[1m[94m107 |[0m ) -> None:
[1m[94m108 |[0m     """Malformed or unrepresented inputs cannot be hidden by otherwise valid artifacts."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m109 |[0m     snapshot = no_scope_snapshot(snapshot_catalog)
[1m[94m110 |[0m     files, records = snapshot.manifest.files, snapshot.artifacts
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_validation_modes.py:172:89
    [1m[94m|[0m
[1m[94m170 |[0m     snapshot_catalog: SchemaCatalog,
[1m[94m171 |[0m ) -> None:
[1m[94m172 |[0m     """Existing capture errors remain blocking and input order cannot change diagnostics."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m173 |[0m     snapshot = no_scope_snapshot(snapshot_catalog)
[1m[94m174 |[0m     errors = (
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_validation_modes.py:188:89
    [1m[94m|[0m
[1m[94m186 |[0m     snapshot_catalog: SchemaCatalog,
[1m[94m187 |[0m ) -> None:
[1m[94m188 |[0m     """Adding the exact derived report changes full identity but not its semantic digest."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m189 |[0m     snapshot = no_scope_snapshot(snapshot_catalog)
[1m[94m190 |[0m     value = report_projection(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_validation_modes.py:279:89
    [1m[94m|[0m
[1m[94m277 |[0m     snapshot_catalog: SchemaCatalog,
[1m[94m278 |[0m ) -> None:
[1m[94m279 |[0m     """Excluding report/control outputs cannot exclude actual inspected source changes."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m280 |[0m     snapshot = no_scope_snapshot(snapshot_catalog)
[1m[94m281 |[0m     file = SnapshotFile(path="src/addition.cs", content=b"source", category="source")
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

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\validation_test_support.py:311:89
    [1m[94m|[0m
[1m[94m309 |[0m     snapshot: DiscoverySnapshot, context: InvocationContext, **changes: object
[1m[94m310 |[0m ) -> tuple[DiscoverySnapshot, InvocationContext]:
[1m[94m311 |[0m     """Change authored manifest fields while retaining separate caller context by default."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m312 |[0m     value = as_object(to_plain_value(context.required_outputs))
[1m[94m313 |[0m     value.update(changes)
    [1m[94m|[0m


[1;32mFixed 20 errors:[0m
[36m-[0m [1mpackages\discovery-runtime\src\drm_copilot_discovery\validation.py[0m[36m:[0m
     1 × [1;31mI001[0m (unsorted-imports)
     1 × [1;31mF401[0m (unused-import)
[36m-[0m [1mtests\discovery_runtime\test_agent_output.py[0m[36m:[0m
     4 × [1;31mF401[0m (unused-import)
     1 × [1;31mI001[0m (unsorted-imports)
[36m-[0m [1mtests\discovery_runtime\test_validation_modes.py[0m[36m:[0m
    11 × [1;31mF401[0m (unused-import)
     1 × [1;31mI001[0m (unsorted-imports)
[36m-[0m [1mtests\discovery_runtime\validation_test_support.py[0m[36m:[0m
     1 × [1;31mI001[0m (unsorted-imports)

Found 49 errors (20 fixed, 29 remaining).
```
