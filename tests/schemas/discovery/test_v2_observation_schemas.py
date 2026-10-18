"""Verify observed feature and evidence contracts using offline synthetic inputs."""

from __future__ import annotations

from copy import deepcopy
from typing import cast

import pytest
from drm_copilot_discovery.resources import read_resource
from jsonschema import Draft202012Validator

from scripts.dev_tools.build_discovery_runtime import verify_schema_closure
from tests.schemas.discovery.v2_schema_test_support import (
    SCHEMAS,
    URN,
    as_object,
    load_fixture,
    load_schema,
    schema_errors,
)

OBSERVATION_KINDS = (
    "feature-contract",
    "evidence-reference",
    "runtime-characterization-scenario",
)
FEATURE_FIELDS = (
    "feature_id name capability_group summary lifecycle observation_state trigger "
    "preconditions inputs state_transitions observable_outputs side_effects ordering "
    "timing cancellation failure offline mobile alternate_clients "
    "environment_constraints "
    "security_permissions source_evidence_refs runtime_evidence_refs confidence "
    "unresolved_behavior_refs product_decision_status product_decision_refs "
    "target_relevance required_dimensions acceptance_criteria extensions"
).split()
DIMENSIONS = (
    "trigger preconditions inputs observable_outputs side_effects ordering timing "
    "cancellation failure offline mobile alternate_clients environment_constraints "
    "security_permissions"
).split()


@pytest.mark.parametrize("kind", OBSERVATION_KINDS)
def test_observation_schemas_are_closed_valid_and_packaged(kind: str) -> None:
    """The new schemas keep exact v2 identity and byte-identical installed resources."""
    schema = load_schema(kind)

    Draft202012Validator.check_schema(schema)

    assert schema["$id"] == URN + kind
    assert schema["additionalProperties"] is False
    assert (
        read_resource(f"schemas/discovery/v2/{kind}.schema.json")
        == (SCHEMAS / f"{kind}.schema.json").read_bytes()
    )


def test_observation_cross_schema_references_have_offline_closure() -> None:
    """Runtime scenarios resolve the one shared evidence environment definition."""
    inputs = {
        f"schemas/discovery/v2/{path.name}": path.read_bytes()
        for path in SCHEMAS.glob("*.schema.json")
    }

    verify_schema_closure(inputs)

    assert "schemas/discovery/v2/evidence-reference.schema.json" in inputs


@pytest.mark.parametrize("kind", OBSERVATION_KINDS)
def test_valid_observation_fixture_preserves_all_original_values(kind: str) -> None:
    """Fixture conformance does not imply graph completeness or mutate observations."""
    document = load_fixture(kind)
    original = deepcopy(document)

    errors = schema_errors(kind, document)

    assert errors == [], [error.message for error in errors]
    assert document == original


@pytest.mark.parametrize("kind", OBSERVATION_KINDS)
def test_invalid_observation_fixture_is_rejected_and_repairable(kind: str) -> None:
    """Each invalid fixture exercises a claim/digest defect, not missing boilerplate."""
    document = load_fixture(kind, invalid=True)

    errors = schema_errors(kind, document)
    if kind == "feature-contract":
        document["source_evidence_refs"] = load_fixture(kind)["source_evidence_refs"]
    elif kind == "evidence-reference":
        document["checksum"] = load_fixture(kind)["checksum"]
    else:
        document["result_status"] = "observed"

    assert errors
    assert schema_errors(kind, document) == []


@pytest.mark.parametrize("kind", OBSERVATION_KINDS)
@pytest.mark.parametrize(
    "field,value",
    [
        ("schema_version", "2.1.0"),
        ("$schema", URN + "common"),
        ("artifact_kind", "domain-profile"),
        ("id", "feature-alpha\n"),
        ("confidence", "verified"),
        ("approved", True),
    ],
)
def test_observation_identity_and_axes_cannot_select_weaker_contracts(
    kind: str, field: str, value: object
) -> None:
    """Wrong versions/kinds/claim keys remain invalid regardless of other evidence."""
    document = load_fixture(kind)
    document[field] = value

    assert schema_errors(kind, document)


@pytest.mark.parametrize("field", FEATURE_FIELDS)
def test_feature_contract_requires_every_behavior_category(field: str) -> None:
    """No required source behavior or independent decision/status field is implicit."""
    contract = load_fixture("feature-contract")
    del contract[field]

    assert schema_errors("feature-contract", contract)


@pytest.mark.parametrize("field", DIMENSIONS)
def test_each_behavior_dimension_requires_evidence_for_verified_claims(
    field: str,
) -> None:
    """Every behavior category uses the same evidence-backed observation rules."""
    contract = load_fixture("feature-contract")
    as_object(contract[field])["evidence_refs"] = []

    assert schema_errors("feature-contract", contract)


@pytest.mark.parametrize("state", ("unknown", "contradictory"))
def test_unknown_contract_and_dimension_require_explicit_unresolved_links(
    state: str,
) -> None:
    """Unknown behavior remains representable without an invented statement."""
    contract = load_fixture("feature-contract")
    contract["observation_state"] = state
    assert schema_errors("feature-contract", contract)
    unresolved = [{"artifact_kind": "unspecified-behavior", "id": "behavior-alpha"}]
    contract["unresolved_behavior_refs"] = unresolved
    as_object(contract["trigger"]).update(
        observation_state=state,
        statement=None,
        evidence_refs=[],
        unresolved_behavior_refs=unresolved,
        confidence="unknown",
    )
    assert schema_errors("feature-contract", contract) == []

    as_object(contract["trigger"])["statement"] = "Unobserved expected result"

    assert schema_errors("feature-contract", contract)


def test_verified_contract_cannot_claim_unresolved_behavior_or_no_evidence() -> None:
    """A verified summary requires proof and cannot retain an unresolved claim."""
    contract = load_fixture("feature-contract")
    contract["unresolved_behavior_refs"] = [
        {"artifact_kind": "unspecified-behavior", "id": "behavior-alpha"}
    ]
    assert schema_errors("feature-contract", contract)
    contract["unresolved_behavior_refs"] = []
    contract["source_evidence_refs"] = []
    assert schema_errors("feature-contract", contract)

    contract["runtime_evidence_refs"] = [
        {"artifact_kind": "evidence-reference", "id": "runtime-alpha"}
    ]

    assert schema_errors("feature-contract", contract) == []


@pytest.mark.parametrize("field", ("before", "action", "after", "evidence_refs"))
def test_transition_requires_before_action_after_and_evidence(field: str) -> None:
    """Transition entries preserve the observable state sequence and its provenance."""
    contract = load_fixture("feature-contract")
    transitions = as_object(contract["state_transitions"])
    entry = as_object(cast("list[object]", transitions["entries"])[0])
    del entry[field]

    assert schema_errors("feature-contract", contract)


@pytest.mark.parametrize("disposition", ("none", "not-applicable"))
def test_empty_transition_list_requires_explicit_disposition_and_rationale(
    disposition: str,
) -> None:
    """An empty list cannot silently stand for an uninspected state transition."""
    contract = load_fixture("feature-contract")
    transitions = as_object(contract["state_transitions"])
    transitions["entries"] = []
    assert schema_errors("feature-contract", contract)
    transitions["disposition"] = disposition
    assert schema_errors("feature-contract", contract)
    transitions["rationale"] = "The observed operation does not change state."

    assert schema_errors("feature-contract", contract) == []


@pytest.mark.parametrize(
    "field,value",
    [
        ("target_relevance", "retired"),
        ("observation_state", "intentionally-unspecified"),
    ],
)
def test_policy_dispositions_need_approved_decision_links(
    field: str, value: str
) -> None:
    """Historical facts and approved target dispositions remain separate fields."""
    contract = load_fixture("feature-contract")
    contract[field] = value
    assert schema_errors("feature-contract", contract)
    contract.update(
        product_decision_status="approved",
        product_decision_refs=[
            {"artifact_kind": "product-decision", "id": "decision-alpha"}
        ],
    )

    assert schema_errors("feature-contract", contract) == []


def test_pending_acceptance_criterion_cannot_invent_an_expected_result() -> None:
    """Pending requirements preserve a reason and null expectation without a pass."""
    contract = load_fixture("feature-contract")
    criterion = as_object(cast("list[object]", contract["acceptance_criteria"])[0])
    criterion.update(
        readiness="pending",
        expected_result=None,
        pending_reason="Await runtime evidence.",
        evidence_refs=[],
    )
    assert schema_errors("feature-contract", contract) == []
    criterion["expected_result"] = "An unobserved target outcome"
    assert schema_errors("feature-contract", contract)
    criterion.update(readiness="ready", pending_reason=None)

    assert schema_errors("feature-contract", contract)


@pytest.mark.parametrize(
    "field",
    (
        "evidence_id evidence_type repository revision path runtime_artifact "
        "timestamp environment checksum author_or_agent confidence notes extensions"
    ).split(),
)
def test_evidence_requires_all_provenance_categories(field: str) -> None:
    """No capture context, identity or integrity field is silently omitted."""
    evidence = load_fixture("evidence-reference")
    del evidence[field]

    assert schema_errors("evidence-reference", evidence)


@pytest.mark.parametrize("kind", ("source", "test"))
@pytest.mark.parametrize("revision", ("a" * 40, "b" * 64))
def test_source_and_test_evidence_require_immutable_repository_pins(
    kind: str, revision: str
) -> None:
    """Static evidence supports both full Git hash formats and rejects mutable refs."""
    evidence = load_fixture("evidence-reference")
    evidence.update(
        evidence_type=kind,
        revision=revision,
        runtime_artifact=None,
        environment=None,
        symbol="Processor.Activate",
        line_range={"start": 1, "end": 3},
    )
    assert schema_errors("evidence-reference", evidence) == []
    evidence["revision"] = "main"
    assert schema_errors("evidence-reference", evidence)
    evidence["revision"] = None

    assert schema_errors("evidence-reference", evidence)


@pytest.mark.parametrize("method", ("manual", "semi-automated", "automated"))
def test_runtime_evidence_records_real_capture_method_and_environment(
    method: str,
) -> None:
    """Capture automation does not alter evidence or environment requirements."""
    evidence = load_fixture("evidence-reference")
    as_object(evidence["runtime_artifact"])["capture_method"] = method
    assert schema_errors("evidence-reference", evidence) == []
    evidence["environment"] = None

    assert schema_errors("evidence-reference", evidence)


@pytest.mark.parametrize(
    "field,value",
    [
        ("checksum", None),
        ("checksum", {"algorithm": "md5", "value": "c" * 64}),
        ("timestamp", "2026-02-30T00:00:00Z"),
        ("runtime_artifact", None),
        ("line_range", {"start": 0, "end": 3}),
        ("line_range", {"start": True, "end": 3}),
        ("author_or_agent", {"kind": "owner", "id": "analyst"}),
    ],
)
def test_local_evidence_integrity_metadata_is_strict(field: str, value: object) -> None:
    """Invalid hashes, timestamps, spans, actors and missing captures fail closed."""
    evidence = load_fixture("evidence-reference")
    evidence[field] = value

    assert schema_errors("evidence-reference", evidence)


def test_uri_only_documentation_is_descriptive_and_not_a_runtime_capture() -> None:
    """A descriptive URL may be retained without pretending it is local evidence."""
    evidence = load_fixture("evidence-reference")
    evidence.update(
        evidence_type="documentation",
        path=None,
        uri="https://example.invalid/reference",
        runtime_artifact=None,
        environment=None,
        checksum=None,
        revision=None,
    )
    assert schema_errors("evidence-reference", evidence) == []
    evidence["evidence_type"] = "runtime"

    assert schema_errors("evidence-reference", evidence)
