# p2t7-origin-regression-pass10

Timestamp: 2026-10-18T09-56
Command: poetry run pytest tests/discovery_runtime/test_acceptance_scope.py -k scoped_decision_cannot -o addopts=-ra --no-cov -q
EXIT_CODE: 1
Output Summary: tests\discovery_runtime\test_acceptance_scope.py:163: AssertionError; =========================== short test summary info ===========================; FAILED tests/discovery_runtime/test_acceptance_scope.py::test_scoped_decision_cannot_add_criteria_for_another_client[criterion]; 1 failed, 1 passed, 12 deselected in 1.53s

Working directory: .
Started: 2026-10-18T09:56:25.523816+00:00
Duration seconds: 2.651
Phase: P2-T7 dimension and acceptance obligations; focused task verification.

## Captured output

```text
.F                                                                       [100%]
================================== FAILURES ===================================
___ test_scoped_decision_cannot_add_criteria_for_another_client[criterion] ____

obligation_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...', 'processing-example'), ('name', 'Example processing system'), ('role', 'combined')))), ('test_roots', ('tests',)))))
snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
identifier = 'criterion'

    @pytest.mark.parametrize("identifier", ["browser-only", "criterion"])
    def test_scoped_decision_cannot_add_criteria_for_another_client(
        obligation_profile: ProfileV2,
        snapshot_catalog: SchemaCatalog,
        identifier: str,
    ) -> None:
        """A browser approval leaves independently supported portable tuples intact."""
        profile = profile_with(
            obligation_profile,
            snapshot_catalog,
            clients=[client(obligation_profile), client(obligation_profile, "portable")],
            required_platforms=[],
        )
        policy = decision(
            profile,
            scope=decision_scope(client_ids=["browser"], platforms=["browser"]),
            approval={
                "owner": "owner-example",
                "timestamp": "2026-01-01T00:00:00Z",
                "evidence_refs": [reference("evidence-reference", "approval")],
            },
            resulting_acceptance_criteria=[
                criterion(
                    id=identifier, evidence_refs=[], expected_result="Approved target."
                )
            ],
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
            f"{identifier}/browser/browser/online."
        ]
E       AssertionError: assert [] == ['Missing rea...wser/online.']
E
E         Right contains one more item: 'Missing ready criterion/client/platform/mode: criterion/browser/browser/online.'
E         Use -v to get more diff

tests\discovery_runtime\test_acceptance_scope.py:163: AssertionError
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_acceptance_scope.py::test_scoped_decision_cannot_add_criteria_for_another_client[criterion]
1 failed, 1 passed, 12 deselected in 1.53s
```
