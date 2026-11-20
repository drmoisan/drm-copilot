# p2t7-tests-pass6

Timestamp: 2026-10-18T09-50
Command: poetry run pytest tests/discovery_runtime/test_dimension_rules.py tests/discovery_runtime/test_acceptance_rules.py tests/discovery_runtime/test_acceptance_scope.py --cov=drm_copilot_discovery.dimension_rules --cov=drm_copilot_discovery.acceptance_rules --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p2t7-coverage.json -q
EXIT_CODE: 1
Output Summary: FAILED tests/discovery_runtime/test_acceptance_rules.py::test_supported_ready_specification_is_not_an_implementation_pass[False]; FAILED tests/discovery_runtime/test_acceptance_scope.py::test_scoped_decision_cannot_add_criteria_for_another_client; FAILED tests/discovery_runtime/test_acceptance_scope.py::test_narrow_source_criterion_cannot_remove_inherited_mode_coverage; 9 failed, 83 passed in 38.05s

Working directory: .
Started: 2026-10-18T09:49:36.693346+00:00
Duration seconds: 39.345
Phase: P2-T7 dimension and acceptance obligations; focused task verification.

## Captured output

```text
.............F.......F..FFF..F............F............................. [ 78%]
..................FF                                                     [100%]
================================== FAILURES ===================================
____ test_unconfigured_optional_dimensions_create_no_obligations_or_passes ____

snapshot_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...rocessing-example'), ('name', 'Example processing system'), ('role', 'legacy-source')))), ('test_roots', ('tests',)))))
snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_unconfigured_optional_dimensions_create_no_obligations_or_passes(
        snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
    ) -> None:
        """Unknown offline/mobile observations remain optional without requirements."""
        snapshot = claim_snapshot(
            snapshot_profile,
            snapshot_catalog,
            feature(
                snapshot_profile,
                offline=dimension("unknown"),
                mobile=dimension("contradictory"),
            ),
        )
        result = validate_dimensions(snapshot, complete=True)
>       assert result.findings == ()
E       AssertionError: assert (Finding(code...ted_paths=())) == ()
E
E         Left contains 2 more items, first extra item: Finding(code='DIMENSION_MISSING', message='Required behavior needs an explicit classification.', next_action='Correct ...docs/workspace-example/feature-contract/feature.json', pointer='/observable_outputs', related_ids=(), related_paths=())
E         Use -v to get more diff

tests\discovery_runtime\test_dimension_rules.py:167: AssertionError
__________ test_client_defaults_classify_but_cannot_approve_waivers ___________

obligation_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...', 'processing-example'), ('name', 'Example processing system'), ('role', 'combined')))), ('test_roots', ('tests',)))))
snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_client_defaults_classify_but_cannot_approve_waivers(
        obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
    ) -> None:
        """Applicability defaults carry no product-decision authority."""
        for classification in ("applicable", "not-applicable"):
            profile = profile_with(
                obligation_profile,
                snapshot_catalog,
                clients=[
                    client(
                        obligation_profile,
                        required_feature_dimensions=["timing"],
                        applicability_defaults={
                            "timing": {
                                "applicability": classification,
                                "rationale": "Default.",
                            }
                        },
                    )
                ],
            )
            snapshot = claim_snapshot(
                profile, snapshot_catalog, feature(profile, timing=dimension("inferred"))
            )
            result = validate_dimensions(snapshot, complete=True)
>           assert bool(result.findings) == (classification == "not-applicable")
E           AssertionError: assert True == ('applicable' == 'not-applicable'
E            +  where True = bool((Finding(code='DIMENSION_MISSING', message='Required behavior needs an explicit classification.', next_action='Correct...act_path='docs/workspace-example/feature-contract/feature.json', pointer='/trigger', related_ids=(), related_paths=())))
E            +    where (Finding(code='DIMENSION_MISSING', message='Required behavior needs an explicit classification.', next_action='Correct...act_path='docs/workspace-example/feature-contract/feature.json', pointer='/trigger', related_ids=(), related_paths=())) = DimensionValidation(obligations=(FeatureObligation(feature=ArtifactRecord(artifact=ArtifactSnapshot(path='docs/workspa...ct_path='docs/workspace-example/feature-contract/feature.json', pointer='/trigger', related_ids=(), related_paths=()))).findings
E
E             - not-applicable
E             ? ----
E             + applicable)

tests\discovery_runtime\test_dimension_rules.py:255: AssertionError
___ test_nested_transitions_and_feature_only_mode_requirements_are_retained ___

snapshot_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...rocessing-example'), ('name', 'Example processing system'), ('role', 'legacy-source')))), ('test_roots', ('tests',)))))
snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_nested_transitions_and_feature_only_mode_requirements_are_retained(
        snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
    ) -> None:
        """Transition behavior is classified at its actual nested schema location."""
        record = feature(
            snapshot_profile,
            **{
                "required_dimensions": ["state_transitions", "offline"],
                "state_transitions": {
                    "behavior": dimension("inferred", applicability="applicable")
                },
                "offline": dimension("inferred", applicability="applicable"),
            },
        )
        result = validate_dimensions(
            claim_snapshot(snapshot_profile, snapshot_catalog, record), complete=True
        )
>       assert result.findings == () and result.obligations[0].requirements.modes == (
            "offline",
            "online",
        )
E       AssertionError: assert ((Finding(code...ted_paths=())) == ()
E
E         Left contains 2 more items, first extra item: Finding(code='DIMENSION_MISSING', message='Required behavior needs an explicit classification.', next_action='Correct ...docs/workspace-example/feature-contract/feature.json', pointer='/observable_outputs', related_ids=(), related_paths=())
E         Use -v to get more diff)

tests\discovery_runtime\test_dimension_rules.py:304: AssertionError
_ test_custom_modes_and_platforms_remain_explicit_acceptance_coordinates[batch] _

snapshot_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...rocessing-example'), ('name', 'Example processing system'), ('role', 'legacy-source')))), ('test_roots', ('tests',)))))
snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
custom = 'batch'

    @pytest.mark.parametrize("custom", ["batch", "satellite"])
    def test_custom_modes_and_platforms_remain_explicit_acceptance_coordinates(
        snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, custom: str
    ) -> None:
        """Closed behavior fields do not manufacture a custom applicability property."""
        profile = profile_with(
            snapshot_profile,
            snapshot_catalog,
            required_modes=[custom],
            required_platforms=[custom],
        )
        result = validate_dimensions(
            claim_snapshot(profile, snapshot_catalog, contract(profile)), complete=True
        )
>       assert result.findings == ()
E       AssertionError: assert (Finding(code...ted_paths=())) == ()
E
E         Left contains 2 more items, first extra item: Finding(code='DIMENSION_MISSING', message='Required behavior needs an explicit classification.', next_action='Correct ...docs/workspace-example/feature-contract/feature.json', pointer='/observable_outputs', related_ids=(), related_paths=())
E         Use -v to get more diff

tests\discovery_runtime\test_dimension_rules.py:324: AssertionError
_ test_custom_modes_and_platforms_remain_explicit_acceptance_coordinates[satellite] _

snapshot_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...rocessing-example'), ('name', 'Example processing system'), ('role', 'legacy-source')))), ('test_roots', ('tests',)))))
snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
custom = 'satellite'

    @pytest.mark.parametrize("custom", ["batch", "satellite"])
    def test_custom_modes_and_platforms_remain_explicit_acceptance_coordinates(
        snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, custom: str
    ) -> None:
        """Closed behavior fields do not manufacture a custom applicability property."""
        profile = profile_with(
            snapshot_profile,
            snapshot_catalog,
            required_modes=[custom],
            required_platforms=[custom],
        )
        result = validate_dimensions(
            claim_snapshot(profile, snapshot_catalog, contract(profile)), complete=True
        )
>       assert result.findings == ()
E       AssertionError: assert (Finding(code...ted_paths=())) == ()
E
E         Left contains 2 more items, first extra item: Finding(code='DIMENSION_MISSING', message='Required behavior needs an explicit classification.', next_action='Correct ...docs/workspace-example/feature-contract/feature.json', pointer='/observable_outputs', related_ids=(), related_paths=())
E         Use -v to get more diff

tests\discovery_runtime\test_dimension_rules.py:324: AssertionError
____ test_reused_assessments_and_requirement_permutations_preserve_results ____

obligation_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...', 'processing-example'), ('name', 'Example processing system'), ('role', 'combined')))), ('test_roots', ('tests',)))))
snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_reused_assessments_and_requirement_permutations_preserve_results(
        obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
    ) -> None:
        """Input ordering does not alter the requirement sets or mutate the snapshot."""
        expected = None
        for identifiers in (("browser", "mobile"), ("mobile", "browser")):
            profile = profile_with(
                obligation_profile,
                snapshot_catalog,
                clients=[client(obligation_profile, name) for name in identifiers],
            )
            snapshot = claim_snapshot(
                profile,
                snapshot_catalog,
                feature(profile, mobile=dimension("inferred", applicability="applicable")),
            )
            index = index_references(snapshot)
            proof = validate_evidence(snapshot, index=index)
            decisions = validate_decisions(snapshot, index=index, evidence=proof)
            result = validate_dimensions(
                snapshot, complete=True, index=index, evidence=proof, decisions=decisions
            )
            projection = tuple(
                (item.client_id, item.requirements) for item in result.obligations
            )
>           assert result.findings == () and (expected is None or projection == expected)
E           AssertionError: assert ((Finding(code...ted_paths=())) == ()
E
E             Left contains 2 more items, first extra item: Finding(code='DIMENSION_MISSING', message='Required behavior needs an explicit classification.', next_action='Correct ...docs/workspace-example/feature-contract/feature.json', pointer='/observable_outputs', related_ids=(), related_paths=())
E             Use -v to get more diff)

tests\discovery_runtime\test_dimension_rules.py:389: AssertionError
___ test_supported_ready_specification_is_not_an_implementation_pass[False] ___

snapshot_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...rocessing-example'), ('name', 'Example processing system'), ('role', 'legacy-source')))), ('test_roots', ('tests',)))))
obligation_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...', 'processing-example'), ('name', 'Example processing system'), ('role', 'combined')))), ('test_roots', ('tests',)))))
snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
target = False

    @pytest.mark.parametrize("target", [False, True])
    def test_supported_ready_specification_is_not_an_implementation_pass(
        snapshot_profile: ProfileV2,
        obligation_profile: ProfileV2,
        snapshot_catalog: SchemaCatalog,
        target: bool,
    ) -> None:
        """Source and target specifications retain distinct ownership and readiness."""
        profile = obligation_profile if target else snapshot_profile
        snapshot = acceptance_graph(profile, snapshot_catalog)
        index = index_references(snapshot)
        proof = validate_evidence(snapshot, index=index)
        decisions = validate_decisions(snapshot, index=index, evidence=proof)
        dimensions = validate_dimensions(
            snapshot, complete=True, index=index, evidence=proof, decisions=decisions
        )
        before = snapshot.sha256
        result = validate_acceptance(
            snapshot,
            complete=True,
            index=index,
            evidence=proof,
            decisions=decisions,
            dimensions=dimensions,
        )
>       assert result.findings == () and len(result.ready) == 1
E       AssertionError: assert ((Finding(code...ted_paths=())) == ()
E
E         Left contains 2 more items, first extra item: Finding(code='ACCEPTANCE_REQUIRED', message='Missing ready criterion/client/platform/mode: */None/browser/online.', ne...ocs/workspace-example/feature-contract/feature.json', pointer='/acceptance_criteria', related_ids=(), related_paths=())
E         Use -v to get more diff)

tests\discovery_runtime\test_acceptance_rules.py:165: AssertionError
_________ test_scoped_decision_cannot_add_criteria_for_another_client _________

obligation_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...', 'processing-example'), ('name', 'Example processing system'), ('role', 'combined')))), ('test_roots', ('tests',)))))
snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_scoped_decision_cannot_add_criteria_for_another_client(
        obligation_profile: ProfileV2,
        snapshot_catalog: SchemaCatalog,
    ) -> None:
        """A browser approval leaves independently supported portable tuples intact."""
        profile = profile_with(
            obligation_profile,
            snapshot_catalog,
            clients=[client(obligation_profile), client(obligation_profile, "portable")],
        )
        policy = decision(
            profile,
            scope=decision_scope(client_ids=["browser"], platforms=["browser"]),
            approval={
                "owner": "owner-example",
                "timestamp": "2026-01-01T00:00:00Z",
                "evidence_refs": [reference("evidence-reference", "approval")],
            },
            resulting_acceptance_criteria=[criterion(id="browser-only", evidence_refs=[])],
        )
        proof = evidence(
            profile,
            kind="decision",
            path="evidence/approval.json",
            changes={"id": "approval", "evidence_id": "approval"},
        )
        snapshot = acceptance_graph(profile, snapshot_catalog, extra=(policy, proof))
        scenario = next(
            a for a in snapshot.artifacts if a.expected_kind == "acceptance-specification"
        )
        fields = as_object(to_plain_value(scenario.document))
        portable = artifact(
            "acceptance-specification",
            "portable",
            repository=profile.repository.id,
            fields={
                **fields,
                "id": "portable",
                "scenario_id": "portable",
                "client_id": "portable",
                "platform_id": "portable",
            },
        )
        snapshot = claim_snapshot(profile, snapshot_catalog, *snapshot.artifacts, portable)
        assert len(validate_decisions(snapshot).approved) == 1
        result = validate_acceptance(snapshot, complete=True)
        assert len(result.ready) == 2
>       assert [f.message for f in result.findings] == [
            "Missing ready criterion/client/platform/mode: "
            "browser-only/browser/browser/online."
        ]
E       AssertionError: assert ['Missing rea...wser/online.'] == ['Missing rea...wser/online.']
E
E         At index 0 diff: 'Missing ready criterion/client/platform/mode: */portable/browser/online.' != 'Missing ready criterion/client/platform/mode: browser-only/browser/browser/online.'
E         Left contains 2 more items, first extra item: 'Missing ready criterion/client/platform/mode: browser-only/browser/browser/online.'
E         Use -v to get more diff

tests\discovery_runtime\test_acceptance_scope.py:156: AssertionError
_____ test_narrow_source_criterion_cannot_remove_inherited_mode_coverage ______

snapshot_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...rocessing-example'), ('name', 'Example processing system'), ('role', 'legacy-source')))), ('test_roots', ('tests',)))))
snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_narrow_source_criterion_cannot_remove_inherited_mode_coverage(
        snapshot_profile: ProfileV2,
        snapshot_catalog: SchemaCatalog,
    ) -> None:
        """Unsupported modes need criteria backed by their own observations or policy."""
        profile = profile_with(
            snapshot_profile, snapshot_catalog, required_modes=["online", "offline"]
        )
        result = validate_acceptance(
            acceptance_graph(profile, snapshot_catalog), complete=True
        )
>       assert [f.message for f in result.findings] == [
            "Missing ready criterion/client/platform/mode: */None/None/offline."
        ]
E       AssertionError: assert ['Missing rea...wser/online.'] == ['Missing rea...one/offline.']
E
E         At index 0 diff: 'Missing ready criterion/client/platform/mode: */None/browser/offline.' != 'Missing ready criterion/client/platform/mode: */None/None/offline.'
E         Left contains 2 more items, first extra item: 'Missing ready criterion/client/platform/mode: */None/browser/online.'
E         Use -v to get more diff

tests\discovery_runtime\test_acceptance_scope.py:173: AssertionError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                       Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\acceptance_rules.py     151      3     76      4    97%   169, 265, 286, 293->292
packages\discovery-runtime\src\drm_copilot_discovery\dimension_rules.py       98      1     32      1    98%   142
----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                        249      4    108      5    97%
Coverage JSON written to file SCRATCH/issue-980-p2t7-coverage.json
Coverage LCOV written to file artifacts/python/lcov.info
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_dimension_rules.py::test_unconfigured_optional_dimensions_create_no_obligations_or_passes
FAILED tests/discovery_runtime/test_dimension_rules.py::test_client_defaults_classify_but_cannot_approve_waivers
FAILED tests/discovery_runtime/test_dimension_rules.py::test_nested_transitions_and_feature_only_mode_requirements_are_retained
FAILED tests/discovery_runtime/test_dimension_rules.py::test_custom_modes_and_platforms_remain_explicit_acceptance_coordinates[batch]
FAILED tests/discovery_runtime/test_dimension_rules.py::test_custom_modes_and_platforms_remain_explicit_acceptance_coordinates[satellite]
FAILED tests/discovery_runtime/test_dimension_rules.py::test_reused_assessments_and_requirement_permutations_preserve_results
FAILED tests/discovery_runtime/test_acceptance_rules.py::test_supported_ready_specification_is_not_an_implementation_pass[False]
FAILED tests/discovery_runtime/test_acceptance_scope.py::test_scoped_decision_cannot_add_criteria_for_another_client
FAILED tests/discovery_runtime/test_acceptance_scope.py::test_narrow_source_criterion_cannot_remove_inherited_mode_coverage
9 failed, 83 passed in 38.05s
```
