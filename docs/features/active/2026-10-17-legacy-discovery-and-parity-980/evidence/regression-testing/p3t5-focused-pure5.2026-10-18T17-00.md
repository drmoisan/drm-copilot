# p3t5-focused-pure5

Timestamp: 2026-10-18T17-00
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_evidence_linking.py tests/discovery_runtime/test_evidence_payloads.py -k not real_plan and not wrapper and not shared_writer and not actual_captured and not missing_pinned and not payload_integrity and not uri_description and not forwards_native and not injected_plan -x -q
EXIT_CODE: 1
Output Summary: =========================== short test summary info ===========================; FAILED tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[outside-root]; !!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!; 1 failed, 43 passed, 12 deselected in 18.17s

Working directory: .
Started: 2026-10-18T17:00:02.812014+00:00
Duration seconds: 19.290
Phase: P3-T5 evidence registration and linking; focused task verification.

## Captured output

```text
...........................................F
================================== FAILURES ===================================
_ test_shared_planner_rejects_ungranted_stale_or_colliding_writes[outside-root] _

link_baseline = CapturedWorkspace(workspace_root='/workspace', snapshot=DiscoverySnapshot(profile=ProfileV2(document=JsonObject(member...ved_path=None, children=())), ('tests', PathMetadata(kind='missing', identity=None, resolved_path=None, children=()))))
invalid = 'outside-root'

    @pytest.mark.parametrize(
        "invalid", ["grant", "digest", "collision", "outside-root", "duplicate-payload"]
    )
    def test_shared_planner_rejects_ungranted_stale_or_colliding_writes(
        link_baseline: CapturedWorkspace, invalid: str
    ) -> None:
        """The evidence composition cannot bypass accepted kind/path/ID or CAS checks."""
        request = request_for(link_baseline)
        changes = evidence_changes(link_baseline, request)
        grants = grants_for(*changes)
        if invalid == "grant":
            grants = (replace(grants[0], artifact_id="wrong"), *grants[1:])
        elif invalid == "digest":
            request = replace(request, expected_sha256="0" * 64)
        elif invalid == "collision":
            # Create-only registration cannot replace a pre-existing opaque file.
            link_baseline = replace(
                link_baseline,
                snapshot=replace(
                    link_baseline.snapshot,
                    manifest=replace(
                        link_baseline.snapshot.manifest,
                        files=(
                            *link_baseline.snapshot.manifest.files,
                            evidence_plan_file(request.payloads[0]),
                        ),
                    ),
                ),
            )
        elif invalid == "outside-root":
            path = "docs/outside.txt"
            document = as_object(to_plain_value(request.record))
            document["path"] = path
            as_object(document["runtime_artifact"])["path"] = path
            request = replace(
                request,
                record=immutable(document),
                payloads=(EvidencePayload(path=path, content=CONTENT),),
            )
            grants = grants_for(*evidence_changes(link_baseline, request))
        else:
            request = replace(request, payloads=request.payloads * 2)
        with pytest.raises((MutationError, PathPolicyError)) as caught:
            plan_evidence_link(link_baseline, request, grants=grants)
>       assert caught.value.code in {
            "MUTATION_GRANT",
            "MUTATION_PRECONDITION",
            "PATH_OUTPUT_ROOT",
            "PATH_COLLISION",
        }
E       assert 'PATH_WRITE_DENIED' in {'MUTATION_GRANT', 'MUTATION_PRECONDITION', 'PATH_COLLISION', 'PATH_OUTPUT_ROOT'}
E        +  where 'PATH_WRITE_DENIED' = PathPolicyError("PATH_WRITE_DENIED: 'docs/outside.txt': Use the artifact kind's exact configured file or child location.").code
E        +    where PathPolicyError("PATH_WRITE_DENIED: 'docs/outside.txt': Use the artifact kind's exact configured file or child location.") = <ExceptionInfo PathPolicyError("PATH_WRITE_DENIED: 'docs/outside.txt': Use the artifact kind's exact configured file or child location.") tblen=4>.value

tests\discovery_runtime\test_evidence_payloads.py:256: AssertionError
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[outside-root]
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!
1 failed, 43 passed, 12 deselected in 18.17s
```
