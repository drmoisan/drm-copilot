"""Project captured v2 acceptance facts independently of legacy CLI placeholders.

These tests consume accepted public generation/model/schema APIs. They do not
render executable files, approve requirements, run consumer tests or change ACs.
"""

from __future__ import annotations

from hashlib import sha256
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.acceptance_generation import generate_acceptance
from drm_copilot_discovery.models import canonical_json
from drm_copilot_discovery.report_models import bounded_object
from drm_copilot_discovery.schema_validation import validate_document

from tests.discovery_runtime.test_acceptance_decisions import (
    observation,
    policy_snapshot,
)
from tests.discovery_runtime.test_acceptance_generation import (
    amended,
    generation_snapshot,
    imported_snapshot,
    source_criterion,
)
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.acceptance_models import AcceptanceKind
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.models import JsonObject


@pytest.mark.parametrize("basis", ["source", "approved-decision"])
def test_v2_projection_retains_exact_given_when_then(
    snapshot_catalog: SchemaCatalog, basis: str
) -> None:
    """Project basis (str) from captured catalog fixtures; return None.

    Assert exact source conditions/action and criterion or approved expectation.
    No external writes, runtime execution or caller mutation occurs.
    """
    snapshot = (
        generation_snapshot(snapshot_catalog)
        if basis == "source"
        else policy_snapshot(snapshot_catalog)
    )
    kind: AcceptanceKind = (
        "legacy-characterization" if basis == "source" else "target-acceptance"
    )
    criterion_id = "criterion-alpha" if basis == "source" else "target-criterion"
    before = snapshot.sha256
    result = generate_acceptance(snapshot, kind=kind)
    assert result.findings == (), result.findings
    # Select the explicit criterion rather than depending on scenario digest order.
    item = next(
        row for row in result.ready if row.identity.criterion_id == criterion_id
    )
    # Target policy changes expectations while conditions/actions remain captured facts.
    source = next(
        row.document
        for row in snapshot.artifacts
        if row.expected_kind == "feature-contract"
    )
    assert source is not None
    assert item.document["given"] == (
        cast("JsonObject", source["preconditions"])["statement"],
    )
    assert item.document["when"] == cast("JsonObject", source["trigger"])["statement"]
    assert item.document["then"] == (
        ("The processor state is active after acknowledgement.",)
        if basis == "source"
        else ("Active state is visible before activation returns.",)
    )
    assert item.document["expectation_basis"] == (
        "verified-source" if basis == "source" else "approved-decision"
    )
    assert bool(item.document["product_decision_refs"]) == (
        basis == "approved-decision"
    )
    assert snapshot.sha256 == before


def test_v2_projection_preserves_full_linked_scenario_identity(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Check all stable coordinates using catalog (SchemaCatalog); return None.

    The expected structured key is independent of names, statements and pins.
    Existing scenario identity remains a discriminator. No external effects occur.
    """
    snapshot = generation_snapshot(
        snapshot_catalog, target=True, extras=(observation(),)
    )
    result = generate_acceptance(snapshot, kind="target-acceptance")
    assert result.findings == () and len(result.ready) == 1, result.findings
    item = result.ready[0]
    key = bounded_object(
        {
            "source_repository_id": snapshot.profile.repository.id,
            "kind": "target-acceptance",
            "feature_id": "feature-alpha",
            "criterion_id": "criterion-alpha",
            "client_id": "client-alpha",
            "platform_id": "generic",
            "mode_id": "online",
            "linked_scenario": (snapshot.profile.repository.id, "scenario-alpha"),
        },
        limits=result.limits,
    )
    expected = "scn-" + sha256(canonical_json(key)).hexdigest()
    assert item.identity.key(limits=result.limits) == key
    assert item.identity.scenario_id(limits=result.limits) == expected
    assert item.document["id"] == item.document["scenario_id"] == expected
    assert (
        item.to_json()
        == generate_acceptance(snapshot, kind="target-acceptance").ready[0].to_json()
    )


def test_v2_projection_uses_closed_document_and_separate_captured_owner(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Validate the imported-source projection using catalog; return None.

    Source provenance retains its original namespace/path while the target owner
    remains outside the closed document. No publication or source mutation occurs.
    """
    snapshot = imported_snapshot(snapshot_catalog)
    result = generate_acceptance(snapshot, kind="target-acceptance")
    assert result.findings == () and len(result.ready) == 1, result.findings
    item = result.ready[0]
    validation = validate_document(
        item.to_json(),
        expected_kind="acceptance-specification",
        expected_version="2.0.0",
        catalog=snapshot_catalog,
    )
    assert validation.findings == ()
    document = item.to_dict()
    assert document["artifact_kind"] == "acceptance-specification"
    assert document["schema_version"] == "2.0.0"
    assert "repository" not in document and "scenarios" not in document
    assert item.repository.id == snapshot.profile.clients[0].target_repository
    assert item.repository.id != item.identity.source_repository_id
    assert item.repository.revision == snapshot.profile.repository.revision
    references = cast("tuple[JsonObject, ...]", item.document["source_contract_refs"])
    assert len(references) == 1
    reference = references[0]
    # Imported storage prefixes must not replace original source identity.
    source = next(
        row for row in snapshot.artifacts if row.expected_kind == "feature-contract"
    )
    assert (
        reference["repository_id"]
        == source.repository.id
        == item.identity.source_repository_id
    )
    assert reference["artifact_path"] == source.origin_path != source.path
    assert reference["revision"] == source.repository.revision
    assert item.document["source_content_sha256"]


@pytest.mark.parametrize(
    "missing", ["expectation", "evidence-reference", "source-feature"]
)
def test_v2_projection_withholds_unknown_or_missing_authority(
    snapshot_catalog: SchemaCatalog, missing: str
) -> None:
    """Use missing (str) to distinguish pending expectations from broken authority.

    Captured fixtures and catalog remain immutable. No missing selection or proof
    creates a ready fallback; pending Then is null. Returns None without I/O.
    """
    snapshot = generation_snapshot(snapshot_catalog)
    selectors: tuple[tuple[str, str], ...] = ()
    # Unknown content is a pending requirement; missing links/selectors are blockers.
    if missing == "source-feature":
        selectors = ((snapshot.profile.repository.id, "absent-feature"),)
    else:
        criterion = (
            source_criterion(
                snapshot,
                readiness="pending",
                expected_result=None,
                pending_reason="Expected behavior remains unresolved.",
            )
            if missing == "expectation"
            else source_criterion(
                snapshot,
                evidence_refs=[
                    {"artifact_kind": "evidence-reference", "id": "absent-proof"}
                ],
            )
        )
        snapshot = amended(
            snapshot, "feature-alpha", {"acceptance_criteria": [criterion]}
        )
    result = generate_acceptance(
        snapshot, kind="legacy-characterization", feature_ids=selectors
    )
    assert result.ready == ()
    # Unknown expectations remain pending; broken authority retains blocking findings.
    if missing == "expectation":
        assert len(result.specifications) == 1
        document = result.specifications[0].document
        assert document["readiness"] == "pending"
        assert (
            document["then"] is None and document["expectation_basis"] == "unresolved"
        )
        assert document["pending_reasons"]
    else:
        # A missing reference or selection must produce an explicit blocking diagnostic.
        assert any(finding.severity == "error" for finding in result.findings)
    # No invalid or unknown input may manufacture a ready-looking fallback.
    assert not any(
        row.document.get("readiness") == "ready" for row in result.specifications
    )
