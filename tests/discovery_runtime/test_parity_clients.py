"""Exercise client/mode obligations and scoped dispositions in memory."""

from __future__ import annotations

from dataclasses import replace
from itertools import permutations
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.claim_rules import ClaimContext
from drm_copilot_discovery.decision_rules import validate_decisions
from drm_copilot_discovery.dimension_rules import (
    DimensionValidation,
    validate_dimensions,
)
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.parity_rules import validate_parity
from drm_copilot_discovery.parity_target_rules import TargetProof
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.repository_reader import RepositoryIdentity
from drm_copilot_discovery.revision_rules import validate_revisions

from tests.discovery_runtime.parity_test_support import (
    classification,
    codes,
    implementation,
    parity_row,
    parity_snapshot,
    source_contract,
    source_row,
)
from tests.discovery_runtime.test_coverage_scope import profile_with
from tests.discovery_runtime.test_decision_rules import decision, decision_scope
from tests.discovery_runtime.test_dimension_rules import client
from tests.discovery_runtime.test_dimension_rules import (
    obligation_profile as obligation_profile,
)
from tests.discovery_runtime.test_evidence_rules import evidence
from tests.discovery_runtime.test_references import immutable, reference
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2


@pytest.mark.parametrize("state", ["partial", "missing", "conflicting", "unassessed"])
def test_optional_rows_do_not_block_required_completion(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog, state: str
) -> None:
    """An explicitly optional incomplete feature remains an honest reported state."""
    source = source_contract(obligation_profile, target_relevance="optional")
    target = implementation(obligation_profile, source)
    row = parity_row(obligation_profile, source, target, parity_state=state)
    assert (
        codes(
            parity_snapshot(
                obligation_profile,
                snapshot_catalog,
                source=source,
                target=target,
                row=row,
            ),
            complete=True,
        )
        == set()
    )


@pytest.mark.parametrize("mode", ["online", "offline", "mobile"])
@pytest.mark.parametrize("different", ["applicability", "verification", "proof"])
def test_both_mode_representations_must_agree_and_have_valid_proof(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    mode: str,
    different: str,
) -> None:
    """Neither direct nor nested mode fields can hide a contradictory or false claim."""
    source = source_contract(obligation_profile)
    target = implementation(obligation_profile, source)
    direct = classification(
        **(
            {"evidence_refs": list[object]()}
            if different == "proof"
            else {
                different: (
                    "not-applicable" if different == "applicability" else "failed"
                )
            }
        )
    )
    row = parity_row(
        obligation_profile,
        source,
        target,
        **{
            mode: direct,
            "dimensions": {mode: classification()},
            "parity_state": "partial",
        },
    )
    result = codes(
        parity_snapshot(
            obligation_profile, snapshot_catalog, source=source, target=target, row=row
        )
    )
    assert (
        "PARITY_DIMENSION_PROOF" if different == "proof" else "PARITY_MODE_CONFLICT"
    ) in result


def test_matching_duplicate_online_classifications_are_valid(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Equivalent supported representations add no synthetic optional requirements."""
    source = source_contract(obligation_profile)
    target = implementation(obligation_profile, source)
    row = parity_row(obligation_profile, source, target, online=classification())
    assert (
        codes(
            parity_snapshot(
                obligation_profile,
                snapshot_catalog,
                source=source,
                target=target,
                row=row,
            ),
            complete=True,
        )
        == set()
    )


@pytest.mark.parametrize("missing", [True, False])
def test_required_dimension_cannot_be_absent_or_unverified(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog, missing: bool
) -> None:
    """A full target claim retains every inherited fixed dimension obligation."""
    source = source_contract(obligation_profile)
    target = implementation(obligation_profile, source)
    dims = (
        {}
        if missing
        else {"online": classification(verification="not-run", evidence_refs=[])}
    )
    row = parity_row(obligation_profile, source, target, dimensions=dims)
    assert "PARITY_DIMENSION" in codes(
        parity_snapshot(
            obligation_profile, snapshot_catalog, source=source, target=target, row=row
        )
    )


@pytest.mark.parametrize("state", ["intentionally-changed", "retired"])
@pytest.mark.parametrize("valid", [True, False])
def test_target_dispositions_need_current_covering_approval(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    state: str,
    valid: bool,
) -> None:
    """Approved scoped policy is distinct from a proposed or foreign disposition."""
    source = source_contract(obligation_profile)
    target = implementation(obligation_profile, source)
    approval = decision(obligation_profile, status="approved" if valid else "proposed")
    row = parity_row(
        obligation_profile,
        source,
        target,
        parity_state=state,
        **(
            {"retirement_decision_ref": reference("product-decision", "decision")}
            if state == "retired"
            else {
                "intentional_deviation_refs": [
                    reference("product-decision", "decision")
                ]
            }
        ),
    )
    result = codes(
        parity_snapshot(
            obligation_profile,
            snapshot_catalog,
            source=source,
            target=target,
            row=row,
            extra=(
                approval,
                evidence(
                    obligation_profile, kind="decision", path="docs/approval-proof.json"
                ),
            ),
        ),
        complete=True,
    )
    assert ("PARITY_DECISION" in result) is not valid
    if valid:
        assert result == set()


@pytest.mark.parametrize("change", ["conflict", "proof"])
def test_retirement_does_not_hide_present_false_mode_claims(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog, change: str
) -> None:
    """A retirement waiver does not exempt authored classifications from truth."""
    source = source_contract(obligation_profile)
    target = implementation(obligation_profile, source)
    row = parity_row(
        obligation_profile,
        source,
        target,
        parity_state="retired",
        retirement_decision_ref=reference("product-decision", "decision"),
        online=classification(
            **(
                {"verification": "failed"}
                if change == "conflict"
                else {"evidence_refs": list[object]()}
            )
        ),
    )
    result = codes(
        parity_snapshot(
            obligation_profile,
            snapshot_catalog,
            source=source,
            target=target,
            row=row,
            extra=(
                decision(obligation_profile),
                evidence(
                    obligation_profile, kind="decision", path="docs/approval-proof.json"
                ),
            ),
        )
    )
    assert (
        "PARITY_MODE_CONFLICT" if change == "conflict" else "PARITY_DIMENSION_PROOF"
    ) in result


@pytest.mark.parametrize("approved", [True, False])
def test_required_nonapplicability_needs_explicit_scoped_waiver(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog, approved: bool
) -> None:
    """A rationale alone cannot remove an inherited mode obligation."""
    source = source_contract(obligation_profile)
    target = implementation(obligation_profile, source)
    row = parity_row(obligation_profile, source, target)
    dims = as_object(row["dimensions"])
    dims["online"] = classification(
        applicability="not-applicable",
        verification="not-applicable",
        rationale="Approved exclusion.",
        evidence_refs=[],
        product_decision_refs=(
            [reference("product-decision", "decision")] if approved else []
        ),
    )
    approval = decision(
        obligation_profile,
        scope=decision_scope(
            client_ids=["browser"],
            platforms=["browser"],
            modes=["online"],
            dimensions=["online"],
        ),
    )
    result = codes(
        parity_snapshot(
            obligation_profile,
            snapshot_catalog,
            source=source,
            target=target,
            row=row,
            extra=(
                approval,
                evidence(
                    obligation_profile, kind="decision", path="docs/approval-proof.json"
                ),
            ),
        )
    )
    assert ("PARITY_DISPOSITION" in result) is not approved
    if approved:
        assert result == set()


def test_mobile_dimension_uses_configured_portable_platform(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """The behavior dimension named mobile need not share its platform identifier."""
    profile = profile_with(
        obligation_profile,
        snapshot_catalog,
        required_platforms=["portable"],
        required_feature_dimensions=["mobile"],
        clients=[client(obligation_profile, platforms=["portable"])],
    )
    source = source_contract(profile)
    target = implementation(
        profile,
        source,
        test_references=[
            {
                "source": source_row(profile, "tests/Target.cs"),
                "modes": ["online"],
                "platforms": ["portable"],
                "verification_state": "passed",
                "evidence_refs": [reference("evidence-reference", "target-proof")],
            }
        ],
    )
    row = parity_row(
        profile,
        source,
        target,
        dimensions={"online": classification(), "mobile": classification()},
    )
    assert (
        codes(
            parity_snapshot(
                profile,
                snapshot_catalog,
                source=source,
                target=target,
                row=row,
                proof_fields={
                    "environment": {
                        "id": "capture",
                        "platform": "portable",
                        "operating_mode": "online",
                        "client_id": "browser",
                    }
                },
            ),
            complete=True,
        )
        == set()
    )


@pytest.mark.parametrize(
    "axis,value", [("modes", ["offline"]), ("platforms", ["other"])]
)
def test_passing_tests_cannot_cover_an_unrelated_coordinate(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    axis: str,
    value: list[str],
) -> None:
    """Required coordinates need tests with matching explicit applicability."""
    source = source_contract(obligation_profile)
    test = {
        "source": source_row(obligation_profile, "tests/Target.cs"),
        "modes": ["online"],
        "platforms": ["browser"],
        "verification_state": "passed",
        "evidence_refs": [reference("evidence-reference", "target-proof")],
        axis: value,
    }
    target = implementation(obligation_profile, source, test_references=[test])
    assert "PARITY_VERIFICATION" in codes(
        parity_snapshot(
            obligation_profile, snapshot_catalog, source=source, target=target
        )
    )


def test_each_configured_client_has_an_independent_required_row(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """One browser result cannot count as verification of a second configured client."""
    profile = profile_with(
        obligation_profile,
        snapshot_catalog,
        clients=[client(obligation_profile), client(obligation_profile, "portable")],
    )
    assert "PARITY_MISSING" in codes(
        parity_snapshot(profile, snapshot_catalog), complete=True
    )


@pytest.mark.parametrize("clone", [False, True])
def test_combined_repository_source_test_proof_is_not_target_execution(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog, clone: bool
) -> None:
    """Equal repository/pin or renamed evidence metadata does not create new proof."""
    source = source_contract(
        obligation_profile,
        source_evidence_refs=[
            reference("evidence-reference", "capture" if clone else "target-proof")
        ],
    )
    legacy = evidence(
        obligation_profile,
        kind="test",
        path="docs/legacy-proof.json",
        changes={"path": "evidence/target.txt", "environment": None},
    )
    snapshot = parity_snapshot(
        obligation_profile,
        snapshot_catalog,
        source=source,
        extra=(legacy,) if clone else (),
        proof_fields={
            "evidence_type": "test",
            "environment": None,
            "runtime_artifact": None,
        },
    )
    assert "PARITY_PROOF" in codes(snapshot)


def test_imported_historical_source_is_resolved_at_its_own_pin(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Source transport identity stays independent from local target Git history."""
    source = source_contract(obligation_profile)
    source = replace(
        source,
        repository=RepositoryIdentity(id="foreign", revision="b" * 40),
        path="imports/contracts/feature.json",
        origin_path="contracts/feature.json",
    )
    assert (
        codes(
            parity_snapshot(obligation_profile, snapshot_catalog, source=source),
            complete=True,
        )
        == set()
    )


def test_reused_assessments_and_artifact_order_have_identical_findings(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Reused assessments and input permutations preserve validation outcomes."""
    snapshot = parity_snapshot(obligation_profile, snapshot_catalog)
    index = index_references(snapshot)
    proof = validate_evidence(snapshot, index=index)
    revisions = validate_revisions(snapshot, index=index)
    decisions = validate_decisions(snapshot, index=index, evidence=proof)
    dimensions = validate_dimensions(
        snapshot, index=index, evidence=proof, decisions=decisions
    )
    assert (
        validate_parity(
            snapshot,
            complete=True,
            index=index,
            evidence=proof,
            revisions=revisions,
            decisions=decisions,
            dimensions=dimensions,
        ).findings
        == ()
    )
    for order in permutations(snapshot.artifacts[:3]):
        assert (
            codes(
                replace(snapshot, artifacts=(*order, snapshot.artifacts[3])),
                complete=True,
            )
            == set()
        )
    assert "PARITY_REQUIREMENTS" in {
        item.code
        for item in validate_parity(
            snapshot, dimensions=DimensionValidation((), ())
        ).findings
    }


def test_target_proof_helpers_reject_invalid_direct_context(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Helper calls cannot manufacture ownership or execution for other records."""
    snapshot = parity_snapshot(obligation_profile, snapshot_catalog)
    index = index_references(snapshot)
    context = ClaimContext(index, validate_evidence(snapshot, index=index), 100)
    proof = TargetProof(snapshot, context, validate_revisions(snapshot, index=index))
    feature = next(item for item in index.records if item.kind == "feature-contract")
    assert proof.identity(feature) is None
    assert not proof.coordinate(feature, "browser", "online")
    target = next(
        item for item in index.records if item.kind == "implementation-record"
    )
    document = as_object(to_plain_value(target.document))
    document["verification_state"] = "not-run"
    assert not proof.coordinate(
        replace(target, document=immutable(document)), "browser", "online"
    )
