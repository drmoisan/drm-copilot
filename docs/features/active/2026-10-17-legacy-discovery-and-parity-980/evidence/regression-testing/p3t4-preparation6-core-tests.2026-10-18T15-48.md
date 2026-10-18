# p3t4-preparation6-core-tests

Timestamp: 2026-10-18T15-48
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_draft_contracts.py tests/discovery_runtime/test_draft_scenarios.py -k nested_transition or projects_truthful_graph or contract_creation_uses or multifeature_scenario or scenario_shared_commit -v -x --junitxml=SCRATCH/issue-980-p3t4-preparation6-core-tests.xml
EXIT_CODE: 1
Output Summary: =========================== short test summary info ===========================; FAILED tests/discovery_runtime/test_draft_scenarios.py::test_multifeature_scenario_preserves_unknown_expectation_and_linked_question[False]; !!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!; =========== 1 failed, 19 passed, 53 deselected in 91.70s (0:01:31) ============

Working directory: .
Started: 2026-10-18T15:47:18.279932+00:00
Duration seconds: 92.748
Phase: P3-T4 contract and scenario drafting; focused task verification.

## Captured output

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 76 items / 53 deselected / 23 selected

tests/discovery_runtime/test_draft_contracts.py::test_contract_projects_truthful_graph_with_inherited_dimensions[False] PASSED [  4%]
tests/discovery_runtime/test_draft_contracts.py::test_contract_projects_truthful_graph_with_inherited_dimensions[True] PASSED [  8%]
tests/discovery_runtime/test_draft_contracts.py::test_contract_creation_uses_shared_writer_without_changing_unrelated_content[True] PASSED [ 13%]
tests/discovery_runtime/test_draft_contracts.py::test_contract_creation_uses_shared_writer_without_changing_unrelated_content[False] PASSED [ 17%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[inferred-False-before] PASSED [ 21%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[inferred-False-action] PASSED [ 26%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[inferred-False-after] PASSED [ 30%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[verified-False-before] PASSED [ 34%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[verified-False-action] PASSED [ 39%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[verified-False-after] PASSED [ 43%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[intentionally-unspecified-False-before] PASSED [ 47%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[intentionally-unspecified-False-action] PASSED [ 52%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[intentionally-unspecified-False-after] PASSED [ 56%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-False-before] PASSED [ 60%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-False-action] PASSED [ 65%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-False-after] PASSED [ 69%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-True-before] PASSED [ 73%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-True-action] PASSED [ 78%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-True-after] PASSED [ 82%]
tests/discovery_runtime/test_draft_scenarios.py::test_multifeature_scenario_preserves_unknown_expectation_and_linked_question[False] FAILED [ 86%]

================================== FAILURES ===================================
_ test_multifeature_scenario_preserves_unknown_expectation_and_linked_question[False] _

mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
custom = False

    @pytest.mark.parametrize("custom", [False, True])
    def test_multifeature_scenario_preserves_unknown_expectation_and_linked_question(
        mutation_catalog: SchemaCatalog, custom: bool
    ) -> None:
        """The complete graph remains structurally valid with exact custom-root outputs."""
        store, baseline = scenario_case(mutation_catalog, custom=custom)
        request = ScenarioDraft(
            scenario_id="selected-scenario",
            feature_ids=("second", "first"),
            fields=scenario_fields(),
        )
        changes = scenario_changes(baseline, request)
>       plan = plan_scenario(baseline, request, grants=grants_for(*changes))
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_draft_scenarios.py:87:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
packages\discovery-runtime\src\drm_copilot_discovery\draft_scenarios.py:183: in plan_scenario
    return plan_mutation(
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

baseline = CapturedWorkspace(workspace_root='/workspace', snapshot=DiscoverySnapshot(profile=ProfileV2(document=JsonObject(member...ved_path=None, children=())), ('tests', PathMetadata(kind='missing', identity=None, resolved_path=None, children=()))))
changes = (MutationChange(artifact_kind='runtime-characterization-scenario', artifact_id='selected-scenario', path='docs/migrati...n"}],"schema_version":"2.0.0"}\n', expected_sha256='1d8225a59c2d3e251739a16c6ab71b441b4eff8e2e0dec683ae54160240ced07'))

    def plan_mutation(
        baseline: CapturedWorkspace,
        changes: tuple[MutationChange, ...],
        *,
        grants: tuple[WriteGrant, ...],
        invocation: InvocationContext | None = None,
    ) -> MutationPlan:
        """Validate all prospective bytes before returning an immutable commit plan.

        Grants and optional native invocation must be authenticated by the caller.
        Absence of invocation is the explicit local-user/root route, not an analyst
        fallback. Invalid requests raise MutationError/ValueError/OSError; no writes
        or authority-store operations occur, including during repeated dry runs.
        """
        if not changes or len(changes) > baseline.snapshot.profile.limits.artifact_records:
            raise MutationError("MUTATION_LIMIT", "Provide a bounded nonempty change set")
        changes = tuple(sorted(changes, key=lambda item: item.path))
        # Reject platform aliases before mapping exact requested identities to grants.
        check_path_collisions(item.path for item in changes)
        # Grants also require unique paths; dictionary insertion must not discard authority.
        check_path_collisions(grant.path for grant in grants)
        # Index authenticated capabilities independently from caller-proposed changes.
        permitted = {grant.path: grant for grant in grants}
        # Original bytes and parsed identities remain separate preconditions.
        files = {item.path: item for item in baseline.snapshot.manifest.files}
        # Imported artifact identities cannot be overwritten as locally authored records.
        originals = {item.path: item for item in baseline.snapshot.artifacts}
        policy = PathPolicy(
            baseline.snapshot.profile,
            workspace_root=baseline.workspace_root,
            metadata=baseline.inspect,
        )
        if invocation is not None and (
            invocation.baseline.sha256 != baseline.snapshot.sha256
            or invocation.workspace.get("workspace_root") != baseline.workspace_root
        ):
            raise MutationError("MUTATION_CONTEXT", "Invocation baseline/workspace differs")
        writes: list[PlannedWrite] = []
        # Exact trusted grants and original-byte preconditions precede any projection.
        for change in changes:
            grant = permitted.get(change.path)
            if grant is None or grant != WriteGrant(
                artifact_kind=change.artifact_kind,
                artifact_id=change.artifact_id,
                path=change.path,
            ):
                raise MutationError("MUTATION_GRANT", "No exact kind/ID/path write grant")
            prior = files.get(change.path)
            if change.expected_sha256 != (prior.sha256 if prior else None):
                raise MutationError(
                    "MUTATION_PRECONDITION", "Original content digest differs"
                )
            original = originals.get(change.path)
            if original is not None and (
                original.expected_kind != change.artifact_kind
                or original.origin_path is not None
                or original.document is not None
                and original.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Existing artifact identity differs"
                )
            if len(change.content) > baseline.snapshot.profile.limits.document_bytes:
                raise MutationError(
                    "MUTATION_LIMIT", "Proposed content exceeds document limit"
                )
            writes.append(
                PlannedWrite(
                    change=change,
                    target=policy.resolve_write(change.path, grant=grant),
                    skipped=prior is not None and prior.content == change.content,
                )
            )
        prospective = project_snapshot(baseline, changes)
        # Only loader-classified artifacts establish the proposed structured identities.
        artifacts = {item.path: item for item in prospective.artifacts}
        # Loader-derived kinds and document IDs must agree with granted output identities.
        for change in changes:
            artifact = artifacts.get(change.path)
            opaque = (
                change.artifact_kind == "evidence-payload"
                and prospective.file(change.path).category == "evidence"
                or change.artifact_kind == "acceptance-view"
                and change.path.endswith((".md", ".feature"))
            )
            # A Markdown report view must name the same kind/ID as its structured peer.
            if change.artifact_kind in REPORT_KINDS and change.path.endswith(".md"):
                artifact = artifacts.get(change.path[:-3] + ".json")
            if artifact is None and opaque:
                continue
            if (
                artifact is None
                or artifact.expected_kind != change.artifact_kind
                or artifact.document is None
                or artifact.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Proposed artifact kind/ID differs"
                )
        validation = validate_snapshot(
            prospective,
            mode="agent-output" if invocation else "structural",
            invocation=invocation,
        )
        if not validation.ok:
>           raise MutationError(
                "MUTATION_INVALID",
                "Prospective graph is invalid",
                findings=validation.findings,
            )
E           drm_copilot_discovery.mutation_plan.MutationError: MUTATION_INVALID: Prospective graph is invalid

packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py:374: MutationError
- generated xml file: SCRATCH\issue-980-p3t4-preparation6-core-tests.xml -
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_draft_scenarios.py::test_multifeature_scenario_preserves_unknown_expectation_and_linked_question[False]
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!
=========== 1 failed, 19 passed, 53 deselected in 91.70s (0:01:31) ============
```
