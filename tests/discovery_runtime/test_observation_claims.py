"""Check feature observation claims with isolated captured artifacts and payloads."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.claim_rules import validate_claims
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.test_evidence_rules import CONTENT, PIN, evidence
from tests.discovery_runtime.test_references import artifact, graph, reference
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.snapshot import ArtifactSnapshot, DiscoverySnapshot


def contract(profile: ProfileV2, **fields: object) -> ArtifactSnapshot:
    """Create a fresh feature whose unasserted observations remain inferred."""
    return artifact(
        "feature-contract",
        "feature",
        repository=profile.repository.id,
        fields={"feature_id": "feature", "observation_state": "inferred", **fields},
    )


def dimension(state: str, **fields: object) -> dict[str, object]:
    """Represent a single observation without deriving state from confidence."""
    return {
        "observation_state": state,
        "statement": (
            None if state in ("unknown", "contradictory") else "Observed behavior."
        ),
        "confidence": "high",
        "evidence_refs": [reference("evidence-reference", "capture")],
        "unresolved_behavior_refs": [],
        **fields,
    }


def question(profile: ProfileV2, **fields: object) -> ArtifactSnapshot:
    """Create an open question that explicitly links the tested feature/dimension."""
    return artifact(
        "unspecified-behavior",
        "question",
        repository=profile.repository.id,
        fields={
            "status": "open",
            "dimensions": ["trigger"],
            "feature_refs": [reference("feature-contract", "feature")],
            **fields,
        },
    )


def claim_snapshot(
    profile: ProfileV2, catalog: SchemaCatalog, *records: ArtifactSnapshot
) -> DiscoverySnapshot:
    """Capture fresh record bytes and one shared payload entirely in memory."""
    snapshot = graph(profile, catalog, *records)
    payload = SnapshotFile(
        path="evidence/capture.txt", content=CONTENT, category="evidence"
    )
    pinned = RepositoryFile(
        repository=RepositoryIdentity(id=profile.repository.id, revision=PIN),
        path=payload.path,
        content=CONTENT,
    )
    return replace(
        snapshot,
        manifest=replace(snapshot.manifest, files=snapshot.manifest.files + (payload,)),
        repository_files=(pinned,),
    )


@pytest.mark.parametrize(
    "kind", ["source", "test", "documentation", "inventory", "runtime", "observation"]
)
def test_verified_observations_require_real_payload_integrity_at_the_feature_pin(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, kind: str
) -> None:
    """Valid proof supports low-confidence observations without changing state."""
    record = contract(
        snapshot_profile,
        observation_state="verified",
        confidence="low",
        source_evidence_refs=[reference("evidence-reference", "capture")],
        trigger=dimension("verified"),
    )
    snapshot = claim_snapshot(
        snapshot_profile,
        snapshot_catalog,
        record,
        evidence(snapshot_profile, kind=kind),
    )
    index = index_references(snapshot)
    assessed = validate_evidence(snapshot, index=index)
    result = validate_claims(snapshot, index=index, evidence=assessed)
    assert result.findings == ()
    assert record.document is not None and record.document["confidence"] == "low"


@pytest.mark.parametrize(
    "change", ["missing", "checksum", "pin", "decision", "runtime-type"]
)
def test_authored_verified_state_cannot_substitute_missing_or_unrelated_proof(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, change: str
) -> None:
    """Graph presence alone cannot establish verified observation evidence."""
    proof = evidence(
        snapshot_profile,
        kind="decision" if change == "decision" else "documentation",
        changes=(
            {"checksum": None}
            if change == "checksum"
            else {"revision": "b" * 40} if change == "pin" else {}
        ),
    )
    name = (
        "runtime_evidence_refs" if change == "runtime-type" else "source_evidence_refs"
    )
    record = contract(
        snapshot_profile,
        observation_state="verified",
        **{name: [reference("evidence-reference", "capture")]},
    )
    records = (record,) if change == "missing" else (record, proof)
    result = validate_claims(
        claim_snapshot(snapshot_profile, snapshot_catalog, *records)
    )
    assert {finding.code for finding in result.findings} == (
        {"CLAIM_EVIDENCE", "CLAIM_RUNTIME_EVIDENCE"}
        if change == "runtime-type"
        else {"CLAIM_EVIDENCE"}
    )


@pytest.mark.parametrize("state", ["unknown", "contradictory"])
@pytest.mark.parametrize(
    "change", ["none", "dimension", "feature", "resolved", "unlinked"]
)
def test_uncertain_dimensions_require_an_open_question_covering_the_same_feature(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    state: str,
    change: str,
) -> None:
    """An unrelated or already resolved question cannot justify an unknown dimension."""
    links = (
        [] if change == "unlinked" else [reference("unspecified-behavior", "question")]
    )
    record = contract(
        snapshot_profile, trigger=dimension(state, unresolved_behavior_refs=links)
    )
    unresolved = question(
        snapshot_profile,
        dimensions=["failure"] if change == "dimension" else ["trigger"],
        status="resolved" if change == "resolved" else "under-review",
        feature_refs=[
            reference("feature-contract", "other" if change == "feature" else "feature")
        ],
    )
    result = validate_claims(
        claim_snapshot(snapshot_profile, snapshot_catalog, record, unresolved)
    )
    assert [finding.code for finding in result.findings] == (
        [] if change == "none" else ["CLAIM_UNRESOLVED"]
    )


def test_open_question_backlinks_block_verified_dimensions_even_when_omitted(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """A feature cannot hide an unresolved question by removing its forward link."""
    record = contract(snapshot_profile, trigger=dimension("verified"))
    result = validate_claims(
        claim_snapshot(
            snapshot_profile,
            snapshot_catalog,
            record,
            question(snapshot_profile),
            evidence(snapshot_profile),
        )
    )
    assert [(item.code, item.pointer) for item in result.findings] == [
        ("CLAIM_UNRESOLVED", "/trigger")
    ]


@pytest.mark.parametrize("state", ["unknown", "contradictory", "inferred"])
def test_verified_summary_cannot_hide_an_uncertain_required_dimension(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, state: str
) -> None:
    """Required dimension uncertainty remains visible despite a verified summary."""
    record = contract(
        snapshot_profile,
        observation_state="verified",
        required_dimensions=["trigger"],
        source_evidence_refs=[reference("evidence-reference", "capture")],
        trigger=dimension(
            state,
            unresolved_behavior_refs=[reference("unspecified-behavior", "question")],
        ),
    )
    result = validate_claims(
        claim_snapshot(
            snapshot_profile,
            snapshot_catalog,
            record,
            question(snapshot_profile),
            evidence(snapshot_profile),
        )
    )
    assert [finding.code for finding in result.findings] == ["CLAIM_SUMMARY"]


@pytest.mark.parametrize("state", ["inferred", "unknown", "contradictory"])
def test_high_confidence_never_promotes_an_observation_state(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, state: str
) -> None:
    """Honest incomplete observations remain valid when their uncertainty is linked."""
    record = contract(
        snapshot_profile,
        observation_state=state,
        confidence="high",
        unresolved_behavior_refs=[reference("unspecified-behavior", "question")],
    )
    result = validate_claims(
        claim_snapshot(
            snapshot_profile, snapshot_catalog, record, question(snapshot_profile)
        )
    )
    assert result.findings == ()
    assert record.document is not None and record.document["observation_state"] == state


@pytest.mark.parametrize(
    "change",
    [
        "none",
        "proposed",
        "rejected",
        "superseded",
        "feature",
        "dimension",
        "approval",
        "rationale",
        "local-rationale",
    ],
)
def test_intentionally_unspecified_dimensions_require_scoped_declared_approval(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, change: str
) -> None:
    """Intentional uncertainty uses approval/rationale links, not confidence labels."""
    record = contract(
        snapshot_profile,
        trigger=dimension(
            "intentionally-unspecified",
            rationale=None if change == "local-rationale" else "Deliberate choice.",
            product_decision_refs=[reference("product-decision", "decision")],
        ),
    )
    decision = artifact(
        "product-decision",
        "decision",
        repository=snapshot_profile.repository.id,
        fields={
            "status": (
                change
                if change in ("proposed", "rejected", "superseded")
                else "approved"
            ),
            "rationale": (
                None if change == "rationale" else "Retain unspecified behavior."
            ),
            "approval": None if change == "approval" else {"owner": "owner"},
            "scope": {
                "feature_ids": ["other" if change == "feature" else "feature"],
                "dimensions": ["failure" if change == "dimension" else "trigger"],
            },
        },
    )
    result = validate_claims(
        claim_snapshot(snapshot_profile, snapshot_catalog, record, decision)
    )
    assert [finding.code for finding in result.findings] == (
        [] if change == "none" else ["CLAIM_DECISION"]
    )


@pytest.mark.parametrize("phase", ["before", "action", "after"])
def test_transition_phases_are_independently_checked_for_observation_proof(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, phase: str
) -> None:
    """A transition summary cannot lend evidence to an unsupported phase."""
    row = {
        "before": dimension("verified"),
        "action": dimension("verified"),
        "after": dimension("verified"),
    }
    row[phase] = dimension("verified", evidence_refs=[], statement=None)
    record = contract(
        snapshot_profile,
        state_transitions={"behavior": dimension("verified"), "entries": [row]},
    )
    result = validate_claims(
        claim_snapshot(
            snapshot_profile, snapshot_catalog, record, evidence(snapshot_profile)
        )
    )
    assert {finding.code for finding in result.findings} == {
        "CLAIM_EVIDENCE",
        "CLAIM_STATEMENT",
    }
    assert all(
        finding.pointer == f"/state_transitions/entries/0/{phase}"
        for finding in result.findings
    )


def test_unknown_dimension_statement_is_rejected_without_reading_extension_payloads(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Opaque extension data cannot supply or manufacture a core observation."""
    record = contract(
        snapshot_profile,
        trigger=dimension(
            "unknown",
            statement="Invented.",
            unresolved_behavior_refs=[reference("unspecified-behavior", "question")],
        ),
        extensions={"example.payload": {"observation_state": "verified"}},
    )
    result = validate_claims(
        claim_snapshot(
            snapshot_profile, snapshot_catalog, record, question(snapshot_profile)
        )
    )
    assert [finding.code for finding in result.findings] == ["CLAIM_STATEMENT"]


@pytest.mark.parametrize("change", ["global-question", "runtime-type"])
def test_verified_source_proof_cannot_hide_other_structured_claim_conflicts(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, change: str
) -> None:
    """Global questions and runtime-typed references remain independently checked."""
    record = contract(
        snapshot_profile,
        observation_state="verified",
        source_evidence_refs=[reference("evidence-reference", "capture")],
        runtime_evidence_refs=(
            [reference("evidence-reference", "capture")]
            if change == "runtime-type"
            else []
        ),
    )
    proof = evidence(snapshot_profile, kind="source")
    records = (
        (record, proof, question(snapshot_profile, dimensions=[]))
        if change == "global-question"
        else (record, proof)
    )
    result = validate_claims(
        claim_snapshot(snapshot_profile, snapshot_catalog, *records)
    )
    assert [finding.code for finding in result.findings] == [
        "CLAIM_UNRESOLVED" if change == "global-question" else "CLAIM_RUNTIME_EVIDENCE"
    ]
