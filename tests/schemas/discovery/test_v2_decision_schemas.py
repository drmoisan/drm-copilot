"""Preserve observed uncertainty separately from approved target policy."""

from __future__ import annotations

from typing import cast

import pytest

from tests.schemas.discovery.v2_schema_test_support import (
    as_object,
    load_fixture,
    schema_errors,
)

DECISION_FIELDS = (
    "decision_id feature_refs unspecified_behavior_refs decision_key scope status "
    "decision rationale alternatives affected_platforms required_migration_behavior "
    "approval resulting_acceptance_criteria supersedes extensions"
).split()
BEHAVIOR_FIELDS = (
    "behavior_id feature_refs dimensions question evidence_refs "
    "competing_interpretations impact status decision_owner decision_ref "
    "decision rationale approved_target_behavior "
    "acceptance_test_implications resolution_basis resolution_evidence_refs extensions"
).split()


def _first(document: dict[str, object], field: str) -> dict[str, object]:
    """Select a fresh nested record without mutating shared fixture state."""
    return as_object(cast("list[object]", document[field])[0])


@pytest.mark.parametrize("field", DECISION_FIELDS)
def test_decisions_require_all_policy_traceability_categories(field: str) -> None:
    """An omitted approval, alternative or scope field cannot be treated as implicit."""
    document = load_fixture("product-decision")
    del document[field]

    assert schema_errors("product-decision", document)


@pytest.mark.parametrize(
    "field,value",
    [
        ("decision", None),
        ("rationale", " "),
        ("required_migration_behavior", None),
        ("approval", None),
        ("resulting_acceptance_criteria", []),
    ],
)
def test_approved_decisions_require_reason_approval_and_ready_criteria(
    field: str,
    value: object,
) -> None:
    """An approval status cannot replace the explicit policy and supporting record."""
    document = load_fixture("product-decision")
    document[field] = value

    assert schema_errors("product-decision", document)


@pytest.mark.parametrize(
    "field,value",
    [
        ("owner", "owner\n"),
        ("timestamp", "2026-02-30T00:00:00Z"),
        ("timestamp", "2026-01-01T00:00:00"),
        ("evidence_refs", []),
        ("authorized", True),
    ],
)
def test_approval_metadata_is_typed_and_cannot_assert_host_authority(
    field: str,
    value: object,
) -> None:
    """Approval requires actor, time and evidence without a permission bit."""
    document = load_fixture("product-decision")
    as_object(document["approval"])[field] = value

    assert schema_errors("product-decision", document)


@pytest.mark.parametrize("field", ("owner", "timestamp", "evidence_refs"))
def test_approval_requires_each_metadata_field(field: str) -> None:
    """The policy owner, event time and evidence remain individually accountable."""
    document = load_fixture("product-decision")
    del as_object(document["approval"])[field]

    assert schema_errors("product-decision", document)


@pytest.mark.parametrize("state", ("proposed", "rejected"))
def test_unapproved_decisions_cannot_supply_ready_expected_results(state: str) -> None:
    """Proposed and rejected policies keep acceptance implications pending."""
    document = load_fixture("product-decision")
    document.update(status=state, approval=None)
    assert schema_errors("product-decision", document)
    criterion = _first(document, "resulting_acceptance_criteria")
    criterion.update(
        readiness="pending",
        expected_result=None,
        pending_reason="No approved target policy exists.",
    )
    assert schema_errors("product-decision", document) == []
    criterion["expected_result"] = "An unapproved target expectation."

    assert schema_errors("product-decision", document)


def test_proposal_cannot_retain_approval_even_with_no_criteria() -> None:
    """Approval metadata and proposed status cannot disagree structurally."""
    document = load_fixture("product-decision")
    document.update(status="proposed", resulting_acceptance_criteria=[])
    assert schema_errors("product-decision", document)
    document["approval"] = None

    assert schema_errors("product-decision", document) == []


def test_superseded_decision_preserves_history_without_ready_criteria() -> None:
    """Historical expectations survive under an inactive readiness state."""
    document = load_fixture("product-decision")
    document["status"] = "superseded"
    assert schema_errors("product-decision", document)
    criterion = _first(document, "resulting_acceptance_criteria")
    criterion["readiness"] = "superseded"

    assert schema_errors("product-decision", document) == []
    assert criterion["expected_result"] is not None
    assert document["approval"] is not None


@pytest.mark.parametrize(
    "field", ("feature_ids", "client_ids", "platforms", "modes", "dimensions")
)
def test_decision_scope_requires_explicit_selectors(field: str) -> None:
    """Scope omission is distinct from an explicitly unrestricted selector."""
    document = load_fixture("product-decision")
    scope = as_object(document["scope"])
    del scope[field]
    assert schema_errors("product-decision", document)
    scope[field] = []

    assert bool(schema_errors("product-decision", document)) == (field == "feature_ids")


def test_decision_can_target_multiple_clients_and_platform_modes() -> None:
    """Policy selectors support multiple target clients without domain assumptions."""
    document = load_fixture("product-decision")
    as_object(document["scope"]).update(
        client_ids=["client-alpha", "client-beta"],
        platforms=["desktop", "mobile"],
        modes=["online", "offline"],
        dimensions=["timing", "offline", "mobile"],
    )

    assert schema_errors("product-decision", document) == []


@pytest.mark.parametrize("field", ("feature_refs", "unspecified_behavior_refs"))
def test_decision_must_link_a_feature_or_unresolved_behavior(field: str) -> None:
    """Either relationship can anchor a decision, but both cannot be absent."""
    document = load_fixture("product-decision")
    document[field] = []
    assert schema_errors("product-decision", document) == []
    document.update(feature_refs=[], unspecified_behavior_refs=[])

    assert schema_errors("product-decision", document)


def test_supersession_links_decisions_without_encoding_an_approval_override() -> None:
    """A stable decision key and typed predecessor support later conflict analysis."""
    document = load_fixture("product-decision")
    document["supersedes"] = [
        {"artifact_kind": "product-decision", "id": "decision-earlier"}
    ]
    assert schema_errors("product-decision", document) == []
    _first(document, "supersedes")["artifact_kind"] = "feature-contract"
    assert schema_errors("product-decision", document)
    document["supersedes"] = []
    document["decision_key"] = "activation-timing\n"

    assert schema_errors("product-decision", document)


@pytest.mark.parametrize("field", BEHAVIOR_FIELDS)
def test_unresolved_records_require_observation_and_resolution_categories(
    field: str,
) -> None:
    """Question, impact and resolution fields stay explicit even when null."""
    document = load_fixture("unspecified-behavior")
    del document[field]

    assert schema_errors("unspecified-behavior", document)


@pytest.mark.parametrize("state", ("open", "under-review"))
@pytest.mark.parametrize(
    "field,value",
    [
        ("decision", "A target policy."),
        ("approved_target_behavior", "An unapproved outcome."),
        ("resolution_basis", "verified-observation"),
        (
            "resolution_evidence_refs",
            [{"artifact_kind": "evidence-reference", "id": "observation-alpha"}],
        ),
    ],
)
def test_open_questions_cannot_claim_a_resolved_target_expectation(
    state: str,
    field: str,
    value: object,
) -> None:
    """Questions under review retain uncertainty without inventing target policy."""
    document = load_fixture("unspecified-behavior")
    document["status"] = state
    assert schema_errors("unspecified-behavior", document) == []
    document[field] = value

    assert schema_errors("unspecified-behavior", document)


def test_verified_observation_resolves_a_question_without_making_target_policy() -> (
    None
):
    """Historical facts resolve uncertainty without assigning target policy."""
    document = load_fixture("unspecified-behavior")
    original_question = document["question"]
    document.update(
        status="resolved",
        resolution_basis="verified-observation",
        rationale="Repeated observation confirms the timing.",
    )
    assert schema_errors("unspecified-behavior", document)
    document["resolution_evidence_refs"] = [
        {"artifact_kind": "evidence-reference", "id": "observation-alpha"}
    ]
    assert schema_errors("unspecified-behavior", document) == []
    assert document["question"] == original_question
    document["approved_target_behavior"] = "A new target policy."

    assert schema_errors("unspecified-behavior", document)


@pytest.mark.parametrize("state", ("resolved", "intentionally-unspecified"))
@pytest.mark.parametrize(
    "field",
    (
        "decision_ref",
        "decision_owner",
        "decision",
        "rationale",
        "approved_target_behavior",
    ),
)
def test_policy_resolutions_keep_owner_decision_and_target_behavior(
    state: str,
    field: str,
) -> None:
    """Intentional ambiguity requires a reviewable target policy record."""
    document = load_fixture("unspecified-behavior")
    document.update(
        status=state,
        resolution_basis="approved-decision",
        decision_owner="owner-alpha",
        decision_ref={"artifact_kind": "product-decision", "id": "decision-alpha"},
        decision="Preserve unspecified timing.",
        rationale="No target timing guarantee is required.",
        approved_target_behavior="Either documented timing remains permitted.",
    )
    assert schema_errors("unspecified-behavior", document) == []
    document[field] = None

    assert schema_errors("unspecified-behavior", document)


def test_intentionally_unspecified_behavior_cannot_use_observation_as_approval() -> (
    None
):
    """Observation cannot approve intentionally unspecified target behavior."""
    document = load_fixture("unspecified-behavior")
    document.update(
        status="intentionally-unspecified",
        resolution_basis="verified-observation",
        rationale="The behavior differs across environments.",
        resolution_evidence_refs=[
            {"artifact_kind": "evidence-reference", "id": "observation-alpha"}
        ],
    )

    assert schema_errors("unspecified-behavior", document)


@pytest.mark.parametrize(
    "field,value",
    [
        ("confidence", "verified"),
        ("description", " "),
        (
            "evidence_refs",
            [{"artifact_kind": "product-decision", "id": "decision-alpha"}],
        ),
    ],
)
def test_competing_interpretations_do_not_replace_observation_confidence(
    field: str,
    value: object,
) -> None:
    """Interpretations retain confidence separately from verification or approval."""
    document = load_fixture("unspecified-behavior")
    _first(document, "competing_interpretations")[field] = value

    assert schema_errors("unspecified-behavior", document)


@pytest.mark.parametrize("kind", ("product-decision", "unspecified-behavior"))
def test_collections_accept_empty_or_strictly_typed_records(kind: str) -> None:
    """An empty initialized collection can later contain complete typed records."""
    collection = load_fixture(kind + "-collection")
    assert schema_errors(kind + "-collection", collection) == []
    collection["records"] = [load_fixture(kind)]
    assert schema_errors(kind + "-collection", collection) == []
    _first(collection, "records")["artifact_kind"] = "feature-contract"

    assert schema_errors(kind + "-collection", collection)


@pytest.mark.parametrize("kind", ("product-decision", "unspecified-behavior"))
def test_collections_reject_exact_duplicates_and_malformed_nested_records(
    kind: str,
) -> None:
    """Collections validate nested rules; keyed conflicts remain a graph gate."""
    collection = load_fixture(kind + "-collection")
    record = load_fixture(kind)
    collection["records"] = [record, record]
    assert schema_errors(kind + "-collection", collection)
    collection["records"] = [record]
    del record["status"]

    assert schema_errors(kind + "-collection", collection)
