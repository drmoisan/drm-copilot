"""Exercise configurable completion policy without replacing mandatory claim truth."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.claim_rules import validate_claims
from drm_copilot_discovery.completion_rules import validate_completion
from drm_copilot_discovery.decision_rules import validate_decisions
from drm_copilot_discovery.dimension_rules import validate_dimensions
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.repository_reader import RepositoryIdentity

from tests.discovery_runtime.test_coverage_scope import profile_with
from tests.discovery_runtime.test_decision_rules import decision, resolved_question
from tests.discovery_runtime.test_evidence_rules import evidence
from tests.discovery_runtime.test_observation_claims import (
    claim_snapshot,
    contract,
    dimension,
    question,
)
from tests.discovery_runtime.test_references import artifact, graph, reference
from tests.discovery_runtime.test_runtime_claims import scenario
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.discovery_runtime.validation_test_support import (
    captured,
    mode_profile,
    no_scope_snapshot,
)
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


def policy_profile(catalog: SchemaCatalog, **enabled: bool) -> ProfileV2:
    """Disable independent policy switches so a test isolates its selected gate."""
    gates = {
        name: False
        for name in (
            "require_confirmed_scope",
            "require_current_inventory",
            "require_all_dispositions",
            "require_feature_evidence",
            "require_acceptance_scenarios",
            "require_runtime_for_declared_features",
            "block_on_unresolved_required_behavior",
            "require_approved_deviations",
        )
    }
    gates.update(enabled)
    return mode_profile(catalog, planning="discovery-complete", **gates)


def completion_codes(snapshot: DiscoverySnapshot, *, parity: bool = False) -> set[str]:
    """Compose the accepted pure assessments exactly once for this isolated policy
    test.
    """
    index = index_references(snapshot)
    evidence_result = validate_evidence(snapshot, index=index)
    claims = validate_claims(snapshot, index=index, evidence=evidence_result)
    decisions = validate_decisions(snapshot, index=index, evidence=evidence_result)
    dimensions = validate_dimensions(
        snapshot, index=index, evidence=evidence_result, decisions=decisions
    )
    result = validate_completion(
        snapshot,
        index=index,
        evidence=evidence_result,
        claims=claims,
        decisions=decisions,
        dimensions=dimensions,
        parity=parity,
    )
    return {item.code for item in result.findings}


@pytest.mark.parametrize(
    "gate,kind",
    [
        ("require_confirmed_scope", "scope"),
        ("require_current_inventory", "inventory-snapshot"),
        ("require_all_dispositions", "coverage-ledger"),
    ],
)
def test_each_source_input_prerequisite_is_independent(
    snapshot_catalog: SchemaCatalog, gate: str, kind: str
) -> None:
    """A missing required input blocks only its enabled presence prerequisite."""
    required = policy_profile(snapshot_catalog, **{gate: True})
    assert completion_codes(captured(required, snapshot_catalog)) == {
        "COMPLETION_INPUT"
    }
    disabled = policy_profile(snapshot_catalog)
    assert completion_codes(captured(disabled, snapshot_catalog)) == set()
    provided = no_scope_snapshot(snapshot_catalog, profile=required)
    assert kind in {item.expected_kind for item in provided.artifacts}
    assert completion_codes(provided) == set()


def test_each_configured_source_requires_its_own_prerequisites(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """One complete source cannot satisfy a second source's missing inventory."""
    profile = policy_profile(snapshot_catalog, require_current_inventory=True)
    repositories: list[dict[str, object]] = [
        {
            "id": "other-source",
            "role": "legacy-source",
            "revision": "b" * 40,
            "snapshot_manifest": None,
            "clients": [],
        }
    ]
    profile = profile_with(profile, snapshot_catalog, repositories=repositories)
    assert "COMPLETION_INPUT" in completion_codes(
        no_scope_snapshot(snapshot_catalog, profile=profile)
    )


@pytest.mark.parametrize(
    "case,expected",
    [
        ("draft", "COMPLETION_PROFILE"),
        ("source-pin", "COMPLETION_SOURCE"),
        ("target-pin", "COMPLETION_TARGET"),
        ("no-source", "COMPLETION_SOURCE"),
        ("no-target", "COMPLETION_TARGET"),
    ],
)
def test_full_repository_pins_are_core_completion_preconditions(
    snapshot_catalog: SchemaCatalog, case: str, expected: str
) -> None:
    """Completion never derives source or target identity from the current HEAD."""
    profile = policy_profile(snapshot_catalog)
    if case in {"draft", "source-pin", "target-pin"}:
        value = as_object(to_plain_value(profile.document["repository"]))
        value["revision"] = None
        profile = profile_with(
            profile, snapshot_catalog, repository=value, profile_state="draft"
        )
    else:
        system = as_object(to_plain_value(profile.document["system"]))
        system["role"] = (
            "modernization-target" if case == "no-source" else "legacy-source"
        )
        clients = (
            list[object]()
            if case == "no-target"
            else to_plain_value(profile.document["clients"])
        )
        profile = profile_with(
            profile, snapshot_catalog, system=system, clients=clients
        )
    assert expected in completion_codes(
        captured(profile, snapshot_catalog), parity=True
    )


@pytest.mark.parametrize(
    "case,expected",
    [
        ("absent", True),
        ("valid", False),
        ("decision", True),
        ("foreign", True),
        ("optional", False),
        ("disabled", False),
    ],
)
def test_required_feature_evidence_uses_actual_source_proof(
    snapshot_catalog: SchemaCatalog, case: str, expected: bool
) -> None:
    """Only qualifying retained source evidence satisfies this configurable
    prerequisite.
    """
    profile = policy_profile(
        snapshot_catalog, require_feature_evidence=case != "disabled"
    )
    feature = contract(
        profile,
        target_relevance="optional" if case == "optional" else "required",
        source_evidence_refs=(
            [] if case == "absent" else [reference("evidence-reference", "capture")]
        ),
    )
    proof = evidence(
        profile,
        kind="decision" if case == "decision" else "documentation",
        changes={"revision": "b" * 40} if case == "foreign" else {},
    )
    result = completion_codes(claim_snapshot(profile, snapshot_catalog, feature, proof))
    assert ("COMPLETION_EVIDENCE" in result) is expected


@pytest.mark.parametrize(
    "state,dimensions,blocked",
    [
        ("open", [], True),
        ("under-review", ["trigger"], True),
        ("open", ["timing"], False),
        ("resolved", ["trigger"], False),
    ],
)
def test_open_required_observation_questions_block_without_rewriting_facts(
    snapshot_catalog: SchemaCatalog, state: str, dimensions: list[str], blocked: bool
) -> None:
    """Unrelated dimensions and resolved questions do not broaden the gate."""
    profile = policy_profile(
        snapshot_catalog, block_on_unresolved_required_behavior=True
    )
    feature = contract(profile, target_relevance="required")
    snapshot = graph(
        profile,
        snapshot_catalog,
        feature,
        question(profile, status=state, dimensions=dimensions),
    )
    original = snapshot.sha256
    assert ("COMPLETION_UNRESOLVED" in completion_codes(snapshot)) is blocked
    assert snapshot.sha256 == original


@pytest.mark.parametrize("name", ["trigger", "state_transitions"])
@pytest.mark.parametrize("approved", [False, True])
def test_intentional_uncertainty_needs_current_linked_scope_approval(
    snapshot_catalog: SchemaCatalog, name: str, approved: bool
) -> None:
    """Intentional-unspecified claims do not derive approval from confidence or text."""
    profile = policy_profile(snapshot_catalog, require_approved_deviations=True)
    value = dimension(
        "intentionally-unspecified",
        product_decision_refs=[reference("product-decision", "decision")],
        rationale="Owner choice.",
    )
    feature = contract(
        profile,
        target_relevance="required",
        **{name: {"behavior": value} if name == "state_transitions" else value},
    )
    snapshot = claim_snapshot(
        profile,
        snapshot_catalog,
        feature,
        decision(profile, status="approved" if approved else "proposed"),
        evidence(profile, kind="decision"),
    )
    assert ("COMPLETION_DECISION" in completion_codes(snapshot)) is not approved


@pytest.mark.parametrize(
    "case,blocked",
    [
        ("observed", False),
        ("not-run", True),
        ("missing", True),
        ("capture", True),
        ("foreign", True),
        ("disabled", False),
        ("unlinked", True),
    ],
)
def test_declared_runtime_need_requires_valid_same_source_observation(
    snapshot_catalog: SchemaCatalog, case: str, blocked: bool
) -> None:
    """Target identity, missing captures or a planned run cannot supply source runtime
    proof.
    """
    profile = policy_profile(
        snapshot_catalog, require_runtime_for_declared_features=case != "disabled"
    )
    profile = profile_with(
        profile,
        snapshot_catalog,
        runtime={"capability": "manual", "required_feature_ids": ["feature"]},
    )
    feature = contract(profile)
    run = scenario(
        profile,
        status="not-run" if case == "not-run" else "observed",
        feature_refs=(
            [] if case == "unlinked" else [reference("feature-contract", "feature")]
        ),
    )
    if case == "foreign":
        run = replace(
            run, repository=RepositoryIdentity(id="target", revision="b" * 40)
        )
    records = (feature, run) if case == "capture" else (feature, run, evidence(profile))
    if case == "missing":
        records = ()
    result = completion_codes(claim_snapshot(profile, snapshot_catalog, *records))
    assert ("COMPLETION_RUNTIME" in result) is blocked


def test_target_policy_resolution_preserves_separate_open_legacy_observation(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Approval can resolve target policy while completion still reports unknown source
    facts.
    """
    profile = policy_profile(
        snapshot_catalog, block_on_unresolved_required_behavior=True
    )
    unknown = dimension(
        "unknown",
        evidence_refs=[],
        unresolved_behavior_refs=[reference("unspecified-behavior", "legacy")],
    )
    feature = contract(profile, target_relevance="required", trigger=unknown)
    legacy = artifact(
        "unspecified-behavior",
        "legacy",
        repository=profile.repository.id,
        fields={
            "status": "open",
            "dimensions": ["trigger"],
            "feature_refs": [reference("feature-contract", "feature")],
        },
    )
    snapshot = claim_snapshot(
        profile,
        snapshot_catalog,
        feature,
        legacy,
        resolved_question(profile),
        decision(profile),
        evidence(profile, kind="decision"),
    )
    before = snapshot.sha256
    assert validate_claims(snapshot).findings == ()
    assert validate_decisions(snapshot).findings == ()
    assert completion_codes(snapshot) == {"COMPLETION_UNRESOLVED"}
    assert snapshot.sha256 == before
    assert feature.document is not None and feature.document[
        "trigger"
    ] == immutable_dimension(unknown)


def immutable_dimension(value: dict[str, object]) -> object:
    """Compare immutable nested source values without converting or mutating them."""
    from tests.discovery_runtime.test_references import immutable

    return immutable(value)
