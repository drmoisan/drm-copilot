"""Verify strict target artifacts and independent parity verification claims."""

from __future__ import annotations

from copy import deepcopy
from typing import cast

import pytest
from drm_copilot_discovery.resources import read_resource
from jsonschema import Draft202012Validator

from scripts.dev_tools.build_discovery_runtime import verify_schema_closure
from tests.schemas.discovery.v2_schema_test_support import (
    HASH,
    PIN,
    SCHEMAS,
    URN,
    as_object,
    load_fixture,
    load_schema,
    schema_errors,
)

TARGET_KINDS = (
    "parity-matrix",
    "implementation-record",
    "unspecified-behavior",
    "product-decision",
    "unspecified-behavior-collection",
    "product-decision-collection",
    "acceptance-specification",
)
ENTRY_FIELDS = (
    "id feature_id source_contract_ref client_id target_repository "
    "target_implementation_refs parity_state dimensions evidence_refs "
    "intentional_deviation_refs retirement_decision_ref blockers "
    "validation_status missing_reason extensions"
).split()
IMPLEMENTATION_FIELDS = (
    "target_repository client_id feature_refs implementation_paths "
    "test_references verification_evidence_refs verification_state "
    "verification_reason extensions"
).split()
SOURCE_FIELDS = (
    "artifact_kind repository_id revision artifact_path artifact_sha256 "
    "feature_id schema_version"
).split()


def _first(document: dict[str, object], field: str) -> dict[str, object]:
    """Select one record in a freshly loaded test-local fixture."""
    return as_object(cast("list[object]", document[field])[0])


def _implementation_reference() -> dict[str, object]:
    """Represent a pinned target record without claiming its verification passed."""
    return {
        "artifact_kind": "implementation-record",
        "id": "implementation-alpha",
        "repository": "synthetic-target",
        "revision": "b" * 40,
        "path": "implementation/implementation-alpha.yaml",
        "sha256": HASH,
    }


@pytest.mark.parametrize("kind", TARGET_KINDS)
def test_target_schemas_are_closed_valid_and_packaged(kind: str) -> None:
    """Exact version identities and bytes survive resource publication."""
    schema = load_schema(kind)

    Draft202012Validator.check_schema(schema)

    assert schema["$id"] == URN + kind
    assert schema["additionalProperties"] is False
    assert (
        read_resource(f"schemas/discovery/v2/{kind}.schema.json")
        == (SCHEMAS / f"{kind}.schema.json").read_bytes()
    )


def test_target_schema_references_resolve_within_the_offline_catalog() -> None:
    """Shared criterion and source definitions resolve without a network."""
    inputs = {
        f"schemas/discovery/v2/{path.name}": path.read_bytes()
        for path in SCHEMAS.glob("*.schema.json")
    }

    verify_schema_closure(inputs)

    assert all(
        f"schemas/discovery/v2/{kind}.schema.json" in inputs for kind in TARGET_KINDS
    )


@pytest.mark.parametrize("kind", TARGET_KINDS)
def test_valid_target_examples_preserve_authored_values(kind: str) -> None:
    """Structural validation neither approves a decision nor modifies an observation."""
    document = load_fixture(kind)
    original = deepcopy(document)

    errors = schema_errors(kind, document)

    assert errors == [], [error.message for error in errors]
    assert document == original


@pytest.mark.parametrize("kind", TARGET_KINDS)
def test_invalid_target_examples_have_actionable_repairable_failures(kind: str) -> None:
    """Each negative fixture isolates a pin, approval, outcome or collection defect."""
    document = load_fixture(kind, invalid=True)
    errors = schema_errors(kind, document)
    if kind == "parity-matrix":
        as_object(_first(document, "entries")["source_contract_ref"])["revision"] = PIN
    elif kind == "implementation-record":
        document["verification_state"] = "not-run"
    elif kind == "unspecified-behavior":
        document["approved_target_behavior"] = None
    elif kind == "product-decision":
        document["approval"] = load_fixture(kind)["approval"]
    elif kind == "acceptance-specification":
        document["then"] = None
    else:
        document["records"] = []

    assert errors and errors[0].absolute_path
    assert schema_errors(kind, document) == []


@pytest.mark.parametrize("kind", TARGET_KINDS)
@pytest.mark.parametrize(
    "field,value",
    [
        ("schema_version", "1.0.0"),
        ("$schema", URN + "common"),
        ("artifact_kind", "scope"),
        ("id", "target-alpha\n"),
        ("verified", True),
    ],
)
def test_target_identity_and_closed_core_cannot_be_bypassed(
    kind: str,
    field: str,
    value: object,
) -> None:
    """Unknown keys and unsupported identities cannot select weaker validation."""
    document = load_fixture(kind)
    document[field] = value

    assert schema_errors(kind, document)


@pytest.mark.parametrize("kind", TARGET_KINDS)
def test_namespaced_extensions_do_not_replace_required_core_fields(kind: str) -> None:
    """Domain enrichment is supported only alongside the complete core contract."""
    document = load_fixture(kind)
    document["extensions"] = {"example.org": {"verified": True, "custom": [1, None]}}
    assert schema_errors(kind, document) == []
    del document["id"]

    assert schema_errors(kind, document)


@pytest.mark.parametrize("field", ENTRY_FIELDS)
def test_parity_entries_require_every_traceability_and_state_category(
    field: str,
) -> None:
    """A row cannot hide absent source, target, disposition or verification metadata."""
    document = load_fixture("parity-matrix")
    del _first(document, "entries")[field]

    assert schema_errors("parity-matrix", document)


@pytest.mark.parametrize("field", SOURCE_FIELDS)
def test_parity_source_identity_is_an_explicit_immutable_contract(field: str) -> None:
    """Source references bind repository, bytes, feature and schema version."""
    document = load_fixture("parity-matrix")
    del as_object(_first(document, "entries")["source_contract_ref"])[field]

    assert schema_errors("parity-matrix", document)


@pytest.mark.parametrize(
    "field,value",
    [
        ("repository_id", "source\n"),
        ("revision", "main"),
        ("revision", PIN + "\n"),
        ("artifact_path", "../contract.yaml"),
        ("artifact_path", "C:/contract.yaml"),
        ("artifact_sha256", HASH + "\n"),
        ("feature_id", "feature-alpha\n"),
        ("schema_version", "1.0.0"),
        ("artifact_kind", "implementation-record"),
    ],
)
def test_source_contract_identity_rejects_mutable_or_unsafe_references(
    field: str,
    value: object,
) -> None:
    """A friendly branch, unsafe path or malformed digest cannot be an immutable pin."""
    document = load_fixture("parity-matrix")
    as_object(_first(document, "entries")["source_contract_ref"])[field] = value

    assert schema_errors("parity-matrix", document)


@pytest.mark.parametrize("field", ("source_repositories", "target_repositories"))
def test_empty_parity_allows_unresolved_initial_pins_but_populated_rows_do_not(
    field: str,
) -> None:
    """Initialization remains honest when repository identity is not yet available."""
    document = load_fixture("parity-matrix")
    _first(document, field)["revision"] = None
    assert schema_errors("parity-matrix", document)
    document["entries"] = []
    assert schema_errors("parity-matrix", document) == []
    document[field] = []

    assert schema_errors("parity-matrix", document) == []


def test_parity_is_client_scoped_and_does_not_force_optional_mode_analysis() -> None:
    """Clients can share a feature without mandatory offline/mobile rows."""
    document = load_fixture("parity-matrix")
    first = _first(document, "entries")
    second = deepcopy(first)
    second.update(id="parity-feature-alpha-client-beta", client_id="client-beta")
    document["entries"] = [first, second]

    assert "offline" not in first and "mobile" not in first
    assert schema_errors("parity-matrix", document) == []


@pytest.mark.parametrize("state", ("full", "partial"))
def test_parity_claims_require_pinned_target_records_and_evidence(state: str) -> None:
    """Positive parity states require more than an author's status string."""
    document = load_fixture("parity-matrix")
    entry = _first(document, "entries")
    entry.update(parity_state=state, validation_status="pass", blockers=[])
    assert schema_errors("parity-matrix", document)
    entry["target_implementation_refs"] = [_implementation_reference()]
    assert schema_errors("parity-matrix", document)
    entry["evidence_refs"] = [
        {"artifact_kind": "evidence-reference", "id": "target-test"}
    ]
    assert schema_errors("parity-matrix", document) == []
    del _first(entry, "target_implementation_refs")["sha256"]

    assert schema_errors("parity-matrix", document)


@pytest.mark.parametrize(
    "state,field,value",
    [
        ("missing", "missing_reason", None),
        ("missing", "target_implementation_refs", [_implementation_reference()]),
        ("intentionally-changed", "intentional_deviation_refs", []),
        ("retired", "retirement_decision_ref", None),
        ("conflicting", "blockers", []),
        (
            "missing",
            "retirement_decision_ref",
            {"artifact_kind": "product-decision", "id": "decision-alpha"},
        ),
    ],
)
def test_parity_dispositions_require_their_own_reason_or_decision(
    state: str,
    field: str,
    value: object,
) -> None:
    """Missing, changed, retired and conflicting states retain distinct obligations."""
    document = load_fixture("parity-matrix")
    entry = _first(document, "entries")
    entry.update(parity_state=state)
    entry[field] = value

    assert schema_errors("parity-matrix", document)


@pytest.mark.parametrize("state", ("intentionally-changed", "retired"))
def test_changed_or_retired_parity_keeps_typed_decision_traceability(
    state: str,
) -> None:
    """Decision references preserve policy traceability without proving approval."""
    document = load_fixture("parity-matrix")
    entry = _first(document, "entries")
    decision = {"artifact_kind": "product-decision", "id": "decision-alpha"}
    entry["parity_state"] = state
    if state == "retired":
        entry["retirement_decision_ref"] = decision
    else:
        entry["intentional_deviation_refs"] = [decision]

    assert schema_errors("parity-matrix", document) == []


@pytest.mark.parametrize("mode", ("online", "offline", "mobile"))
@pytest.mark.parametrize("state", ("passed", "failed"))
def test_mode_verification_needs_evidence_separate_from_applicability(
    mode: str,
    state: str,
) -> None:
    """Mode applicability remains independent from actual verification results."""
    document = load_fixture("parity-matrix")
    entry = _first(document, "entries")
    dimension = deepcopy(as_object(entry["online"]))
    entry[mode] = dimension
    dimension["verification"] = state
    assert schema_errors("parity-matrix", document)
    dimension["evidence_refs"] = [
        {"artifact_kind": "evidence-reference", "id": "target-test"}
    ]
    assert schema_errors("parity-matrix", document) == []
    dimension["applicability"] = "unspecified"

    assert schema_errors("parity-matrix", document)


def test_optional_not_applicable_mode_requires_rationale_without_forcing_approval() -> (
    None
):
    """Local completion policy governs approval for optional mode exclusions."""
    document = load_fixture("parity-matrix")
    mode = as_object(_first(document, "entries")["online"])
    mode.update(applicability="not-applicable", verification="not-applicable")
    assert schema_errors("parity-matrix", document)
    mode["rationale"] = "This client does not expose this operating mode."
    assert schema_errors("parity-matrix", document) == []
    mode["verification"] = "not-run"

    assert schema_errors("parity-matrix", document)


@pytest.mark.parametrize("field", IMPLEMENTATION_FIELDS)
def test_implementation_records_require_target_and_test_provenance(field: str) -> None:
    """A target implementation record cannot omit its explicit verification context."""
    document = load_fixture("implementation-record")
    del document[field]

    assert schema_errors("implementation-record", document)


@pytest.mark.parametrize("state", ("passed", "failed"))
def test_implementation_outcomes_require_matching_test_results_and_evidence(
    state: str,
) -> None:
    """An existing source path alone cannot establish that a target test ran."""
    document = load_fixture("implementation-record")
    document["verification_state"] = state
    evidence = [{"artifact_kind": "evidence-reference", "id": "target-test"}]
    document["verification_evidence_refs"] = evidence
    assert schema_errors("implementation-record", document)
    test = _first(document, "test_references")
    test["verification_state"] = state
    assert schema_errors("implementation-record", document)
    test["evidence_refs"] = evidence
    assert schema_errors("implementation-record", document) == []
    test["verification_state"] = "failed" if state == "passed" else "passed"

    assert schema_errors("implementation-record", document)


@pytest.mark.parametrize("state", ("blocked", "not-applicable"))
def test_unrun_implementation_dispositions_require_an_explicit_reason(
    state: str,
) -> None:
    """Unavailable verification is not silently converted to a passing result."""
    document = load_fixture("implementation-record")
    document["verification_state"] = state
    assert schema_errors("implementation-record", document)
    document["verification_reason"] = "The required client environment is unavailable."

    assert schema_errors("implementation-record", document) == []


@pytest.mark.parametrize(
    "field,value",
    [
        ("revision", "main"),
        ("path", "../Processor.cs"),
        ("sha256", "unknown"),
    ],
)
def test_implementation_paths_preserve_immutable_target_bytes(
    field: str, value: object
) -> None:
    """Implementation paths use the same pin contract as analyzer findings."""
    document = load_fixture("implementation-record")
    _first(document, "implementation_paths")[field] = value

    assert schema_errors("implementation-record", document)
