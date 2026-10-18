# p1t6-lint-pass1

Timestamp: 2026-10-18T05-49
Command: poetry run ruff check tests/schemas/discovery/test_v2_target_schemas.py tests/schemas/discovery/test_v2_decision_schemas.py tests/schemas/discovery/test_v2_acceptance_schemas.py
EXIT_CODE: 1
Output Summary: [1m[94m392 |[0m     _first(document, "implementation_paths")[field] = value;     [1m[94m|[0m; ; Found 34 errors.

Working directory: .
Started: 2026-10-18T05:49:11.006018+00:00
Duration seconds: 0.819
Phase: P1-T6 target/decision/acceptance schemas; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
  [1m[94m-->[0m tests\schemas\discovery\test_v2_acceptance_schemas.py:26:89
   [1m[94m|[0m
[1m[94m24 |[0m     field: str,
[1m[94m25 |[0m ) -> None:
[1m[94m26 |[0m     """Scenario identity and expectation provenance remain explicit in test specifications."""
   [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m27 |[0m     document = load_fixture("acceptance-specification")
[1m[94m28 |[0m     del document[field]
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
  [1m[94m-->[0m tests\schemas\discovery\test_v2_acceptance_schemas.py:49:89
   [1m[94m|[0m
[1m[94m47 |[0m     value: object,
[1m[94m48 |[0m ) -> None:
[1m[94m49 |[0m     """Ready means a supported specification exists, never that an implementation passed."""
   [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m50 |[0m     document = load_fixture("acceptance-specification")
[1m[94m51 |[0m     document[field] = value
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m tests\schemas\discovery\test_v2_acceptance_schemas.py:57:89
   [1m[94m|[0m
[1m[94m56 |[0m def test_pending_specification_preserves_unknown_expectation_and_reason() -> None:
[1m[94m57 |[0m     """An unresolved criterion retains null Then and an actionable pending explanation."""
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m58 |[0m     document = load_fixture("acceptance-specification")
[1m[94m59 |[0m     document.update(
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
  [1m[94m-->[0m tests\schemas\discovery\test_v2_acceptance_schemas.py:77:89
   [1m[94m|[0m
[1m[94m76 |[0m def test_target_expectation_can_reference_a_product_decision() -> None:
[1m[94m77 |[0m     """Target policy uses typed decision linkage; approval truth is checked by the graph."""
   [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m78 |[0m     document = load_fixture("acceptance-specification")
[1m[94m79 |[0m     document.update(expectation_basis="approved-decision", evidence_refs=[])
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m tests\schemas\discovery\test_v2_acceptance_schemas.py:92:89
   [1m[94m|[0m
[1m[94m92 |[0m def test_legacy_characterization_can_omit_target_client_without_using_target_policy() -> (
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m93 |[0m     None
[1m[94m94 |[0m ):
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (95 > 88)[0m
  [1m[94m-->[0m tests\schemas\discovery\test_v2_acceptance_schemas.py:95:89
   [1m[94m|[0m
[1m[94m93 |[0m     None
[1m[94m94 |[0m ):
[1m[94m95 |[0m     """Legacy observations can exist without a modern client or an approved target decision."""
   [1m[94m|[0m                                                                                         [1m[91m^^^^^^^[0m
[1m[94m96 |[0m     document = load_fixture("acceptance-specification")
[1m[94m97 |[0m     document.update(kind="legacy-characterization", client_id=None, platform_id=None)
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_acceptance_schemas.py:160:89
    [1m[94m|[0m
[1m[94m158 |[0m     value: object,
[1m[94m159 |[0m ) -> None:
[1m[94m160 |[0m     """A generated expectation must remain traceable to immutable source contract bytes."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m161 |[0m     document = load_fixture("acceptance-specification")
[1m[94m162 |[0m     source = as_object(cast("list[object]", document["source_contract_refs"])[0])
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_acceptance_schemas.py:184:89
    [1m[94m|[0m
[1m[94m182 |[0m     value: object,
[1m[94m183 |[0m ) -> None:
[1m[94m184 |[0m     """Identity, source hashing, readiness and implementation execution remain separate."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m185 |[0m     document = load_fixture("acceptance-specification")
[1m[94m186 |[0m     document[field] = value
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_acceptance_schemas.py:192:89
    [1m[94m|[0m
[1m[94m191 |[0m def test_implementation_test_links_preserve_provenance_without_test_outcome() -> None:
[1m[94m192 |[0m     """A downstream test may link to a specification without assigning a passing state."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m193 |[0m     document = load_fixture("acceptance-specification")
[1m[94m194 |[0m     implementation = load_fixture("implementation-record")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_acceptance_schemas.py:204:89
    [1m[94m|[0m
[1m[94m203 |[0m def test_superseded_specification_keeps_its_historical_expectation() -> None:
[1m[94m204 |[0m     """Retained history has an explicit inactive state rather than a fresh ready claim."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m205 |[0m     document = load_fixture("acceptance-specification")
[1m[94m206 |[0m     document["readiness"] = "superseded"
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
  [1m[94m-->[0m tests\schemas\discovery\test_v2_decision_schemas.py:21:89
   [1m[94m|[0m
[1m[94m19 |[0m ).split()
[1m[94m20 |[0m BEHAVIOR_FIELDS = (
[1m[94m21 |[0m     "behavior_id feature_refs dimensions question evidence_refs competing_interpretations "
   [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m22 |[0m     "impact status decision_owner decision_ref decision rationale approved_target_behavior "
[1m[94m23 |[0m     "acceptance_test_implications resolution_basis resolution_evidence_refs extensions"
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
  [1m[94m-->[0m tests\schemas\discovery\test_v2_decision_schemas.py:22:89
   [1m[94m|[0m
[1m[94m20 |[0m BEHAVIOR_FIELDS = (
[1m[94m21 |[0m     "behavior_id feature_refs dimensions question evidence_refs competing_interpretations "
[1m[94m22 |[0m     "impact status decision_owner decision_ref decision rationale approved_target_behavior "
   [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m23 |[0m     "acceptance_test_implications resolution_basis resolution_evidence_refs extensions"
[1m[94m24 |[0m ).split()
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
  [1m[94m-->[0m tests\schemas\discovery\test_v2_decision_schemas.py:76:89
   [1m[94m|[0m
[1m[94m74 |[0m     value: object,
[1m[94m75 |[0m ) -> None:
[1m[94m76 |[0m     """Approval requires an actor, valid timestamp and evidence; no permission bit exists."""
   [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m77 |[0m     document = load_fixture("product-decision")
[1m[94m78 |[0m     as_object(document["approval"])[field] = value
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m tests\schemas\discovery\test_v2_decision_schemas.py:94:89
   [1m[94m|[0m
[1m[94m92 |[0m @pytest.mark.parametrize("state", ("proposed", "rejected"))
[1m[94m93 |[0m def test_unapproved_decisions_cannot_supply_ready_expected_results(state: str) -> None:
[1m[94m94 |[0m     """A proposed or rejected target policy keeps its acceptance implications pending."""
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m95 |[0m     document = load_fixture("product-decision")
[1m[94m96 |[0m     document.update(status=state, approval=None)
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_decision_schemas.py:121:89
    [1m[94m|[0m
[1m[94m120 |[0m def test_superseded_decision_preserves_history_without_ready_criteria() -> None:
[1m[94m121 |[0m     """Historical approved expectations are retained under an inactive readiness state."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m122 |[0m     document = load_fixture("product-decision")
[1m[94m123 |[0m     document["status"] = "superseded"
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_decision_schemas.py:148:89
    [1m[94m|[0m
[1m[94m147 |[0m def test_decision_can_target_multiple_clients_and_platform_modes() -> None:
[1m[94m148 |[0m     """Policy selectors represent more than one target client without domain assumptions."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m149 |[0m     document = load_fixture("product-decision")
[1m[94m150 |[0m     as_object(document["scope"]).update(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_decision_schemas.py:190:89
    [1m[94m|[0m
[1m[94m188 |[0m     field: str,
[1m[94m189 |[0m ) -> None:
[1m[94m190 |[0m     """Questions, impact, alternatives and policy resolution stay explicit even when null."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m191 |[0m     document = load_fixture("unspecified-behavior")
[1m[94m192 |[0m     del document[field]
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_decision_schemas.py:215:89
    [1m[94m|[0m
[1m[94m213 |[0m     value: object,
[1m[94m214 |[0m ) -> None:
[1m[94m215 |[0m     """Under-review questions retain uncertainty instead of silently inventing policy."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m216 |[0m     document = load_fixture("unspecified-behavior")
[1m[94m217 |[0m     document["status"] = state
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (95 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_decision_schemas.py:227:89
    [1m[94m|[0m
[1m[94m225 |[0m     None
[1m[94m226 |[0m ):
[1m[94m227 |[0m     """Historical facts can resolve uncertainty while approved target behavior remains null."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^[0m
[1m[94m228 |[0m     document = load_fixture("unspecified-behavior")
[1m[94m229 |[0m     original_question = document["question"]
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_decision_schemas.py:261:89
    [1m[94m|[0m
[1m[94m259 |[0m     field: str,
[1m[94m260 |[0m ) -> None:
[1m[94m261 |[0m     """Intentional ambiguity requires a reviewable policy record, not a confidence claim."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m262 |[0m     document = load_fixture("unspecified-behavior")
[1m[94m263 |[0m     document.update(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_decision_schemas.py:270:89
    [1m[94m|[0m
[1m[94m268 |[0m         decision="Preserve unspecified timing.",
[1m[94m269 |[0m         rationale="No target timing guarantee is required.",
[1m[94m270 |[0m         approved_target_behavior="Either documented timing interpretation remains permitted.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m271 |[0m     )
[1m[94m272 |[0m     assert schema_errors("unspecified-behavior", document) == []
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_decision_schemas.py:281:89
    [1m[94m|[0m
[1m[94m279 |[0m     None
[1m[94m280 |[0m ):
[1m[94m281 |[0m     """A factual observation does not grant authority to leave target behavior unspecified."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m282 |[0m     document = load_fixture("unspecified-behavior")
[1m[94m283 |[0m     document.update(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_decision_schemas.py:310:89
    [1m[94m|[0m
[1m[94m308 |[0m     value: object,
[1m[94m309 |[0m ) -> None:
[1m[94m310 |[0m     """Interpretations use confidence and evidence, not a verification or approval status."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m311 |[0m     document = load_fixture("unspecified-behavior")
[1m[94m312 |[0m     _first(document, "competing_interpretations")[field] = value
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_decision_schemas.py:319:89
    [1m[94m|[0m
[1m[94m317 |[0m @pytest.mark.parametrize("kind", ("product-decision", "unspecified-behavior"))
[1m[94m318 |[0m def test_collections_accept_empty_or_strictly_typed_records(kind: str) -> None:
[1m[94m319 |[0m     """The initializer can emit an empty collection and later add complete typed records."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m320 |[0m     collection = load_fixture(kind + "-collection")
[1m[94m321 |[0m     assert schema_errors(kind + "-collection", collection) == []
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_decision_schemas.py:333:89
    [1m[94m|[0m
[1m[94m331 |[0m     kind: str,
[1m[94m332 |[0m ) -> None:
[1m[94m333 |[0m     """Collection validity includes nested schema rules; keyed conflicts are a graph gate."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m334 |[0m     collection = load_fixture(kind + "-collection")
[1m[94m335 |[0m     record = load_fixture(kind)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m tests\schemas\discovery\test_v2_target_schemas.py:69:89
   [1m[94m|[0m
[1m[94m67 |[0m @pytest.mark.parametrize("kind", TARGET_KINDS)
[1m[94m68 |[0m def test_target_schemas_are_closed_valid_and_packaged(kind: str) -> None:
[1m[94m69 |[0m     """Every new artifact has an exact version identity and identical installed bytes."""
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m70 |[0m     schema = load_schema(kind)
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m tests\schemas\discovery\test_v2_target_schemas.py:83:89
   [1m[94m|[0m
[1m[94m82 |[0m def test_target_schema_references_resolve_within_the_offline_catalog() -> None:
[1m[94m83 |[0m     """Shared criterion, source and provenance definitions require no network resolver."""
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m84 |[0m     inputs = {
[1m[94m85 |[0m         f"schemas/discovery/v2/{path.name}": path.read_bytes()
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_target_schemas.py:177:89
    [1m[94m|[0m
[1m[94m175 |[0m @pytest.mark.parametrize("field", SOURCE_FIELDS)
[1m[94m176 |[0m def test_parity_source_identity_is_an_explicit_immutable_contract(field: str) -> None:
[1m[94m177 |[0m     """Every source reference binds its repository, bytes, feature and schema version."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m178 |[0m     document = load_fixture("parity-matrix")
[1m[94m179 |[0m     del as_object(_first(document, "entries")["source_contract_ref"])[field]
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_target_schemas.py:225:89
    [1m[94m|[0m
[1m[94m224 |[0m def test_parity_is_client_scoped_and_does_not_force_optional_mode_analysis() -> None:
[1m[94m225 |[0m     """Two clients may reference one source feature without mandatory offline/mobile rows."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m226 |[0m     document = load_fixture("parity-matrix")
[1m[94m227 |[0m     first = _first(document, "entries")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_target_schemas.py:238:89
    [1m[94m|[0m
[1m[94m236 |[0m @pytest.mark.parametrize("state", ("full", "partial"))
[1m[94m237 |[0m def test_parity_claims_require_pinned_target_records_and_evidence(state: str) -> None:
[1m[94m238 |[0m     """Positive parity states cannot be represented solely by an author's status string."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m239 |[0m     document = load_fixture("parity-matrix")
[1m[94m240 |[0m     entry = _first(document, "entries")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_target_schemas.py:287:89
    [1m[94m|[0m
[1m[94m285 |[0m     state: str,
[1m[94m286 |[0m ) -> None:
[1m[94m287 |[0m     """Decision references preserve a reviewable policy basis without asserting approval."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m288 |[0m     document = load_fixture("parity-matrix")
[1m[94m289 |[0m     entry = _first(document, "entries")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_target_schemas.py:306:89
    [1m[94m|[0m
[1m[94m304 |[0m     state: str,
[1m[94m305 |[0m ) -> None:
[1m[94m306 |[0m     """Each mode records applicability independently from an actual verification result."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m307 |[0m     document = load_fixture("parity-matrix")
[1m[94m308 |[0m     entry = _first(document, "entries")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_target_schemas.py:325:89
    [1m[94m|[0m
[1m[94m323 |[0m     None
[1m[94m324 |[0m ):
[1m[94m325 |[0m     """A local completion policy decides when an optional exclusion needs product approval."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m326 |[0m     document = load_fixture("parity-matrix")
[1m[94m327 |[0m     mode = as_object(_first(document, "entries")["online"])
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_target_schemas.py:390:89
    [1m[94m|[0m
[1m[94m388 |[0m     field: str, value: object
[1m[94m389 |[0m ) -> None:
[1m[94m390 |[0m     """Implementation evidence uses the same pinned source contract as analyzer findings."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m391 |[0m     document = load_fixture("implementation-record")
[1m[94m392 |[0m     _first(document, "implementation_paths")[field] = value
    [1m[94m|[0m

Found 34 errors.
```
