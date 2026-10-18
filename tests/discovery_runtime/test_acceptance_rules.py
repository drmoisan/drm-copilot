"""Bind ready expectations and required scenario tuples using memory-only graphs."""

from __future__ import annotations

import hashlib
from dataclasses import replace
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.acceptance_rules import (
    acceptance_source_digest,
    validate_acceptance,
)
from drm_copilot_discovery.decision_rules import validate_decisions
from drm_copilot_discovery.dimension_rules import validate_dimensions
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.models import canonical_json, to_plain_value
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.repository_reader import RepositoryIdentity

from tests.discovery_runtime.test_coverage_scope import profile_with
from tests.discovery_runtime.test_decision_rules import decision, decision_scope
from tests.discovery_runtime.test_dimension_rules import feature
from tests.discovery_runtime.test_dimension_rules import (
    obligation_profile as obligation_profile,
)
from tests.discovery_runtime.test_evidence_rules import PIN, evidence
from tests.discovery_runtime.test_observation_claims import (
    claim_snapshot,
    dimension,
    question,
)
from tests.discovery_runtime.test_references import artifact, reference
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from collections.abc import Sequence

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.snapshot import ArtifactSnapshot, DiscoverySnapshot


def criterion(**changes: object) -> dict[str, object]:
    """Keep criterion expectation, readiness and selectors independent."""
    return {
        "id": "criterion",
        "readiness": "ready",
        "statement": "Invoke behavior.",
        "expected_result": "Expected behavior.",
        "pending_reason": None,
        "evidence_refs": [reference("evidence-reference", "capture")],
        "product_decision_refs": [],
        "client_ids": [],
        "platforms": [],
        "modes": ["online"],
        **changes,
    }


def acceptance_graph(
    profile: ProfileV2,
    catalog: SchemaCatalog,
    *,
    criteria: Sequence[object] | None = None,
    feature_changes: dict[str, object] | None = None,
    changes: dict[str, object] | None = None,
    policy: ArtifactSnapshot | None = None,
    extra: tuple[ArtifactSnapshot, ...] = (),
    proof_changes: dict[str, object] | None = None,
    proof_kind: str = "runtime",
) -> DiscoverySnapshot:
    """Capture source, proof and scenario data without touching filesystem state."""
    source = feature(
        profile,
        acceptance_criteria=[criterion()] if criteria is None else criteria,
        **(feature_changes or {}),
    )
    proof = evidence(
        profile, kind="decision" if policy else proof_kind, changes=proof_changes
    )
    base = claim_snapshot(
        profile, catalog, source, proof, *((policy,) if policy else ()), *extra
    )
    index = index_references(base)
    sources = tuple(item for item in index.records if item.kind == "feature-contract")
    decisions = tuple(
        item for item in index.records if item.kind == "product-decision" and policy
    )
    assert source.document is not None
    client = profile.clients[0] if profile.clients else None
    record = artifact(
        "acceptance-specification",
        "specification",
        repository=profile.repository.id,
        fields={
            "scenario_id": "specification",
            "kind": "target-acceptance" if client else "legacy-characterization",
            "feature_id": "feature",
            "criterion_id": "criterion",
            "client_id": client.id if client else None,
            "platform_id": (
                client.platforms[0]
                if client
                else next(iter(profile.required_platforms), None)
            ),
            "mode_id": "online",
            "readiness": "ready",
            "given": ["Initial conditions."],
            "when": "Invoke behavior.",
            "then": ["Target behavior." if policy else "Expected behavior."],
            "pending_reasons": [],
            "expectation_basis": "approved-decision" if policy else "verified-source",
            "source_contract_refs": [
                {
                    "artifact_kind": "feature-contract",
                    "repository_id": profile.repository.id,
                    "revision": PIN,
                    "artifact_path": source.path,
                    "artifact_sha256": hashlib.sha256(
                        canonical_json(source.document)
                    ).hexdigest(),
                    "feature_id": "feature",
                    "schema_version": "2.0.0",
                }
            ],
            "evidence_refs": (
                [] if policy else [reference("evidence-reference", "capture")]
            ),
            "product_decision_refs": (
                [reference("product-decision", "decision")] if policy else []
            ),
            "source_content_sha256": acceptance_source_digest(sources, decisions),
            **(changes or {}),
        },
    )
    return claim_snapshot(profile, catalog, *base.artifacts, record)


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
    assert result.findings == () and len(result.ready) == 1
    assert snapshot.sha256 == before and "passed" not in result.ready[0].document


@pytest.mark.parametrize(
    "changes",
    [
        {"source_contract_refs": []},
        {"feature_id": "foreign"},
        {"criterion_id": "missing"},
        {"then": ["Invented behavior."]},
        {"when": None},
        {"pending_reasons": ["Unknown."]},
        {"source_content_sha256": "f" * 64},
        {"evidence_refs": []},
        {"expectation_basis": "unresolved"},
        {"client_id": "missing"},
    ],
)
def test_authored_readiness_cannot_replace_exact_support(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    changes: dict[str, object],
) -> None:
    """False source linkage, expectations and proof cannot enter ready results."""
    result = validate_acceptance(
        acceptance_graph(snapshot_profile, snapshot_catalog, changes=changes)
    )
    assert result.ready == () and any(
        f.code == "ACCEPTANCE_CLAIM" for f in result.findings
    )


@pytest.mark.parametrize("state", ["pending", "superseded"])
def test_unready_specs_are_structurally_valid_and_cannot_satisfy_completion(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, state: str
) -> None:
    """Pending specifications preserve uncertainty without satisfying readiness."""
    snapshot = acceptance_graph(
        snapshot_profile,
        snapshot_catalog,
        changes={
            "readiness": state,
            "then": None,
            "expectation_basis": "unresolved",
            "pending_reasons": ["Unknown behavior."],
        },
    )
    assert validate_acceptance(snapshot).findings == ()
    assert any(
        f.code == "ACCEPTANCE_REQUIRED"
        for f in validate_acceptance(snapshot, complete=True).findings
    )


@pytest.mark.parametrize(
    "change",
    [{"readiness": "pending"}, {"expected_result": None}, {"evidence_refs": []}],
)
def test_ready_source_expectation_requires_a_known_evidenced_criterion(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    change: dict[str, object],
) -> None:
    """A scenario cannot promote the readiness of its source criterion."""
    snapshot = acceptance_graph(
        snapshot_profile, snapshot_catalog, criteria=[criterion(**change)]
    )
    assert validate_acceptance(snapshot).ready == ()


@pytest.mark.parametrize(
    "proof_kind,proof_changes",
    [
        ("decision", {}),
        ("runtime", {"revision": "b" * 40}),
        ("runtime", {"checksum": None}),
    ],
)
def test_source_expectations_reject_wrong_pin_or_non_observation_evidence(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    proof_kind: str,
    proof_changes: dict[str, object],
) -> None:
    """Target policy approval and unrelated captures do not prove legacy behavior."""
    snapshot = acceptance_graph(
        snapshot_profile,
        snapshot_catalog,
        proof_kind=proof_kind,
        proof_changes=proof_changes,
    )
    assert validate_acceptance(snapshot).ready == ()


@pytest.mark.parametrize(
    "axis,value",
    [
        ("client_ids", ["mobile"]),
        ("platforms", ["desktop"]),
        ("modes", ["offline"]),
        ("feature_ids", ["other"]),
    ],
)
def test_approved_criterion_must_cover_the_exact_scenario_context(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    axis: str,
    value: list[str],
) -> None:
    """A different approved scope cannot authorize the selected target expectation."""
    policy = decision(obligation_profile, scope=decision_scope(**{axis: value}))
    result = validate_acceptance(
        acceptance_graph(obligation_profile, snapshot_catalog, policy=policy)
    )
    assert result.ready == ()


@pytest.mark.parametrize("status", ["approved", "proposed", "rejected", "superseded"])
def test_only_current_approved_decisions_supply_ready_target_expectations(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog, status: str
) -> None:
    """Proposal/rejection/history cannot provide a required Then statement."""
    snapshot = acceptance_graph(
        obligation_profile,
        snapshot_catalog,
        policy=decision(obligation_profile, status=status),
    )
    result = validate_acceptance(snapshot, complete=True)
    assert bool(result.ready) == (status == "approved")
    if status == "approved":
        assert (
            result.findings == ()
        ), "The approved same-ID target replaces its expectation."


def test_approved_target_acceptance_preserves_open_legacy_observation(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Ready target policy does not relabel an unknown required legacy dimension."""
    profile = profile_with(
        obligation_profile, snapshot_catalog, required_feature_dimensions=["timing"]
    )
    snapshot = acceptance_graph(
        profile,
        snapshot_catalog,
        policy=decision(profile),
        feature_changes={
            "timing": dimension(
                "unknown",
                applicability="applicable",
                unresolved_behavior_refs=[
                    reference("unspecified-behavior", "question")
                ],
            )
        },
        extra=(question(profile, dimensions=["timing"]),),
    )
    assert len(validate_acceptance(snapshot).ready) == 1
    assert any(
        f.code == "DIMENSION_UNRESOLVED"
        for f in validate_dimensions(snapshot, complete=True).findings
    )


@pytest.mark.parametrize(
    "axis,value",
    [("required_modes", ["online", "batch"]), ("required_platforms", ["satellite"])],
)
def test_custom_required_coordinates_cannot_be_satisfied_by_a_different_tuple(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    axis: str,
    value: list[str],
) -> None:
    """Explicit custom platform/mode coordinates participate in scenario accounting."""
    profile = profile_with(snapshot_profile, snapshot_catalog, **{axis: value})
    result = validate_acceptance(
        acceptance_graph(profile, snapshot_catalog, changes={"platform_id": "browser"}),
        complete=True,
    )
    assert any(f.code == "ACCEPTANCE_REQUIRED" for f in result.findings)


def test_required_custom_scenario_matches_the_configured_platform_and_mode(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """A supported explicit custom tuple satisfies its own obligation only."""
    profile = profile_with(
        snapshot_profile,
        snapshot_catalog,
        required_modes=["batch"],
        required_platforms=["satellite"],
    )
    snapshot = acceptance_graph(
        profile,
        snapshot_catalog,
        criteria=[criterion(modes=["batch"], platforms=["satellite"])],
        changes={"mode_id": "batch", "platform_id": "satellite"},
    )
    assert validate_acceptance(snapshot, complete=True).findings == ()


@pytest.mark.parametrize(
    "case", ["missing-criteria", "unknown-client", "optional", "disabled"]
)
def test_required_feature_policy_preserves_incomplete_and_optional_outcomes(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, case: str
) -> None:
    """Only required scenario coverage is controlled by the completion switch."""
    profile = snapshot_profile
    if case == "disabled":
        gates = as_object(to_plain_value(profile.document["completion_gates"]))
        gates["require_acceptance_scenarios"] = False
        profile = profile_with(profile, snapshot_catalog, completion_gates=gates)
    snapshot = acceptance_graph(
        profile,
        snapshot_catalog,
        criteria=(
            []
            if case == "missing-criteria"
            else [criterion(client_ids=["unknown"] if case == "unknown-client" else [])]
        ),
        feature_changes={"target_relevance": "optional"} if case == "optional" else {},
        changes={"readiness": "pending"},
    )
    found = {f.code for f in validate_acceptance(snapshot, complete=True).findings}
    assert found == (
        {"ACCEPTANCE_CRITERIA"}
        if case == "missing-criteria"
        else (
            {"ACCEPTANCE_CLIENT", "ACCEPTANCE_REQUIRED"}
            if case == "unknown-client"
            else set()
        )
    )


@pytest.mark.parametrize("kind", ["legacy-characterization", "target-acceptance"])
def test_specification_owner_pin_is_independent_of_declared_kind(
    snapshot_profile: ProfileV2,
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    kind: str,
) -> None:
    """A source/target identity label cannot replace the trusted snapshot pin."""
    profile = (
        snapshot_profile if kind == "legacy-characterization" else obligation_profile
    )
    snapshot = acceptance_graph(profile, snapshot_catalog)
    changed = tuple(
        (
            replace(
                item,
                repository=RepositoryIdentity(id=item.repository.id, revision="b" * 40),
            )
            if item.expected_kind == "acceptance-specification"
            else item
        )
        for item in snapshot.artifacts
    )
    assert validate_acceptance(replace(snapshot, artifacts=changed)).ready == ()


def test_source_digest_is_order_independent_and_binds_document_and_pin(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Canonical source identity changes for content/pin changes, not permutations."""
    snapshot = acceptance_graph(snapshot_profile, snapshot_catalog)
    records = tuple(
        item
        for item in index_references(snapshot).records
        if item.kind in {"feature-contract", "evidence-reference"}
    )
    assert acceptance_source_digest(records) == acceptance_source_digest(
        tuple(reversed(records)) + records
    )
    changed = (
        replace(
            records[0],
            artifact=replace(
                records[0].artifact,
                repository=RepositoryIdentity(
                    id=records[0].repository, revision="b" * 40
                ),
            ),
        ),
        *records[1:],
    )
    assert acceptance_source_digest(records) != acceptance_source_digest(changed)
