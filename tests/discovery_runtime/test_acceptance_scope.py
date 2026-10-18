"""Retain exact criterion scope and confirmed zero-feature accounting."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.acceptance_rules import validate_acceptance
from drm_copilot_discovery.decision_rules import validate_decisions
from drm_copilot_discovery.models import to_plain_value

from tests.discovery_runtime.test_acceptance_rules import acceptance_graph, criterion
from tests.discovery_runtime.test_coverage_rules import coverage_snapshot
from tests.discovery_runtime.test_coverage_scope import profile_with
from tests.discovery_runtime.test_decision_rules import decision, decision_scope
from tests.discovery_runtime.test_dimension_rules import client, feature
from tests.discovery_runtime.test_dimension_rules import (
    obligation_profile as obligation_profile,
)
from tests.discovery_runtime.test_evidence_rules import evidence
from tests.discovery_runtime.test_observation_claims import claim_snapshot
from tests.discovery_runtime.test_references import artifact, reference
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2


@pytest.mark.parametrize(
    "case", ["empty", "draft", "supporting", "no-scope", "required-feature"]
)
def test_zero_feature_completion_requires_confirmed_accounting(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, case: str
) -> None:
    """An empty graph never acquires completion from a zero denominator."""
    if case == "empty":
        snapshot = claim_snapshot(snapshot_profile, snapshot_catalog)
    else:
        scope: dict[str, object] = (
            {"status": "draft", "confirmed_by": None}
            if case == "draft"
            else (
                {
                    "disposition": "no-scope",
                    "no_scope_rationale": "No migration scope.",
                    "included_roots": [],
                }
                if case in {"no-scope", "required-feature"}
                else {}
            )
        )
        snapshot = coverage_snapshot(
            snapshot_profile, snapshot_catalog, scope_changes=scope
        )
        records = tuple(
            item
            for item in snapshot.artifacts
            if item.expected_kind != "feature-contract"
        )
        if case == "required-feature":
            records += (feature(snapshot_profile),)
        snapshot = replace(snapshot, artifacts=records)
    result = validate_acceptance(snapshot, complete=True)
    assert any(f.code == "ACCEPTANCE_SCOPE" for f in result.findings) == (
        case not in {"supporting", "no-scope"}
    )


@pytest.mark.parametrize(
    "changes",
    [
        {},
        {"client_id": "portable"},
        {"platform_id": "portable"},
        {"mode_id": "offline"},
    ],
)
def test_ready_criterion_must_apply_to_the_exact_scenario_tuple(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    changes: dict[str, object],
) -> None:
    """Inherited requirements never broaden an observed criterion's applicability."""
    profile = profile_with(
        obligation_profile,
        snapshot_catalog,
        clients=[client(obligation_profile), client(obligation_profile, "portable")],
        required_modes=["online", "offline"],
        required_platforms=["portable"],
    )
    result = validate_acceptance(
        acceptance_graph(
            profile,
            snapshot_catalog,
            criteria=[criterion(client_ids=["browser"], platforms=["browser"])],
            changes=changes,
        )
    )
    assert bool(result.ready) == (not changes)
    assert bool(result.findings) == bool(changes)


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
    assert [f.message for f in result.findings] == [
        "Missing ready criterion/client/platform/mode: "
        f"{identifier}/browser/browser/online."
    ]


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
    assert [f.message for f in result.findings] == [
        "Missing ready criterion/client/platform/mode: */None/browser/offline."
    ]


@pytest.mark.parametrize("status", ["approved", "proposed"])
def test_required_retirement_needs_a_whole_feature_approval(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog, status: str
) -> None:
    """A required retired feature retains obligations until its owner approves."""
    scope = artifact(
        "scope",
        "scope",
        repository=obligation_profile.repository.id,
        fields={
            "required_coverage": {
                "feature_refs": [reference("feature-contract", "feature")],
                "client_ids": ["browser"],
                "modes": ["online"],
            }
        },
    )
    snapshot = acceptance_graph(
        obligation_profile,
        snapshot_catalog,
        feature_changes={
            "target_relevance": "retired",
            "product_decision_refs": [reference("product-decision", "decision")],
        },
        policy=decision(obligation_profile, status=status),
        extra=(scope,),
        changes={"readiness": "pending"},
    )
    result = validate_acceptance(snapshot, complete=True)
    assert bool(result.findings) == (status != "approved") and result.ready == ()
