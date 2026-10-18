"""Validate target approvals and resolutions with isolated in-memory evidence."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.decision_rules import validate_decisions
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.profile_v2 import ProfileV2
from drm_copilot_discovery.references import index_references

from tests.discovery_runtime.test_evidence_rules import configured, evidence
from tests.discovery_runtime.test_observation_claims import (
    claim_snapshot,
    contract,
    question,
)
from tests.discovery_runtime.test_references import artifact, reference
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.snapshot import ArtifactSnapshot, DiscoverySnapshot


@pytest.fixture(scope="module")
def decision_profile(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> ProfileV2:
    """Reuse only an immutable profile with two explicit target client identities."""
    base = configured(snapshot_profile, snapshot_catalog)
    document = as_object(to_plain_value(base.document))
    document["clients"] = [
        {
            "id": name,
            "target_repository": base.repository.id,
            "platforms": [name],
            "modes": ["online", "offline"],
            "required_feature_dimensions": [],
            "applicability_defaults": {},
        }
        for name in ("browser", "mobile")
    ]
    return ProfileV2(json.dumps(document), format="json", catalog=snapshot_catalog)


def decision_scope(**changes: object) -> dict[str, object]:
    """Return fresh selectors where empty non-feature lists are unrestricted."""
    return {
        "feature_ids": ["feature"],
        "client_ids": [],
        "platforms": [],
        "modes": [],
        "dimensions": [],
        **changes,
    }


def decision(
    profile: ProfileV2,
    identifier: str = "decision",
    *,
    status: str = "approved",
    overrides: dict[str, object] | None = None,
    **changes: object,
) -> ArtifactSnapshot:
    """Build a decision whose declared approval is independent of payload proof."""
    approved = status in ("approved", "superseded")
    return artifact(
        "product-decision",
        identifier,
        repository=profile.repository.id,
        fields={
            "$schema": "urn:drm-copilot:discovery:2.0.0:product-decision",
            "schema_version": "2.0.0",
            "decision_id": identifier,
            "decision_key": "behavior",
            "status": status,
            "feature_refs": [reference("feature-contract", "feature")],
            "unspecified_behavior_refs": [],
            "scope": decision_scope(),
            "decision": "Chosen target policy.",
            "rationale": "Owner rationale.",
            "required_migration_behavior": "Required target behavior.",
            "affected_platforms": [],
            "alternatives": [],
            "approval": (
                {
                    "owner": "owner-example",
                    "timestamp": "2026-01-01T00:00:00Z",
                    "evidence_refs": [reference("evidence-reference", "capture")],
                }
                if approved
                else None
            ),
            "resulting_acceptance_criteria": [
                {
                    "id": "criterion",
                    "readiness": (
                        "superseded"
                        if status == "superseded"
                        else "ready" if approved else "pending"
                    ),
                    "statement": "Target behavior.",
                    "expected_result": "Target behavior." if approved else None,
                    "pending_reason": None if approved else "Owner approval pending.",
                    "evidence_refs": [],
                    "product_decision_refs": [
                        reference("product-decision", identifier)
                    ],
                    "client_ids": [],
                    "platforms": [],
                    "modes": [],
                }
            ],
            "supersedes": [],
            "extensions": {},
            **(overrides or {}),
            **changes,
        },
    )


def decision_snapshot(
    profile: ProfileV2, catalog: SchemaCatalog, *records: ArtifactSnapshot
) -> DiscoverySnapshot:
    """Supply one linked feature and an actual local approval payload in memory."""
    return claim_snapshot(
        profile,
        catalog,
        contract(profile),
        evidence(profile, kind="decision"),
        *records,
    )


def resolved_question(profile: ProfileV2, **changes: object) -> ArtifactSnapshot:
    """Represent a target resolution without claiming the historical facts changed."""
    fields: dict[str, object] = {
        "status": "resolved",
        "resolution_basis": "approved-decision",
        "decision_owner": "owner-example",
        "decision_ref": reference("product-decision", "decision"),
        "decision": "Chosen target policy.",
        "rationale": "Apply the explicit owner choice.",
        "approved_target_behavior": "Required target behavior.",
        "resolution_evidence_refs": [],
        **changes,
    }
    return question(profile, **fields)


def test_approved_decision_returns_scoped_eligibility_without_mutating_inputs(
    decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Owner proof permits target policy while source state remains inferred."""
    snapshot = decision_snapshot(
        decision_profile, snapshot_catalog, decision(decision_profile)
    )
    before = snapshot.sha256
    index = index_references(snapshot)
    result = validate_decisions(
        snapshot, index=index, evidence=validate_evidence(snapshot, index=index)
    )
    assert result.findings == ()
    assert [item.record.id for item in result.approved] == ["decision"]
    assert result.approved[0].scope.features == frozenset(
        {(decision_profile.repository.id, "feature")}
    )
    assert snapshot.sha256 == before


@pytest.mark.parametrize("status", ["proposed", "rejected"])
@pytest.mark.parametrize("readiness", ["pending", "ready"])
def test_unapproved_decisions_never_establish_ready_target_requirements(
    decision_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    status: str,
    readiness: str,
) -> None:
    """Pending drafts stay valid; ready criteria cannot approve a proposal."""
    record = decision(
        decision_profile,
        status=status,
        resulting_acceptance_criteria=[{"id": "criterion", "readiness": readiness}],
    )
    result = validate_decisions(
        decision_snapshot(decision_profile, snapshot_catalog, record)
    )
    assert result.approved == ()
    assert {f.code for f in result.findings} == (
        {"DECISION_TARGET"} if readiness == "ready" else set()
    )


@pytest.mark.parametrize(
    "change",
    [
        "missing",
        "unknown-owner",
        "bad-time",
        "missing-time",
        "no-proof",
        "broken-proof",
    ],
)
def test_approval_metadata_and_references_require_real_owner_authority(
    decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog, change: str
) -> None:
    """A status label cannot replace the configured owner, timestamp or evidence."""
    approval: object = {
        "owner": "owner-example",
        "timestamp": "2026-01-01T00:00:00Z",
        "evidence_refs": [reference("evidence-reference", "capture")],
    }
    if change == "missing":
        approval = None
    else:
        values = as_object(approval)
        if change == "unknown-owner":
            values["owner"] = "analyst"
        elif change in ("bad-time", "missing-time"):
            values["timestamp"] = "yesterday" if change == "bad-time" else None
        else:
            values["evidence_refs"] = (
                []
                if change == "no-proof"
                else [reference("evidence-reference", "absent")]
            )
    result = validate_decisions(
        decision_snapshot(
            decision_profile,
            snapshot_catalog,
            decision(decision_profile, approval=approval),
        )
    )
    assert result.approved == () and result.findings
    assert all(item.code.startswith("DECISION_APPROVAL") for item in result.findings)


@pytest.mark.parametrize("change", ["wrong-type", "checksum", "uri-only", "foreign"])
def test_approval_evidence_must_be_local_intact_and_match_owner_requirements(
    decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog, change: str
) -> None:
    """Unrelated or descriptive payloads cannot grant target-policy eligibility."""
    changes: dict[str, object] = {}
    if change == "checksum":
        changes["checksum"] = None
    elif change == "uri-only":
        changes.update(path=None, uri="https://example.invalid/approval")
    elif change == "foreign":
        changes["repository"] = "foreign"
    proof = evidence(
        decision_profile,
        kind="documentation" if change == "wrong-type" else "decision",
        changes=changes,
    )
    snapshot = claim_snapshot(
        decision_profile,
        snapshot_catalog,
        contract(decision_profile),
        proof,
        decision(decision_profile),
    )
    result = validate_decisions(snapshot)
    assert result.approved == ()
    assert {f.code for f in result.findings} == {"DECISION_APPROVAL_EVIDENCE"}


def test_every_configured_evidence_type_is_required_not_just_one_allowed_type(
    decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Multiple required approval types form a conjunction with independent payloads."""
    document = as_object(to_plain_value(decision_profile.document))
    document["decision_owners"] = [
        {
            "id": "owner-example",
            "required_evidence_types": ["decision", "documentation"],
        }
    ]
    profile = ProfileV2(json.dumps(document), format="json", catalog=snapshot_catalog)
    base = decision_snapshot(profile, snapshot_catalog, decision(profile))
    assert {f.code for f in validate_decisions(base).findings} == {
        "DECISION_APPROVAL_EVIDENCE"
    }
    extra = evidence(
        profile,
        kind="documentation",
        path="docs/extra.json",
        changes={"id": "extra", "evidence_id": "extra"},
    )
    record = decision(
        profile,
        approval={
            "owner": "owner-example",
            "timestamp": "2026-01-01t00:00:00z",
            "evidence_refs": [
                reference("evidence-reference", "capture"),
                reference("evidence-reference", "extra"),
            ],
        },
    )
    assert (
        validate_decisions(
            decision_snapshot(profile, snapshot_catalog, record, extra)
        ).findings
        == ()
    )


@pytest.mark.parametrize(
    "field", ["decision", "rationale", "required_migration_behavior"]
)
def test_approved_policy_requires_substantive_target_fields(
    decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog, field: str
) -> None:
    """A metadata-only approval cannot invent an unstated target requirement."""
    result = validate_decisions(
        decision_snapshot(
            decision_profile,
            snapshot_catalog,
            decision(decision_profile, overrides={field: None}),
        )
    )
    assert result.approved == ()
    assert {f.code for f in result.findings} == {"DECISION_TARGET"}


@pytest.mark.parametrize(
    "scope",
    [
        None,
        {},
        decision_scope(feature_ids=[]),
        decision_scope(feature_ids=["absent"]),
        decision_scope(feature_ids=[3]),
        decision_scope(client_ids=["absent"]),
        decision_scope(modes=None),
    ],
    ids=[
        "null",
        "missing",
        "empty",
        "foreign-feature",
        "numeric",
        "unknown-client",
        "null-mode",
    ],
)
def test_invalid_scope_cannot_produce_an_eligible_approval(
    decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog, scope: object
) -> None:
    """Malformed or unresolved selectors fail closed without throwing exceptions."""
    result = validate_decisions(
        decision_snapshot(
            decision_profile, snapshot_catalog, decision(decision_profile, scope=scope)
        )
    )
    assert result.approved == ()
    assert {f.code for f in result.findings} == {"DECISION_SCOPE"}


@pytest.mark.parametrize(
    "change",
    [
        "valid",
        "proposed",
        "wrong-owner",
        "wrong-decision",
        "wrong-target",
        "wrong-dimension",
        "narrow-client",
        "no-rationale",
        "missing",
        "unknown-owner",
    ],
)
def test_resolved_questions_require_exact_active_target_policy_and_scope(
    decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog, change: str
) -> None:
    """Resolution does not permit substituted text or an unrelated scoped approval."""
    fields: dict[str, object] = {}
    if change == "wrong-owner":
        fields["decision_owner"] = None
    elif change == "unknown-owner":
        fields["decision_owner"] = "analyst"
    elif change == "wrong-decision":
        fields["decision"] = "Unapproved replacement."
    elif change == "wrong-target":
        fields["approved_target_behavior"] = "Unapproved behavior."
    elif change == "no-rationale":
        fields["rationale"] = None
    elif change == "missing":
        fields["decision_ref"] = reference("product-decision", "absent")
    question_record = resolved_question(decision_profile, **fields)
    record = decision(
        decision_profile,
        status="proposed" if change == "proposed" else "approved",
        scope=decision_scope(
            dimensions=["timing"] if change == "wrong-dimension" else [],
            client_ids=["browser"] if change == "narrow-client" else [],
        ),
    )
    snapshot = decision_snapshot(
        decision_profile, snapshot_catalog, record, question_record
    )
    before = snapshot.sha256
    codes = {f.code for f in validate_decisions(snapshot).findings}
    assert codes == (
        set()
        if change == "valid"
        else (
            {"DECISION_RESOLUTION", "DECISION_OWNER"}
            if change == "unknown-owner"
            else {"DECISION_RESOLUTION"}
        )
    )
    assert snapshot.sha256 == before


@pytest.mark.parametrize(
    "kind,target",
    [("documentation", None), ("decision", None), ("documentation", "invented")],
)
def test_observation_resolution_requires_observation_proof_without_target_policy(
    decision_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    kind: str,
    target: str | None,
) -> None:
    """Verified historical resolution stays separate from a target approval choice."""
    record = question(
        decision_profile,
        status="resolved",
        decision_owner=None,
        resolution_basis="verified-observation",
        decision_ref=None,
        decision=None,
        approved_target_behavior=target,
        resolution_evidence_refs=[reference("evidence-reference", "capture")],
    )
    snapshot = claim_snapshot(
        decision_profile,
        snapshot_catalog,
        contract(decision_profile),
        evidence(decision_profile, kind=kind),
        record,
    )
    result = validate_decisions(snapshot)
    assert result.approved == ()
    assert {f.code for f in result.findings} == (
        set() if kind == "documentation" and target is None else {"DECISION_RESOLUTION"}
    )


@pytest.mark.parametrize("basis", [None, "approved-decision"])
def test_open_questions_keep_pending_policy_separate(
    decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog, basis: str | None
) -> None:
    """A draft question remains valid until it asserts an unsupported resolution."""
    record = question(decision_profile, resolution_basis=basis)
    result = validate_decisions(
        decision_snapshot(decision_profile, snapshot_catalog, record)
    )
    assert {f.code for f in result.findings} == (
        set() if basis is None else {"DECISION_RESOLUTION"}
    )
