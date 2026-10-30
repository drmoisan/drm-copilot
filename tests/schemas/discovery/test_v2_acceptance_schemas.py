"""Verify acceptance readiness without claiming implementation test results."""

from __future__ import annotations

from typing import cast

import pytest

from tests.schemas.discovery.v2_schema_test_support import (
    as_object,
    load_fixture,
    schema_errors,
)

ACCEPTANCE_FIELDS = (
    "scenario_id kind feature_id criterion_id client_id platform_id mode_id "
    "readiness given when then pending_reasons expectation_basis source_contract_refs "
    "evidence_refs product_decision_refs tags source_content_sha256 extensions"
).split()


@pytest.mark.parametrize("field", ACCEPTANCE_FIELDS)
def test_acceptance_records_require_linkage_context_and_expectation_basis(
    field: str,
) -> None:
    """Test specifications retain explicit scenario and expectation provenance."""
    document = load_fixture("acceptance-specification")
    del document[field]

    assert schema_errors("acceptance-specification", document)


@pytest.mark.parametrize(
    "field,value",
    [
        ("then", None),
        ("then", []),
        ("then", [" "]),
        ("when", None),
        ("pending_reasons", ["Await approval."]),
        ("expectation_basis", "unresolved"),
        ("evidence_refs", []),
    ],
)
def test_ready_specifications_require_known_actions_outcomes_and_provenance(
    field: str,
    value: object,
) -> None:
    """Readiness identifies a supported specification, without an execution result."""
    document = load_fixture("acceptance-specification")
    document[field] = value

    assert schema_errors("acceptance-specification", document)


def test_pending_specification_preserves_unknown_expectation_and_reason() -> None:
    """Unresolved criteria retain null Then and an actionable explanation."""
    document = load_fixture("acceptance-specification")
    document.update(
        readiness="pending",
        when=None,
        then=None,
        pending_reasons=["Await repeatable runtime evidence."],
        expectation_basis="unresolved",
        evidence_refs=[],
    )
    assert schema_errors("acceptance-specification", document) == []
    document["then"] = ["An invented expected result."]
    assert schema_errors("acceptance-specification", document)
    document["then"] = None
    document["pending_reasons"] = []

    assert schema_errors("acceptance-specification", document)


def test_target_expectation_can_reference_a_product_decision() -> None:
    """Policy uses typed decision links; the graph checks actual approval."""
    document = load_fixture("acceptance-specification")
    document.update(expectation_basis="approved-decision", evidence_refs=[])
    assert schema_errors("acceptance-specification", document)
    document["product_decision_refs"] = [
        {"artifact_kind": "product-decision", "id": "decision-alpha"}
    ]
    assert schema_errors("acceptance-specification", document) == []
    as_object(cast("list[object]", document["product_decision_refs"])[0])[
        "artifact_kind"
    ] = "feature-contract"

    assert schema_errors("acceptance-specification", document)


def test_legacy_characterization_needs_no_target_client_or_decision() -> None:
    """Legacy observations remain independent of modern clients and target policy."""
    document = load_fixture("acceptance-specification")
    document.update(kind="legacy-characterization", client_id=None, platform_id=None)
    assert schema_errors("acceptance-specification", document) == []
    document.update(
        expectation_basis="approved-decision",
        product_decision_refs=[
            {"artifact_kind": "product-decision", "id": "decision-alpha"}
        ],
    )

    assert schema_errors("acceptance-specification", document)


@pytest.mark.parametrize("field", ("client_id", "platform_id"))
def test_target_specifications_require_client_and_platform_identity(field: str) -> None:
    """Target scenarios remain attributable when several clients share one feature."""
    document = load_fixture("acceptance-specification")
    document[field] = None

    assert schema_errors("acceptance-specification", document)


@pytest.mark.parametrize("mode", ("online", "offline"))
@pytest.mark.parametrize("platform", ("desktop", "mobile"))
def test_scenarios_preserve_configured_platform_and_mode_tags(
    mode: str, platform: str
) -> None:
    """Offline/mobile labels are supported without making them universal obligations."""
    document = load_fixture("acceptance-specification")
    document.update(mode_id=mode, platform_id=platform)
    tags = cast("list[str]", document["tags"])
    document["tags"] = [
        tag for tag in tags if not tag.startswith(("@mode_", "@platform_"))
    ] + [f"@mode_{mode}", f"@platform_{platform}"]

    assert schema_errors("acceptance-specification", document) == []


@pytest.mark.parametrize(
    "tag", ("@offline\n", "@mobile\r\n", "@mode_online\u2028", "offline", "@not valid")
)
def test_tag_lexemes_reject_hidden_suffixes_and_invalid_gherkin_labels(
    tag: str,
) -> None:
    """Stable scenario tags cannot contain whitespace or a final newline suffix."""
    document = load_fixture("acceptance-specification")
    document["tags"] = [tag]

    assert schema_errors("acceptance-specification", document)


@pytest.mark.parametrize(
    "field,value",
    [
        ("revision", "main"),
        ("artifact_sha256", "c" * 64 + "\n"),
        ("artifact_path", "../source.yaml"),
        ("schema_version", "1.0.0"),
    ],
)
def test_acceptance_provenance_preserves_the_exact_source_contract(
    field: str,
    value: object,
) -> None:
    """Generated expectations retain immutable source contract references."""
    document = load_fixture("acceptance-specification")
    source = as_object(cast("list[object]", document["source_contract_refs"])[0])
    source[field] = value

    assert schema_errors("acceptance-specification", document)


@pytest.mark.parametrize(
    "field,value",
    [
        ("scenario_id", "scenario-alpha\n"),
        ("criterion_id", "criterion-alpha\n"),
        ("source_content_sha256", "d" * 64 + "\n"),
        ("kind", "implementation-test"),
        ("readiness", "passed"),
        ("verification_state", "passed"),
        ("test_code", "assert True"),
    ],
)
def test_specifications_cannot_be_relabelled_as_test_implementations_or_results(
    field: str,
    value: object,
) -> None:
    """Identity, source hashing and readiness remain separate from execution."""
    document = load_fixture("acceptance-specification")
    document[field] = value

    assert schema_errors("acceptance-specification", document)


def test_implementation_test_links_preserve_provenance_without_test_outcome() -> None:
    """A downstream test link cannot assign a passing state to a specification."""
    document = load_fixture("acceptance-specification")
    implementation = load_fixture("implementation-record")
    test = as_object(cast("list[object]", implementation["test_references"])[0])
    document["implementation_test_refs"] = [test["source"]]
    assert schema_errors("acceptance-specification", document) == []
    as_object(test["source"])["verification_state"] = "passed"

    assert schema_errors("acceptance-specification", document)


def test_superseded_specification_keeps_its_historical_expectation() -> None:
    """Historical specifications retain an explicitly inactive state."""
    document = load_fixture("acceptance-specification")
    document["readiness"] = "superseded"

    assert schema_errors("acceptance-specification", document) == []
    assert document["then"] is not None
