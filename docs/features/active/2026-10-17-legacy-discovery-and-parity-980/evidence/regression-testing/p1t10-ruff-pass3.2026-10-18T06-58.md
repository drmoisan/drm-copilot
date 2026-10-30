# p1t10-ruff-pass3

Timestamp: 2026-10-18T06-58
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/profile_v2.py packages/discovery-runtime/src/drm_copilot_discovery/profile_models.py packages/discovery-runtime/src/drm_copilot_discovery/activation_models.py packages/discovery-runtime/src/drm_copilot_discovery/domain_profile.py scripts/dev_tools/validate_discovery_profile.py tests/discovery_runtime/test_profile_v2.py tests/discovery_runtime/test_profile_dimensions.py tests/scripts/dev_tools/test_validate_discovery_profile.py tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py
EXIT_CODE: 1
Output Summary:     [1m[94m|[0m; ; Found 30 errors.; [[36m*[0m] 4 fixable with the `--fix` option (2 hidden fixes can be enabled with the `--unsafe-fixes` option).

Working directory: .
Started: 2026-10-18T06:58:08.181695+00:00
Duration seconds: 0.751
Phase: P1-T10 immutable profile, inherited gates and explicit compatibility; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mMove application import `drm_copilot_discovery.catalog.SchemaCatalog` into a type-checking block[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_models.py:8:43
   [1m[94m|[0m
[1m[94m 6 |[0m from typing import Literal, cast
[1m[94m 7 |[0m
[1m[94m 8 |[0m from drm_copilot_discovery.catalog import SchemaCatalog
   [1m[94m|[0m                                           [1m[91m^^^^^^^^^^^^^[0m
[1m[94m 9 |[0m from drm_copilot_discovery.models import JsonObject
[1m[94m10 |[0m from drm_copilot_discovery.profile_v2 import ProfileError
   [1m[94m|[0m
[1m[96mhelp[0m: [1mMove into type-checking block[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mMove application import `drm_copilot_discovery.models.JsonObject` into a type-checking block[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_models.py:9:42
   [1m[94m|[0m
[1m[94m 8 |[0m from drm_copilot_discovery.catalog import SchemaCatalog
[1m[94m 9 |[0m from drm_copilot_discovery.models import JsonObject
   [1m[94m|[0m                                          [1m[91m^^^^^^^^^^[0m
[1m[94m10 |[0m from drm_copilot_discovery.profile_v2 import ProfileError
[1m[94m11 |[0m from drm_copilot_discovery.schema_validation import validate_document
   [1m[94m|[0m
[1m[96mhelp[0m: [1mMove into type-checking block[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_models.py:59:89
   [1m[94m|[0m
[1m[94m58 |[0m     def require_profile_path(self, path: str) -> None:
[1m[94m59 |[0m         """Reject caller/locator disagreement; later path policy resolves the location."""
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m60 |[0m         if path != self.profile_path:
[1m[94m61 |[0m             raise ValueError("Explicit profile path disagrees with activation locator")
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\profile_models.py:295:89
    [1m[94m|[0m
[1m[94m294 |[0m     def __getitem__(self, key: ArtifactKey) -> str:
[1m[94m295 |[0m         """Look up an exact closed-contract artifact key; unknown names raise KeyError."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m296 |[0m         return cast("str", self.data[key])
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\profile_models.py:319:89
    [1m[94m|[0m
[1m[94m317 |[0m     @property
[1m[94m318 |[0m     def mandatory_claim_rules(self) -> frozenset[str]:
[1m[94m319 |[0m         """Keep structural, evidence and path consistency requirements non-disableable."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m320 |[0m         return CORE_CLAIM_RULES
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\profile_models.py:364:89
    [1m[94m|[0m
[1m[94m362 |[0m             values = cast("tuple[object, ...] | list[object]", raw)
[1m[94m363 |[0m             pattern = r"[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*"
[1m[94m364 |[0m             # Validate every member before sorting; malformed axes cannot partially apply.
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m365 |[0m             if any(
[1m[94m366 |[0m                 not isinstance(item, str)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py:33:89
   [1m[94m|[0m
[1m[94m32 |[0m class ProfileError(DomainProfileError):
[1m[94m33 |[0m     """Retain deterministic profile findings without exposing a partial configuration."""
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m34 |[0m
[1m[94m35 |[0m     def __init__(self, findings: tuple[Finding, ...]) -> None:
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py:59:89
   [1m[94m|[0m
[1m[94m57 |[0m                 pointer=pointer,
[1m[94m58 |[0m                 message=message,
[1m[94m59 |[0m                 next_action="Correct the profile's identifiers or pinned extension catalog.",
   [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m60 |[0m             )
[1m[94m61 |[0m         )
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py:101:89
    [1m[94m|[0m
[1m[94m 99 |[0m                 f"Unknown target repository: {target}",
[1m[94m100 |[0m             )
[1m[94m101 |[0m     # A repository's declared client links cannot name missing or differently owned clients.
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m102 |[0m     for index, repository in enumerate(
[1m[94m103 |[0m         cast("tuple[JsonObject, ...]", document["repositories"])
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (111 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py:131:89
    [1m[94m|[0m
[1m[94m129 |[0m             problem(
[1m[94m130 |[0m                 child_pointer("/extension_schemas", namespace),
[1m[94m131 |[0m                 "Configured extension schema is absent or its path/checksum differs from the trusted catalog.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^^^^^^^^^^^^[0m
[1m[94m132 |[0m             )
[1m[94m133 |[0m     # Undeclared catalog entries cannot silently add validation policy.
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (107 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py:208:89
    [1m[94m|[0m
[1m[94m206 |[0m                         code="PROFILE_DRAFT",
[1m[94m207 |[0m                         pointer="/profile_state",
[1m[94m208 |[0m                         message="Draft configuration cannot satisfy completion or planning prerequisites.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^^^^^^^^[0m
[1m[94m209 |[0m                         next_action="Supply roots, repository pins and clients, then configure the profile.",
[1m[94m210 |[0m                     ),
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (109 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py:209:89
    [1m[94m|[0m
[1m[94m207 |[0m                         pointer="/profile_state",
[1m[94m208 |[0m                         message="Draft configuration cannot satisfy completion or planning prerequisites.",
[1m[94m209 |[0m                         next_action="Supply roots, repository pins and clients, then configure the profile.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^^^^^^^^^^[0m
[1m[94m210 |[0m                     ),
[1m[94m211 |[0m                 )
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py:330:89
    [1m[94m|[0m
[1m[94m328 |[0m     @property
[1m[94m329 |[0m     def limits(self) -> ProfileLimits:
[1m[94m330 |[0m         """Project schema-valid integral numbers to ints, preserving original wire data."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m331 |[0m         values = cast("JsonObject", self.document.get("limits", JsonObject(())))
[1m[94m332 |[0m         # JSON Schema includes integral floats in integer; normalize only these fields.
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py:349:89
    [1m[94m|[0m
[1m[94m347 |[0m         client = None
[1m[94m348 |[0m         if client_id is not None:
[1m[94m349 |[0m             # Select only an explicitly configured client; no default client is inferred.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m350 |[0m             client = next((item for item in self.clients if item.id == client_id), None)
[1m[94m351 |[0m             if client is None:
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py:378:89
    [1m[94m|[0m
[1m[94m376 |[0m     limits: ParseLimits | None = None,
[1m[94m377 |[0m ) -> ProfileV2:
[1m[94m378 |[0m     """Provide the common pure parser; default catalog reads installed resources only."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m379 |[0m     return ProfileV2(content, format=format, catalog=catalog, limits=limits)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_profile_dimensions.py:65:89
   [1m[94m|[0m
[1m[94m65 |[0m def test_optional_dimensions_and_applicability_do_not_create_or_remove_obligations() -> (
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m66 |[0m     None
[1m[94m67 |[0m ):
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (96 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_profile_dimensions.py:68:89
   [1m[94m|[0m
[1m[94m66 |[0m     None
[1m[94m67 |[0m ):
[1m[94m68 |[0m     """Online-only configuration stays optional for offline/mobile until explicitly required."""
   [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^[0m
[1m[94m69 |[0m     profile = parse_profile_v2(profile_text())
[1m[94m70 |[0m     required = profile.requirements(client_id="browser-example")
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_profile_dimensions.py:90:89
   [1m[94m|[0m
[1m[94m88 |[0m     axis: str, value: object
[1m[94m89 |[0m ) -> None:
[1m[94m90 |[0m     """Feature additions cannot widen the schema's case-sensitive identifier vocabulary."""
   [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m91 |[0m     values: dict[str, tuple[object, ...]] = {
[1m[94m92 |[0m         "platforms": (),
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_profile_dimensions.py:134:89
    [1m[94m|[0m
[1m[94m132 |[0m     prerequisite: str,
[1m[94m133 |[0m ) -> None:
[1m[94m134 |[0m     """Root-authored optional gates do not make verified evidence or path safety optional."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m135 |[0m     document = profile_document()
[1m[94m136 |[0m     gates = as_object(document["completion_gates"])
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mDo not call `setattr` with a constant attribute value. It is not any safer than normal property access.[0m
   [1m[94m-->[0m tests\discovery_runtime\test_profile_dimensions.py:157:9
    [1m[94m|[0m
[1m[94m155 |[0m         )
[1m[94m156 |[0m     with pytest.raises(FrozenInstanceError):
[1m[94m157 |[0m         setattr(profile.completion_gates, "index", 1)
    [1m[94m|[0m         [1m[91m^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^[0m
    [1m[94m|[0m
[1m[96mhelp[0m: [1mReplace `setattr` with assignment[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_profile_dimensions.py:171:89
    [1m[94m|[0m
[1m[94m169 |[0m )
[1m[94m170 |[0m def test_unknown_or_malformed_gate_policy_fails_closed(key: str, value: object) -> None:
[1m[94m171 |[0m     """Configuration cannot disable mandatory rules through undeclared keys or coercion."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m172 |[0m     document = profile_document()
[1m[94m173 |[0m     as_object(document["completion_gates"])[key] = value
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (95 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_profile_dimensions.py:199:89
    [1m[94m|[0m
[1m[94m198 |[0m def test_draft_profile_is_valid_but_cannot_satisfy_configured_prerequisites() -> None:
[1m[94m199 |[0m     """Missing pins, roots and clients remain explicit draft values with no false readiness."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^[0m
[1m[94m200 |[0m     document = profile_document()
[1m[94m201 |[0m     document.update(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_profile_dimensions.py:283:89
    [1m[94m|[0m
[1m[94m282 |[0m def test_locator_is_exact_immutable_configuration_without_authority() -> None:
[1m[94m283 |[0m     """The four-key envelope selects a profile and cannot contain permissions or receipts."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m284 |[0m     value = {
[1m[94m285 |[0m         "schema_version": "2.0.0",
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mDo not call `setattr` with a constant attribute value. It is not any safer than normal property access.[0m
   [1m[94m-->[0m tests\discovery_runtime\test_profile_dimensions.py:299:9
    [1m[94m|[0m
[1m[94m297 |[0m         locator.require_profile_path("docs/other.yaml")
[1m[94m298 |[0m     with pytest.raises(FrozenInstanceError):
[1m[94m299 |[0m         setattr(locator, "document", None)
    [1m[94m|[0m         [1m[91m^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^[0m
[1m[94m300 |[0m     # Invalid replacements and added authority claims must all reject the locator.
[1m[94m301 |[0m     for key, invalid in (
    [1m[94m|[0m
[1m[96mhelp[0m: [1mReplace `setattr` with assignment[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_profile_dimensions.py:316:89
    [1m[94m|[0m
[1m[94m314 |[0m     mem_fs_path: Path,
[1m[94m315 |[0m ) -> None:
[1m[94m316 |[0m     """Compatibility defaults remain v1; content cannot silently choose the new parser."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m317 |[0m     legacy = parse_domain_profile_text(VALID_MINIMAL)
[1m[94m318 |[0m     assert isinstance(legacy, DomainProfile) and legacy.profile_version == 1
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_profile_v2.py:113:89
    [1m[94m|[0m
[1m[94m111 |[0m     assert profile.limits.source_files == 1000000
[1m[94m112 |[0m     assert profile.completion_gates.planning_prerequisite == "discovery-complete"
[1m[94m113 |[0m     # Every configured output key must preserve its exact location, including custom names.
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m114 |[0m     for key, value in as_object(document["artifacts"]).items():
[1m[94m115 |[0m         assert profile.artifacts[cast("ArtifactKey", key)] == value
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_profile_v2.py:171:89
    [1m[94m|[0m
[1m[94m169 |[0m     None
[1m[94m170 |[0m ):
[1m[94m171 |[0m     """Custom wire paths remain exact; only documented optional limits receive defaults."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m172 |[0m     document = profile_document()
[1m[94m173 |[0m     artifacts = as_object(document["artifacts"])
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mDo not call `setattr` with a constant attribute value. It is not any safer than normal property access.[0m
   [1m[94m-->[0m tests\discovery_runtime\test_profile_v2.py:205:9
    [1m[94m|[0m
[1m[94m203 |[0m     assert first.system.name != "Changed"
[1m[94m204 |[0m     with pytest.raises(FrozenInstanceError):
[1m[94m205 |[0m         setattr(first, "document", JsonObject(()))
    [1m[94m|[0m         [1m[91m^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^[0m
[1m[94m206 |[0m     with pytest.raises(FrozenInstanceError):
[1m[94m207 |[0m         setattr(first.system, "profile", second)
    [1m[94m|[0m
[1m[96mhelp[0m: [1mReplace `setattr` with assignment[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mDo not call `setattr` with a constant attribute value. It is not any safer than normal property access.[0m
   [1m[94m-->[0m tests\discovery_runtime\test_profile_v2.py:207:9
    [1m[94m|[0m
[1m[94m205 |[0m         setattr(first, "document", JsonObject(()))
[1m[94m206 |[0m     with pytest.raises(FrozenInstanceError):
[1m[94m207 |[0m         setattr(first.system, "profile", second)
    [1m[94m|[0m         [1m[91m^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^[0m
[1m[94m208 |[0m     detached = as_object(to_plain_value(first.document))
[1m[94m209 |[0m     as_object(detached["system"])["name"] = "Detached"
    [1m[94m|[0m
[1m[96mhelp[0m: [1mReplace `setattr` with assignment[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_profile_v2.py:279:89
    [1m[94m|[0m
[1m[94m277 |[0m     repository_index: int, client_id: str
[1m[94m278 |[0m ) -> None:
[1m[94m279 |[0m     """Declared backlinks retain exact target ownership without changing unrelated clients."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m280 |[0m     document = profile_document()
[1m[94m281 |[0m     cast("list[dict[str, object]]", document["repositories"])[repository_index][
    [1m[94m|[0m

Found 30 errors.
[[36m*[0m] 4 fixable with the `--fix` option (2 hidden fixes can be enabled with the `--unsafe-fixes` option).
```
