# p3t5-preparation-tests10

Timestamp: 2026-10-18T17-11
Command: poetry run python SCRATCH/issue-980-p3t5-tests.py diagnostic10
EXIT_CODE: 1
Output Summary: FAILED tests/discovery_runtime/test_evidence_payloads.py::test_source_and_test_records_use_actual_captured_immutable_objects[source]; !!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!; ================== 1 failed, 56 passed in 232.71s (0:03:52) ===================; {"started_at_utc": "2026-10-18T17:07:57.417089+00:00", "ended_at_utc": "2026-10-18T17:11:50.384068+00:00", "elapsed_seconds": 232.96697660000063, "pytest_exit": 1, "source_hashes_before": {"packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py": "98a0b6dda37acb98fe143ce680f3a5caa3b65eccc15047394c1929d1a0cc4f18", "tests/discovery_runtime/test_evidence_linking.py": "2964f9b9f9fb194c95ca51d5e304f03bae86e0908c9223a1b5791d49b6a5285b", "tests/discovery_runtime/test_evidence_payloads.py": "ebdb5d35ee79108d7c87abb9aa6f662542e0fcd27cc169478a8769e6985e8fe5", "tests/discovery_runtime/evidence_test_support.py": "bf84d9146bcac7ccbdb0fb6f712e15ae9aff176f0bb232c3f03ed6b3374695e3"}, "source_hashes_after": {"packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py": "98a0b6dda37acb98fe143ce680f3a5caa3b65eccc15047394c1929d1a0cc4f18", "tests/discovery_runtime/test_evidence_linking.py": "2964f9b9f9fb194c95ca51d5e304f03bae86e0908c9223a1b5791d49b6a5285b", "tests/discovery_runtime/test_evidence_payloads.py": "ebdb5d35ee79108d7c87abb9aa6f662542e0fcd27cc169478a8769e6985e8fe5", "tests/discovery_runtime/evidence_test_support.py": "bf84d9146bcac7ccbdb0fb6f712e15ae9aff176f0bb232c3f03ed6b3374695e3"}, "source_stable": true, "reverse": false}

Working directory: .
Started: 2026-10-18T17:07:56.507083+00:00
Duration seconds: 233.967
Phase: P3-T5 evidence registration and linking; focused task verification.

## Captured output

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 61 items

tests/discovery_runtime/test_evidence_linking.py::test_collection_member_update_preserves_siblings_and_approval[product-decision] PASSED [  1%]
tests/discovery_runtime/test_evidence_linking.py::test_collection_member_update_preserves_siblings_and_approval[unspecified-behavior] PASSED [  3%]
tests/discovery_runtime/test_evidence_linking.py::test_duplicate_evidence_identity_is_rejected_before_proposing_writes[evidence_id] PASSED [  4%]
tests/discovery_runtime/test_evidence_linking.py::test_duplicate_evidence_identity_is_rejected_before_proposing_writes[id] PASSED [  6%]
tests/discovery_runtime/test_evidence_linking.py::test_evidence_link_cannot_create_a_product_approval PASSED [  8%]
tests/discovery_runtime/test_evidence_linking.py::test_existing_links_are_preserved_and_exact_repeat_is_not_duplicated[False] PASSED [  9%]
tests/discovery_runtime/test_evidence_linking.py::test_existing_links_are_preserved_and_exact_repeat_is_not_duplicated[True] PASSED [ 11%]
tests/discovery_runtime/test_evidence_linking.py::test_invalid_captured_input_remains_an_explicit_prewrite_error PASSED [ 13%]
tests/discovery_runtime/test_evidence_linking.py::test_malformed_evidence_is_rejected_by_the_accepted_schema[change0] PASSED [ 14%]
tests/discovery_runtime/test_evidence_linking.py::test_malformed_evidence_is_rejected_by_the_accepted_schema[change1] PASSED [ 16%]
tests/discovery_runtime/test_evidence_linking.py::test_malformed_evidence_is_rejected_by_the_accepted_schema[change2] PASSED [ 18%]
tests/discovery_runtime/test_evidence_linking.py::test_malformed_evidence_is_rejected_by_the_accepted_schema[change3] PASSED [ 19%]
tests/discovery_runtime/test_evidence_linking.py::test_nested_evidence_is_linked_without_promoting_observation[path0] PASSED [ 21%]
tests/discovery_runtime/test_evidence_linking.py::test_nested_evidence_is_linked_without_promoting_observation[path1] PASSED [ 22%]
tests/discovery_runtime/test_evidence_linking.py::test_only_core_existing_evidence_arrays_are_eligible[path0] PASSED [ 24%]
tests/discovery_runtime/test_evidence_linking.py::test_only_core_existing_evidence_arrays_are_eligible[path1] PASSED [ 26%]
tests/discovery_runtime/test_evidence_linking.py::test_only_core_existing_evidence_arrays_are_eligible[path2] PASSED [ 27%]
tests/discovery_runtime/test_evidence_linking.py::test_only_core_existing_evidence_arrays_are_eligible[path3] PASSED [ 29%]
tests/discovery_runtime/test_evidence_linking.py::test_only_core_existing_evidence_arrays_are_eligible[path4] PASSED [ 31%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[decision] PASSED [ 32%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[documentation] PASSED [ 34%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[inventory] PASSED [ 36%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[observation] PASSED [ 37%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[runtime] PASSED [ 39%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[source] PASSED [ 40%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[test] PASSED [ 42%]
tests/discovery_runtime/test_evidence_linking.py::test_target_must_resolve_to_one_local_record[duplicate] PASSED [ 44%]
tests/discovery_runtime/test_evidence_linking.py::test_target_must_resolve_to_one_local_record[imported] PASSED [ 45%]
tests/discovery_runtime/test_evidence_linking.py::test_target_must_resolve_to_one_local_record[missing] PASSED [ 47%]
tests/discovery_runtime/test_evidence_payloads.py::test_custom_root_controls_record_and_supplied_payload_locations PASSED [ 49%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_paths_reject_escape_without_filesystem_access[../escape.txt] PASSED [ 50%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_paths_reject_escape_without_filesystem_access[/absolute.txt] PASSED [ 52%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_paths_reject_escape_without_filesystem_access[EXTERNAL_PATH PASSED [ 54%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_paths_reject_escape_without_filesystem_access[evidence/../escape.txt] PASSED [ 55%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_requires_exact_immutable_bytes PASSED [ 57%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes0] PASSED [ 59%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes1] PASSED [ 60%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes2] PASSED [ 62%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes3] PASSED [ 63%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes4] PASSED [ 65%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes5] PASSED [ 67%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes6] PASSED [ 68%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_detaches_caller_sequences PASSED [ 70%]
tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[collision] PASSED [ 72%]
tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[digest] PASSED [ 73%]
tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[duplicate-payload] PASSED [ 75%]
tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[grant] PASSED [ 77%]
tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[outside-root] PASSED [ 78%]
tests/discovery_runtime/test_evidence_payloads.py::test_unrelated_payload_cannot_be_added_to_an_evidence_operation PASSED [ 80%]
tests/discovery_runtime/test_evidence_linking.py::test_real_plan_validates_local_bytes_and_preserves_unknown_state PASSED [ 81%]
tests/discovery_runtime/test_evidence_linking.py::test_shared_writer_commits_or_reports_explicit_partial_failure[False] PASSED [ 83%]
tests/discovery_runtime/test_evidence_linking.py::test_shared_writer_commits_or_reports_explicit_partial_failure[True] PASSED [ 85%]
tests/discovery_runtime/test_evidence_linking.py::test_wrapper_forwards_exact_context_grants_and_dry_run PASSED [ 86%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_integrity_uses_both_exact_declared_paths[checksum] PASSED [ 88%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_integrity_uses_both_exact_declared_paths[second-capture] PASSED [ 90%]
tests/discovery_runtime/test_evidence_payloads.py::test_planner_forwards_native_context_and_exact_grants_without_creation PASSED [ 91%]
tests/discovery_runtime/test_evidence_payloads.py::test_source_and_test_records_use_actual_captured_immutable_objects[source] FAILED [ 93%]

================================== FAILURES ===================================
_ test_source_and_test_records_use_actual_captured_immutable_objects[source] __

link_baseline = CapturedWorkspace(workspace_root='/workspace', snapshot=DiscoverySnapshot(profile=ProfileV2(document=JsonObject(member...ved_path=None, children=())), ('tests', PathMetadata(kind='missing', identity=None, resolved_path=None, children=()))))
kind = 'source'

    @pytest.mark.parametrize("kind", ["source", "test"])
    def test_source_and_test_records_use_actual_captured_immutable_objects(
        link_baseline: CapturedWorkspace, kind: str
    ) -> None:
        """A full pin and matching retained Git bytes pass prospective validation."""
        request = replace(
            request_for(
                link_baseline,
                kind=kind,
                updates={
                    "path": "src/code.py" if kind == "source" else "tests/test_code.py"
                },
            ),
            payloads=(),
        )
        retained = RepositoryFile(
            repository=RepositoryIdentity(
                id=link_baseline.snapshot.profile.repository.id, revision="a" * 40
            ),
            path=str(request.record["path"]),
            content=CONTENT,
        )
        baseline = replace(
            link_baseline,
            snapshot=replace(link_baseline.snapshot, repository_files=(retained,)),
        )
        changes = evidence_changes(baseline, request)
>       result = plan_evidence_link(baseline, request, grants=grants_for(*changes))
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_evidence_payloads.py:142:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
packages\discovery-runtime\src\drm_copilot_discovery\evidence_linking.py:301: in plan_evidence_link
    plan = plan_mutation(
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

baseline = CapturedWorkspace(workspace_root='/workspace', snapshot=DiscoverySnapshot(profile=ProfileV2(document=JsonObject(member...ved_path=None, children=())), ('tests', PathMetadata(kind='missing', identity=None, resolved_path=None, children=()))))
changes = (MutationChange(artifact_kind='evidence-reference', artifact_id='proof', path='docs/migration/discovery/evidence/proof...":"unknown-feature-feature"}]}\n', expected_sha256='0c21868d38153eb39aa9d63fdde08c4b435c9ae5b0eb5a5dacaf4f6b6a24b59a'))

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
- generated xml file: SCRATCH\issue-980-p3t5-diagnostic10-tests.xml -
============================= slowest 8 durations =============================
84.54s call     tests/discovery_runtime/test_evidence_linking.py::test_shared_writer_commits_or_reports_explicit_partial_failure[False]
38.22s call     tests/discovery_runtime/test_evidence_linking.py::test_shared_writer_commits_or_reports_explicit_partial_failure[True]
14.84s setup    tests/discovery_runtime/test_evidence_linking.py::test_real_plan_validates_local_bytes_and_preserves_unknown_state
8.79s call     tests/discovery_runtime/test_evidence_linking.py::test_wrapper_forwards_exact_context_grants_and_dry_run
8.27s setup    tests/discovery_runtime/test_evidence_payloads.py::test_planner_forwards_native_context_and_exact_grants_without_creation
8.14s call     tests/discovery_runtime/test_evidence_payloads.py::test_source_and_test_records_use_actual_captured_immutable_objects[source]
7.44s call     tests/discovery_runtime/test_evidence_payloads.py::test_payload_integrity_uses_both_exact_declared_paths[checksum]
7.36s call     tests/discovery_runtime/test_evidence_payloads.py::test_payload_integrity_uses_both_exact_declared_paths[second-capture]
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_evidence_payloads.py::test_source_and_test_records_use_actual_captured_immutable_objects[source]
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!
================== 1 failed, 56 passed in 232.71s (0:03:52) ===================
{"started_at_utc": "2026-10-18T17:07:57.417089+00:00", "ended_at_utc": "2026-10-18T17:11:50.384068+00:00", "elapsed_seconds": 232.96697660000063, "pytest_exit": 1, "source_hashes_before": {"packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py": "98a0b6dda37acb98fe143ce680f3a5caa3b65eccc15047394c1929d1a0cc4f18", "tests/discovery_runtime/test_evidence_linking.py": "2964f9b9f9fb194c95ca51d5e304f03bae86e0908c9223a1b5791d49b6a5285b", "tests/discovery_runtime/test_evidence_payloads.py": "ebdb5d35ee79108d7c87abb9aa6f662542e0fcd27cc169478a8769e6985e8fe5", "tests/discovery_runtime/evidence_test_support.py": "bf84d9146bcac7ccbdb0fb6f712e15ae9aff176f0bb232c3f03ed6b3374695e3"}, "source_hashes_after": {"packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py": "98a0b6dda37acb98fe143ce680f3a5caa3b65eccc15047394c1929d1a0cc4f18", "tests/discovery_runtime/test_evidence_linking.py": "2964f9b9f9fb194c95ca51d5e304f03bae86e0908c9223a1b5791d49b6a5285b", "tests/discovery_runtime/test_evidence_payloads.py": "ebdb5d35ee79108d7c87abb9aa6f662542e0fcd27cc169478a8769e6985e8fe5", "tests/discovery_runtime/evidence_test_support.py": "bf84d9146bcac7ccbdb0fb6f712e15ae9aff176f0bb232c3f03ed6b3374695e3"}, "source_stable": true, "reverse": false}
```
