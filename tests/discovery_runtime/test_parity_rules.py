"""Check source/target proof separation using fresh captured graphs in memory."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.repository_reader import RepositoryIdentity

from tests.discovery_runtime.parity_test_support import (
    codes,
    implementation,
    parity_row,
    parity_snapshot,
    pinned,
    source_contract,
    source_row,
)
from tests.discovery_runtime.test_decision_rules import decision
from tests.discovery_runtime.test_dimension_rules import (
    obligation_profile as obligation_profile,
)
from tests.discovery_runtime.test_evidence_rules import PIN
from tests.discovery_runtime.test_references import reference
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2


def test_full_parity_uses_target_proof_and_preserves_snapshot(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Independent target execution closes the required coordinate without mutation."""
    snapshot = parity_snapshot(obligation_profile, snapshot_catalog)
    before = snapshot.manifest.sha256
    assert codes(snapshot, complete=True) == set()
    assert snapshot.manifest.sha256 == before
    assert (
        codes(
            replace(
                snapshot,
                checkout=RepositoryIdentity(
                    id=obligation_profile.repository.id, revision="c" * 40
                ),
            ),
            complete=True,
        )
        == set()
    )


@pytest.mark.parametrize(
    "field,value",
    [
        ("artifact_sha256", "0" * 64),
        ("revision", "b" * 40),
        ("feature_id", "absent"),
        ("repository_id", "foreign"),
        ("artifact_path", "missing.json"),
    ],
)
def test_source_link_must_match_exact_identity_and_bytes(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    field: str,
    value: str,
) -> None:
    """A full status cannot repair a missing or substituted source contract."""
    source = source_contract(obligation_profile)
    target = implementation(obligation_profile, source)
    row = parity_row(
        obligation_profile,
        source,
        target,
        source_contract_ref={**pinned(source), field: value},
    )
    assert "PARITY_SOURCE" in codes(
        parity_snapshot(
            obligation_profile, snapshot_catalog, source=source, target=target, row=row
        )
    )


@pytest.mark.parametrize("state", ["unassessed", "partial", "missing", "conflicting"])
def test_incomplete_states_are_truthful_drafts_but_not_required_completion(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog, state: str
) -> None:
    """Draft structure and required completion remain separate decisions."""
    source = source_contract(obligation_profile)
    target = implementation(obligation_profile, source)
    row = parity_row(
        obligation_profile,
        source,
        target,
        parity_state=state,
        dimensions={},
        validation_status="not-run",
    )
    snapshot = parity_snapshot(
        obligation_profile, snapshot_catalog, source=source, target=target, row=row
    )
    assert codes(snapshot) == set()
    assert codes(snapshot, complete=True) == {"PARITY_INCOMPLETE"}


@pytest.mark.parametrize(
    "field,value",
    [("target_repository", {"id": "absent", "revision": PIN}), ("client_id", "absent")],
)
def test_entry_requires_configured_target_identity(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    field: str,
    value: object,
) -> None:
    """Unknown clients and targets cannot inherit another client's passing proof."""
    source = source_contract(obligation_profile)
    target = implementation(obligation_profile, source)
    row = parity_row(obligation_profile, source, target, **{field: value})
    assert "PARITY_TARGET" in codes(
        parity_snapshot(
            obligation_profile, snapshot_catalog, source=source, target=target, row=row
        )
    )


@pytest.mark.parametrize(
    "field,value",
    [
        ("checksum", {"algorithm": "sha256", "value": "f" * 64}),
        ("path", None),
        ("revision", "b" * 40),
        ("repository", "foreign"),
        (
            "environment",
            {
                "id": "x",
                "client_id": "other",
                "platform": "browser",
                "operating_mode": "online",
            },
        ),
    ],
)
def test_invalid_or_foreign_capture_cannot_support_full_parity(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    field: str,
    value: object,
) -> None:
    """Claimed execution requires retained target integrity and client identity."""
    result = codes(
        parity_snapshot(
            obligation_profile, snapshot_catalog, proof_fields={field: value}
        )
    )
    assert "PARITY_PROOF" in result


@pytest.mark.parametrize("kind", ["source", "documentation", "inventory", "decision"])
def test_nonexecution_payload_cannot_be_target_execution(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog, kind: str
) -> None:
    """Inspectable bytes do not establish an executed target test result."""
    assert "PARITY_PROOF" in codes(
        parity_snapshot(
            obligation_profile,
            snapshot_catalog,
            proof_fields={"evidence_type": kind, "runtime_artifact": None},
        )
    )


@pytest.mark.parametrize(
    "field,value",
    [
        ("client_id", "absent"),
        ("target_repository", None),
        ("implementation_paths", []),
        ("feature_refs", []),
        ("verification_state", "failed"),
        ("test_references", []),
    ],
)
def test_implementation_claims_have_independent_integrity(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    field: str,
    value: object,
) -> None:
    """Invalid implementation records fail even when row and dimension statuses pass."""
    source = source_contract(obligation_profile)
    target = implementation(obligation_profile, source, **{field: value})
    assert "PARITY_IMPLEMENTATION" in codes(
        parity_snapshot(
            obligation_profile, snapshot_catalog, source=source, target=target
        )
    )


@pytest.mark.parametrize("state", ["failed", "not-run"])
def test_passing_component_cannot_mask_another_linked_incomplete_component(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog, state: str
) -> None:
    """Every linked target component must support a full implementation summary."""
    source = source_contract(obligation_profile)
    first = implementation(obligation_profile, source)
    second = implementation(
        obligation_profile,
        source,
        "second",
        verification_state=state,
        test_references=[
            {
                "source": source_row(obligation_profile, "tests/Target.cs"),
                "verification_state": state,
                "modes": ["online"],
                "platforms": ["browser"],
                "evidence_refs": [reference("evidence-reference", "target-proof")],
            }
        ],
    )
    row = parity_row(
        obligation_profile,
        source,
        first,
        target_implementation_refs=[pinned(first), pinned(second)],
    )
    assert "PARITY_VERIFICATION" in codes(
        parity_snapshot(
            obligation_profile,
            snapshot_catalog,
            source=source,
            target=first,
            row=row,
            extra=(second,),
        )
    )


@pytest.mark.parametrize(
    "field,value", [("blockers", ["blocked"]), ("validation_status", "fail")]
)
def test_full_result_cannot_hide_explicit_blockers(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    field: str,
    value: object,
) -> None:
    """Passing test bytes do not erase an explicitly failing row summary."""
    source = source_contract(obligation_profile)
    target = implementation(obligation_profile, source)
    row = parity_row(obligation_profile, source, target, **{field: value})
    assert "PARITY_STATE" in codes(
        parity_snapshot(
            obligation_profile, snapshot_catalog, source=source, target=target, row=row
        )
    )


def test_duplicate_entries_and_missing_required_entries_are_not_complete(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """A row cannot be counted twice and an absent required row cannot imply success."""
    source = source_contract(obligation_profile)
    target = implementation(obligation_profile, source)
    row = parity_row(obligation_profile, source, target)
    assert "PARITY_DUPLICATE" in codes(
        parity_snapshot(
            obligation_profile,
            snapshot_catalog,
            source=source,
            target=target,
            matrix_fields={"entries": [row, {**row, "id": "duplicate"}]},
        )
    )
    missing = parity_snapshot(
        obligation_profile, snapshot_catalog, matrix_fields={"entries": []}
    )
    assert codes(missing) == set()
    assert codes(missing, complete=True) == {"PARITY_MISSING"}


@pytest.mark.parametrize("state", ["blocked", "not-applicable"])
@pytest.mark.parametrize("reason", [None, "Unavailable in the captured environment."])
def test_unexecuted_implementation_requires_an_explicit_reason(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    state: str,
    reason: str | None,
) -> None:
    """Honest blocked/not-applicable states remain structural, with stated cause."""
    source = source_contract(obligation_profile)
    target = implementation(
        obligation_profile,
        source,
        verification_state=state,
        verification_reason=reason,
        test_references=[],
    )
    row = parity_row(
        obligation_profile, source, target, parity_state="partial", dimensions={}
    )
    result = codes(
        parity_snapshot(
            obligation_profile, snapshot_catalog, source=source, target=target, row=row
        )
    )
    assert ("PARITY_IMPLEMENTATION" in result) is (reason is None)
    if reason is not None:
        assert result == set()


@pytest.mark.parametrize(
    "test_source",
    [
        None,
        {"repository": "foreign", "revision": PIN},
        {"repository": "workspace-example", "revision": "b" * 40},
    ],
)
def test_test_byte_ownership_cannot_be_substituted(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    test_source: dict[str, str] | None,
) -> None:
    """A passing test status cannot substitute a source or unrelated test path."""
    source = source_contract(obligation_profile)
    target = implementation(
        obligation_profile,
        source,
        test_references=[
            {
                "source": test_source,
                "modes": ["online"],
                "platforms": ["browser"],
                "verification_state": "passed",
                "evidence_refs": [reference("evidence-reference", "target-proof")],
            }
        ],
    )
    assert "PARITY_IMPLEMENTATION" in codes(
        parity_snapshot(
            obligation_profile, snapshot_catalog, source=source, target=target
        )
    )


def test_one_passing_test_cannot_hide_an_explicit_failed_test(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
) -> None:
    """A passed implementation summary must be consistent with its linked tests."""
    source = source_contract(obligation_profile)
    tests = [
        {
            "source": source_row(obligation_profile, "tests/Target.cs"),
            "modes": ["online"],
            "platforms": ["browser"],
            "verification_state": state,
            "evidence_refs": [reference("evidence-reference", "target-proof")],
        }
        for state in ("passed", "failed")
    ]
    target = implementation(obligation_profile, source, test_references=tests)
    assert "PARITY_IMPLEMENTATION" in codes(
        parity_snapshot(
            obligation_profile, snapshot_catalog, source=source, target=target
        )
    )


@pytest.mark.parametrize("platform,mode", [("other", "online"), ("browser", "offline")])
def test_capture_context_must_match_the_required_coordinate(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    platform: str,
    mode: str,
) -> None:
    """A correctly labeled test cannot relabel a capture from a different context."""
    snapshot = parity_snapshot(
        obligation_profile,
        snapshot_catalog,
        proof_fields={
            "environment": {
                "id": "capture",
                "client_id": "browser",
                "platform": platform,
                "operating_mode": mode,
            },
        },
    )
    assert "PARITY_VERIFICATION" in codes(snapshot)


def test_wrong_target_revision_and_malformed_dimension_fail_without_exceptions(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Direct semantic calls remain bounded on upstream-invalid present records."""
    source = source_contract(obligation_profile)
    target = implementation(
        obligation_profile,
        source,
        target_repository={
            "id": obligation_profile.repository.id,
            "revision": "b" * 40,
        },
    )
    row = parity_row(obligation_profile, source, target, dimensions={"trigger": False})
    result = codes(
        parity_snapshot(
            obligation_profile, snapshot_catalog, source=source, target=target, row=row
        )
    )
    assert {"PARITY_DIMENSION", "PARITY_IMPLEMENTATION"} <= result


def test_non_evidence_source_links_do_not_disqualify_independent_target_capture(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
) -> None:
    """A proposed source-linked decision is not misclassified as copied proof."""
    source = source_contract(
        obligation_profile,
        product_decision_refs=[reference("product-decision", "decision")],
    )
    snapshot = parity_snapshot(
        obligation_profile,
        snapshot_catalog,
        source=source,
        extra=(decision(obligation_profile, status="proposed"),),
    )
    assert codes(snapshot, complete=True) == set()
