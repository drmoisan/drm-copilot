"""Exercise scoped conflicts and supersession without editing historical facts."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.decision_rules import validate_decisions

from tests.discovery_runtime.test_decision_rules import (
    decision,
    decision_scope,
    decision_snapshot,
    resolved_question,
)
from tests.discovery_runtime.test_decision_rules import (
    decision_profile as decision_profile,
)
from tests.discovery_runtime.test_evidence_rules import evidence
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

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2


@pytest.mark.parametrize("axis", ["client_ids", "platforms", "modes", "dimensions"])
@pytest.mark.parametrize(
    "selection", ["same", "disjoint", "left-wildcard", "right-wildcard"]
)
def test_scope_axes_require_overlap_before_approvals_conflict(
    decision_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    axis: str,
    selection: str,
) -> None:
    """One disjoint selector separates requirements while an empty selector overlaps."""
    first, second = {
        "client_ids": ("browser", "mobile"),
        "platforms": ("browser", "desktop"),
        "modes": ("online", "offline"),
        "dimensions": ("trigger", "timing"),
    }[axis]
    left = [] if selection == "left-wildcard" else [first]
    right = (
        []
        if selection == "right-wildcard"
        else [second if selection == "disjoint" else first]
    )
    records = (
        decision(decision_profile, "first", scope=decision_scope(**{axis: left})),
        decision(decision_profile, "second", scope=decision_scope(**{axis: right})),
    )
    result = validate_decisions(
        decision_snapshot(decision_profile, snapshot_catalog, *records)
    )
    assert {f.code for f in result.findings} == (
        set() if selection == "disjoint" else {"DECISION_CONFLICT"}
    )
    assert len(result.approved) == (2 if selection == "disjoint" else 0)


def test_separate_decision_keys_do_not_infer_prose_conflicts(
    decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Structured keys determine conflicts without interpreting policy prose."""
    records = (
        decision(decision_profile, "first"),
        decision(
            decision_profile,
            "second",
            decision_key="other",
            required_migration_behavior="A different policy.",
        ),
    )
    result = validate_decisions(
        decision_snapshot(decision_profile, snapshot_catalog, *records)
    )
    assert result.findings == () and len(result.approved) == 2


@pytest.mark.parametrize("status", ["approved", "superseded"])
@pytest.mark.parametrize("reverse", [False, True])
def test_complete_acyclic_supersession_leaves_only_current_approval(
    decision_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    status: str,
    reverse: bool,
) -> None:
    """Transitive history stays immutable and valid independently of storage order."""
    old = decision(
        decision_profile,
        "old",
        status=status,
        scope=decision_scope(dimensions=["trigger"]),
    )
    middle = decision(
        decision_profile,
        "middle",
        status=status,
        scope=decision_scope(dimensions=["trigger", "timing"]),
        supersedes=[reference("product-decision", "old")],
    )
    current = decision(
        decision_profile,
        "current",
        supersedes=[reference("product-decision", "middle")],
    )
    records = (old, middle, current) if not reverse else (current, middle, old)
    snapshot = decision_snapshot(decision_profile, snapshot_catalog, *records)
    before = snapshot.sha256
    result = validate_decisions(snapshot)
    assert result.findings == ()
    assert [item.record.id for item in result.approved] == ["current"]
    assert snapshot.sha256 == before


def test_one_successor_can_resolve_multiple_overlapping_historical_approvals(
    decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Fully replaced predecessors cannot retain an active target-policy conflict."""
    first = decision(decision_profile, "first")
    second = decision(decision_profile, "second")
    current = decision(
        decision_profile,
        "current",
        supersedes=[
            reference("product-decision", "first"),
            reference("product-decision", "second"),
        ],
    )
    snapshot = decision_snapshot(
        decision_profile, snapshot_catalog, first, second, current
    )
    result = validate_decisions(snapshot)
    assert result.findings == ()
    assert [item.record.id for item in result.approved] == ["current"]


@pytest.mark.parametrize("axis", ["client_ids", "platforms", "modes", "dimensions"])
def test_partial_scope_replacement_cannot_suppress_overlapping_approval(
    decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog, axis: str
) -> None:
    """A finite replacement cannot discard an unrestricted predecessor requirement."""
    value = {
        "client_ids": "browser",
        "platforms": "browser",
        "modes": "online",
        "dimensions": "trigger",
    }[axis]
    old = decision(decision_profile, "old")
    new = decision(
        decision_profile,
        "new",
        scope=decision_scope(**{axis: [value]}),
        supersedes=[reference("product-decision", "old")],
    )
    result = validate_decisions(
        decision_snapshot(decision_profile, snapshot_catalog, old, new)
    )
    assert {f.code for f in result.findings} == {
        "DECISION_SUPERSESSION",
        "DECISION_CONFLICT",
    }
    assert result.approved == ()


@pytest.mark.parametrize(
    "change",
    [
        "missing",
        "different-key",
        "proposed-predecessor",
        "orphan",
        "proposed-successor",
    ],
)
def test_supersession_requires_a_real_approved_predecessor_and_successor(
    decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog, change: str
) -> None:
    """Status labels and future proposals cannot silently remove approved history."""
    old = decision(
        decision_profile,
        "old",
        status=(
            "proposed"
            if change == "proposed-predecessor"
            else "superseded" if change == "orphan" else "approved"
        ),
    )
    new = decision(
        decision_profile,
        "new",
        status="proposed" if change == "proposed-successor" else "approved",
        decision_key="other" if change == "different-key" else "behavior",
        supersedes=[
            reference("product-decision", "missing" if change == "missing" else "old")
        ],
    )
    records = (old,) if change == "orphan" else (old, new)
    result = validate_decisions(
        decision_snapshot(decision_profile, snapshot_catalog, *records)
    )
    if change == "proposed-successor":
        assert result.findings == ()
        assert [item.record.id for item in result.approved] == ["old"]
    else:
        assert "DECISION_SUPERSESSION" in {f.code for f in result.findings}


@pytest.mark.parametrize("length", [1, 2, 3])
@pytest.mark.parametrize("status", ["approved", "proposed"])
def test_supersession_cycles_block_even_proposals_and_self_links(
    decision_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    length: int,
    status: str,
) -> None:
    """Every member of a directed cycle receives an explicit blocking finding."""
    records = tuple(
        decision(
            decision_profile,
            f"decision-{index}",
            status=status,
            supersedes=[
                reference("product-decision", f"decision-{(index + 1) % length}")
            ],
        )
        for index in range(length)
    )
    result = validate_decisions(
        decision_snapshot(decision_profile, snapshot_catalog, *records)
    )
    assert sum(f.code == "DECISION_CYCLE" for f in result.findings) == length
    assert result.approved == ()


def test_feature_scope_is_resolved_through_linked_unresolved_records(
    decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """A question's explicit feature links can scope an approval without duplicates."""
    record = decision(
        decision_profile,
        feature_refs=[],
        unspecified_behavior_refs=[reference("unspecified-behavior", "question")],
    )
    result = validate_decisions(
        decision_snapshot(
            decision_profile, snapshot_catalog, record, question(decision_profile)
        )
    )
    assert result.findings == () and len(result.approved) == 1


@pytest.mark.parametrize("ambiguous", [False, True])
def test_equal_feature_ids_in_different_repositories_remain_distinct(
    decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog, ambiguous: bool
) -> None:
    """Explicit foreign links preserve identity; a bare selector cannot select both."""
    foreign = artifact(
        "feature-contract",
        "feature",
        repository="foreign",
        fields={"feature_id": "feature"},
    )
    local_ref = reference(
        "feature-contract", "feature", repository=decision_profile.repository.id
    )
    foreign_ref = reference("feature-contract", "feature", repository="foreign")
    first = decision(decision_profile, "first", feature_refs=[local_ref])
    second = decision(
        decision_profile,
        "second",
        feature_refs=[foreign_ref, local_ref] if ambiguous else [foreign_ref],
    )
    result = validate_decisions(
        decision_snapshot(decision_profile, snapshot_catalog, foreign, first, second)
    )
    assert {f.code for f in result.findings} == (
        {"DECISION_SCOPE"} if ambiguous else set()
    )
    assert len(result.approved) == (1 if ambiguous else 2)


@pytest.mark.parametrize("reference_id", ["old", "decision"])
def test_resolved_questions_cannot_use_a_fully_superseded_approval(
    decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog, reference_id: str
) -> None:
    """Historical approval proof remains preserved but cannot supply current policy."""
    old = decision(decision_profile, "old")
    new = decision(decision_profile, supersedes=[reference("product-decision", "old")])
    resolved = resolved_question(
        decision_profile, decision_ref=reference("product-decision", reference_id)
    )
    result = validate_decisions(
        decision_snapshot(decision_profile, snapshot_catalog, old, new, resolved)
    )
    assert {f.code for f in result.findings} == (
        {"DECISION_RESOLUTION"} if reference_id == "old" else set()
    )


def test_empty_graph_and_unrelated_artifacts_have_no_target_requirements(
    decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """No approval is synthesized from an empty or unrelated artifact collection."""
    snapshot = claim_snapshot(
        decision_profile,
        snapshot_catalog,
        artifact("coverage-ledger", "ledger", fields={}),
    )
    result = validate_decisions(snapshot)
    assert result.findings == () and result.approved == ()


@pytest.mark.parametrize(
    "state", ["proposed", "approved", "retired", "narrow-retirement"]
)
def test_feature_target_claims_require_current_covering_approval(
    decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog, state: str
) -> None:
    """Global retirement cannot be justified by a decision covering one dimension."""
    feature = contract(
        decision_profile,
        product_decision_status="approved",
        target_relevance="retired" if "retire" in state else "required",
        product_decision_refs=[reference("product-decision", "decision")],
    )
    record = decision(
        decision_profile,
        status="proposed" if state == "proposed" else "approved",
        scope=decision_scope(
            dimensions=["trigger"] if state == "narrow-retirement" else []
        ),
    )
    snapshot = claim_snapshot(
        decision_profile,
        snapshot_catalog,
        feature,
        evidence(decision_profile, kind="decision"),
        record,
    )
    codes = {f.code for f in validate_decisions(snapshot).findings}
    assert codes == (
        {"DECISION_TARGET"}
        if state == "proposed"
        else {"DECISION_RETIREMENT"} if state == "narrow-retirement" else set()
    )
