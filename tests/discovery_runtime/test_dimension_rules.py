"""Verify inherited applicability and approvals with fresh in-memory graphs."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.decision_rules import validate_decisions
from drm_copilot_discovery.dimension_rules import validate_dimensions
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.references import index_references

from tests.discovery_runtime.test_coverage_scope import profile_with
from tests.discovery_runtime.test_decision_rules import decision, decision_scope
from tests.discovery_runtime.test_evidence_rules import configured, evidence
from tests.discovery_runtime.test_observation_claims import (
    claim_snapshot,
    contract,
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
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.snapshot import ArtifactSnapshot


def feature(profile: ProfileV2, **changes: object) -> ArtifactSnapshot:
    """Retain explicit online applicability without enabling optional modes."""
    fields: dict[str, object] = {
        "target_relevance": "required",
        "required_dimensions": [],
        "online": dimension("inferred", applicability="applicable"),
        "trigger": dimension("inferred", applicability="applicable"),
        "observable_outputs": dimension("inferred", applicability="applicable"),
        **changes,
    }
    return contract(profile, **fields)


def client(
    profile: ProfileV2, identifier: str = "browser", **changes: object
) -> dict[str, object]:
    """Create a configured client with isolated selector and applicability values."""
    return {
        "id": identifier,
        "target_repository": profile.repository.id,
        "platforms": [identifier],
        "modes": ["online"],
        "required_feature_dimensions": [],
        "applicability_defaults": {},
        **changes,
    }


@pytest.fixture(scope="module")
def obligation_profile(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> ProfileV2:
    """Share one immutable combined profile; all authored graph records stay fresh."""
    return configured(snapshot_profile, snapshot_catalog, role="combined")


def test_global_client_feature_and_scope_requirements_form_a_monotonic_union(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Child arrays add obligations and cannot remove inherited requirements."""
    profile = profile_with(
        obligation_profile,
        snapshot_catalog,
        required_modes=["online"],
        required_platforms=["desktop"],
        required_feature_dimensions=["timing"],
        clients=[
            client(
                obligation_profile,
                modes=["offline"],
                required_feature_dimensions=["failure"],
            )
        ],
    )
    record = feature(
        profile,
        **{
            "required_dimensions": ["cancellation"],
            "timing": dimension("inferred", applicability="applicable"),
            "failure": dimension("inferred", applicability="applicable"),
            "cancellation": dimension("inferred", applicability="applicable"),
            "offline": dimension("inferred", applicability="applicable"),
        },
    )
    scope = artifact(
        "scope",
        "scope",
        repository=profile.repository.id,
        fields={
            "required_coverage": {
                "feature_refs": [reference("feature-contract", "feature")],
                "client_ids": ["browser"],
                "modes": ["custom"],
            }
        },
    )
    snapshot = claim_snapshot(profile, snapshot_catalog, record, scope)
    result = validate_dimensions(snapshot, complete=True)
    assert result.findings == ()
    required = result.obligations[0].requirements
    assert required.platforms == ("browser", "desktop")
    assert required.modes == ("custom", "offline", "online")
    assert required.dimensions == ("cancellation", "failure", "timing")


@pytest.mark.parametrize("name", ["online", "offline", "mobile", "timing"])
@pytest.mark.parametrize("applicability", ["applicable", "unspecified", None])
def test_configured_dimensions_require_explicit_classification(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    name: str,
    applicability: str | None,
) -> None:
    """Required classification fails only at completion when it remains absent."""
    profile = profile_with(
        snapshot_profile,
        snapshot_catalog,
        required_modes=[name] if name in {"online", "offline"} else ["online"],
        required_feature_dimensions=[name],
    )
    value = dimension("inferred")
    if applicability is not None:
        value["applicability"] = applicability
    record = (
        contract(
            profile,
            required_dimensions=[],
            online=dimension("inferred", applicability="applicable"),
            **({name: value} if name != "online" else {}),
        )
        if name != "online"
        else contract(profile, required_dimensions=[], online=value)
    )
    snapshot = claim_snapshot(profile, snapshot_catalog, record)
    assert validate_dimensions(snapshot).findings == ()
    result = validate_dimensions(snapshot, complete=True)
    assert bool(result.findings) == (applicability != "applicable")


def test_unconfigured_optional_dimensions_create_no_obligations_or_passes(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Unknown offline/mobile observations remain optional without requirements."""
    snapshot = claim_snapshot(
        snapshot_profile,
        snapshot_catalog,
        feature(
            snapshot_profile,
            offline=dimension("unknown"),
            mobile=dimension("contradictory"),
        ),
    )
    result = validate_dimensions(snapshot, complete=True)
    assert result.findings == ()
    assert result.obligations[0].requirements.modes == ("online",)
    assert result.obligations[0].waived == frozenset()


@pytest.mark.parametrize(
    "case",
    [
        "approved",
        "proposed",
        "missing",
        "rationale",
        "wrong-client",
        "wrong-mode",
        "wrong-dimension",
    ],
)
def test_required_not_applicable_needs_current_covering_approval(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog, case: str
) -> None:
    """A waiver must cover the actual feature/client/mode/dimension requirement."""
    profile = profile_with(
        obligation_profile, snapshot_catalog, required_modes=["online", "offline"]
    )
    value = dimension(
        "inferred",
        applicability="not-applicable",
        rationale="Unavailable by design." if case != "rationale" else "",
        product_decision_refs=(
            [] if case == "missing" else [reference("product-decision", "decision")]
        ),
    )
    selector = decision_scope(
        client_ids=["browser"] if case != "wrong-client" else [],
        modes=["offline"] if case != "wrong-mode" else ["online"],
        dimensions=["offline"] if case != "wrong-dimension" else ["timing"],
    )
    if case == "wrong-client":
        profile = profile_with(
            profile,
            snapshot_catalog,
            clients=[client(profile), client(profile, "mobile")],
        )
        selector["client_ids"] = ["mobile"]
    snapshot = claim_snapshot(
        profile,
        snapshot_catalog,
        feature(profile, offline=value),
        decision(
            profile,
            status="proposed" if case == "proposed" else "approved",
            scope=selector,
        ),
        evidence(profile, kind="decision"),
    )
    result = validate_dimensions(snapshot, complete=True)
    assert any(f.code == "DIMENSION_DISPOSITION" for f in result.findings) == (
        case != "approved"
    )
    if case == "approved":
        assert result.obligations[0].waived == frozenset({"offline"})


def test_client_defaults_classify_but_cannot_approve_waivers(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Applicability defaults carry no product-decision authority."""
    for classification in ("applicable", "not-applicable"):
        profile = profile_with(
            obligation_profile,
            snapshot_catalog,
            clients=[
                client(
                    obligation_profile,
                    required_feature_dimensions=["timing"],
                    applicability_defaults={
                        "timing": {
                            "applicability": classification,
                            "rationale": "Default.",
                        }
                    },
                )
            ],
        )
        snapshot = claim_snapshot(
            profile, snapshot_catalog, feature(profile, timing=dimension("inferred"))
        )
        result = validate_dimensions(snapshot, complete=True)
        assert bool(result.findings) == (classification == "not-applicable")


@pytest.mark.parametrize("state", ["unknown", "contradictory"])
def test_target_approval_preserves_unresolved_required_legacy_observations(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog, state: str
) -> None:
    """Known target policy cannot silently resolve unknown historical behavior."""
    profile = profile_with(
        obligation_profile, snapshot_catalog, required_feature_dimensions=["timing"]
    )
    value = dimension(
        state,
        applicability="applicable",
        unresolved_behavior_refs=[reference("unspecified-behavior", "question")],
    )
    snapshot = claim_snapshot(
        profile,
        snapshot_catalog,
        feature(profile, timing=value),
        question(profile, dimensions=["timing"]),
        decision(profile),
        evidence(profile, kind="decision"),
    )
    before = snapshot.sha256
    assert any(
        f.code == "DIMENSION_UNRESOLVED"
        for f in validate_dimensions(snapshot, complete=True).findings
    )
    assert snapshot.sha256 == before


def test_nested_transitions_and_feature_only_mode_requirements_are_retained(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Transition behavior is classified at its actual nested schema location."""
    record = feature(
        snapshot_profile,
        **{
            "required_dimensions": ["state_transitions", "offline"],
            "state_transitions": {
                "behavior": dimension("inferred", applicability="applicable")
            },
            "offline": dimension("inferred", applicability="applicable"),
        },
    )
    result = validate_dimensions(
        claim_snapshot(snapshot_profile, snapshot_catalog, record), complete=True
    )
    assert result.findings == () and result.obligations[0].requirements.modes == (
        "offline",
        "online",
    )


@pytest.mark.parametrize("custom", ["batch", "satellite"])
def test_custom_modes_and_platforms_remain_explicit_acceptance_coordinates(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, custom: str
) -> None:
    """Closed behavior fields do not manufacture a custom applicability property."""
    profile = profile_with(
        snapshot_profile,
        snapshot_catalog,
        required_modes=[custom],
        required_platforms=[custom],
    )
    result = validate_dimensions(
        claim_snapshot(profile, snapshot_catalog, feature(profile)), complete=True
    )
    assert result.findings == ()
    assert result.obligations[0].requirements.modes == (custom,)
    assert result.obligations[0].requirements.platforms == (custom,)


def test_missing_and_malformed_upstream_requirements_report_without_exceptions(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Invalid dimension names cannot enter checked ProfileRequirements values."""
    record = contract(snapshot_profile, required_dimensions=["unsupported"])
    result = validate_dimensions(
        claim_snapshot(snapshot_profile, snapshot_catalog, record), complete=True
    )
    assert {f.code for f in result.findings} == {
        "DIMENSION_REQUIREMENTS",
        "DIMENSION_MISSING",
    }


def test_scope_client_selection_cannot_add_an_unknown_configured_client(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Required coverage uses the same configured client namespace as the profile."""
    scope = artifact(
        "scope",
        "scope",
        repository=snapshot_profile.repository.id,
        fields={
            "included_features": [reference("feature-contract", "feature")],
            "required_coverage": {"client_ids": ["missing"], "modes": []},
        },
    )
    result = validate_dimensions(
        claim_snapshot(
            snapshot_profile, snapshot_catalog, feature(snapshot_profile), scope
        )
    )
    assert {f.code for f in result.findings} == {"DIMENSION_CLIENT"}


def test_reused_assessments_and_requirement_permutations_preserve_results(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Input ordering does not alter the requirement sets or mutate the snapshot."""
    expected = None
    for identifiers in (("browser", "mobile"), ("mobile", "browser")):
        profile = profile_with(
            obligation_profile,
            snapshot_catalog,
            clients=[client(obligation_profile, name) for name in identifiers],
        )
        snapshot = claim_snapshot(
            profile,
            snapshot_catalog,
            feature(profile, mobile=dimension("inferred", applicability="applicable")),
        )
        index = index_references(snapshot)
        proof = validate_evidence(snapshot, index=index)
        decisions = validate_decisions(snapshot, index=index, evidence=proof)
        result = validate_dimensions(
            snapshot, complete=True, index=index, evidence=proof, decisions=decisions
        )
        projection = tuple(
            (item.client_id, item.requirements) for item in result.obligations
        )
        assert result.findings == () and (expected is None or projection == expected)
        expected = projection


@pytest.mark.parametrize("state", ["unknown", "contradictory", "inferred"])
@pytest.mark.parametrize("complete", [False, True])
@pytest.mark.parametrize("applicability", ["applicable", "not-applicable"])
def test_verified_summary_cannot_hide_client_required_uncertainty(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    state: str,
    complete: bool,
    applicability: str,
) -> None:
    """Summary truth remains mandatory before completion switches or waivers."""
    gates = as_object(to_plain_value(obligation_profile.document["completion_gates"]))
    gates["block_on_unresolved_required_behavior"] = False
    profile = profile_with(
        obligation_profile,
        snapshot_catalog,
        completion_gates=gates,
        clients=[client(obligation_profile, required_feature_dimensions=["timing"])],
    )
    snapshot = claim_snapshot(
        profile,
        snapshot_catalog,
        feature(
            profile,
            observation_state="verified",
            online=dimension("verified", applicability="applicable"),
            timing=dimension(state, applicability=applicability),
        ),
    )
    findings = validate_dimensions(snapshot, complete=complete).findings
    assert any(f.code == "CLAIM_SUMMARY" and f.pointer == "/timing" for f in findings)
