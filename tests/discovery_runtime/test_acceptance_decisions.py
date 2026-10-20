"""Verify scoped decisions, linked scenarios and imported source provenance."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import acceptance_generation as generation_module
from drm_copilot_discovery.acceptance_generation import generate_acceptance
from drm_copilot_discovery.acceptance_generation_context import (
    GenerationContext,
    generation_preflight,
)
from drm_copilot_discovery.models import to_plain_value

from tests.discovery_runtime.test_acceptance_generation import (
    amended,
    capture_documents,
    generation_snapshot,
    imported_snapshot,
    source_criterion,
)
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture

if TYPE_CHECKING:
    from typing import Protocol

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.references import ArtifactRecord
    from drm_copilot_discovery.snapshot import DiscoverySnapshot

    class ScenarioSelection(Protocol):
        """Describe the actual selection stage used by defensive branch controls."""

        def scenarios(
            self, source: ArtifactRecord, platform: str | None, mode: str
        ) -> tuple[ArtifactRecord | None, ...]:
            """Return retained matches for typed source/platform/mode inputs.

            Only call-local findings and work change; excess raises ValueError.
            No external effects occur.
            """
            ...


def policy_snapshot(
    catalog: SchemaCatalog, *, status: str = "approved"
) -> DiscoverySnapshot:
    """Return a memory source and scoped decision with separate approval proof.

    catalog is SchemaCatalog and status is a known fixture disposition. Invalid
    fixture values propagate constructors' errors. No files or shared state change.
    """
    snapshot = generation_snapshot(catalog, target=True)
    # Detach known source/proof records before adding the independent policy evidence.
    documents = [
        as_object(to_plain_value(item.document)) for item in snapshot.artifacts
    ]
    proof = next(
        item for item in documents if item["artifact_kind"] == "evidence-reference"
    )
    decision_proof = {
        **proof,
        "id": "decision-evidence-alpha",
        "evidence_id": "decision-evidence-alpha",
        "evidence_type": "decision",
        "runtime_artifact": None,
    }
    policy = load_fixture("product-decision")
    policy.update(
        unspecified_behavior_refs=[],
        status=status,
        affected_platforms=["generic"],
        scope={
            "feature_ids": ["feature-alpha"],
            "client_ids": ["client-alpha"],
            "platforms": ["generic"],
            "modes": ["online"],
            "dimensions": [],
        },
    )
    criterion = as_object(
        cast("list[object]", policy["resulting_acceptance_criteria"])[0]
    )
    criterion.update(id="target-criterion", platforms=["generic"])
    as_object(policy["approval"])["owner"] = snapshot.profile.decision_owners[0]["id"]
    # Inactive policy preserves uncertainty; superseded approval remains historical.
    if status != "approved":
        criterion.update(
            readiness="superseded" if status == "superseded" else "pending",
            expected_result=None,
            pending_reason="Policy remains unresolved.",
        )
        if status != "superseded":
            policy["approval"] = None
    return capture_documents(
        snapshot.profile, catalog, (*documents, decision_proof, policy)
    )


def observation(identifier: str = "scenario-alpha") -> dict[str, object]:
    """Return a structurally complete linked runtime scenario fixture.

    identifier (str) distinguishes recorded observations. No runtime is executed,
    no outcome is invented, and no external state changes; return a fresh dict.
    """
    value = load_fixture("runtime-characterization-scenario")
    value.update(
        id=identifier,
        scenario_id=identifier,
        unresolved_findings=[],
    )
    rows = [value, *map(as_object, cast("list[object]", value["runs"]))]
    # Preserve the recorded run while binding every proof to the captured payload.
    for row in rows:
        row["evidence_refs"] = [
            {"artifact_kind": "evidence-reference", "id": "source-alpha"}
        ]
        # Root and run state captures must agree on retained evidence identity.
        for name in ("pre_state_capture", "post_state_capture"):
            as_object(row[name])["evidence_refs"] = row["evidence_refs"]
        as_object(row["environment"])["client_id"] = None
    return value


@pytest.mark.parametrize("status", ["approved", "proposed", "rejected", "superseded"])
def test_only_current_approved_scoped_policy_can_supply_target_expectations(
    snapshot_catalog: SchemaCatalog,
    status: str,
) -> None:
    """Keep source observations distinct from policy; typed fixtures return None.

    No I/O or source mutation occurs. Inactive policies remain pending and cannot
    replace observed legacy expectations, even when their rationale is populated.
    """
    snapshot = policy_snapshot(snapshot_catalog, status=status)
    result = generate_acceptance(snapshot, kind="target-acceptance")
    # Locate exact explicit criteria rather than relying on digest ordering.
    values = {item.identity.criterion_id: item for item in result.specifications}
    assert len(values) == 2, result.findings
    assert values["criterion-alpha"].document["then"] == (
        "The processor state is active after acknowledgement.",
    )
    target = values["target-criterion"]
    assert target.document["then"] == (
        ("Active state is visible before activation returns.",)
        if status == "approved"
        else None
    )
    assert target.document["expectation_basis"] == (
        "approved-decision" if status == "approved" else "unresolved"
    )
    legacy = generate_acceptance(snapshot, kind="legacy-characterization")
    assert {item.identity.criterion_id for item in legacy.specifications} == {
        "criterion-alpha"
    }
    if status == "approved":
        assert len(result.ready) == 2 and result.findings == (), result.findings
    else:
        assert target not in result.ready


@pytest.mark.parametrize(
    "change", ["scope", "conflict", "invalid-ref", "identity-conflict"]
)
def test_scope_conflicts_and_broken_links_never_create_ready_target_claims(
    snapshot_catalog: SchemaCatalog,
    change: str,
) -> None:
    """Keep authored conflicts/traceability failures visible; return None.

    catalog/change select bounded immutable fixture changes. No external effects
    occur; errors remain findings rather than repaired identities.
    """
    snapshot = policy_snapshot(snapshot_catalog)
    # Resolve the one authored policy rather than relying on capture ordering.
    policy = next(
        as_object(to_plain_value(item.document))
        for item in snapshot.artifacts
        if item.expected_kind == "product-decision"
    )
    # Each branch alters exactly one scope, linkage or identity conflict boundary.
    if change == "scope":
        as_object(policy["scope"])["modes"] = ["offline"]
        snapshot = amended(snapshot, "decision-alpha", policy)
    elif change == "invalid-ref":
        policy["feature_refs"] = [
            {"artifact_kind": "feature-contract", "id": "missing"}
        ]
        snapshot = amended(snapshot, "decision-alpha", policy)
    elif change == "identity-conflict":
        row = as_object(
            cast("list[object]", policy["resulting_acceptance_criteria"])[0]
        )
        row["id"] = "criterion-alpha"
        snapshot = amended(snapshot, "decision-alpha", policy)
    else:
        documents = tuple(
            as_object(to_plain_value(item.document)) for item in snapshot.artifacts
        )
        policy.update(
            id="decision-beta",
            decision_id="decision-beta",
            decision="A contradictory policy.",
        )
        row = as_object(
            cast("list[object]", policy["resulting_acceptance_criteria"])[0]
        )
        row.update(
            id="other-target",
            product_decision_refs=[
                {"artifact_kind": "product-decision", "id": "decision-beta"}
            ],
        )
        snapshot = capture_documents(
            snapshot.profile, snapshot_catalog, (*documents, policy)
        )
    result = generate_acceptance(snapshot, kind="target-acceptance")
    assert all(item.identity.criterion_id == "criterion-alpha" for item in result.ready)
    if change != "scope":
        assert result.ready == () and result.findings
    if change == "identity-conflict":
        assert not result.specifications
        assert any(item.code == "ACCEPTANCE_COLLISION" for item in result.findings)


def test_linked_scenarios_discriminate_ids_without_replacing_criterion_expectations(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Keep two observations distinct using catalog fixture; return None.

    Source/scenario order does not affect results. No runtime or I/O occurs.
    """
    first, second = observation(), observation("scenario-beta")
    as_object(second["action"])["description"] = "Submit another observed action."
    snapshot = generation_snapshot(snapshot_catalog, extras=(second, first))
    result = generate_acceptance(snapshot, kind="legacy-characterization")
    assert len(result.ready) == 2 and result.findings == (), result.findings
    assert {item.identity.linked_scenario for item in result.ready} == {
        (snapshot.profile.repository.id, "scenario-alpha"),
        (snapshot.profile.repository.id, "scenario-beta"),
    }
    assert len({item.document["id"] for item in result.ready}) == 2
    assert {item.document["then"] for item in result.ready} == {
        ("The processor state is active after acknowledgement.",)
    }
    assert (
        generate_acceptance(
            replace(snapshot, artifacts=tuple(reversed(snapshot.artifacts))),
            kind="legacy-characterization",
        )
        == result
    )


@pytest.mark.parametrize(
    "applicability", ["applicable", "unspecified", "not-applicable"]
)
def test_mobile_and_custom_modes_follow_actual_configuration(
    snapshot_catalog: SchemaCatalog,
    applicability: str,
) -> None:
    """Assert mobile/default applicability and offline tags; return None.

    catalog/str inputs alter only memory. Optional names never establish support.
    """
    snapshot = generation_snapshot(
        snapshot_catalog,
        target=True,
        profile_changes={
            "required_modes": ["online", "offline", "batch-job"],
            "required_feature_dimensions": ["mobile"],
        },
    )
    # Edit the authoritative feature classification, not a generated tag or alias.
    source = next(
        as_object(to_plain_value(item.document))
        for item in snapshot.artifacts
        if item.expected_kind == "feature-contract"
    )
    as_object(source["mobile"]).update(
        applicability=applicability, rationale="Explicit fixture classification."
    )
    source["acceptance_criteria"] = [
        source_criterion(snapshot, modes=["online", "offline", "batch-job"])
    ]
    snapshot = amended(snapshot, "feature-alpha", source)
    result = generate_acceptance(snapshot, kind="target-acceptance")
    assert len(result.specifications) == 3
    # Tags describe actual configured coordinates without inventing a client alias.
    for value in result.specifications:
        tags = value.document["tags"]
        assert isinstance(tags, tuple)
        assert ("@offline" in tags) == (value.identity.mode_id == "offline")
        assert ("@mobile" in tags) == (applicability == "applicable")
        assert "@mode_" + value.identity.mode_id in tags


def test_imported_source_retains_original_provenance_and_distinct_target_owner(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Verify captured imported provenance through final public ready membership.

    snapshot_catalog is SchemaCatalog. Returns None; asserts original path/pin/raw
    hash and distinct target ownership without I/O, mutation or expected errors.
    """
    snapshot = imported_snapshot(snapshot_catalog)
    before = snapshot.sha256
    source, target = (
        snapshot.manifest.source_repositories[0],
        snapshot.manifest.target_repositories[0],
    )
    result = generate_acceptance(
        snapshot,
        kind="target-acceptance",
        feature_ids=((source.id, "feature-alpha"),),
    )
    assert result.findings == () and len(result.ready) == 1, result.findings
    assert result.specifications == result.ready
    value = result.ready[0]
    assert value.repository == target and target != source
    assert target.revision != source.revision
    assert value.identity.source_repository_id == source.id
    # Resolve the exact imported descriptor, independent of storage ordering.
    artifact = next(
        item for item in snapshot.artifacts if item.expected_kind == "feature-contract"
    )
    raw = snapshot.file(artifact.path)
    assert raw is not None and artifact.path != artifact.origin_path
    reference = as_object(
        cast("list[object]", value.to_dict()["source_contract_refs"])[0]
    )
    assert reference["repository_id"] == source.id
    assert reference["revision"] == source.revision
    assert reference["artifact_path"] == artifact.origin_path
    assert reference["artifact_sha256"] == raw.sha256
    assert snapshot.sha256 == before


@pytest.mark.parametrize("change", ["foreign-owner", "coordinate", "duplicate"])
def test_linked_scenario_selection_preserves_defensive_boundaries(
    snapshot_catalog: SchemaCatalog, change: str
) -> None:
    """Exercise actual selection guards with already captured in-memory records.

    SchemaCatalog/str fixtures select one boundary. Return None; only the local
    index/findings change, with no I/O or expected exception. Ownership and
    identity ambiguity must block authority; a different coordinate is absent.
    """
    snapshot = generation_snapshot(snapshot_catalog, extras=(observation(),))
    context = GenerationContext(snapshot, generation_preflight(snapshot))
    # Resolve actual records and keep their existing physical link identities.
    source = next(
        item for item in context.index.records if item.kind == "feature-contract"
    )
    scenario = next(
        item
        for item in context.index.records
        if item.kind == "runtime-characterization-scenario"
    )
    assert not context.blocked
    original_owner = scenario.artifact.repository
    if change == "foreign-owner":
        scenario = replace(
            scenario,
            artifact=replace(
                scenario.artifact,
                repository=replace(original_owner, id="other-source"),
            ),
        )
    records = (
        (source, scenario, scenario) if change == "duplicate" else (source, scenario)
    )
    context.index = replace(context.index, records=records)
    selection = cast(
        "ScenarioSelection",
        vars(generation_module)["_Generation"](
            context, "legacy-characterization", (), (), ()
        ),
    )
    selected = selection.scenarios(
        source, "generic", "offline" if change == "coordinate" else "online"
    )
    assert selected == ((scenario,) if change == "duplicate" else (None,))
    if change == "coordinate":
        assert not context.blocked and context.collector.findings == ()
    else:
        assert context.blocked
        assert len(context.collector.findings) == 1
        assert context.collector.findings[0].code == "ACCEPTANCE_SCENARIO"
        assert context.collector.findings[0].message == (
            "Linked scenario ownership differs from its source."
            if change == "foreign-owner"
            else "Linked scenario identity is ambiguous."
        )
    assert source.artifact.repository == original_owner
